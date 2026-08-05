-- Initial schema for Tadabbur, mirroring docs/database-schema.md exactly.
-- Run via `supabase db push` (see app/README.md for setup). RLS policies
-- at the bottom implement the access rules from docs/api-design.md §1 —
-- keep these two documents in sync if the schema changes.

-- ============================================================
-- 1. Quran reference data (static, seeded once)
-- ============================================================

create table surahs (
  number          smallint primary key check (number between 1 and 114),
  name_arabic     text not null,
  name_english    text not null,
  ayah_count      smallint not null,
  revelation_type text not null check (revelation_type in ('meccan','medinan'))
);

create table ayat (
  id                   bigserial primary key,
  surah_number         smallint not null references surahs(number),
  ayah_number          smallint not null,
  text_uthmani         text not null,
  text_diacritized     text not null,
  tajweed_markup       jsonb not null,
  translation_en       text not null,
  unique (surah_number, ayah_number)
);

-- ============================================================
-- 2. Curriculum content (admin-authored)
-- ============================================================

create table tracks (
  id    serial primary key,
  code  text unique not null,
  name  text not null
);

create table units (
  id             serial primary key,
  track_id       int not null references tracks(id),
  unit_type      text not null check (unit_type in ('surah','thematic')),
  surah_number   smallint references surahs(number),
  title          text not null,
  sequence_order int not null,
  unique (track_id, sequence_order)
);

create table lessons (
  id                 serial primary key,
  unit_id            int not null references units(id),
  title              text not null,
  sequence_order     int not null,
  estimated_minutes  smallint not null default 5,
  unique (unit_id, sequence_order)
);

create table vocab_items (
  id               serial primary key,
  arabic_text      text not null,
  transliteration  text not null,
  root_letters     text,
  wazn_pattern     text,
  meaning_en       text not null,
  frequency_rank   int,
  audio_url        text not null
);

create table vocab_item_occurrences (
  vocab_item_id  int not null references vocab_items(id),
  ayah_id        bigint not null references ayat(id),
  word_position  smallint not null,
  primary key (vocab_item_id, ayah_id, word_position)
);

create table grammar_points (
  id                serial primary key,
  code              text unique not null,
  category          text not null check (category in ('nahw','sarf')),
  title_en          text not null,
  explanation_short text not null,
  explanation_full  text not null
);

create table exercises (
  id             serial primary key,
  lesson_id      int not null references lessons(id),
  exercise_type  text not null check (exercise_type in
                   ('vocab_card','grammar_explanation','reading_passage',
                    'listening_drill','pronunciation_recording','recall_quiz',
                    'mastery_challenge')),
  sequence_order int not null,
  unique (lesson_id, sequence_order)
);

create table exercise_vocab_card (
  exercise_id    int primary key references exercises(id),
  vocab_item_id  int not null references vocab_items(id)
);

create table exercise_grammar_explanation (
  exercise_id      int primary key references exercises(id),
  grammar_point_id int not null references grammar_points(id),
  example_ayah_id  bigint references ayat(id)
);

create table exercise_reading_passage (
  exercise_id    int primary key references exercises(id),
  start_ayah_id  bigint not null references ayat(id),
  end_ayah_id    bigint not null references ayat(id)
);

create table exercise_listening_drill (
  exercise_id  int primary key references exercises(id),
  audio_url    text not null,
  drill_kind   text not null check (drill_kind in ('minimal_pair','word_match','full_ayah'))
);

create table exercise_pronunciation (
  exercise_id     int primary key references exercises(id),
  target_ayah_id  bigint not null references ayat(id)
);

create table exercise_recall_quiz (
  exercise_id          int primary key references exercises(id),
  question             text not null,
  options              jsonb not null,
  correct_option_index smallint not null
);

create table exercise_mastery_challenge (
  exercise_id     int primary key references exercises(id),
  challenge_surah smallint not null references surahs(number)
);

create table achievements (
  id             serial primary key,
  code           text unique not null,
  title          text not null,
  description    text not null,
  icon_url       text not null
);

-- ============================================================
-- 3. Users & progress
-- ============================================================

-- Extends auth.users 1:1 — standard Supabase pattern. id is NOT a
-- separate foreign key with cascade here because Supabase Auth manages
-- that relationship; application code always sets id = auth.uid().
create table users (
  id                    uuid primary key,
  display_name          text not null,
  motivation            text check (motivation in ('faith_practice','heritage','academic','curiosity')),
  current_track_id      int references tracks(id),
  timezone              text not null,
  next_notification_at  timestamptz,
  created_at            timestamptz not null default now()
);

create table placement_results (
  id                       serial primary key,
  user_id                  uuid not null references users(id),
  script_literacy_score    numeric(4,1) not null,
  recitation_fluency_score numeric(4,1) not null,
  vocab_grammar_score      numeric(4,1) not null,
  recommended_unit_id      int not null references units(id),
  taken_at                 timestamptz not null default now()
);

create table user_unit_progress (
  user_id       uuid not null references users(id),
  unit_id       int not null references units(id),
  status        text not null check (status in ('locked','in_progress','completed','mastered')) default 'locked',
  started_at    timestamptz,
  completed_at  timestamptz,
  primary key (user_id, unit_id)
);

create table lesson_attempts (
  id                 bigserial primary key,
  user_id            uuid not null references users(id),
  lesson_id          int not null references lessons(id),
  started_at         timestamptz not null default now(),
  completed_at       timestamptz,
  exercises_correct  smallint,
  exercises_total    smallint,
  xp_earned          smallint
);

create table exercise_attempts (
  id                 bigserial primary key,
  lesson_attempt_id  bigint not null references lesson_attempts(id),
  exercise_id        int not null references exercises(id),
  is_correct         boolean,
  user_response      jsonb,
  attempted_at       timestamptz not null default now()
);

-- ============================================================
-- 4. Spaced repetition
-- ============================================================

create table srs_items (
  id                bigserial primary key,
  user_id           uuid not null references users(id),
  vocab_item_id     int references vocab_items(id),
  grammar_point_id  int references grammar_points(id),
  ease_factor       numeric(3,2) not null default 2.5,
  interval_days     int not null default 1,
  repetitions       int not null default 0,
  due_at            timestamptz not null default now(),
  last_reviewed_at  timestamptz,
  check (num_nonnulls(vocab_item_id, grammar_point_id) = 1)
);

create unique index srs_items_user_vocab_uq on srs_items(user_id, vocab_item_id) where vocab_item_id is not null;
create unique index srs_items_user_grammar_uq on srs_items(user_id, grammar_point_id) where grammar_point_id is not null;
create index srs_items_due_idx on srs_items(user_id, due_at);

create table srs_review_log (
  id                bigserial primary key,
  srs_item_id       bigint not null references srs_items(id),
  quality_rating    smallint not null check (quality_rating between 0 and 5),
  response_time_ms  int,
  reviewed_at       timestamptz not null default now()
);

-- ============================================================
-- 5. Pronunciation & AI tutor
-- ============================================================

create table pronunciation_attempts (
  id              bigserial primary key,
  user_id         uuid not null references users(id),
  ayah_id         bigint not null references ayat(id),
  audio_url       text not null,
  tajweed_score   jsonb not null,
  overall_score   numeric(4,1) not null,
  attempted_at    timestamptz not null default now()
);

create table tutor_conversations (
  id            bigserial primary key,
  user_id       uuid not null references users(id),
  context_type  text not null check (context_type in ('vocab_item','grammar_point','ayah')),
  context_id    int not null,
  created_at    timestamptz not null default now()
);

create table tutor_messages (
  id              bigserial primary key,
  conversation_id bigint not null references tutor_conversations(id),
  role            text not null check (role in ('user','assistant')),
  content         text not null,
  token_count     int,
  created_at      timestamptz not null default now()
);

-- ============================================================
-- 6. Gamification
-- ============================================================

create table user_achievements (
  user_id        uuid not null references users(id),
  achievement_id int not null references achievements(id),
  earned_at      timestamptz not null default now(),
  primary key (user_id, achievement_id)
);

create table daily_activity_log (
  user_id            uuid not null references users(id),
  activity_date      date not null,
  minutes_active     smallint not null default 0,
  lessons_completed  smallint not null default 0,
  reviews_completed  smallint not null default 0,
  primary key (user_id, activity_date)
);

create table mastery_challenges (
  id                  bigserial primary key,
  user_id             uuid not null references users(id),
  unit_id             int not null references units(id),
  challenge_surah     smallint not null references surahs(number),
  comprehension_score numeric(4,1) not null,
  recitation_score    numeric(4,1) not null,
  passed              boolean not null,
  attempted_at        timestamptz not null default now()
);

-- ============================================================
-- 7. Row Level Security
-- ============================================================
-- Content tables: public read, no write policy (only service_role /
-- Supabase Studio, i.e. the founder-as-admin, can write — see
-- feature-specs.md §12 on why there's no custom admin UI in v1).

alter table surahs enable row level security;
alter table ayat enable row level security;
alter table tracks enable row level security;
alter table units enable row level security;
alter table lessons enable row level security;
alter table vocab_items enable row level security;
alter table vocab_item_occurrences enable row level security;
alter table grammar_points enable row level security;
alter table exercises enable row level security;
alter table exercise_vocab_card enable row level security;
alter table exercise_grammar_explanation enable row level security;
alter table exercise_reading_passage enable row level security;
alter table exercise_listening_drill enable row level security;
alter table exercise_pronunciation enable row level security;
alter table exercise_recall_quiz enable row level security;
alter table exercise_mastery_challenge enable row level security;
alter table achievements enable row level security;

create policy "content_public_read" on surahs for select using (true);
create policy "content_public_read" on ayat for select using (true);
create policy "content_public_read" on tracks for select using (true);
create policy "content_public_read" on units for select using (true);
create policy "content_public_read" on lessons for select using (true);
create policy "content_public_read" on vocab_items for select using (true);
create policy "content_public_read" on vocab_item_occurrences for select using (true);
create policy "content_public_read" on grammar_points for select using (true);
create policy "content_public_read" on exercises for select using (true);
create policy "content_public_read" on exercise_vocab_card for select using (true);
create policy "content_public_read" on exercise_grammar_explanation for select using (true);
create policy "content_public_read" on exercise_reading_passage for select using (true);
create policy "content_public_read" on exercise_listening_drill for select using (true);
create policy "content_public_read" on exercise_pronunciation for select using (true);
create policy "content_public_read" on exercise_recall_quiz for select using (true);
create policy "content_public_read" on exercise_mastery_challenge for select using (true);
create policy "content_public_read" on achievements for select using (true);

-- User-owned tables: full read/write of own rows only.

alter table users enable row level security;
create policy "own_row" on users for all using (auth.uid() = id) with check (auth.uid() = id);

alter table placement_results enable row level security;
create policy "own_rows_read" on placement_results for select using (auth.uid() = user_id);

alter table user_unit_progress enable row level security;
create policy "own_rows" on user_unit_progress for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table lesson_attempts enable row level security;
create policy "own_rows" on lesson_attempts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table exercise_attempts enable row level security;
create policy "own_rows_via_lesson_attempt" on exercise_attempts for all using (
  exists (select 1 from lesson_attempts la where la.id = lesson_attempt_id and la.user_id = auth.uid())
) with check (
  exists (select 1 from lesson_attempts la where la.id = lesson_attempt_id and la.user_id = auth.uid())
);

alter table user_achievements enable row level security;
create policy "own_rows_read" on user_achievements for select using (auth.uid() = user_id);

alter table daily_activity_log enable row level security;
create policy "own_rows_read" on daily_activity_log for select using (auth.uid() = user_id);

alter table mastery_challenges enable row level security;
create policy "own_rows_read" on mastery_challenges for select using (auth.uid() = user_id);

-- SRS, pronunciation, and tutor tables: read-only for the client per
-- docs/api-design.md §1 — writes must go through Edge Functions (server
-- holds the scheduling algorithm / usage caps / API keys), so no
-- INSERT/UPDATE policy is granted here on purpose.

alter table srs_items enable row level security;
create policy "own_rows_read" on srs_items for select using (auth.uid() = user_id);

alter table srs_review_log enable row level security;
create policy "own_rows_read" on srs_review_log for select using (
  exists (select 1 from srs_items si where si.id = srs_item_id and si.user_id = auth.uid())
);

alter table pronunciation_attempts enable row level security;
create policy "own_rows_read" on pronunciation_attempts for select using (auth.uid() = user_id);

alter table tutor_conversations enable row level security;
create policy "own_rows_read" on tutor_conversations for select using (auth.uid() = user_id);

alter table tutor_messages enable row level security;
create policy "own_rows_read" on tutor_messages for select using (
  exists (select 1 from tutor_conversations tc where tc.id = conversation_id and tc.user_id = auth.uid())
);
