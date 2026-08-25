import 'package:flutter/material.dart';

/// The circular icon dot fronting a list row — a lesson in the Learn
/// carousel's lesson list, a step in the Install guide. Distinct from
/// [StatusBadge] (a rounded square, sized to the 44px touch target,
/// used where the badge itself is the tappable element): this is purely
/// decorative leading iconography inside an already-tappable row, so it
/// stays small and circular per the design.
class RowIconDot extends StatelessWidget {
  const RowIconDot({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 38,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: foreground),
    );
  }
}
