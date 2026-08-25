import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/review/data/srs_repository.dart';

/// Bottom nav: Learn, Review, Prayer Times, and Install. Tutor and
/// Progress (the other two tabs docs/information-architecture.md
/// originally specified) were pulled per user request — both were still
/// bare "coming in M4/M6" stub screens, not real features, so removing
/// them from the nav shows working tabs instead of ones that lead
/// nowhere. Re-add them as their own StatefulShellBranch (see
/// app_router.dart) once there's a real screen behind each.
///
/// Install is a permanent tab, not a one-time onboarding step — the app
/// is distributed as a website added to the home screen rather than
/// through an App/Play Store listing (see InstallGuideScreen), so it
/// needs to stay reachable for a user setting up a second device.
///
/// The bar is a floating blurred pill *over* the content rather than a
/// Material [NavigationBar] docked to the bottom edge. Screens therefore
/// have to pad their own scrollables by [AppSpacing.navOverlayInsetOf] —
/// the pill reserves no layout space. That helper and the pill's own
/// position below are both derived from [AppSpacing.navPillInset], so the
/// two stay in step on hardware with a home indicator.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A badge on Review is the only place the shell shows live data: the
    // due count is the reason to switch tabs at all, so it has to be
    // visible from every other tab. Errors and loading both read as "no
    // badge" rather than surfacing shell-level error UI.
    final dueCount = ref.watch(dueSrsItemsProvider).valueOrNull?.length ?? 0;

    // The pill floats over the content with nothing between it and the
    // window edge, so it is the one piece of chrome that has to apply the
    // display's insets itself — every screen below it is already wrapped
    // in a SafeArea. Horizontally that means the landscape notch/camera
    // cutout (viewPadding.left/right, non-zero only in landscape on a
    // notched device); vertically the home indicator, via
    // AppSpacing.navPillInset.
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Scaffold(
      // The shell owns no content of its own — each branch screen is its
      // own Scaffold and does its own keyboard avoidance. Letting this one
      // resize too would inset the keyboard's height twice, and would
      // measure the pill's `bottom` from the top of the keyboard rather
      // than from the bottom of the window, which is the frame
      // AppSpacing.navPillInset's viewPadding reading assumes.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: AppSpacing.navPillSideGap + viewPadding.left,
            right: AppSpacing.navPillSideGap + viewPadding.right,
            bottom: AppSpacing.navPillInset(context),
            child: _FloatingNavBar(
              currentIndex: navigationShell.currentIndex,
              dueCount: dueCount,
              onSelected: (index) => navigationShell.goBranch(
                index,
                // Tapping the already-active tab pops back to its root,
                // matching standard mobile nav conventions rather than
                // staying stuck deep in that tab's stack.
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.dueCount,
    required this.onSelected,
  });

  final int currentIndex;
  final int dueCount;
  final ValueChanged<int> onSelected;

  static const _destinations = [
    (icon: Icons.menu_book_rounded, label: 'Learn'),
    // Was Icons.refresh — read as "reload," not "spaced-repetition
    // recall." Psychology (a brain) is what this tab actually is:
    // flip-card review that grades how well you remembered something,
    // not a data refresh action.
    (icon: Icons.psychology_rounded, label: 'Review'),
    (icon: Icons.mosque_rounded, label: 'Prayer'),
    (icon: Icons.install_mobile_rounded, label: 'Install'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: AppSpacing.navPillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.bgGlass,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _destinations[i].icon,
                    label: _destinations[i].label,
                    selected: i == currentIndex,
                    badge: i == 1 && dueCount > 0 ? dueCount : null,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.brandPrimary : AppColors.textSecondary;

    return Semantics(
      selected: selected,
      button: true,
      label: badge == null ? label : '$label, $badge due',
      // Without this the visible Text below is announced too, so the
      // label is read twice.
      excludeSemantics: true,
      child: Material(
        color: selected
            ? AppColors.brandPrimary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 23, color: foreground),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: AppTypography.label(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
                if (badge != null)
                  Positioned(
                    top: 5,
                    right: 12,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 17),
                      height: 17,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.brandAccent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '$badge',
                        style: AppTypography.numeric(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
