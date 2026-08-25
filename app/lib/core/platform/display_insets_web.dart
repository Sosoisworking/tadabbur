import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Reads the CSS `env(safe-area-inset-*)` values the browser exposes and
/// publishes them so [DisplayInsets] can inject them into `MediaQuery`.
///
/// ## Why this file has to exist
///
/// Flutter Web never populates display insets. In
/// `flutter_web_sdk/lib/_engine/engine/window.dart` the view holds
/// `final ViewConfiguration _viewConfiguration = const ViewConfiguration();`
/// — a const that is never reassigned — and `viewPadding`, `padding` and
/// `systemGestureInsets` all read straight off it, so all three are
/// permanently `ViewPadding.zero`. `_viewInsets` is separately pinned to
/// `ui.ViewPadding.zero`. Nothing in the entire web engine references
/// `safe-area-inset` (grep returns no files). The upshot is that `SafeArea`
/// is a no-op on web and `MediaQuery.viewPaddingOf` always returns zero —
/// on the target this app actually ships to, a home-screen PWA.
///
/// ## Why the top inset is deliberately not relied upon
///
/// `env()` only reports non-zero once `viewport-fit=cover` is active, and
/// the engine rewrites the viewport `<meta>` on boot without it (see
/// `full_page_embedding_strategy.dart#_applyViewportMeta`), so cover has to
/// be re-applied from Dart after boot. That much is revertible.
///
/// The *top* inset is not. web/index.html sets
/// `apple-mobile-web-app-status-bar-style: black`, which makes iOS start the
/// web view below an opaque status-bar band — the Dynamic Island is masked
/// by iOS itself, and `env(safe-area-inset-top)` is correspondingly 0.
/// Getting a real top inset would mean switching to `black-translucent`,
/// which iOS reads *once, at launch, from the cached home-screen bookmark*
/// and which JavaScript cannot revert at runtime. Shipping that would make
/// "is my header under the Dynamic Island?" depend entirely on this probe
/// succeeding on every future iOS version, with no fallback — so it is not
/// shipped. The Island stays protected by iOS, not by this code, and this
/// file only ever *adds* insets that were previously zero.
///
/// The failure mode is therefore bounded: if the probe reads nothing, the
/// viewport is put back exactly as it was and the app behaves as it does
/// today.

extension type _CssStyle._(JSObject _) implements JSObject {
  external void setProperty(String property, String value);
  external String getPropertyValue(String property);
}

extension type _Element._(JSObject _) implements JSObject {
  external _CssStyle get style;
  external String? getAttribute(String name);
  external void setAttribute(String name, String value);
  external void appendChild(_Element child);
  external void remove();
}

extension type _Document._(JSObject _) implements JSObject {
  external _Element? querySelector(String selectors);
  external _Element createElement(String tagName);
  external _Element? get body;
}

extension type _Window._(JSObject _) implements JSObject {
  external _CssStyle getComputedStyle(_Element element);
  external void addEventListener(String type, JSFunction listener);
}

@JS('document')
external _Document get _document;

@JS('window')
external _Window get _window;

final ValueNotifier<EdgeInsets> _insets = ValueNotifier(EdgeInsets.zero);

ValueListenable<EdgeInsets> get displayInsets => _insets;

/// The viewport `<meta>` content string exactly as the engine wrote it, kept
/// so a failed probe can put it back byte-for-byte.
String? _originalViewportContent;

/// Each probe waits at most this long for the browser to settle the layout
/// viewport after `viewport-fit=cover` goes in. Safari updates the visual
/// viewport a frame or two after the meta changes, so an immediate read can
/// legitimately still be zero.
const _probeSchedule = <Duration>[
  Duration.zero,
  Duration(milliseconds: 20),
  Duration(milliseconds: 60),
  Duration(milliseconds: 150),
];

/// Applies `viewport-fit=cover`, probes `env(safe-area-inset-*)`, and either
/// keeps cover (insets found) or restores the original viewport (none found).
///
/// Called before `runApp` so the first frame is never painted edge-to-edge
/// without insets already in hand — there is no window in which content can
/// flash underneath the home indicator.
Future<void> initDisplayInsets() async {
  final meta = _document.querySelector('meta[name="viewport"]');
  if (meta == null) return;

  _originalViewportContent = meta.getAttribute('content');
  _applyViewportFitCover(meta);

  for (final delay in _probeSchedule) {
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    final measured = _probe();
    if (measured != EdgeInsets.zero) {
      _insets.value = measured;
      _listenForChanges();
      return;
    }
  }

  // Nothing to inset against — desktop, Android without cutouts, or a
  // browser that does not implement env(). Put the viewport back so the
  // layout is byte-for-byte what it was before this ran.
  final original = _originalViewportContent;
  if (original != null) meta.setAttribute('content', original);
}

void _applyViewportFitCover(_Element meta) {
  final content = meta.getAttribute('content') ?? '';
  if (content.contains('viewport-fit')) return;
  meta.setAttribute(
    'content',
    content.isEmpty ? 'viewport-fit=cover' : '$content, viewport-fit=cover',
  );
}

/// Re-probes on anything that can change the safe area: rotation, window
/// resize, and Safari's URL-bar show/hide (which fires resize).
void _listenForChanges() {
  void handler(JSAny _) {
    // The engine re-runs _applyViewportMeta on hot restart, which would drop
    // the cover flag; re-asserting it here is cheap and idempotent.
    final meta = _document.querySelector('meta[name="viewport"]');
    if (meta != null) _applyViewportFitCover(meta);

    final measured = _probe();
    if (measured != EdgeInsets.zero) _insets.value = measured;
  }

  _window.addEventListener('resize', handler.toJS);
  _window.addEventListener('orientationchange', handler.toJS);
}

/// Measures the safe area by letting the browser resolve `env()` into a
/// throwaway element's padding, then reading it back computed.
///
/// The `var(--tadabbur-safe-area-inset-*)` layer in front of each `env()` is
/// an override hook: setting those custom properties on `:root` forces known
/// inset values, which is how this plumbing is exercised end to end in a
/// browser that has no physical safe area of its own.
EdgeInsets _probe() {
  final body = _document.body;
  if (body == null) return EdgeInsets.zero;

  final probe = _document.createElement('div');
  probe.style
    ..setProperty('position', 'fixed')
    ..setProperty('top', '0')
    ..setProperty('left', '0')
    ..setProperty('width', '0')
    ..setProperty('height', '0')
    ..setProperty('visibility', 'hidden')
    ..setProperty('pointer-events', 'none')
    ..setProperty('padding-top', 'var(--tadabbur-safe-area-inset-top, env(safe-area-inset-top, 0px))')
    ..setProperty('padding-right', 'var(--tadabbur-safe-area-inset-right, env(safe-area-inset-right, 0px))')
    ..setProperty('padding-bottom', 'var(--tadabbur-safe-area-inset-bottom, env(safe-area-inset-bottom, 0px))')
    ..setProperty('padding-left', 'var(--tadabbur-safe-area-inset-left, env(safe-area-inset-left, 0px))');

  body.appendChild(probe);
  final computed = _window.getComputedStyle(probe);
  final result = EdgeInsets.fromLTRB(
    _px(computed.getPropertyValue('padding-left')),
    _px(computed.getPropertyValue('padding-top')),
    _px(computed.getPropertyValue('padding-right')),
    _px(computed.getPropertyValue('padding-bottom')),
  );
  probe.remove();

  // env() is reported in CSS pixels, which is the same unit Flutter Web uses
  // for logical pixels, so no devicePixelRatio conversion is needed.
  return result;
}

double _px(String value) {
  final parsed = double.tryParse(value.replaceAll('px', '').trim()) ?? 0;
  // Guard against a browser handing back something absurd (or negative)
  // rather than trusting it into the layout.
  return parsed.isFinite && parsed >= 0 && parsed < 200 ? parsed : 0;
}
