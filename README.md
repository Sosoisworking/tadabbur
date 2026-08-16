# Tadabbur

**An AI-first Quranic Arabic learning app.** The goal: help any Muslim — regardless of prior Arabic exposure — independently read an unfamiliar page of the Quran and understand its meaning, structure, and grammar, through daily guided practice that takes less time than a single prayer.

Built solo, with Claude as engineering/product partner. See [`docs/PRD.md`](docs/PRD.md) for the full product vision and success metrics.

[![CI](https://github.com/Sosoisworking/tadabbur/actions/workflows/ci.yml/badge.svg)](https://github.com/Sosoisworking/tadabbur/actions/workflows/ci.yml)

## Status

Live in the app today:

- **Learn** — curriculum path from the Arabic alphabet through vocabulary, grammar, and short surahs, with a lesson player covering vocab cards, reading passages, letter drills, grammar explanations, and recall quizzes
- **Review** — SM-2 spaced-repetition due-queue for everything you've been exposed to
- **Prayer Times** — on-device calculation (no network dependency) from GPS or a manually-picked city
- **Install** — home-screen setup instructions; see [Distribution](#distribution) below

Not built yet (see [`docs/implementation-plan.md`](docs/implementation-plan.md) for the full milestone roadmap): the AI tutor, pronunciation scoring, gamification/progress tracking, and push notifications.

## Distribution

Tadabbur ships as a website added to the home screen, not through the App Store or Play Store — the in-app **Install** tab walks users through it per platform. No store review cycle, no $99/year developer account, no separate iOS/Android release process.

## Tech stack

- **Client**: Flutter (single codebase, deployed as a web app)
- **Backend**: Supabase — Postgres, Auth, Storage, Edge Functions
- **State management**: Riverpod
- **AI tutor** (planned): Claude Haiku via the Anthropic API

Full rationale in [`docs/tech-stack.md`](docs/tech-stack.md) and [`docs/flutter-architecture.md`](docs/flutter-architecture.md).

## Repo layout

```
app/       Flutter client — see app/README.md for setup
docs/      Product/architecture docs (PRD, schema, API design, design system, ...)
supabase/  Database migrations (supabase/migrations) and Edge Functions (supabase/functions)
```

## Getting started

Full setup (Supabase project, environment variables, running the app) is in [`app/README.md`](app/README.md). Quick version:

```bash
cd app
cp .env.example .env   # fill in your Supabase project URL + publishable key
flutter pub get
flutter run -d chrome
```

Database schema lives in `supabase/migrations/` — deploy with the [Supabase CLI](https://supabase.com/docs/guides/cli):

```bash
supabase link --project-ref your-project-ref
supabase db push
```

## Testing

```bash
cd app
flutter analyze   # must be clean before any commit
flutter test
```

Runs automatically in CI on every push/PR to `main` — see [`.github/workflows/ci.yml`](.github/workflows/ci.yml). Details on what's covered in [`docs/testing-strategy.md`](docs/testing-strategy.md).

## Documentation

| Doc | Covers |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | Vision, personas, success metrics, MVP scope |
| [`docs/implementation-plan.md`](docs/implementation-plan.md) | Milestones and sequencing |
| [`docs/information-architecture.md`](docs/information-architecture.md) | Navigation, screen inventory |
| [`docs/design-system.md`](docs/design-system.md) | Color/type/spacing tokens, component patterns |
| [`docs/database-schema.md`](docs/database-schema.md) | Postgres schema, RLS policies |
| [`docs/api-design.md`](docs/api-design.md) | Edge Function contracts |
| [`docs/tech-stack.md`](docs/tech-stack.md) | Stack choices and trade-offs |
| [`docs/flutter-architecture.md`](docs/flutter-architecture.md) | Client folder structure, state management |
| [`docs/testing-strategy.md`](docs/testing-strategy.md) | What's tested and why |
