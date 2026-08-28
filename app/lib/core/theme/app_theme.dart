import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the app's single dark ThemeData. The design is dark-first and
/// ships dark only — there is no light variant to keep in sync, so a
/// palette change is [AppColors] plus this file and nothing else.
class AppTheme {
  AppTheme._();

  /// How the OS should draw the status bar and Android's navigation bar over
  /// this app.
  ///
  /// Applied through an [AnnotatedRegion] at the root (see app.dart) rather
  /// than through `appBarTheme.systemOverlayStyle`, which only takes effect
  /// where an `AppBar` is actually rendered — and the redesign has none. On
  /// [AppColors.bgBase] the platform default draws *dark* status-bar content,
  /// so without this the clock, battery and signal are near-invisible.
  ///
  /// The two brightness fields mean opposite things by platform, which is why
  /// they look contradictory: iOS reads `statusBarBrightness` as the
  /// brightness of the background *behind* the bar (dark ⇒ draw light
  /// content), while Android reads `statusBarIconBrightness` as the wanted
  /// brightness of the icons themselves.
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bgBase,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  static ThemeData dark() {
    // ColorScheme.dark() only fills the handful of roles passed to it —
    // Material 3 has ~30, and every role left unset quietly falls back to
    // Flutter's own default purple seed, which then surfaces in chips,
    // container tints, and selection states. fromSeed derives a full
    // harmonious palette from our own primary; the explicit overrides
    // below still win for the roles the design specifies exactly.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.brandPrimary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.brandAccent,
      onSecondary: AppColors.onAccent,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      outline: AppColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgBase,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgBase,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        // Belt-and-braces: no screen currently renders an AppBar, but if one
        // ever does it must not revert the root AnnotatedRegion's style.
        systemOverlayStyle: overlayStyle,
      ),
      cardTheme: _cardTheme(),
      chipTheme: _chipTheme(),
      inputDecorationTheme: _inputTheme(),
      filledButtonTheme: _filledButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandPrimary,
        linearTrackColor: AppColors.borderSubtle,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderSubtle, thickness: 1),
      // No ThemeExtension for success/locked: those existed only to swap
      // per brightness, and the app is dark-only now. Widgets read
      // AppColors.success / AppColors.locked directly — one spelling per
      // color rather than two.
    );
  }

  /// One card idiom for the whole app: no drop shadow, a hairline border,
  /// and a generous radius. Depth comes from the border and the surface
  /// step above the ground, not from elevation — Material's shadows read
  /// as muddy smears against a near-black background.
  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 0,
      color: AppColors.bgSurface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
    );
  }

  /// Text fields follow the same over-rounded, hairline-bordered idiom as
  /// every other container, so a form doesn't read as Material dropped
  /// into the middle of the design.
  static InputDecorationTheme _inputTheme() {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      hintStyle: AppTypography.label(fontSize: 14, fontWeight: FontWeight.w400),
      labelStyle: AppTypography.label(fontSize: 14, fontWeight: FontWeight.w400),
      floatingLabelStyle: AppTypography.label(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.brandPrimary,
      ),
      enabledBorder: border(AppColors.borderSubtle),
      focusedBorder: border(AppColors.brandPrimary, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  static ChipThemeData _chipTheme() {
    return ChipThemeData(
      backgroundColor: Colors.transparent,
      labelStyle: AppTypography.label(fontSize: 11.5),
      side: const BorderSide(color: AppColors.borderSubtle),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    );
  }

  static FilledButtonThemeData _filledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(0, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        shape: const StadiumBorder(),
        textStyle: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        minimumSize: const Size(0, AppSpacing.minTouchTarget),
        shape: const StadiumBorder(),
        textStyle: AppTypography.label(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
