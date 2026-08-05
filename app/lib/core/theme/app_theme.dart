import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the light and dark ThemeData from docs/design-system.md tokens.
/// Contrast pairs there are verified at WCAG AA — if you change a color
/// here, re-verify contrast before shipping, don't assume it still holds.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const primary = AppColors.lightBrandPrimary;
    const surface = AppColors.lightBgSurface;
    const textPrimary = AppColors.lightTextPrimary;
    const textSecondary = AppColors.lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBgBase,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: AppColors.lightBrandAccent,
        surface: surface,
        error: AppColors.lightError,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: AppTypography.textTheme(textPrimary, textSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgBase,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    const primary = AppColors.darkBrandPrimary;
    const surface = AppColors.darkBgSurface;
    const textPrimary = AppColors.darkTextPrimary;
    const textSecondary = AppColors.darkTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgBase,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: AppColors.darkBrandAccent,
        surface: surface,
        error: AppColors.darkError,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      textTheme: AppTypography.textTheme(textPrimary, textSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgBase,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
    );
  }
}
