import 'package:flutter/material.dart';

/// Color tokens from docs/design-system.md. Keep this file as the single
/// source of truth for palette values — never hardcode a hex color in a
/// widget; reference these tokens so a palette change is a one-file edit.
class AppColors {
  AppColors._();

  // Light mode
  static const lightBgBase = Color(0xFFFBF7EE);
  static const lightBgSurface = Color(0xFFFFFFFF);
  static const lightBrandPrimary = Color(0xFF1B5E4A);
  static const lightBrandAccent = Color(0xFFC8932A);
  static const lightTextPrimary = Color(0xFF1C2620);
  static const lightTextSecondary = Color(0xFF5B6660);
  static const lightSuccess = Color(0xFF2E7D4F);
  static const lightError = Color(0xFFB3462C);
  static const lightLocked = Color(0xFFC9C2B2);

  // Dark mode
  static const darkBgBase = Color(0xFF12201C);
  static const darkBgSurface = Color(0xFF1A2B25);
  static const darkBrandPrimary = Color(0xFF3FA37E);
  static const darkBrandAccent = Color(0xFFE0AC4F);
  static const darkTextPrimary = Color(0xFFF2EFE6);
  static const darkTextSecondary = Color(0xFFAAB3AC);
  static const darkSuccess = Color(0xFF4FAE78);
  static const darkError = Color(0xFFD97456);
  static const darkLocked = Color(0xFF3A423C);
}
