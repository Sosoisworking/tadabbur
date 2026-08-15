import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// The one card idiom for the app (see AppTheme's cardTheme for the
/// shared radius/elevation) — use this instead of choosing between a bare
/// `Card` and a hand-rolled `Material`+`InkWell` each time a screen needs
/// a tappable or non-tappable grouped surface.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
