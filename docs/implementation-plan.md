# Phased Implementation Plan — Tadabbur

Milestone-based (not calendar-locked, since solo-founder availability varies), sized for full-time solo effort as the reference point — adjust proportionally for part-time. **Two risks dominate this plan and are called out explicitly rather than buried in a task list**, because they're what will actually determine the timeline, not the Flutter engineering.

## The Two Real Bottlenecks

1. **Content authoring, not code.** Every unit needs diacritized ayat text, vocab items with correct root/pattern analysis, grammar explanations at two depths, and exercise definitions — this is careful linguistic work, not something that parallelizes well or goes faster with more engineering effort thrown at it. **Start this in Week 1**, in parallel with initial engineering setup, not after the app shell exists — M2 (Learn tab) can't be meaningfully tested without at least 2-3 lessons' worth of real content.
2. **Pronunciation scoring is the second-highest technical risk** (`tech-stack.md` §5) — self-hosting and tuning an ASR pipeline is real ML-adjacent engineering a solo full-stack builder may not have done before. Budget for this taking longer than the estimate below and being wrong on the first pass.

## Milestones

| # | Milestone | Est. duration | Depends on | What "done" looks like |
|---|---|---|---|---|
| M0 | **Foundations** | 2 weeks | — | Flutter project scaffolded (Stage 11), Supabase project provisioned with `database-schema.md` deployed, RLS policies live, CI/CD pipeline (Codemagic + GitHub Actions) running on every push, auth (Apple/Google/email) working end-to-end |
| M1 | **Content pipeline + seed content** *(runs in parallel with M0–M2)* | 3-4 weeks, ongoing | — | Al-Fatiha + first ~10 short surahs of Juz Amma fully authored: diacritized ayat, tagged vocab with root/pattern, grammar points at both explanation depths, exercise definitions per lesson |
| M2 | **Onboarding, placement, Learn tab MVP** | 3 weeks | M0, M1 (partial) | Placement test (3 axes) routes correctly; curriculum path renders; lesson player supports `vocab_card`, `reading_passage`, `listening_drill`, `recall_quiz` exercise types (pronunciation + mastery-challenge types deferred to their own milestones) |
| M3 | **SRS + Review tab** | 2 weeks | M2 | SM-2 scheduling live via Edge Function; due-queue UI functional; review sessions feed back into the schedule correctly |
| M4 | **AI Tutor** | 2 weeks | M2 | Scoped Q&A working end-to-end with usage cap enforcement; contextual "Ask" entry points wired into exercises |
| M5 | **Pronunciation scoring** | 3-4 weeks (highest schedule risk) | M2 | Self-hosted Whisper deployed; recording → word-accuracy pipeline working with acceptable latency; feedback UI shows per-word correctness |
| M6 | **Gamification + Progress tab + mastery challenges** | 2 weeks | M3, M5 (mastery challenges need both SRS-driven "understood" tracking and recitation scoring) | Streaks (Hijri+Gregorian), XP, achievement catalog, and the pass/fail mastery-challenge flow all live |
| M7 | **Notifications** | 1 week | M3, M6 | On-device prayer-time calc, FCM delivery, server-side content-routing dispatcher (review vs. lesson vs. re-engagement) |
| M8 | **Offline hardening** | 2 weeks | M2-M6 | Local Drift cache for curriculum content, outbox queue for writes, tested against real airplane-mode / flaky-connectivity scenarios |
| M9 | **Accessibility audit + QA + closed beta** | 2-3 weeks | M0-M8 | Screen-reader pass on every screen, dynamic-type scaling verified, WCAG contrast re-checked against shipped (not just designed) colors, a small closed beta cohort (ideally including both an Aisha-profile and an Omar-profile tester) run through the full funnel |
| M10 | **Launch prep** | 1-2 weeks | M9 | App Store / Play Store listings, privacy policy (flagging the voice-recording retention policy from `PRD.md` §5), analytics verified firing correctly, submission |

**Rough total: ~5-7 months full-time solo effort**, with M1's content work continuing well past its "start" point in the table — it's the one workstream that runs the entire length of the project rather than sitting in a single block.

## Sequencing Notes

- **M2 before M3/M4/M5, not after**: the Learn tab is the spine everything else hangs off — reviewing content that was never learned, tutoring about lessons that don't exist, and scoring recitations of ayat nobody's been taught yet are all meaningless without it.
- **M5 (pronunciation) is deliberately not on the critical path to a testable app.** If it runs long, M2/M3/M4/M6(partial)/M7 can still ship a coherent, testable product with pronunciation exercises stubbed out — worth keeping in mind as a fallback if the ASR work proves harder than estimated.
- **M8 (offline) is placed late but shouldn't be an afterthought bolted on at the end** — the outbox-queue pattern (`tech-stack.md` §4) is easiest to build correctly if the write paths in M2-M6 are designed with it in mind from the start, even if the offline-specific testing and edge-case hardening happens in its own dedicated milestone.
- **Nothing here is billable/revenue-blocking** given the PRD's no-monetization decision — the plan can slip without a business-model consequence, which is worth remembering if M1 or M5 run long: better to ship a smaller, real Al-Fatiha-plus-a-few-surahs product than to rush content quality to hit an arbitrary date.

---

*Next stage: Flutter project scaffold and architecture (folder structure, state management, backend service layer, security rules, testing strategy, CI/CD config) — this is the first stage that produces actual production code, so per your original instructions I'll wait for explicit go-ahead before generating it.*
