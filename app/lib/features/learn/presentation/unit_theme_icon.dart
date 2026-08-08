import 'package:flutter/material.dart';

/// Inferred from a unit's title — a display-only hint (which icon to
/// show), same pattern as the lesson/quiz icon in UnitDetailScreen. The
/// domain model doesn't carry a "topic" field, and adding one just to
/// pick an icon isn't worth a schema change yet. Shared between
/// LearnScreen's unit tiles and UnitDetailScreen's app bar so the same
/// unit always shows the same icon in both places.
IconData unitThematicIcon(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('alphabet')) return Icons.abc_rounded;
  if (lower.contains('vowel marks') || lower.contains('harakat')) return Icons.tune_rounded;
  if (lower.contains('madd') || lower.contains('leen') || lower.contains('diphthong')) {
    return Icons.waves_rounded;
  }
  if (lower.contains('shaddah')) return Icons.repeat_rounded;
  return Icons.auto_stories_rounded; // surah/reading units, e.g. Al-Fatiha
}
