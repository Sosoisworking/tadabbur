import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// Bridges the service worker's "a newer build is waiting" state into Dart.
///
/// The worker in web/sw.js precaches a new build and then waits rather than
/// activating, so a running session is never swapped onto different code
/// mid-use. index.html applies a waiting worker at the next launch, which
/// means the only way for a user to pick up an update is to fully quit the
/// app and relaunch — not something anyone should have to know. This lets
/// Settings offer it directly.
///
/// The two globals below are defined in web/index.html, next to the
/// registration logic they belong to; this file only reads them.
@JS('__tadabburApplyUpdate')
external JSFunction? get _applyUpdate;

@JS('__tadabburUpdateReady')
external JSFunction? get _updateReady;

@JS('__tadabburOnUpdateAvailable')
external set _onUpdateAvailable(JSFunction? callback);

final ValueNotifier<bool> _available = _install();

ValueListenable<bool>? get updateAvailable => _available;

ValueNotifier<bool> _install() {
  final notifier = ValueNotifier<bool>(false);

  // Registered before the poll below, so an update that lands between the two
  // is announced rather than dropped.
  _onUpdateAvailable = (() => notifier.value = true).toJS;

  // A worker can already have been waiting before Flutter attached, in which
  // case the callback above had nothing to call. Ask once for that case.
  final ready = _updateReady;
  if (ready != null && (ready.callAsFunction() as JSBoolean?)?.toDart == true) {
    notifier.value = true;
  }

  return notifier;
}

void applyUpdate() => _applyUpdate?.callAsFunction();
