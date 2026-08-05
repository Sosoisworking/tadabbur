# Flutter Architecture — Tadabbur

Covers the decisions behind what's now running in `app/` — not a restatement of the code, which is commented in place, but the *why* behind each choice.

## State Management: Riverpod

**Chosen over Provider and Bloc.** For a solo builder maintaining this codebase alone for months:

- **vs. plain Provider**: Riverpod is Provider's successor, fixing its main pain points — no `BuildContext` needed to read state (matters a lot for the repository/service layer, which shouldn't need widget context at all), compile-time-safe dependency access (a typo in a provider name is a compile error, not a runtime crash), and straightforward testing via `ProviderScope` overrides (used throughout `app/test/`).
- **vs. Bloc**: Bloc's explicit event→state modeling is valuable at larger team scale where the ceremony pays for itself in consistency across many contributors. For a solo builder, that ceremony is mostly overhead — Riverpod gets equivalent testability and separation of concerns with substantially less boilerplate per feature.

**No code generation (`riverpod_generator`/`build_runner`) in this scaffold.** The annotation-based codegen approach is more ergonomic at scale, but adds a build step that has to run correctly for the IDE and `flutter analyze` to even see up-to-date code — an extra failure mode a solo, non-Flutter-background founder doesn't need yet. Revisit if the plain-provider boilerplate becomes a real burden as more features land.

## Folder Structure: Feature-First

```
lib/
  core/           # cross-cutting: theme, router, config, backend service wrappers
  shared/         # reusable widgets used by 2+ features (e.g. the bottom nav shell)
  features/
    <feature>/
      data/         # repositories — the only layer that talks to Supabase
      domain/       # plain Dart models, no Flutter/Supabase imports
      presentation/
        screens/
        widgets/
```

**Why feature-first over layer-first** (i.e. not `lib/screens/`, `lib/models/`, `lib/repositories/` as top-level folders): each feature in `docs/information-architecture.md` (Learn, Review, Tutor, Progress, Onboarding) is a self-contained vertical slice that's usually developed, tested, and reasoned about as a unit. Feature-first keeps everything for one feature in one place — layer-first scatters a single feature's code across three or four top-level folders, which costs more the longer the project runs, even for a team of one.

**Why `data`/`domain`/`presentation` within each feature**: this is the concrete implementation of the split `docs/api-design.md` §5 already establishes at the API layer — `data/` (repositories) is the only code allowed to import `supabase_flutter`, `domain/` is plain Dart with zero framework dependencies (easy to unit test, easy to reason about independent of how it's fetched or displayed), and `presentation/` never talks to Supabase directly. `lib/features/learn/` is the reference implementation of this pattern — every other feature should follow its shape.

## Backend Service Layer

`core/services/supabase_service.dart` exposes exactly one `Provider<SupabaseClient>` — every repository takes that client as a constructor argument rather than calling `Supabase.instance.client` directly. This one indirection is what makes `CurriculumRepository` (and every repository after it) testable without a real network connection: tests can override `supabaseClientProvider` with a mock.

Auth state is exposed as a `StreamProvider<AuthState>` that the router listens to (`core/router/app_router.dart`), so sign-in/sign-out reactively redirects between the onboarding flow and the main app shell — no manual "check auth and navigate" calls scattered through the codebase.

## Routing

`go_router` with `StatefulShellRoute.indexedStack` for the 4-tab bottom nav from `docs/information-architecture.md` — each tab keeps its own navigation stack (switching tabs and back preserves where you were), matching standard mobile app behavior. The `redirect` callback is the single source of truth for the onboarding-vs-main-app gate, driven by the auth stream above rather than checked ad hoc in individual screens.

## Security Rules

Row Level Security policies live in `supabase/migrations/0001_initial_schema.sql`, directly implementing the access table in `docs/api-design.md` §1: content tables are public-read with no client write policy at all (only the founder, via Supabase Studio, can write — see `feature-specs.md` §12), user-owned tables restrict to `auth.uid() = user_id`, and the SRS/tutor/pronunciation tables are **read-only for the client** — writes to those only happen through Edge Functions, because the logic they enforce (SM-2 scheduling, AI usage caps) can't be expressed as a row-ownership check.

## What's Deliberately Not Built Yet

This scaffold proves the architecture end-to-end (one real vertical slice — Learn — reading from Supabase through the full stack, plus working auth) without building every feature. Per `docs/implementation-plan.md`, SRS, the AI tutor, pronunciation scoring, gamification, and notifications are separate milestones (M3–M7) — their screens exist as placeholders that state which milestone fills them in, not empty stubs pretending to be finished.
