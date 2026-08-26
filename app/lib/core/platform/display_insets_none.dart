import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'keyboard_inset.dart';

/// Native no-op half of [display_insets.dart]'s conditional import.
///
/// iOS and Android already deliver real `viewPadding`/`padding` through the
/// engine's `ViewConfiguration`, and a real `viewInsets` for the on-screen
/// keyboard through the platform's own metrics callback, so there is nothing
/// to plumb and nothing to override — doing either would double-apply the
/// insets.
Future<void> initDisplayInsets() async {}

/// Always null on native, which is what makes `DisplayInsets` return its
/// child untouched.
ValueListenable<EdgeInsets>? get displayInsets => null;

/// Always null on native for the same reason: the engine reports the keyboard
/// itself, so there is nothing here to measure or correct.
ValueListenable<KeyboardInset>? get keyboardInset => null;
