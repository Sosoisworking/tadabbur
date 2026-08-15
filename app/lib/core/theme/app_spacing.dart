/// Spacing and radius tokens from docs/design-system.md's "8px base grid."
/// Never hand-write a raw `EdgeInsets.all(24)`/`SizedBox(height: 16)`/
/// `BorderRadius.circular(16)` in a widget — reference these so the scale
/// stays a one-file edit instead of a find-and-replace across every screen.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// docs/design-system.md: "Minimum touch target 44×44pt everywhere,
  /// non-negotiable" — Aisha-persona users may have low technical
  /// dexterity with a new app.
  static const double minTouchTarget = 44;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}
