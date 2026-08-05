import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The 4-tab bottom nav from docs/information-architecture.md — Learn,
/// Review, Tutor, Progress. Deliberately shallow (4 items, no 5th
/// Settings tab) per that doc's accessibility reasoning: this audience
/// includes low-tech-literacy users, so navigation depth is a real
/// accessibility concern, not just a style choice. Settings/profile is
/// reached via an avatar icon on each screen's AppBar instead (not yet
/// wired in this scaffold).
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
          NavigationDestination(icon: Icon(Icons.refresh_outlined), selectedIcon: Icon(Icons.refresh), label: 'Review'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Tutor'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progress'),
        ],
      ),
    );
  }
}
