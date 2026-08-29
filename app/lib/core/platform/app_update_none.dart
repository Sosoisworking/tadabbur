import 'package:flutter/foundation.dart';

/// Native half of [AppUpdate]. There is no service worker off the web, and
/// app updates arrive through the store, so there is nothing to offer and
/// nothing to apply.
ValueListenable<bool>? get updateAvailable => null;

void applyUpdate() {}
