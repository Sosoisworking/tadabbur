import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// One badge shape/size for the app's icon badges (unit list, lesson
/// grid, etc.) — screens had drifted onto two different shapes (a
/// circle in one place, a rounded square in another) for the same kind
/// of "what is this" indicator. Rounded square, sized to the 44×44
/// minimum touch target docs/design-system.md requires, since these
/// badges are frequently the tappable element itself.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.color,
    required this.child,
    this.size = AppSpacing.minTouchTarget,
  });

  final Color color;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
