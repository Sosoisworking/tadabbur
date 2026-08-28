/// A per-unit identity glyph, inferred from the unit's title — a
/// display-only hint. The domain model doesn't carry a "topic" field, and
/// adding one just to pick a glyph isn't worth a schema change yet.
/// Shared between LearnScreen's carousel cards and UnitDetailScreen's
/// header so the same unit looks like itself in both places.
///
/// Deliberately Arabic glyphs, not abstract Material icons (sliders for
/// "vowel marks," waves for "elongation," etc.) — per feedback, generic
/// icon-hunting felt both wrong and stylistically flat next to the rest
/// of the app. Showing the actual script each unit teaches is more
/// accurate and more on-brand (design-system.md: "the Arabic is the
/// star") than any Latin-alphabet Material icon could be.
String? unitGlyph(String title) {
  final lower = title.toLowerCase();

  if (lower.contains('alphabet')) {
    return 'ا'; // a bare letter — this unit teaches letters themselves
  } else if (lower.contains('connecting letters')) {
    return 'بت'; // two letters joined together — the unit's whole subject
  } else if (lower.contains('vowel marks') || lower.contains('harakat')) {
    return 'بَ'; // ب + Fathah — a letter carrying a vowel mark
  } else if (lower.contains('madd') || lower.contains('leen') || lower.contains('diphthong')) {
    return 'آ'; // Alif with Madda above — the elongation symbol itself
  } else if (lower.contains('shaddah')) {
    return 'بّ'; // ب + Shaddah — the doubling mark itself
  }
  // No single glyph represents "a surah" the way the marks above do —
  // Al-Fatiha and future surah units fall back to null (callers show a
  // book icon instead).
  return null;
}

