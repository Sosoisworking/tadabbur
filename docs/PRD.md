# Product Requirements Document
## [Working Name: "Tadabbur"] — AI-First Quranic Arabic Learning App

Status: Draft v1 — MVP scope
Owner: Solo founder (budget-conscious, building with Claude as engineering/product partner)
Track: Quranic Arabic (MVP). MSA / Egyptian / Levantine / Gulf are explicitly future tracks — not in scope until the Quranic engine and business model are validated.

---

## 1. Vision

Help any Muslim — regardless of prior Arabic exposure — independently read an unfamiliar page of the Quran and understand its meaning, structure, and grammar, through daily AI-guided practice that takes less time than a single prayer.

Brand voice: fully Islamic in tone and framing — prayer-time-aware, du'a-styled encouragement, Hijri-aware calendaring where relevant, content and copy that treat Quran engagement as worship (*ibadah*), not just study. This shapes notification copy, gamification language (e.g. "khatm streak" instead of generic "streak"), and marketing.

## 2. Success Metrics

| Metric | Definition | Target |
|---|---|---|
| Comprehension mastery | % of intermediate-course completers who can read an *unseen* short surah and correctly explain its meaning + grammar of most words, unassisted | Primary success bar (target: majority of completers, measured via in-app unseen-surah challenge, not self-report) |
| Spoken component | % of the same cohort who can recite that surah with acceptable AI-scored Tajweed and verbally explain 3-5 key phrases | Secondary bar |
| D1 retention | Users active the day after install | >40% |
| D7 retention | Users active 7 days after install | >30% |
| Habit loop health | Median session length, sessions/week | Tracked, no hard target yet — informs pacing tuning |

## 3. Primary Personas (MVP wedge)

**Aisha — The New Muslim.** Zero Arabic script literacy. High motivation, easily overwhelmed. Needs script literacy from zero and an emotional win in the first 3 minutes.

**Omar — The Practicing Professional.** Recites fluently from memory (5x daily prayer) but doesn't understand the words. Budget-conscious, wants 5-10 minute sessions. Needs a curriculum that starts from what he *already recites* (Fatiha, short surahs) rather than generic vocab.

These two sit at opposite ends of a "script literacy × comprehension" matrix and are the hardest test of the placement engine — if it correctly routes both, it generalizes to Yusuf (heritage, literate, no comprehension) and Sarah (academic, wants grammar depth) later without new engineering, only content.

## 4. MVP Scope

### 4.1 In scope for MVP (v1.0)

1. **Onboarding & adaptive placement test** — three independent axes: script literacy, recitation fluency, vocabulary/grammar knowledge. Routes to one of a small number of starting points (not just "beginner/intermediate/advanced").
2. **Core curriculum content**: Juz Amma (the 37 short surahs) + Al-Fatiha, sequenced by frequency of high-value Quranic vocabulary (the ~500-word list covering ~75% of Quran text is the backbone). This is a deliberately bounded content set a solo founder can actually produce and QA.
3. **Spaced repetition engine (SRS)** for vocabulary and morphological patterns (root/pattern system, since Arabic vocabulary compresses heavily once root+pattern is understood — this is a bigger leverage point here than in most languages).
4. **Grammar explanations** — bite-sized *nahw/sarf* explanations delivered in-context (e.g., "why is this word in the accusative here") rather than upfront theory dumps. Grammar depth is expandable on demand (serves Sarah-persona needs without a separate track).
5. **Reading exercises** — guided reading of real ayat with word-by-word breakdown, progressing to unaided reading.
6. **Listening exercises** — recitation audio matched to text, minimal-pair listening drills for letters/sounds that are hard for non-native speakers.
7. **AI pronunciation scoring (word-accuracy, v1)** — record a verse, get feedback on whether the correct words were recited in the correct order (self-hosted Whisper-based ASR). **Descoped from full Tajweed-rule scoring** (madd, ghunnah, qalqalah detection) — that is an open ML research problem with no mature ready-made API as of this writing (see `tech-stack.md` §5), not a solved integration. Rule-level Tajweed scoring is a post-MVP phase once usage data justifies the added ML investment.
8. **AI tutor (chat)** — text-based Q&A tied to the current lesson ("why does this word mean X here" / "explain this grammar point differently"), not open-ended free conversation in v1. Keeps LLM API cost bounded and scope-limited, appropriate for solo/budget-conscious resourcing.
9. **Gamification**: streaks (branded, e.g. "consistency" framed around daily worship habit), XP, achievement badges tied to real milestones (first surah memorized-with-meaning, first unseen-surah pass), Hijri-calendar-aware events (e.g. Ramadan challenges). **No leaderboards in v1** — see Section 6.
10. **Mastery milestone challenges** — the "unseen surah" comprehension + light recitation check that operationalizes the primary success metric directly in-product.
11. **Prayer-time-aware notifications** — daily reminder tuned to local prayer times, not just generic push.
12. **No monetization / fully free** — the entire curriculum and AI features are free with no paywall or subscription tier. This removes payment/entitlement engineering from scope entirely. Given full Islamic branding, an optional voluntary-donation (*sadaqah*) mechanism is a natural later addition — never feature-gated, purely optional support — but is not required for v1. **Cost implication**: because there is no revenue to offset marginal AI usage, AI-powered features (tutor chat, pronunciation scoring) must ship with hard per-user daily/monthly usage caps from day one as the cost-control mechanism, rather than a paywall. This will be sized concretely in the tech stack stage against actual API pricing.
13. **Basic analytics** — funnel (install → placement → D1/D7 → subscription), lesson-level engagement, SRS performance — enough to run the retention loop, not a full BI stack.
14. **Minimal admin/content tooling** — a lightweight internal tool (not customer-facing) for the founder to author/edit lesson content and review flagged AI tutor conversations. Not a full CMS in v1.

### 4.2 Explicitly out of scope for MVP (future phases)

- Writing correction (handwriting/OCR-based Arabic writing practice) — high engineering cost, lower priority than reading/listening for this persona set.
- Open-ended conversational AI practice / "conversation simulations" — deferred until the tutor's scoped-QA mode is validated and cost-justified.
- Social features: leaderboards, friends, clans/guilds — deferred; risk of diluting the reflective/worship-oriented brand tone if done generically (a "competing" frame can feel at odds with sincerity in worship — needs deliberate design, not a stock leaderboard).
- MSA / Egyptian / Levantine / Gulf tracks — future expansion once the Quranic Arabic engine + business model are validated. Architecture should not preclude this (see PRD Section 7), but no content/UI work in v1.
- Full CMS / multi-admin roles / content marketplace.
- Android tablet / web / desktop apps — mobile phone (iOS + Android via Flutter) only for v1.

## 5. Non-Functional Requirements

- **Offline support**: downloaded lessons, SRS review, and audio playback must work offline (many users engage during prayer times/commutes with poor connectivity) — AI tutor chat and pronunciation scoring require connectivity (server-side inference) and should degrade gracefully offline (queue/retry).
- **RTL & typography**: correct Arabic script rendering including Tashkeel (diacritics) and Tajweed color-coding; UI itself can remain LTR (English-first interface) with embedded RTL Arabic content — confirm with user before locking (see open question below).
- **Accessibility**: screen reader support for both English UI and Arabic content, adjustable text size (critical given the visually dense nature of diacritized Arabic), color-blind-safe Tajweed color coding.
- **Performance**: cold start <2s, lesson screens interactive <1s, offline-first data layer to avoid loading spinners on core learning flows.
- **Security & privacy**: user voice recordings for pronunciation scoring are sensitive — clear retention/deletion policy, no third-party sharing beyond the ASR/AI vendor needed to score them, encrypted at rest and in transit.
- **Cost discipline**: every AI-powered feature (tutor chat, pronunciation scoring) must have a bounded per-user cost model appropriate for a solo/budget-conscious operator — covered in the tech stack stage.

## 6. Decisions Locked (v1)

1. **UI language**: English-first interface; Arabic appears as fully diacritized/Tajweed-colored learning content, not translated chrome.
2. **Leaderboards**: deferred from v1. May revisit a non-competitive, worship-appropriate community-progress feature (not head-to-head ranking) post-launch if retention data warrants it.
3. **Monetization**: none. Fully free, no paywall, no subscription. AI features are cost-capped per user (daily/monthly limits) rather than gated behind payment — sized in the tech stack stage.
4. **Working name**: "Tadabbur" (Arabic: reflective contemplation of the Quran).

---

*Next stage: Information Architecture (screen map, navigation model, content hierarchy).*
