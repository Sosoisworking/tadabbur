import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type families from docs/design-system.md:
/// - Work Sans for English UI chrome (warm humanist sans, not the generic
///   Inter/Roboto default).
/// - Amiri Quran for diacritized Arabic content — purpose-built for
///   Quranic typesetting, always used at [arabicMinFontSize] or larger
///   regardless of the user's text-scale setting, since Tashkeel is
///   illegible below that.
/// - Lora as a serif accent, reserved for emotional moments (onboarding,
///   mastery-challenge results, achievement unlocks) — never everyday
///   lesson screens.
class AppTypography {
  AppTypography._();

  static const double arabicMinFontSize = 24;

  /// Named Arabic display sizes, replacing the ad hoc per-call-site numbers
  /// that had drifted across the app (e.g. 80 on one screen and 72 on
  /// another for the same "focused practice" purpose). Pick the step that
  /// matches the moment, not a bespoke number:
  /// - [arabicXL]: a single letter/word as the whole point of the screen
  ///   (letter cards).
  /// - [arabicLarge]: short focused practice — a letter chain, an SRS flip
  ///   card.
  /// - [arabicMedium]: a vocab card's headword.
  /// - [arabicCompact]: a teaching grid where Arabic shares space with
  ///   other UI (diacritic-mark grids).
  /// - [arabicSmall]: Arabic embedded inline in reading passages, quiz
  ///   questions, and grammar examples — still floor-enforced, never
  ///   smaller than [arabicMinFontSize].
  static const double arabicXL = 96;
  static const double arabicLarge = 72;
  static const double arabicMedium = 48;
  static const double arabicCompact = 40;
  static const double arabicSmall = 32;

  static TextTheme textTheme(Color primary, Color secondary) {
    final base = GoogleFonts.workSansTextTheme();
    return base.copyWith(
      // A prominent standalone stat (a due-count, a streak number) needs
      // its own token — reach for this instead of a bespoke hardcoded
      // TextStyle, which is exactly the kind of drift this file's header
      // comment warns against.
      displayMedium: base.displayMedium?.copyWith(color: primary, fontWeight: FontWeight.bold),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: primary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      titleLarge: base.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(color: primary),
    );
  }

  /// Pure floor-clamping logic, kept separate from [arabic] so it's
  /// testable without touching google_fonts' asset/network-loading path.
  static double resolveArabicFontSize(double? requested) {
    final size = requested ?? arabicMinFontSize;
    return size < arabicMinFontSize ? arabicMinFontSize : size;
  }

  /// Style for any diacritized Arabic content — always route rendering of
  /// Quranic text through this, never a plain Text() with an ad hoc font.
  static TextStyle arabic({double? fontSize, Color? color}) {
    return GoogleFonts.amiriQuran(
      fontSize: resolveArabicFontSize(fontSize),
      color: color,
      height: 1.8,
    );
  }

  /// Serif accent for emotional/celebratory moments only — see class doc.
  static TextStyle accent({double? fontSize, FontWeight? fontWeight, Color? color}) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
