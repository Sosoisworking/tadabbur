import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'display_insets_none.dart' if (dart.library.js_interop) 'display_insets_web.dart' as impl;

/// Prepares real display insets on platforms where the engine does not
/// supply them. A no-op everywhere except web — see display_insets_web.dart
/// for why web needs it and what it deliberately does not attempt.
///
/// Await this before `runApp`: on web it may switch the page to
/// `viewport-fit=cover`, and the first frame must not be painted
/// edge-to-edge before the matching insets exist.
Future<void> initDisplayInsets() => impl.initDisplayInsets();

/// Injects [initDisplayInsets]'s measurements into the `MediaQuery` that
/// `SafeArea`, `MediaQuery.paddingOf` and `MediaQuery.viewPaddingOf` read.
///
/// Belongs in `MaterialApp.builder`, not above the app: `MaterialApp`
/// installs its own `MediaQuery.fromView`, which would overwrite anything
/// wrapped around it.
///
/// Returns [child] untouched on native (where the engine already reports
/// insets, so overriding would double-apply them) and on any web page whose
/// safe area measured zero.
class DisplayInsets extends StatelessWidget {
  const DisplayInsets({super.key, required this.child, this.source});

  final Widget child;

  /// Overrides where the insets come from. Production leaves this null and
  /// takes the platform's own source; supplying a listenable lets the
  /// injection be exercised on a platform that has no safe area to measure.
  @visibleForTesting
  final ValueListenable<EdgeInsets>? source;

  @override
  Widget build(BuildContext context) {
    final source = this.source ?? impl.displayInsets;
    if (source == null) return child;

    return ValueListenableBuilder<EdgeInsets>(
      valueListenable: source,
      child: child,
      builder: (context, insets, child) {
        if (insets == EdgeInsets.zero) return child!;

        final media = MediaQuery.of(context);
        // `padding` is `viewPadding` with anything the keyboard has already
        // covered removed, which is the invariant the framework maintains on
        // native and which SafeArea depends on. Web reports zero viewInsets
        // today (window.dart pins _viewInsets to ViewPadding.zero), so this
        // is currently a subtraction of nothing — but deriving it rather
        // than assigning `insets` to both keeps it correct if the engine
        // ever starts reporting a keyboard.
        final viewInsets = media.viewInsets;
        final padding = EdgeInsets.fromLTRB(
          (insets.left - viewInsets.left).clamp(0.0, double.infinity),
          (insets.top - viewInsets.top).clamp(0.0, double.infinity),
          (insets.right - viewInsets.right).clamp(0.0, double.infinity),
          (insets.bottom - viewInsets.bottom).clamp(0.0, double.infinity),
        );

        return MediaQuery(
          data: media.copyWith(viewPadding: insets, padding: padding),
          child: child!,
        );
      },
    );
  }
}
