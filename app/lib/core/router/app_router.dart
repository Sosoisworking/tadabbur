import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/learn/presentation/screens/learn_screen.dart';
import '../../features/learn/presentation/screens/lesson_player_screen.dart';
import '../../features/learn/presentation/screens/unit_detail_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/review/presentation/screens/review_screen.dart';
import '../../features/tutor/presentation/screens/tutor_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../services/supabase_service.dart';

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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
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
            GoRoute(path: '/tutor', builder: (context, state) => const TutorScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
          ]),
        ],
      ),
    ],
  );
});
