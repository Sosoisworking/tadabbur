# Technology Stack — Tadabbur

Sized against the PRD's hard constraints: solo/budget-conscious builder, fully free app (no revenue to offset AI costs), offline support as an explicit requirement.

## 1. Mobile Client

**Flutter** (per original brief) — single codebase for iOS + Android, which matters most for a solo builder maintaining two app stores alone. State management, folder structure, and testing strategy are detailed in Stage 11 (Flutter architecture), not here.

## 2. Backend: Supabase over Firebase

**Recommendation: Supabase** (managed Postgres + Auth + Storage + Edge Functions), not Firebase.

| | Firebase (Firestore) | Supabase (Postgres) |
|---|---|---|
| Fit for this data model | Poor — the curriculum tree, word↔verse many-to-many mappings, and SRS query patterns in `docs/database-schema.md` are deeply relational; Firestore forces denormalization that fights this shape at every turn | Strong — the schema is already normalized SQL; no translation layer needed |
| Offline-first sync | Excellent, built-in | Not built-in — requires the custom pattern below (§4) |
| Cost at MVP scale | Free tier generous | Free tier generous (500MB DB, 1GB storage, 50K MAU auth, 500K edge function calls/month) |
| Vendor lock-in | Firestore's data model is hard to migrate off | Open-source, self-hostable if ever needed |

Given the schema is the harder constraint to bend and the offline gap has a known, bounded fix (§4), Supabase wins here. Auth, file storage (audio recordings), and Edge Functions (Deno-based serverless) cover the custom backend logic needed: SRS scheduling, placement-test scoring, the AI tutor proxy (enforces usage caps before calling Claude), and pronunciation-scoring orchestration.

## 3. AI Tutor: Claude Haiku 4.5

The PRD scopes the tutor to context-anchored Q&A (word/verse/grammar-point specific), not open conversation — that scope match, plus the free-app cost constraint, points at the cheapest capable model rather than a larger one.

**Claude Haiku 4.5** ($1/MTok input, $5/MTok output) via the Anthropic API. A typical scoped exchange (~500 input tokens of lesson context + conversation history, ~150 output tokens) costs roughly **$0.0013/message**. Two cost levers, both cheap to implement:

- **Prompt caching** on the shared system-prompt/persona instructions (identical across all users) — after the first cache write, that portion of every request costs ~10% of full price.
- **Hard per-user daily cap**, enforced in a Supabase Edge Function that checks today's `tutor_messages` count for the user before calling the Claude API (PRD §4.1, item 12). Starting cap: **15 messages/day/user** — at that ceiling, worst case is ~$0.02/user/month, i.e. ~$20/month at 1,000 daily active tutor users. Tune the cap against real usage once live; this is a config value, not a code change.

## 4. Offline Support: local cache + outbox, not a sync engine

Supabase has no Firestore-equivalent offline persistence built in — this is the real cost of picking Postgres over Firestore, and it's worth naming rather than glossing over.

**Recommendation: a lightweight custom pattern, not a third-party sync engine** (PowerSync/ElectricSQL exist and solve this generally, but add a vendor and, past their free tier, a second recurring cost — not the right trade for a free app with a bounded write surface):

- **Curriculum content** (units, lessons, vocab, ayat, audio) is read-mostly reference data — download-and-cache locally via **Drift** (SQLite ORM for Flutter) on first access per unit, no bidirectional sync needed.
- **User-generated writes** (SRS reviews, lesson completions, pronunciation attempts) are a much smaller surface — queue them in a local **outbox table**, flush to Supabase when connectivity returns, retry with backoff on failure.

This is more code than "install a sync SDK," but it's a well-understood pattern, free, and matched to how small the actual write surface is (per PRD §5, only SRS state, attempts, and pronunciation results need to round-trip — everything else is static content).

## 5. Pronunciation & Tajweed Scoring — the highest-risk component

Flagging this clearly rather than understating it: **accurate, rule-level Tajweed scoring (madd, ghunnah, qalqalah detection) is an open ML research problem**, not a solved API call. My research (`docs/` research, Aug 2026) found no mature commercial API for this — Tarteel AI (the closest analog, 4% WER on plain transcription) doesn't offer third-party Tajweed-rule scoring as a product API; the rule-level work (e.g. the "Quran Phonetic Script" approach in recent research) is still active research, not a drop-in service.

**Recommended phasing, not a single build:**

- **v1 (MVP)**: self-hosted **faster-whisper** (open-source, runs on modest CPU/small GPU — no per-call API fee) for **word-level recitation accuracy**: did the user say the right words, in the right order. This alone is genuinely useful feedback and is technically tractable for a solo builder. Store it in the `tajweed_score` JSONB field as a simplified word-accuracy breakdown rather than true per-rule Tajweed scoring.
- **v2 (post-MVP, once usage justifies the investment)**: layer in rule-level Tajweed detection, drawing on the open research/models referenced above (e.g. HuggingFace `obadx/recitation-segmenter-v2`) or a licensed specialist provider if one matures commercially.

**This is a real descope from the PRD's "AI pronunciation/Tajweed scoring" language** — worth your explicit sign-off before I carry it into the feature spec stage, since it changes what "pronunciation coaching" means in the v1 product.

## 6. Push Notifications, Analytics, Crash Reporting

- **Firebase Cloud Messaging (FCM)** for push delivery only — not for data storage, so this doesn't reintroduce the Firestore modeling problem. Standard Flutter integration (`firebase_messaging`).
- **Firebase Analytics + Crashlytics** — free, unlimited events, and since FCM already pulls in the Firebase SDK, this is close to zero marginal integration cost. Upgrade path to PostHog (self-hosted or cheap cloud tier) if funnel/retention analysis needs outgrow what Firebase Analytics gives you.

## 7. CI/CD

- **Codemagic** — Flutter-native CI/CD config, free tier (~500 build minutes/month) sufficient for a solo project, handles TestFlight/Play Console deployment without hand-rolled Fastlane setup.
- **GitHub Actions** for lint/test on every PR (free tier is generous even for private repos at this scale).

## 8. Rough Cost Envelope at 1,000 Monthly Active Users

| Component | Estimated monthly cost |
|---|---|
| Supabase (DB, auth, storage, edge functions) | $0 (free tier) → $25 (Pro tier, once traffic exceeds free limits) |
| Claude Haiku 4.5 (tutor, capped at 15 msg/day/user) | ~$20 (worst case, all users at cap) |
| Self-hosted Whisper (pronunciation scoring compute) | ~$20-50 depending on hosting choice (a small always-on VM or pay-per-second serverless GPU) |
| FCM, Firebase Analytics/Crashlytics | $0 |
| Codemagic, GitHub Actions | $0 (free tiers) |
| **Total** | **~$40-100/month** at 1,000 MAU |

This scales roughly linearly with usage, all on pay-as-you-go tiers — no fixed cost floor beyond near-zero at zero users, which matters for a pre-revenue free app.
