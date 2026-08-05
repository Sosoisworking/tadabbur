# Testing Strategy — Tadabbur

## What's tested, and at what layer

| Layer | Test type | Example in the scaffold | Why here |
|---|---|---|---|
| `domain/` | Plain unit tests | `test/features/learn/curriculum_unit_test.dart` | Pure Dart, no Flutter/Supabase — fastest tests in the suite, run in milliseconds, no mocking needed since there's nothing to mock |
| `core/theme/` | Plain unit tests | `test/core/theme/app_typography_test.dart` | Business-rule-shaped logic (the 24px diacritic floor from `docs/design-system.md`) deliberately extracted into a pure function so it's testable without touching `google_fonts`'s network/asset-loading path — see the code comment in `app_typography.dart` for why that split exists |
| `data/` (repositories) | Unit tests with a mocked `SupabaseClient` | Not yet added — `CurriculumRepository` is the first repository and doesn't have one yet; add when the next repository lands, following the mocktail pattern already used in `test/widget_test.dart` | Repositories are the only layer allowed to talk to Supabase — testing them means asserting the right query shape against a mock, not hitting a real project |
| `presentation/` | Widget tests | `test/widget_test.dart` (OnboardingScreen) | Verifies UI renders and responds to interaction correctly with dependencies overridden via `ProviderScope` — never against a live backend |

**No integration/E2E tests yet.** `integration_test` (driving a real emulator/simulator against a real or staging Supabase project) is worth adding once there's more than one working feature to exercise end-to-end — for a single vertical slice, widget tests with mocked dependencies cover the meaningful risk at much lower cost (no emulator boot time, no flaky network dependency in CI).

## Why mocktail over mockito

`mockito` needs a code-generation step (`build_runner`) to produce mock classes; `mocktail` doesn't — you write `class MockFoo extends Mock implements Foo {}` directly. Given the scaffold already avoids Riverpod codegen for the same reason (`docs/flutter-architecture.md`), staying consistent and skipping `build_runner` entirely keeps the toolchain simpler for a solo, non-Flutter-background founder to reason about.

## CI

`.github/workflows/ci.yml` runs `flutter analyze` and `flutter test` on every push and pull request against `main`. It copies `.env.example` to `.env` before running — CI never has real Supabase credentials, which is fine because nothing in the current test suite makes a live network call (every test that touches the backend layer does so through a mock or fake). **If a future test needs real backend behavior**, that's a signal that it belongs in a separate, explicitly-network-dependent test suite (or a staging-project integration test), not the fast unit/widget suite this workflow runs on every commit.

## What to add as each milestone lands

Per `docs/implementation-plan.md`:
- **M2 (Learn tab)**: widget tests for the real unit-node visual states (locked/in-progress/completed/mastered) once they're built out beyond the current plain `ListTile` placeholder.
- **M3 (SRS)**: unit tests for the SM-2 scheduling math — this logic runs server-side (Edge Function), so these tests live wherever that function's code lives, not in `app/`.
- **M4 (AI tutor)**: widget tests for the chat UI with a mocked tutor repository; a manual/exploratory test pass for actual response quality (that's not something a unit test can meaningfully assert).
- **M9 (accessibility audit)**: this is explicitly a manual pass (screen reader, dynamic type, contrast) per `docs/implementation-plan.md` — not something to try to automate away.
