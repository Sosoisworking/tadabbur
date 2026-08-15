import 'package:flutter/material.dart';

/// `success` and `locked` from docs/design-system.md's color table —
/// Material 3's [ColorScheme] has no role for either, so without this
/// they have no way to reach a widget except a hardcoded [Color] literal
/// (exactly what the design system says never to do). Access via
/// `Theme.of(context).extension<AppSemanticColors>()!`.
///
/// `error` isn't duplicated here — [ColorScheme.error] already carries
/// the spec's warm-terracotta value (see [AppTheme]), so incorrect-answer
/// styling should read `colorScheme.error` directly, not a second token
/// for the same thing.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({required this.success, required this.locked});

  final Color success;
  final Color locked;

  @override
  AppSemanticColors copyWith({Color? success, Color? locked}) {
    return AppSemanticColors(
      success: success ?? this.success,
      locked: locked ?? this.locked,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      locked: Color.lerp(locked, other.locked, t)!,
    );
  }
}
