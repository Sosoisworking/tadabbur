# Database Schema — Tadabbur

Target: PostgreSQL (assumed regardless of final Firebase-vs-Supabase call in the tech stack stage — the content model here is deeply relational: curriculum trees, many-to-many word↔verse mappings, per-user SRS state with tight query patterns. Firestore's document model would force denormalization that fights this data shape at every turn, so Postgres is treated as settled here and re-justified in Stage 6).

Normalized to 3NF except where explicitly noted as a deliberate denormalization trade-off.

## 1. Quran Reference Data (static, seeded once)

```sql
CREATE TABLE surahs (
  number          SMALLINT PRIMARY KEY CHECK (number BETWEEN 1 AND 114),
  name_arabic     TEXT NOT NULL,
  name_english    TEXT NOT NULL,
  ayah_count      SMALLINT NOT NULL,
  revelation_type TEXT NOT NULL CHECK (revelation_type IN ('meccan','medinan'))
);

CREATE TABLE ayat (
  id                   BIGSERIAL PRIMARY KEY,
  surah_number         SMALLINT NOT NULL REFERENCES surahs(number),
  ayah_number          SMALLINT NOT NULL,
  text_uthmani         TEXT NOT NULL,        -- standard Uthmani script
  text_diacritized     TEXT NOT NULL,        -- fully vocalized for learners
  tajweed_markup       JSONB NOT NULL,       -- [{start, end, rule_code}] segments for color-coding
  translation_en       TEXT NOT NULL,
  UNIQUE (surah_number, ayah_number)
);
```

## 2. Curriculum Content (admin-authored)

```sql
CREATE TABLE tracks (
  id    SERIAL PRIMARY KEY,
  code  TEXT UNIQUE NOT NULL,        -- 'quranic_arabic' (only row in v1; future: 'msa', 'egyptian', ...)
  name  TEXT NOT NULL
);

CREATE TABLE units (
  id             SERIAL PRIMARY KEY,
  track_id       INT NOT NULL REFERENCES tracks(id),
  unit_type      TEXT NOT NULL CHECK (unit_type IN ('surah','thematic')),
  surah_number   SMALLINT REFERENCES surahs(number),   -- set when unit_type = 'surah'
  title          TEXT NOT NULL,
  sequence_order INT NOT NULL,
  UNIQUE (track_id, sequence_order)
);

CREATE TABLE lessons (
  id                 SERIAL PRIMARY KEY,
  unit_id            INT NOT NULL REFERENCES units(id),
  title              TEXT NOT NULL,
  sequence_order     INT NOT NULL,
  estimated_minutes  SMALLINT NOT NULL DEFAULT 5,
  UNIQUE (unit_id, sequence_order)
);

CREATE TABLE vocab_items (
  id               SERIAL PRIMARY KEY,
  arabic_text      TEXT NOT NULL,
  transliteration  TEXT NOT NULL,
  root_letters     TEXT,              -- e.g. 'ر-ح-م', nullable (particles have no root)
  wazn_pattern     TEXT,              -- morphological pattern, e.g. 'فَعِيل'
  meaning_en       TEXT NOT NULL,
  frequency_rank   INT,               -- position in the ~500-word high-frequency list
  audio_url        TEXT NOT NULL
);

-- Where a vocab item appears in the actual Quran text, for in-context teaching
CREATE TABLE vocab_item_occurrences (
  vocab_item_id  INT NOT NULL REFERENCES vocab_items(id),
  ayah_id        BIGINT NOT NULL REFERENCES ayat(id),
  word_position  SMALLINT NOT NULL,   -- word index within the ayah
  PRIMARY KEY (vocab_item_id, ayah_id, word_position)
);

CREATE TABLE grammar_points (
  id                SERIAL PRIMARY KEY,
  code              TEXT UNIQUE NOT NULL,        -- e.g. 'idafa_construction'
  category          TEXT NOT NULL CHECK (category IN ('nahw','sarf')),  -- syntax vs. morphology
  title_en          TEXT NOT NULL,
  explanation_short TEXT NOT NULL,   -- shown inline during a lesson
  explanation_full  TEXT NOT NULL    -- shown on demand ("explain more" — serves the Sarah persona)
);
```

### Exercises: base table + per-type extension tables

A single `exercises` row with a polymorphic JSONB payload was the tempting shortcut, but it makes the schema unqueryable (you can't ask "which exercises teach vocab_item X" without unpacking JSON) and unenforceable (nothing stops a `reading_passage` row from missing its ayah range). Table-per-type costs one join but keeps every exercise type's required fields NOT NULL and foreign-keyed.

```sql
CREATE TABLE exercises (
  id             SERIAL PRIMARY KEY,
  lesson_id      INT NOT NULL REFERENCES lessons(id),
  exercise_type  TEXT NOT NULL CHECK (exercise_type IN
                   ('vocab_card','grammar_explanation','reading_passage',
                    'listening_drill','pronunciation_recording','recall_quiz',
                    'mastery_challenge')),
  sequence_order INT NOT NULL,
  UNIQUE (lesson_id, sequence_order)
);

CREATE TABLE exercise_vocab_card (
  exercise_id    INT PRIMARY KEY REFERENCES exercises(id),
  vocab_item_id  INT NOT NULL REFERENCES vocab_items(id)
);

CREATE TABLE exercise_grammar_explanation (
  exercise_id      INT PRIMARY KEY REFERENCES exercises(id),
  grammar_point_id INT NOT NULL REFERENCES grammar_points(id),
  example_ayah_id  BIGINT REFERENCES ayat(id)
);

CREATE TABLE exercise_reading_passage (
  exercise_id    INT PRIMARY KEY REFERENCES exercises(id),
  start_ayah_id  BIGINT NOT NULL REFERENCES ayat(id),
  end_ayah_id    BIGINT NOT NULL REFERENCES ayat(id)
);

CREATE TABLE exercise_listening_drill (
  exercise_id  INT PRIMARY KEY REFERENCES exercises(id),
  audio_url    TEXT NOT NULL,
  drill_kind   TEXT NOT NULL CHECK (drill_kind IN ('minimal_pair','word_match','full_ayah'))
);

CREATE TABLE exercise_pronunciation (
  exercise_id     INT PRIMARY KEY REFERENCES exercises(id),
  target_ayah_id  BIGINT NOT NULL REFERENCES ayat(id)
);

-- recall_quiz options are inherently a variable-length list with no independent identity
-- of their own — this is the one deliberate JSONB denormalization in the schema.
CREATE TABLE exercise_recall_quiz (
  exercise_id          INT PRIMARY KEY REFERENCES exercises(id),
  question             TEXT NOT NULL,
  options              JSONB NOT NULL,   -- ["...", "...", "...", "..."]
  correct_option_index SMALLINT NOT NULL
);

CREATE TABLE exercise_mastery_challenge (
  exercise_id       INT PRIMARY KEY REFERENCES exercises(id),
  challenge_surah    SMALLINT NOT NULL REFERENCES surahs(number)  -- an *unseen* surah, not this unit's
);
```

## 3. Users & Progress

Assumes Supabase Auth (or equivalent) issues `auth.users.id`; this table extends it 1:1 — standard Supabase pattern, avoided duplicating auth concerns here.

```sql
CREATE TABLE users (
  id                UUID PRIMARY KEY,   -- = auth.users.id
  display_name      TEXT NOT NULL,
  motivation        TEXT CHECK (motivation IN ('faith_practice','heritage','academic','curiosity')),
  current_track_id  INT REFERENCES tracks(id),
  timezone          TEXT NOT NULL,       -- IANA tz, e.g. 'Europe/London'
  next_notification_at TIMESTAMPTZ,      -- precomputed prayer-time-based send time; see privacy note below
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Privacy design decision**: no raw lat/lon is stored server-side. Prayer times are computed **on-device** (a well-established offline calculation from timezone + coordinates, no API call needed) and the client pushes up only the resulting `next_notification_at` timestamp for the server's notification scheduler to consume. This satisfies the PRD's prayer-time-aware notifications without the server ever holding precise user location — a meaningfully lower privacy footprint for a free app with no dedicated privacy/legal team behind it.

```sql
CREATE TABLE placement_results (
  id                       SERIAL PRIMARY KEY,
  user_id                  UUID NOT NULL REFERENCES users(id),
  script_literacy_score    NUMERIC(4,1) NOT NULL,
  recitation_fluency_score NUMERIC(4,1) NOT NULL,
  vocab_grammar_score      NUMERIC(4,1) NOT NULL,
  recommended_unit_id      INT NOT NULL REFERENCES units(id),
  taken_at                 TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_unit_progress (
  user_id       UUID NOT NULL REFERENCES users(id),
  unit_id       INT NOT NULL REFERENCES units(id),
  status        TEXT NOT NULL CHECK (status IN ('locked','in_progress','completed')) DEFAULT 'locked',
  started_at    TIMESTAMPTZ,
  completed_at  TIMESTAMPTZ,
  PRIMARY KEY (user_id, unit_id)
);

CREATE TABLE lesson_attempts (
  id               BIGSERIAL PRIMARY KEY,
  user_id          UUID NOT NULL REFERENCES users(id),
  lesson_id        INT NOT NULL REFERENCES lessons(id),
  started_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at     TIMESTAMPTZ,
  exercises_correct SMALLINT,
  exercises_total   SMALLINT,
  xp_earned         SMALLINT
);

CREATE TABLE exercise_attempts (
  id                BIGSERIAL PRIMARY KEY,
  lesson_attempt_id BIGINT NOT NULL REFERENCES lesson_attempts(id),
  exercise_id       INT NOT NULL REFERENCES exercises(id),
  is_correct        BOOLEAN,
  user_response     JSONB,           -- free-form: selected option index, recorded audio ref, etc.
  attempted_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## 4. Spaced Repetition

```sql
CREATE TABLE srs_items (
  id                BIGSERIAL PRIMARY KEY,
  user_id           UUID NOT NULL REFERENCES users(id),
  vocab_item_id     INT REFERENCES vocab_items(id),
  grammar_point_id  INT REFERENCES grammar_points(id),
  ease_factor       NUMERIC(3,2) NOT NULL DEFAULT 2.5,
  interval_days     INT NOT NULL DEFAULT 1,
  repetitions       INT NOT NULL DEFAULT 0,
  due_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_reviewed_at  TIMESTAMPTZ,
  CHECK (num_nonnulls(vocab_item_id, grammar_point_id) = 1)
);

-- The single most-queried access pattern in the whole schema: "give me this user's due items."
CREATE UNIQUE INDEX srs_items_user_vocab_uq ON srs_items(user_id, vocab_item_id) WHERE vocab_item_id IS NOT NULL;
CREATE UNIQUE INDEX srs_items_user_grammar_uq ON srs_items(user_id, grammar_point_id) WHERE grammar_point_id IS NOT NULL;
CREATE INDEX srs_items_due_idx ON srs_items(user_id, due_at);

CREATE TABLE srs_review_log (
  id             BIGSERIAL PRIMARY KEY,
  srs_item_id    BIGINT NOT NULL REFERENCES srs_items(id),
  quality_rating SMALLINT NOT NULL CHECK (quality_rating BETWEEN 0 AND 5),  -- SM-2 style
  response_time_ms INT,
  reviewed_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## 5. Pronunciation & AI Tutor

```sql
CREATE TABLE pronunciation_attempts (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES users(id),
  ayah_id         BIGINT NOT NULL REFERENCES ayat(id),
  audio_url       TEXT NOT NULL,           -- storage path; subject to retention policy (PRD §5)
  tajweed_score   JSONB NOT NULL,          -- per-rule breakdown, e.g. {"madd": 0.9, "ghunnah": 0.6}
  overall_score   NUMERIC(4,1) NOT NULL,
  attempted_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tutor_conversations (
  id            BIGSERIAL PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES users(id),
  context_type  TEXT NOT NULL CHECK (context_type IN ('vocab_item','grammar_point','ayah')),
  context_id    INT NOT NULL,     -- polymorphic on context_type; see note below
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tutor_messages (
  id              BIGSERIAL PRIMARY KEY,
  conversation_id BIGINT NOT NULL REFERENCES tutor_conversations(id),
  role            TEXT NOT NULL CHECK (role IN ('user','assistant')),
  content         TEXT NOT NULL,
  token_count     INT,           -- for AI cost tracking against the per-user usage cap
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

`tutor_conversations.context_id` is a deliberate second denormalization: it's polymorphic (points into `vocab_items`, `grammar_points`, or `ayat` depending on `context_type`) rather than three nullable FK columns. A true 3NF design would use three nullable FKs with a check constraint like `srs_items` above — I chose polymorphic here instead because this table is write-heavy and read-only-by-app-code (never joined against ad hoc in reporting the way `srs_items` is), so the FK integrity loss is a smaller cost than three mostly-null columns. Flagging this so you can override it — it's a judgment call, not a hard rule.

## 6. Gamification

```sql
CREATE TABLE achievements (
  id             SERIAL PRIMARY KEY,
  code           TEXT UNIQUE NOT NULL,
  title          TEXT NOT NULL,
  description    TEXT NOT NULL,
  icon_url       TEXT NOT NULL
);

CREATE TABLE user_achievements (
  user_id        UUID NOT NULL REFERENCES users(id),
  achievement_id INT NOT NULL REFERENCES achievements(id),
  earned_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE daily_activity_log (
  user_id            UUID NOT NULL REFERENCES users(id),
  activity_date      DATE NOT NULL,
  minutes_active     SMALLINT NOT NULL DEFAULT 0,
  lessons_completed  SMALLINT NOT NULL DEFAULT 0,
  reviews_completed  SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, activity_date)
);
-- current/longest streak are derived from this table via a query (consecutive-date scan),
-- not stored redundantly — avoids a second source of truth that can drift out of sync.

CREATE TABLE mastery_challenges (
  id                  BIGSERIAL PRIMARY KEY,
  user_id             UUID NOT NULL REFERENCES users(id),
  unit_id             INT NOT NULL REFERENCES units(id),
  challenge_surah     SMALLINT NOT NULL REFERENCES surahs(number),
  comprehension_score NUMERIC(4,1) NOT NULL,
  recitation_score    NUMERIC(4,1) NOT NULL,
  passed              BOOLEAN NOT NULL,
  attempted_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## Notes on What's Deliberately Absent

- **No payments/entitlement tables** — free app, no monetization (PRD §6).
- **No leaderboard/social tables** — deferred from v1 (PRD §6).
- **No `ai_usage_quota` table** — daily/monthly AI usage caps (tutor messages, pronunciation scoring) are enforced by querying `COUNT(*)` against `tutor_messages`/`pronunciation_attempts` filtered by date, or via an in-memory rate limiter (Redis) at the API layer for low-latency checks. A dedicated quota table would be a second source of truth for something already derivable — sized concretely in Stage 6 (API design) once request patterns are pinned down.
