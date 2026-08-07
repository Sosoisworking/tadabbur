# Tadabbur — Flutter App

## First-time setup

### 1. Create a Supabase project (one-time, only you can do this)

1. Go to [supabase.com](https://supabase.com) and sign up / log in.
2. Create a new project (pick any name/region; the free tier is enough for MVP — see `docs/tech-stack.md`).
3. Once it's provisioned, go to **Project Settings → API Keys** and copy:
   - **Project URL**
   - **Publishable key** (Supabase's current name for what used to be called the "anon key")
4. In this `app/` folder, copy `.env.example` to `.env` and paste those two values in:
   ```
   cp .env.example .env
   ```
   Then edit `.env` with your real values. **Never commit `.env`** — it's already gitignored.

### 2. Deploy the database schema

The schema lives in `supabase/migrations/0001_initial_schema.sql` (mirrors `docs/database-schema.md`, RLS policies included). Install the [Supabase CLI](https://supabase.com/docs/guides/cli), then from the repo root:

```
supabase link --project-ref your-project-ref
supabase db push
```

### 3. Run the app

```
cd app
flutter pub get
flutter run -d chrome --web-port=5173     # or -d macos, or a connected device/simulator once Xcode/Android Studio are set up
```

`--web-port=5173` just keeps things consistent across runs — not load-bearing for auth anymore (see below), but still convenient. (Port 5000 seems like the obvious default but is usually taken on macOS by ControlCenter/AirPlay Receiver, a system service — use a different port rather than fighting it.)

### 4. Auth: email/password, not magic link

Sign-in uses email + password (`AuthRepository.signUpWithPassword` / `signInWithPassword`), not a magic-link email — a magic link redirects back to a URL that has to exactly match whatever port the dev server happens to be on, which was a real source of friction locally. Password auth has no redirect step, and only needs an email round-trip once (confirming a new account, if your project has "Confirm email" enabled under Authentication settings) rather than on every sign-in.

There's also a "Continue without an account" option on the onboarding screen, using Supabase anonymous sign-in — needs "Allow anonymous sign-ins" enabled under Authentication settings in your dashboard.

## Architecture

See `docs/flutter-architecture.md` for the full rationale (why Riverpod, why this folder structure, why the data/domain/presentation split). Short version:

- **State management**: Riverpod. Every backend read/write goes through a `Provider`/`FutureProvider`, never called directly from a widget's `build()`.
- **Folder structure**: feature-first (`lib/features/<feature>/{data,domain,presentation}`), not layer-first — each feature is a self-contained vertical slice.
- **Backend access**: reads/writes go straight through Supabase (PostgREST + Row Level Security) from the client wherever possible; custom server logic only exists where it has to (see `docs/api-design.md`).

## Testing

```
flutter analyze   # static analysis — must be clean before any commit
flutter test      # unit + widget tests
```

See `docs/testing-strategy.md` for what's covered and the reasoning behind test placement.

## What's not set up yet

- **iOS builds** need Xcode installed (`flutter doctor` will guide you) — not required until you want to test on an iPhone/simulator.
- **Android builds** need Android Studio (same story, for Android).
- **Anthropic API key** (for the AI tutor, milestone M4) and the self-hosted Whisper service (pronunciation scoring, M5) aren't wired up in this scaffold — see `docs/implementation-plan.md`.
