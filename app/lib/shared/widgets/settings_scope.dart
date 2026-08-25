import 'package:flutter/material.dart';

/// Marks the part of the tree where Settings is reachable, and carries the
/// one action for getting there.
///
/// The redesign removed AppBars, so the "avatar icon on each screen's
/// AppBar" that `app_shell.dart` describes has nowhere to live. What every
/// top-level screen still shares is [ScreenHeader], so the entry point
/// went there — but only where it belongs: a settings gear makes sense on
/// the four tabs, and makes no sense on a full-screen takeover like the
/// lesson player or the placement result. A scope rather than a flag on
/// each screen because those screens decide nothing about it; the router
/// does, by wrapping the tab shell and nothing else.
///
/// [open] is passed in rather than hardcoded so this shared widget doesn't
/// have to know the route. Pass a top-level function (not an inline
/// closure) so [updateShouldNotify] can compare it by identity.
class SettingsScope extends InheritedWidget {
  const SettingsScope({super.key, required this.open, required super.child});

  final void Function(BuildContext context) open;

  /// Null when Settings isn't reachable from here — the caller should show
  /// no affordance at all rather than a disabled one.
  static void Function(BuildContext context)? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsScope>()?.open;
  }

  @override
  bool updateShouldNotify(SettingsScope oldWidget) => oldWidget.open != open;
}
