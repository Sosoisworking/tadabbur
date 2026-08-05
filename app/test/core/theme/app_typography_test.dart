import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur/core/theme/app_typography.dart';

void main() {
  // Pure Dart logic, deliberately kept separate from AppTypography.arabic()
  // (which calls into google_fonts and needs either a bundled font asset
  // or network access to fully resolve) — see app_typography.dart.
  group('AppTypography.resolveArabicFontSize', () {
    test('never resolves below the diacritic-legibility floor', () {
      // docs/design-system.md: diacritics are illegible below 24px,
      // regardless of the user's text-scale setting — this must hold even
      // if a caller passes something smaller by mistake.
      expect(AppTypography.resolveArabicFontSize(12), AppTypography.arabicMinFontSize);
    });

    test('respects a font size at or above the floor', () {
      expect(AppTypography.resolveArabicFontSize(32), 32);
    });

    test('defaults to the floor when no size is given', () {
      expect(AppTypography.resolveArabicFontSize(null), AppTypography.arabicMinFontSize);
    });
  });
}
