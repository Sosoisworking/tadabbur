import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Native no-op half of [display_insets.dart]'s conditional import.
///
/// iOS and Android already deliver real `viewPadding`/`padding` through the
/// engine's `ViewConfiguration`, so there is nothing to plumb and nothing to
/// override — doing either would double-apply the insets.
Future<void> initDisplayInsets() async {}

/// Always null on native, which is what makes `DisplayInsets` return its
/// child untouched.
ValueListenable<EdgeInsets>? get displayInsets => null;
