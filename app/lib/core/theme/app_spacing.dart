import 'package:flutter/widgets.dart';

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

  /// The floating nav pill's geometry (see AppShell). It lives here rather
  /// than in app_shell.dart because the pill reserves no layout space —
  /// every scrollable screen in the shell has to pad around it, so both
  /// sides of that contract need the same numbers.
  static const double navPillHeight = 70;

  /// Gap below the pill on hardware with no home indicator (older iPhones,
  /// most Android, desktop/web). On a device that *does* have one the pill
  /// is lifted instead — see [navPillInset].
  static const double navPillGap = 22;

  /// Gap between the pill and the left/right edge of the safe area.
  static const double navPillSideGap = 20;

  /// Breathing room between the last item of a scrollable and the pill's
  /// top edge.
  static const double navPillClearance = 28;

  /// How far the pill's bottom edge sits above the bottom of the window.
  ///
  /// Derived from `viewPadding`, not `padding`: the two are identical
  /// except while the on-screen keyboard is up, when `padding.bottom`
  /// collapses to zero because the keyboard has swallowed the home
  /// indicator's strip. The home indicator is a fixed property of the
  /// hardware, so keying off `padding` would drop the pill by ~34pt the
  /// moment a keyboard opened and snap it back when it closed — motion
  /// caused by the keyboard, not by the thing we're avoiding.
  /// `viewPadding` reports the indicator's inset regardless of keyboard
  /// state, which is what "sit above the home indicator" actually means.
  ///
  /// On hardware with an indicator the indicator's own strip already reads
  /// as margin, so the pill only needs [sm] on top of it rather than the
  /// full [navPillGap]; on hardware without one the value is exactly
  /// [navPillGap], i.e. unchanged.
  static double navPillInset(BuildContext context) {
    final homeIndicator = MediaQuery.viewPaddingOf(context).bottom;
    return homeIndicator > 0 ? homeIndicator + sm : navPillGap;
  }

  /// Bottom padding a scrollable screen inside the shell owes the floating
  /// nav pill, which overlays content rather than reserving layout space.
  ///
  /// Prefer this over [navOverlayInset]: it tracks the pill's real
  /// on-device position, so the last row of a list can always be scrolled
  /// clear of the pill on a phone with a home indicator too.
  static double navOverlayInsetOf(BuildContext context) =>
      navPillInset(context) + navPillHeight + navPillClearance;

  /// The value [navOverlayInsetOf] returns on hardware with no home
  /// indicator (120). Only for contexts that genuinely have no
  /// [BuildContext] to measure from.
  static const double navOverlayInset =
      navPillGap + navPillHeight + navPillClearance;

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
