import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'keyboard_inset.dart';

import 'display_insets_none.dart' if (dart.library.js_interop) 'display_insets_web.dart' as impl;

export 'keyboard_inset.dart' show KeyboardInset;

/// Prepares real display insets on platforms where the engine does not
/// supply them. A no-op everywhere except web — see display_insets_web.dart
/// for why web needs it and what it deliberately does not attempt.
///
/// Await this before `runApp`: on web it may switch the page to
/// `viewport-fit=cover`, and the first frame must not be painted
/// edge-to-edge before the matching insets exist.
Future<void> initDisplayInsets() => impl.initDisplayInsets();

/// Injects [initDisplayInsets]'s measurements into the `MediaQuery` that
/// `SafeArea`, `MediaQuery.paddingOf`, `MediaQuery.viewPaddingOf` and
/// `Scaffold.resizeToAvoidBottomInset` read.
///
/// Belongs in `MaterialApp.builder`, not above the app: `MaterialApp`
/// installs its own `MediaQuery.fromView`, which would overwrite anything
/// wrapped around it.
///
/// Returns [child] untouched on native (where the engine already reports
/// insets, so overriding would double-apply them) and on any web page where
/// there is currently nothing to add — no safe area, no keyboard.
class DisplayInsets extends StatelessWidget {
  const DisplayInsets({
    super.key,
    required this.child,
    this.source,
    this.keyboardSource,
  });

  final Widget child;

  /// Overrides where the safe-area insets come from. Production leaves this
  /// null and takes the platform's own source; supplying a listenable lets the
  /// injection be exercised on a platform that has no safe area to measure.
  @visibleForTesting
  final ValueListenable<EdgeInsets>? source;

  /// Overrides where the keyboard measurement comes from, for the same reason
  /// [source] exists: no test platform has an on-screen keyboard to raise.
  @visibleForTesting
  final ValueListenable<KeyboardInset>? keyboardSource;

  @override
  Widget build(BuildContext context) {
    final safeAreaSource = source ?? impl.displayInsets;
    final keyboardInsetSource = keyboardSource ?? impl.keyboardInset;
    if (safeAreaSource == null && keyboardInsetSource == null) return child;

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable?>[safeAreaSource, keyboardInsetSource]),
      child: child,
      builder: (context, child) {
        final safeArea = safeAreaSource?.value ?? EdgeInsets.zero;
        final keyboard = keyboardInsetSource?.value ?? KeyboardInset.none;

        final media = MediaQuery.of(context);
        final viewInsets = _resolveViewInsets(media, keyboard);
        if (safeArea == EdgeInsets.zero && viewInsets == media.viewInsets) {
          return child!;
        }

        // Leave `viewPadding` alone when there is no safe area to report, so a
        // keyboard-only correction cannot clobber a value someone else set.
        final viewPadding = safeArea == EdgeInsets.zero ? media.viewPadding : safeArea;

        // `padding` is `viewPadding` with anything the keyboard has already
        // covered removed, which is the invariant the framework maintains on
        // native and which `SafeArea` depends on. It is derived from the
        // *resolved* `viewInsets`, not the engine's: once a keyboard is
        // measured, the bottom safe area is behind it and must stop producing
        // padding, or `SafeArea` would hold content a home-indicator's height
        // above a keyboard that is already covering that strip.
        final padding = EdgeInsets.fromLTRB(
          (viewPadding.left - viewInsets.left).clamp(0.0, double.infinity),
          (viewPadding.top - viewInsets.top).clamp(0.0, double.infinity),
          (viewPadding.right - viewInsets.right).clamp(0.0, double.infinity),
          (viewPadding.bottom - viewInsets.bottom).clamp(0.0, double.infinity),
        );

        return MediaQuery(
          data: media.copyWith(
            viewPadding: viewPadding,
            padding: padding,
            viewInsets: viewInsets,
          ),
          child: child!,
        );
      },
    );
  }

  /// Combines the engine's own `viewInsets` with the browser measurement.
  ///
  /// The engine wins ties and wins outright whenever it reports more, so this
  /// can only ever *reveal* a keyboard the framework was blind to. Replacing
  /// the engine's value with a smaller one would be a regression on exactly
  /// the devices where it already works.
  static EdgeInsets _resolveViewInsets(MediaQueryData media, KeyboardInset keyboard) {
    final engine = media.viewInsets;
    if (keyboard.bottom <= engine.bottom) return engine;

    // The measurement is only meaningful if it was taken against the same
    // viewport height the framework is laying out into. When the browser
    // shrinks the layout viewport to make room for the keyboard, the Flutter
    // view has already been resized and the covered strip no longer exists —
    // subtracting it again would take the space twice. A mismatch here is the
    // signal for that, and the engine's number is the one to keep.
    if ((keyboard.referenceHeight - media.size.height).abs() > 1.0) return engine;

    return engine.copyWith(bottom: keyboard.bottom);
  }
}
