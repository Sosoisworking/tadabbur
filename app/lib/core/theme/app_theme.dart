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
    const accent = AppColors.lightBrandAccent;
    const surface = AppColors.lightBgSurface;
    const textPrimary = AppColors.lightTextPrimary;
    const textSecondary = AppColors.lightTextSecondary;

    // ColorScheme.light() only fills the handful of roles passed to it —
    // Material 3 has ~30 (primaryContainer, surfaceContainerHighest,
    // outline, the NavigationBar indicator, ...), and every role left
    // unset quietly falls back to Flutter's own default purple seed. That
    // was the actual cause of the app feeling generic: our warm
    // emerald/gold palette was only reaching a few widgets, and
    // everything else (nav bar selection, chips, container tints) was
    // showing Material's stock purple underneath. fromSeed derives a
    // full, harmonious palette from our own primary color instead of
    // Material's, then the explicit overrides below still win for the
    // handful of roles docs/design-system.md specifies exactly.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: AppColors.lightError,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBgBase,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(textPrimary, textSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgBase,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      navigationBarTheme: _navigationBarTheme(primary, accent, surface, textSecondary),
      chipTheme: _chipTheme(colorScheme),
    );
  }

  static ThemeData dark() {
    const primary = AppColors.darkBrandPrimary;
    const accent = AppColors.darkBrandAccent;
    const surface = AppColors.darkBgSurface;
    const textPrimary = AppColors.darkTextPrimary;
    const textSecondary = AppColors.darkTextSecondary;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: AppColors.darkError,
      onPrimary: Colors.black,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgBase,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(textPrimary, textSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgBase,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      navigationBarTheme: _navigationBarTheme(primary, accent, surface, textSecondary),
      chipTheme: _chipTheme(colorScheme),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(
    Color primary,
    Color accent,
    Color surface,
    Color textSecondary,
  ) {
    return NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withValues(alpha: 0.25),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? primary : textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: states.contains(WidgetState.selected) ? primary : textSecondary,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      side: BorderSide.none,
    );
  }
}
