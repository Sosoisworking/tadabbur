import 'package:flutter/foundation.dart';

import 'app_update_none.dart' if (dart.library.js_interop) 'app_update_web.dart' as impl;

/// Whether a newer build has finished downloading and is waiting to be
/// applied, and the way to apply it.
///
/// Web only. The service worker deliberately does not swap a new build in
/// mid-session — reloading someone out of a lesson is worse than a launch of
/// staleness (see web/sw.js) — so without something like this the only way to
/// pick up an update is to fully quit the app and relaunch, which nobody
/// should be expected to guess. Settings offers it instead.
///
/// On native the store handles updates, so this is null and the Settings row
/// that reads it renders nothing.
abstract final class AppUpdate {
  /// True once a newer build is precached and waiting. Never becomes false
  /// again in a session: the only way out is applying it, which reloads.
  static ValueListenable<bool>? get available => impl.updateAvailable;

  /// Hands control to the waiting worker and reloads onto the new build.
  /// Safe to call when nothing is waiting — it does nothing.
  static void apply() => impl.applyUpdate();
}
