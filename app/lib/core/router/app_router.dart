import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/learn/presentation/screens/learn_screen.dart';
import '../../features/learn/presentation/screens/lesson_player_screen.dart';
import '../../features/learn/presentation/screens/unit_detail_screen.dart';
import '../../features/install_guide/presentation/screens/install_guide_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/review/presentation/screens/review_screen.dart';
import '../../features/review/presentation/screens/review_session_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/settings_scope.dart';
import '../services/supabase_service.dart';

/// The single way into Settings. A top-level function rather than an
/// inline closure so [SettingsScope] can compare it by identity across
/// rebuilds, and `push` rather than `go` so closing it returns to the tab
/// the user opened it from.
void _openSettings(BuildContext context) => context.push(SettingsScreen.routePath);

/// A ChangeNotifier that pings GoRouter's refreshListenable whenever auth
/// state changes, so the redirect logic below re-runs reactively instead
/// of only being checked once at cold start.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

final _authRefreshNotifierProvider = Provider<_AuthRefreshNotifier>((ref) {
  return _AuthRefreshNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  // Kept alive for the life of the router: it turns an unrefreshable
  // session into a normal signed-out state, which the redirect below then
  // sends to onboarding. Without something watching it, the provider is
  // never created and the listener never runs.
  ref.watch(authFailureRecoveryProvider);

  return GoRouter(
    initialLocation: '/learn',
    refreshListenable: ref.watch(_authRefreshNotifierProvider),
    redirect: (context, state) {
      final signedIn = client.auth.currentUser != null;
      final onOnboarding = state.matchedLocation == '/onboarding';

      if (!signedIn && !onOnboarding) return '/onboarding';
      if (signedIn && onOnboarding) return '/learn';
      return null;
    },
    // PlacementResultScreen is deliberately absent from these routes.
    // It renders a PlacementResult, and nothing in the app can produce
    // one: docs/feature-specs.md §1 puts placement scoring server-side
    // (`POST /functions/v1/placement/score`) so the routing table stays a
    // single tunable source of truth, that function doesn't exist yet,
    // and neither do the three assessment modules that feed it. A route
    // to it today could only be reached by manufacturing scores on the
    // client — which is the one thing that spec, and the model's own doc
    // comments, forbid. It stays unrouted until the placement test exists.
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      // Full-screen modal takeover per docs/design-system.md — deliberately
      // a top-level route, not nested under the /learn branch, so it
      // renders without the bottom nav bar.
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (context, state) {
          final lessonId = int.parse(state.pathParameters['lessonId']!);
          final args = state.extra as ({int unitId, String lessonTitle});
          return LessonPlayerScreen(lessonId: lessonId, unitId: args.unitId, lessonTitle: args.lessonTitle);
        },
      ),
      GoRoute(
        path: '/review-session',
        builder: (context, state) => const ReviewSessionScreen(),
      ),
      // Top-level for the same reason as the two routes above: Settings is
      // a takeover, not a fifth tab. It's low-frequency (a user sets the
      // Hijri offset and their calculation method roughly once), and a
      // permanent nav slot for it would push the four real destinations
      // narrower for something visited far less than any of them.
      GoRoute(
        path: SettingsScreen.routePath,
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        // The shell — and only the shell — is where the settings gear is
        // offered, so it appears on the four tabs and not on a lesson,
        // review session, or the settings screen itself. ScreenHeader
        // picks it up from here; see SettingsScope.
        builder: (context, state, navigationShell) => SettingsScope(
          open: _openSettings,
          child: AppShell(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/learn',
              builder: (context, state) => const LearnScreen(),
              routes: [
                GoRoute(
                  path: 'unit/:unitId',
                  builder: (context, state) {
                    final unitId = int.parse(state.pathParameters['unitId']!);
                    final title = state.extra as String?;
                    return UnitDetailScreen(unitId: unitId, unitTitle: title);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/review', builder: (context, state) => const ReviewScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/prayer-times', builder: (context, state) => const PrayerTimesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/install', builder: (context, state) => const InstallGuideScreen()),
          ]),
        ],
      ),
    ],
  );
});
