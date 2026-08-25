import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type families:
/// - **Lora** is the English UI voice — headings *and* body. A serif
///   throughout is what keeps the app reading as a book rather than a
///   dashboard.
/// - **Work Sans** is reserved for the places a serif goes muddy:
///   numerals, uppercase micro-labels, button text, and dense metadata.
///   Reach for it via [label], [eyebrow], or [numeric], never by naming
///   the family at a call site.
/// - **Amiri Quran** for all diacritized Arabic — purpose-built for
///   Quranic typesetting, always at [arabicMinFontSize] or larger
///   regardless of the user's text-scale setting, since Tashkeel is
///   illegible below that.
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

  static TextTheme textTheme() {
    final serif = GoogleFonts.loraTextTheme();
    return serif.copyWith(
      displayLarge: display(fontSize: 38),
      displayMedium: display(fontSize: 34),
      displaySmall: display(fontSize: 30),
      headlineMedium: display(fontSize: 24),
      titleLarge: serif.titleLarge?.copyWith(color: AppColors.textPrimary, height: 1.25),
      titleMedium: serif.titleMedium?.copyWith(color: AppColors.textPrimary, height: 1.3),
      bodyLarge: serif.bodyLarge?.copyWith(color: AppColors.textPrimary, height: 1.5),
      bodyMedium: serif.bodyMedium?.copyWith(color: AppColors.textPrimary, height: 1.5),
      bodySmall: serif.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.5),
      // Buttons and tabs are the one piece of chrome that stays sans —
      // see the class doc.
      labelLarge: label(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: label(fontSize: 12),
      labelSmall: label(fontSize: 11),
    );
  }

  /// The screen-title voice: Lora, tight leading, slightly negative
  /// tracking. Pair with [emphasis] for the italic coloured clause that
  /// most screen titles carry.
  static TextStyle display({double fontSize = 30, Color? color}) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      height: 1.16,
      letterSpacing: -0.3,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// The italic coloured clause inside a [display] title ("Keep going,
  /// *Connecting Letters*"). Inherits size from the surrounding display
  /// style, so only the varying parts are set here.
  static TextStyle emphasis(Color color) {
    return GoogleFonts.lora(fontStyle: FontStyle.italic, color: color);
  }

  /// Uppercase tracked-out kicker above a screen title. Callers pass
  /// already-cased text; this only sets the tracking and weight.
  static TextStyle eyebrow({Color? color}) {
    return GoogleFonts.workSans(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      height: 1,
      color: color ?? AppColors.brandAccent,
    );
  }

  /// Work Sans for metadata, hints, and button text — see the class doc
  /// for when a sans is correct instead of Lora.
  static TextStyle label({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.workSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textSecondary,
    );
  }

  /// Standalone figures — a due-count, a streak, a percentage. Lora's
  /// numerals are too soft to carry a screen at this size.
  static TextStyle numeric({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.workSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1,
      color: color ?? AppColors.textPrimary,
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
  static TextStyle arabic({double? fontSize, Color? color, double height = 1.8}) {
    return GoogleFonts.amiriQuran(
      fontSize: resolveArabicFontSize(fontSize),
      color: color,
      height: height,
    );
  }

  /// Oversized translucent Arabic used as a decorative unit identity mark
  /// behind card content. Deliberately exempt from the [arabicMinFontSize]
  /// floor logic's *intent* (it is never read, only felt) but far above it
  /// anyway.
  static TextStyle glyphMark({required double fontSize, required Color color}) {
    return GoogleFonts.amiriQuran(fontSize: fontSize, color: color, height: 1);
  }
}
