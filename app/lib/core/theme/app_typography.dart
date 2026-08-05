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

  static TextTheme textTheme(Color primary, Color secondary) {
    final base = GoogleFonts.workSansTextTheme();
    return base.copyWith(
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
