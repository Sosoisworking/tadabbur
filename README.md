# Tadabbur

**An AI-first Quranic Arabic learning app.** The goal: help any Muslim — regardless of prior Arabic exposure — independently read an unfamiliar page of the Quran and understand its meaning, structure, and grammar, through daily guided practice that takes less time than a single prayer.

Built solo, with Claude as engineering/product partner. See [`docs/PRD.md`](docs/PRD.md) for the full product vision and success metrics.

[![CI](https://github.com/Sosoisworking/tadabbur/actions/workflows/ci.yml/badge.svg)](https://github.com/Sosoisworking/tadabbur/actions/workflows/ci.yml)
[![Deploy](https://github.com/Sosoisworking/tadabbur/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/Sosoisworking/tadabbur/actions/workflows/deploy-pages.yml)

## Try it on your phone

**→ [sosoisworking.github.io/tadabbur](https://sosoisworking.github.io/tadabbur/)**

Open that link on your phone and add it to the home screen. There is nothing to
download from a store, and no account required — you can start a lesson as a
guest and create an account later.

### iPhone / iPad

**Use Safari, not Chrome.** iOS only grants standalone mode, offline support and
safe-area handling to Safari. Added from Chrome you get a plain bookmark: browser
chrome stays visible, offline does not work, and the layout does not clear the
Dynamic Island.

1. Open **[the link](https://sosoisworking.github.io/tadabbur/)** in Safari
2. Tap **Share** (the square with an arrow pointing up)
3. Scroll down and tap **Add to Home Screen**
4. Tap **Add**
5. Launch it from the home-screen icon — not from Safari

### Android

1. Open **[the link](https://sosoisworking.github.io/tadabbur/)** in Chrome
2. Tap the **⋮** menu
3. Tap **Install app** (or **Add to Home screen**)
4. Confirm

### First launch

Leave it open for a few seconds on first run. It caches about 4 MB up front so
the app works offline, then fetches the rest of the rendering engine in the
background. On a slow connection the first paint can take a moment; after that
it starts instantly and works with no network.

### Getting updates

The app checks for a new build each time it starts. When one has finished
downloading, **Settings → App** shows *"New version — tap to reload"*. Tap it.

Updates are never applied mid-session, so a deploy can never reload you out of a
lesson — it waits until you ask, or until the next launch.

**Settings → App** also shows which build you are running, e.g. `1.0.0 · build 8`.
That number matches the run number in the
[Deploy workflow](https://github.com/Sosoisworking/tadabbur/actions/workflows/deploy-pages.yml),
so "is my phone on the latest?" is a five-second check rather than a guess.

## Status

Live in the app today:

- **Learn** — curriculum path from the Arabic alphabet through vocabulary, grammar, and short surahs, with a lesson player covering vocab cards, reading passages, letter drills, grammar explanations, and recall quizzes
- **Review** — SM-2 spaced-repetition due-queue for everything you've been exposed to
- **Prayer Times** — on-device calculation (no network dependency) from GPS or a manually-picked city
- **Install** — home-screen setup instructions; see [Distribution](#distribution) below

Not built yet (see [`docs/implementation-plan.md`](docs/implementation-plan.md) for the full milestone roadmap): the AI tutor, pronunciation scoring, gamification/progress tracking, and push notifications.

## Distribution

Tadabbur ships as a website added to the home screen, not through the App Store or Play Store — see [Try it on your phone](#try-it-on-your-phone) above, and the in-app **Install** tab, which walks users through it per platform. No store review cycle, no $99/year developer account, no separate iOS/Android release process.

Every push to `main` builds and publishes to GitHub Pages via
[`deploy-pages.yml`](.github/workflows/deploy-pages.yml), which runs `flutter analyze`,
the full test suite, and a set of deployability checks before anything reaches the
live site.

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

## Production web build

Build releases with the script, never with a bare `flutter build web`:

```bash
./scripts/build-web.sh
```

It runs `flutter build web --release --no-web-resources-cdn`, then verifies the
output before declaring success. Deploy the **contents** of `app/build/web`.

### Why `--no-web-resources-cdn` is mandatory

Flutter's default web build does not bundle a reference to its own CanvasKit
copy. The generated `flutter_bootstrap.js` resolves the CanvasKit URL like this:

```js
buildConfig.engineRevision && !buildConfig.useLocalCanvasKit
  ? "https://www.gstatic.com/flutter-canvaskit/<engineRevision>/"
  : "canvaskit"
```

Without the flag, `useLocalCanvasKit` is simply absent, so every cold start
fetches CanvasKit from **`https://www.gstatic.com/flutter-canvaskit/`**.
`--no-web-resources-cdn` adds `"useLocalCanvasKit":true` to the build config and
the same files are loaded from your own origin instead.

This is **not a size optimization** — the CanvasKit files are copied into
`build/web/canvaskit/` either way. Measured across the whole 43 MB output, only
two of the 40 files differ: `flutter_bootstrap.js` (+25 bytes, the config key)
and `main.dart.js` (−73 bytes). Net difference: **48 bytes.** The `canvaskit/`
directory is identical. What changes is *who serves those files*:

- **Privacy.** Tadabbur is a Qur'an study app used privately. The default build
  discloses every user's IP address, User-Agent, and visit timing to Google on
  every cold start, with no consent prompt and nothing in the UI to suggest it.
  That is the reason this flag is non-negotiable here.
- **Offline / installability.** The app is installed to the home screen and is
  expected to work on a bad connection. A CDN-dependent build cannot render at
  all until a third-party host responds — the service worker cannot cache a
  cross-origin URL it does not control.
- **Availability.** It removes a third party from the critical rendering path
  entirely; nothing renders before that request resolves.

Size is unchanged on disk, but the ~2.9 MB gzipped CanvasKit payload moves from
Google's servers to yours, so **serve `build/web` with gzip or brotli enabled**
(`canvaskit.wasm` is 7.2 MB raw, ~2.8 MB gzipped).

### What a deployment must supply

`app/.env` must exist **at build time**, containing:

```
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<your-publishable-key>
```

`.env` is declared as a bundled asset in `app/pubspec.yaml`, so its contents are
compiled into the output. **These are build-time inputs, not runtime config** —
the deployed site cannot pick up credentials later, and rotating a key means
rebuilding and redeploying. There is no environment variable to set on the host.

`build-web.sh` refuses to build if `.env` is missing, has an empty key, or still
contains the `.env.example` placeholders.

> The publishable (formerly "anon") key is safe to ship in client code; it is
> protected by row-level security. Never put the service-role key in `.env`.

### Versioning each deploy

`flutter build web` writes `app/build/web/version.json` from the `version:` field
in `app/pubspec.yaml` (currently `1.0.0+1`):

```json
{"app_name":"tadabbur","version":"1.0.0","build_number":"1","package_name":"tadabbur"}
```

This is served at `https://<your-domain>/version.json`, so it is the one
reliable way to ask "which build is this user actually on?" when triaging a bug
report — a hard-refresh question the UI cannot currently answer, since nothing
in the app reads `version.json` or displays a version string.

**Bump `version:` in `app/pubspec.yaml` before every production deploy** —
increment the build number after the `+` (`1.0.0+1` → `1.0.0+2`) for a redeploy
of the same release, and the semantic version for a user-visible release. The
script echoes the version it built so it can be recorded alongside the deploy.

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
