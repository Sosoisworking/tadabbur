import 'package:flutter/material.dart';

/// Color tokens for the dark-first palette. Keep this file as the single
/// source of truth for palette values — never hardcode a hex color in a
/// widget; reference these tokens so a palette change is a one-file edit.
class AppColors {
  AppColors._();

  /// Page ground. Deeper than the card surface so the over-rounded
  /// containers read as lifted rather than flush.
  static const bgBase = Color(0xFF0D1815);
  static const bgSurface = Color(0xFF16241F);

  /// Backdrop for the floating nav pill — translucent so the blur behind
  /// it has something to tint.
  static const bgGlass = Color(0xDC13201B);

  static const brandPrimary = Color(0xFF3FA37E);
  static const brandPrimaryHover = Color(0xFF4FBB92);
  static const brandAccent = Color(0xFFE0AC4F);

  /// Foregrounds for text sitting *on* the brand fills. Near-black rather
  /// than pure black, tinted toward each fill's own hue.
  static const onPrimary = Color(0xFF08120F);
  static const onAccent = Color(0xFF20170A);

  static const textPrimary = Color(0xFFF2EFE6);
  static const textSecondary = Color(0xFF94A39B);

  /// Third text step, for hints and captions that must recede behind
  /// [textSecondary] without disappearing.
  static const textMuted = Color(0xFF5D6B64);

  static const success = Color(0xFF4FAE78);
  static const error = Color(0xFFD97456);
  static const locked = Color(0xFF3A423C);

  /// Hairline borders and low-contrast fills, expressed as alpha over the
  /// ground so a container reads consistently on both bgBase and bgSurface.
  static const borderSubtle = Color(0x1AF2EFE6);
  static const borderStrong = Color(0x2EF2EFE6);
  static const fillSubtle = Color(0x0DFFFFFF);
}
