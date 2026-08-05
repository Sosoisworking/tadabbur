# Feature Specifications — Tadabbur MVP

Each spec assumes the schema (`database-schema.md`), API (`api-design.md`), and components (`design-system.md`) already defined — this document is about the *logic*, not the plumbing.

## 1. Onboarding & Adaptive Placement Test

**Flow** (per `information-architecture.md`): motivation selection → three independent placement modules → routing → first lesson before signup.

**Why three independent axes, not one score.** A single "beginner/intermediate/advanced" placement fails both target personas: Aisha (zero script literacy, but nothing else to measure yet) and Omar (fluent recitation, zero comprehension) would both plausibly land at "beginner" on a single-axis test despite needing opposite starting points.

| Axis | How it's measured | What routes on it |
|---|---|---|
| Script literacy | Can the user identify/read isolated Arabic letters and short words shown on screen? | Below threshold → routes into a letter-recognition primer *before* any vocabulary content (this is Aisha's path) |
| Recitation fluency | User reads a short familiar passage (Al-Fatiha) aloud; scored via the same word-accuracy ASR as pronunciation scoring (§8) | High fluency + low comprehension → skip straight to meaning/grammar content, skip phonics entirely (this is Omar's path) |
| Vocabulary/grammar knowledge | Short multiple-choice set on the highest-frequency Quranic words and basic sentence patterns | Determines which unit within the sequenced curriculum is the actual starting point |

**Scoring** happens server-side (`POST /functions/v1/placement/score`, `api-design.md` §2) — never client-side, so the routing logic is a single source of truth and can be tuned without an app release.

**Routing table** (illustrative starting points, tunable post-launch against real completion data):

| Script literacy | Recitation fluency | Route |
|---|---|---|
| Low | (n/a — can't assess fluency without literacy) | Letter-recognition primer → Al-Fatiha unit |
| High | Low | Al-Fatiha unit, full pace (new letters/vocab/grammar together) |
| High | High | Skip Al-Fatiha's phonics content; start on meaning/grammar for Al-Fatiha, then proceed to Juz Amma sequence |

**First lesson runs before account creation** (design-system + IA decision) — the placement result must therefore be held in local device state until signup, then written to `placement_results` once a `user_id` exists.

## 2. Adaptive Learning Engine (Curriculum Sequencing)

The curriculum tree (`tracks → units → lessons → exercises`) is authored content with a fixed sequence — adaptivity in v1 is about **pacing within that sequence**, not reordering it (a fully dynamic curriculum graph is a v2 investment, not justified yet against a single bounded content set of Juz Amma + Al-Fatiha).

**What actually adapts per user:**
- **New-vs-review ratio per session**: if a user's SRS due queue (§3) exceeds a threshold (e.g. 20 items), the next lesson session is capped to review-only until the queue is back under threshold — protects the 5-10 minute session target (PRD's Omar persona) from being overwhelmed by a backlog.
- **Unit unlock gating**: a unit unlocks only once its prerequisite unit's mastery challenge (§9) is passed, not merely completed — this is where "seen" vs "understood" becomes a hard gate, not just a UI distinction.
- **Grammar depth exposure**: `grammar_explanation` exercises default to the short inline text; a user who repeatedly taps "explain more" across several lessons is a signal (tracked, not yet acted on in v1) worth surfacing in analytics as a candidate for a future "grammar-depth" user segment (the Sarah persona from the personas doc) — no scope creep into building that segment now, just don't lose the signal.

## 3. Spaced Repetition System (SRS)

**Algorithm: SM-2**, computed exclusively server-side (`POST /functions/v1/srs/review`) so a modified client can't fabricate favorable schedules.

```
On review with quality_rating q (0–5):
  if q < 3:
    repetitions = 0
    interval_days = 1
  else:
    if repetitions == 0: interval_days = 1
    elif repetitions == 1: interval_days = 6
    else: interval_days = round(interval_days * ease_factor)
    repetitions += 1
  ease_factor = max(1.3, ease_factor + (0.1 - (5-q)*(0.08 + (5-q)*0.02)))
  due_at = now() + interval_days
```
(Standard SM-2; `ease_factor` floor of 1.3 prevents runaway-short intervals for consistently-struggled items.)

**What generates an SRS item.** Every `vocab_item` and `grammar_point` a user is exposed to in a lesson gets a corresponding `srs_items` row on first exposure (not before) — this is why the schema's unique constraint is `(user_id, vocab_item_id)` rather than pre-seeding all content for all users.

**Root-pattern leverage.** Because Arabic vocabulary compresses heavily once a learner knows a root + pattern (per `PRD.md` §4.1 item 3), a vocab item's SRS record additionally surfaces (read-only, not separately reviewed) related words sharing its `root_letters` when a review is shown — reinforces the pattern without multiplying the SRS item count.

## 4. Grammar Explanations

Two-tier delivery, matching the design-system's short/full distinction:

- **Inline (`grammar_points.explanation_short`)**: shown automatically the first time a grammar point appears in an exercise, in-context ("why is this word in the accusative here" — tied to the specific ayah being read, not abstract theory).
- **On-demand (`explanation_short` → `explanation_full`)**: a persistent "explain more" affordance on every grammar-tagged exercise opens the fuller explanation. This is also a natural entry point into the AI tutor (§7) for a follow-up question specific to that grammar point — the tutor's `context_type: 'grammar_point'` anchoring exists specifically for this handoff.

No separate "grammar course" screen in v1 — grammar is taught exclusively in-context inside lessons, per the PRD's explicit rejection of upfront theory dumps.

## 5. Vocabulary Training

Delivered as `exercise_type: 'vocab_card'` within lessons (new vocabulary) and folded into the SRS review queue thereafter (§3) — there is no separate standalone "vocabulary drilling" mode distinct from lessons/review, keeping the mental model to two places content lives: Learn (new) and Review (due).

Sequencing within a unit follows `vocab_items.frequency_rank` — the highest-value words (by Quranic occurrence frequency) are introduced first within any given unit, so a user who drops off partway through a unit has still learned the words that generalize best.

## 6. Reading & Listening Exercises

- **Reading (`exercise_type: 'reading_passage'`)**: progressive difficulty within a passage — first pass shows word-by-word gloss (tap any word for meaning + root), later repetitions of the same or a related passage (via SRS resurfacing) hide the gloss, building toward the unaided reading the PRD's comprehension metric requires.
- **Listening (`exercise_type: 'listening_drill'`)**: three `drill_kind` variants per the schema — `minimal_pair` (distinguishing similar-sounding letters/sounds, the hardest phonetic discrimination for non-native speakers), `word_match` (audio-to-meaning matching), `full_ayah` (listen-along with the diacritized/Tajweed-colored text, building the audio↔text association that supports later unaided recitation).

Reciter audio comes from a licensed/public-domain Quran recitation source per `reciters` table — user's preferred reciter voice is a Settings option (`design-system.md`), not fixed.

## 7. AI Tutor (Scoped Q&A)

**Deliberately not open conversation** — every conversation is anchored to a `context_type` (`vocab_item` | `grammar_point` | `ayah`), surfaced via the contextual "Ask" button on any exercise (per `information-architecture.md`) or from the Tutor tab's history.

**System prompt** (cached across all users per `tech-stack.md` §3) establishes: persona (warm, Islamically-literate tutor voice matching the brand principles), the boundary (answer questions about the current word/verse/grammar point; redirect broader tangents back to the lesson content rather than open-ended discussion — this is what keeps cost bounded and keeps the feature inside its PRD scope), and a instruction to keep answers short enough to read in a few seconds (PRD's 5-10 minute session budget applies to tutor interactions too).

**Suggested prompts are AI-generated from SRS error patterns** (per IA): after a review session with 2+ missed items on the same grammar point, the next Tutor tab visit surfaces a suggested question specifically about that point — turns a passive failure signal into an active learning opportunity without the user having to know what to ask.

**Cost governance**: hard daily cap enforced before every call (§`api-design.md`), starting at 15 messages/day/user, tuned from real usage data post-launch.

## 8. Pronunciation Scoring (Word-Accuracy, v1)

Per the tech-stack Tajweed descope: v1 scores **which words were said correctly, in order** — not Tajweed rule adherence.

**Flow**: user records via `AudioRecordButton` (design-system) → audio uploaded to Supabase Storage → `POST /functions/v1/pronunciation/score` → self-hosted Whisper transcribes → transcript aligned word-by-word against the target `ayat.text_uthmani` → per-word correct/incorrect flags + an overall percentage.

**Feedback UI**: each word in the recited ayah is highlighted (correct/incorrect) after scoring — directly actionable ("you missed this word") rather than a single opaque score, which matters more for a beginner's confidence than a number would.

**What's explicitly NOT in v1**: Tajweed rule feedback (madd length, ghunnah, qalqalah) — the `tajweed_score` JSONB field is populated with a simplified word-accuracy structure, not per-rule scores, until the v2 phase described in `tech-stack.md` §5.

## 9. Gamification: Streaks, XP, Achievements, Mastery Challenges

- **Streaks**: computed from `daily_activity_log` (consecutive-date scan), not stored redundantly (per `database-schema.md` note) — displayed with both Hijri and Gregorian dates.
- **XP**: awarded per completed lesson/review session, scaled modestly by accuracy — XP is a secondary motivator behind the mastery-challenge system, not the primary progress signal (that's "seen" vs "understood," per Brand Principle 3).
- **Achievements**: fixed catalog (`achievements` table) tied to real milestones — first surah understood, first mastery-challenge pass, N-day streak thresholds, Hijri-calendar-aware events (e.g. a Ramadan-specific challenge). No arbitrary "login 5 days" filler achievements — every badge should map to something the PRD's success metric actually cares about.
- **Mastery challenges** (`POST /functions/v1/mastery-challenge/submit`, §`api-design.md`): the unseen-surah comprehension + light-recitation check. **Pass threshold**: comprehension score ≥ 80% AND recitation word-accuracy ≥ 80% — both bars must clear, since the PRD's primary and secondary success metrics are both real requirements, not either/or. A near-miss (one bar cleared, one not) surfaces which specific gap to work on, not just "try again."

## 10. Notifications

Prayer-time-aware, computed on-device for privacy (`tech-stack.md` §4) — the server only ever holds a precomputed `next_notification_at` timestamp.

**Content decision logic** (server-side, in the scheduled dispatcher per `api-design.md` §3): if the user's SRS due queue is large (>10 items), the notification promotes review ("12 words are ready to review"); otherwise it promotes the next lesson. This routing decision is what makes the notification land on the actually-highest-value action rather than a generic "come back!" ping.

**Re-engagement variant**: for a lapsed user (no activity in 3+ days), the dispatcher instead surfaces the single weakest SRS item's context ("You're close to fully understanding Surah Al-Mulk") — a spiritually resonant, specific hook rather than a generic push, per the IA's re-engagement journey design.

## 11. Analytics

Minimal, funnel-focused per PRD §4.1 item 13 — not a full BI stack. Tracked events: `install`, `placement_completed`, `first_lesson_completed`, `signup_completed`, `d1_active`, `d7_active`, `lesson_completed`, `review_session_completed`, `mastery_challenge_attempted/passed`, `tutor_message_sent`, `pronunciation_attempt`. Delivered via Firebase Analytics (`tech-stack.md` §6) — no custom analytics pipeline to build or maintain.

**One product-specific metric beyond standard funnel tracking**: the comprehension-mastery rate itself (% of intermediate-course completers who pass an unseen-surah challenge) is the PRD's primary success metric and gets a dedicated query/dashboard, not buried in generic engagement stats.

## 12. Admin Tools (Internal, Minimal)

Per PRD §4.1 item 14 — a lightweight internal tool for the founder, not a customer-facing CMS. v1 scope:

- **Content authoring**: direct Supabase Studio table editing (built into Supabase, zero additional engineering) is sufficient at MVP content volume (Juz Amma + Al-Fatiha, ~500 vocab items) — a custom admin UI is not justified until content volume or a second content editor makes raw table editing untenable.
- **Tutor conversation review**: a simple read-only query/view (also via Supabase Studio, or a minimal internal Flutter/web screen if founder-only table browsing proves too clunky) to spot-check AI tutor conversations for quality and cost patterns.

Deliberately deferred: multi-admin roles, a purpose-built CMS, in-app moderation queues — none of these are needed at solo-founder, pre-launch scale, and building them now would be the "designing for hypothetical future requirements" the project's own engineering principles warn against.
