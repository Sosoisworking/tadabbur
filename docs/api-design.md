# API Design — Tadabbur

## REST, not GraphQL — and mostly not hand-written either

Supabase generates a full REST API (PostgREST) directly from the Postgres schema, with Row Level Security (RLS) policies enforcing per-row access control at the database layer. For a solo builder, the highest-leverage choice is to **let PostgREST handle all plain CRUD** (reading curriculum content, reading/writing a user's own progress) via the Supabase Flutter SDK's typed query builder, and write **custom Edge Functions only for real business logic** — anything involving a server-held secret (the Claude API key), an algorithm that must not be client-trusted (SRS scheduling), or an external service call (ASR).

GraphQL (available via Supabase's `pg_graphql` extension) is not used here — it solves over-fetching and schema flexibility problems this app doesn't have at this scale, and adds a second query language for a solo dev to maintain. Skip it unless a future client (e.g. a web dashboard) genuinely needs flexible nested queries.

## 1. Auto-generated (PostgREST + RLS) — no custom code

The client (via `supabase_flutter`) queries these tables directly. RLS policies, not application code, enforce the access rules in the right-hand column.

| Table | Access pattern | RLS policy |
|---|---|---|
| `tracks`, `units`, `lessons`, `exercises`, `exercise_*`, `vocab_items`, `vocab_item_occurrences`, `grammar_points`, `ayat`, `surahs`, `achievements` | Read-only | Public read (`SELECT` allowed for `anon` + `authenticated`) — this is shared curriculum content, not user data |
| `user_unit_progress`, `lesson_attempts`, `exercise_attempts` | Read/write own rows | `user_id = auth.uid()` on all operations |
| `srs_items`, `srs_review_log` | Read own; **write only via Edge Function** (§2) | `SELECT` where `user_id = auth.uid()`; no direct client `INSERT`/`UPDATE` — the SM-2 scheduling math must run server-side so a client can't fabricate a favorable review schedule |
| `pronunciation_attempts`, `tutor_conversations`, `tutor_messages` | Read own; **write only via Edge Function** (§2) | Same pattern — these involve paid API calls or storage writes that must be gated server-side |
| `mastery_challenges`, `user_achievements`, `daily_activity_log` | Read own; written by Edge Functions on evaluation | `SELECT` where `user_id = auth.uid()` |
| `users` (own profile) | Read/write own row | `id = auth.uid()`; used for `next_notification_at`, `display_name`, `timezone`, `motivation`, `current_track_id` |
| `placement_results` | Read own; written by Edge Function (§2) | `SELECT` where `user_id = auth.uid()` |

**Placement test content is not database-driven.** With one fixed instrument in v1 (not an authorable, evolving test bank), the question set ships as a static JSON asset bundled with the app rather than a DB table — avoids a schema/admin-tool cost for something that doesn't need to change per-user or be edited without a release. Revisit if the placement test needs frequent tuning post-launch.

## 2. Custom Edge Functions (Deno, server-side)

Each of these needs something PostgREST can't give a plain table: a secret, a trusted algorithm, or an external call.

### `POST /functions/v1/srs/review`

Records a spaced-repetition review and computes the next schedule. **Runs server-side so the SM-2 algorithm can't be gamed by a modified client** (e.g. always claiming "easy" to inflate intervals and dodge review load).

```
Request:  { srs_item_id: uuid, quality_rating: 0-5, response_time_ms?: int }
Response: { srs_item_id, ease_factor, interval_days, repetitions, due_at }
```
Writes: one `srs_review_log` row, updates the matching `srs_items` row.

### `POST /functions/v1/placement/score`

Takes the user's placement-test responses (against the static bundled instrument), scores the three independent axes, and determines the starting unit — the routing logic (PRD's "correctly route Aisha and Omar to completely different starting points") lives here, not on the client.

```
Request:  { script_literacy_responses: [...], recitation_responses: [...], vocab_grammar_responses: [...] }
Response: { script_literacy_score, recitation_fluency_score, vocab_grammar_score,
            recommended_unit_id, rationale: string }
```
Writes: one `placement_results` row, sets `users.current_track_id`.

### `POST /functions/v1/tutor/message`

The AI tutor proxy — holds the Claude API key, enforces the daily usage cap, and is the only path that can call the Claude API on the user's behalf.

```
Request:  { conversation_id?: uuid, context_type: 'vocab_item'|'grammar_point'|'ayah',
            context_id: int, message: string }
Response: { conversation_id, reply: string }
Errors:   429 { error: "daily_limit_reached", reset_at: timestamp } — cap enforced by
          counting today's tutor_messages for the user before calling Claude
```
Flow: check cap → create `tutor_conversations` row if new → call Claude Haiku 4.5 with cached system prompt + lesson context → write both `tutor_messages` rows (user + assistant) → return reply.

### `POST /functions/v1/pronunciation/score`

Orchestrates ASR scoring against an uploaded recitation recording.

```
Request:  { ayah_id: int, audio_storage_path: string }   // audio pre-uploaded to Supabase Storage
Response: { overall_score: number, word_accuracy: [{ word, correct: bool }] }
```
Flow: fetch audio from Storage → call self-hosted Whisper service → align transcript against `ayat.text_uthmani` → compute word-accuracy → write `pronunciation_attempts` row (v1 scope: word-accuracy only, per the tech-stack Tajweed descope).

### `POST /functions/v1/mastery-challenge/submit`

Grades the comprehension + recitation "unseen surah" challenge that operationalizes the PRD's primary success metric.

```
Request:  { unit_id: int, challenge_surah: int, comprehension_responses: [...],
            audio_storage_path: string }
Response: { comprehension_score, recitation_score, passed: bool }
```
Writes: one `mastery_challenges` row; on pass, may also write `user_achievements`.

### `POST /functions/v1/notifications/register-schedule`

Client computes prayer times **on-device** (per the tech-stack privacy design — no raw coordinates sent to the server) and calls this only to persist the resulting timestamp.

```
Request:  { next_notification_at: timestamp }
Response: { ok: true }
```
This is thin enough it could be a plain PostgREST `PATCH /rest/v1/users` update instead of an Edge Function — listed here for completeness of the notification flow, but §1's table access already covers it.

## 3. Scheduled Job (not a client-facing endpoint)

**Notification dispatcher** — a Supabase scheduled Edge Function (cron, e.g. every 5 minutes) that queries `users` for rows where `next_notification_at` has just passed, and triggers an FCM push for each. Decides push content server-side per PRD's "prayer-time-aware notifications route to whichever has more pressing content" rule: query the user's due `srs_items` count vs. next unstarted lesson, and pick the higher-value 5-minute action.

## 4. Authentication

Handled entirely by **Supabase Auth** (`/auth/v1/*`) — not custom-built. Apple/Google/email sign-in per PRD §4.1. The client SDK manages token refresh; every custom Edge Function and every RLS policy above authenticates via the same Supabase-issued JWT (`auth.uid()`).

## 5. Why gate SRS and tutor writes behind functions instead of RLS alone

RLS can restrict *which rows* a user touches, but it can't validate *business logic* (was this SM-2 calculation done correctly? has this user exceeded their daily AI budget?). Where the write requires a decision, not just an ownership check, it goes through an Edge Function; everything else is a direct table operation through PostgREST + RLS. This split is also why `srs_items` appears in §1 for reads (RLS suffices — a user reading their own due queue needs no business logic) but only in §2 for writes (the SM-2 math needs a trusted execution point).
