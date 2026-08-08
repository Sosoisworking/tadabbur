import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// A per-unit badge, inferred from the unit's title — a display-only
/// hint, same pattern as the lesson/quiz icon in UnitDetailScreen. The
/// domain model doesn't carry a "topic" field, and adding one just to
/// pick a badge isn't worth a schema change yet. Shared between
/// LearnScreen's unit tiles and UnitDetailScreen's app bar so the same
/// unit always shows the same badge in both places.
///
/// Deliberately Arabic glyphs, not abstract Material icons (sliders for
/// "vowel marks," waves for "elongation," etc.) — per feedback, generic
/// icon-hunting felt both wrong and stylistically flat next to the rest
/// of the app. Showing the actual script each unit teaches is more
/// accurate and more on-brand (design-system.md: "the Arabic is the
/// star") than any Latin-alphabet Material icon could be.
Widget unitThematicBadge(String title, {required double size, required Color color}) {
  final lower = title.toLowerCase();

  String? glyph;
  if (lower.contains('alphabet')) {
    glyph = 'ا'; // a bare letter — this unit teaches letters themselves
  } else if (lower.contains('vowel marks') || lower.contains('harakat')) {
    glyph = 'بَ'; // ب + Fathah — a letter carrying a vowel mark
  } else if (lower.contains('madd') || lower.contains('leen') || lower.contains('diphthong')) {
    glyph = 'آ'; // Alif with Madda above — the elongation symbol itself
  } else if (lower.contains('shaddah')) {
    glyph = 'بّ'; // ب + Shaddah — the doubling mark itself
  }

  if (glyph != null) {
    return Text(glyph, style: AppTypography.arabic(fontSize: size, color: color));
  }

  // No single glyph represents "a surah" the way the marks above do —
  // Al-Fatiha and future surah units fall back to a book icon.
  return Icon(Icons.auto_stories_rounded, size: size, color: color);
}
