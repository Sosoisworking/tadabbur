import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom nav: Learn, Review, Prayer Times, and Install. Tutor and
/// Progress (the other two tabs docs/information-architecture.md
/// originally specified) were pulled per user request — both were still
/// bare "coming in M4/M6" stub screens, not real features, so removing
/// them from the nav shows working tabs instead of ones that lead
/// nowhere. Re-add them as their own StatefulShellBranch (see
/// app_router.dart) once there's a real screen behind each.
/// Settings/profile is reached via an avatar icon on each screen's
/// AppBar instead (not yet wired in this scaffold).
///
/// Install is a permanent tab, not a one-time onboarding step — the app
/// is distributed as a website added to the home screen rather than
/// through an App/Play Store listing (see InstallGuideScreen), so it
/// needs to stay reachable for a user setting up a second device.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the already-active tab pops back to its root, matching
          // standard mobile nav conventions rather than staying stuck deep
          // in that tab's stack.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Learn'),
          // Was Icons.refresh — read as "reload," not "spaced-repetition
          // recall." Psychology (a brain) is what this tab actually is:
          // flip-card review that grades how well you remembered
          // something, not a data refresh action.
          NavigationDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology), label: 'Review'),
          NavigationDestination(icon: Icon(Icons.mosque_outlined), selectedIcon: Icon(Icons.mosque), label: 'Prayer'),
          NavigationDestination(
            icon: Icon(Icons.install_mobile_outlined),
            selectedIcon: Icon(Icons.install_mobile),
            label: 'Install',
          ),
        ],
      ),
    );
  }
}
