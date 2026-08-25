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

  /// Horizontal page inset. Wider than [lg] so the generous corner radii
  /// have room to breathe against the screen edge.
  static const double screenInset = 26;

  /// Bottom padding every scrollable screen owes the floating nav pill,
  /// which overlays content rather than reserving layout space.
  static const double navOverlayInset = 120;

  /// docs/design-system.md: "Minimum touch target 44×44pt everywhere,
  /// non-negotiable" — Aisha-persona users may have low technical
  /// dexterity with a new app.
  static const double minTouchTarget = 44;
}

/// Corner radii. The design leans hard on over-rounding: containers sit
/// between [lg] and [xxl], and anything interactive that isn't a container
/// is a full [pill].
class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 22;
  static const double xl = 26;
  static const double xxl = 30;

  /// Feature surfaces — the exercise deck card, the SRS review card.
  static const double card = 34;

  /// Any radius large enough to fully round the shorter axis.
  static const double pill = 999;
}
