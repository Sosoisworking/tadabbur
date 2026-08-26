import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'keyboard_inset.dart';

/// Reads the CSS `env(safe-area-inset-*)` values the browser exposes, measures
/// the on-screen keyboard through `window.visualViewport`, and publishes both
/// so [DisplayInsets] can inject them into `MediaQuery`.
///
/// ## Why this file has to exist
///
/// Flutter Web never populates display insets. In
/// `flutter_web_sdk/lib/_engine/engine/window.dart` the view holds
/// `final ViewConfiguration _viewConfiguration = const ViewConfiguration();`
/// — a const that is never reassigned — and `viewPadding`, `padding` and
/// `systemGestureInsets` all read straight off it, so all three are
/// permanently `ViewPadding.zero`. Nothing in the entire web engine references
/// `safe-area-inset` (grep returns no files). The upshot is that `SafeArea`
/// is a no-op on web and `MediaQuery.viewPaddingOf` always returns zero —
/// on the target this app actually ships to, a home-screen PWA.
///
/// ## What the engine *does* do about the keyboard
///
/// `viewInsets` is the one inset the web engine is not blind to, and it is
/// deliberately *not* re-implemented here. Since Flutter 3.44 (checked against
/// the 3.44.8 SDK this app builds with) `window.dart` keeps `_viewInsets` in a
/// mutable field and recomputes it on every visual-viewport resize:
/// `_handleBrowserResize` holds `_physicalSize` stale while
/// `isMobile && textEditing.isEditing`, then
/// `FullPageDimensionsProvider.computeKeyboardInsets` returns
/// `stalePhysicalHeight - visualViewport.height` as the bottom inset.
///
/// So the engine already covers the case where a Flutter `TextField` has focus
/// and the engine's own hidden DOM input is what summoned the keyboard. What
/// it does not cover is everything outside that narrow gate: a keyboard raised
/// while `textEditing.isEditing` has not (yet) flipped, a browser the
/// `isMobile` sniff does not classify as mobile, or a resize the engine
/// misreads as a rotation. In those cases `viewInsets` stays zero while the
/// keyboard is very much on screen, `resizeToAvoidBottomInset` does nothing,
/// and a field near the bottom of a home-screen PWA cannot be scrolled clear.
///
/// The measurement below therefore *supplements* the engine rather than
/// replacing it: [DisplayInsets] takes the larger of the two, so this code can
/// only ever reveal a keyboard the framework was blind to, never shrink or
/// contradict one it already knew about.
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
  external int get clientHeight;
}

extension type _Document._(JSObject _) implements JSObject {
  external _Element? querySelector(String selectors);
  external _Element createElement(String tagName);
  external _Element? get body;
  external _Element? get documentElement;
}

extension type _VisualViewport._(JSObject _) implements JSObject {
  external double get height;
  external double get offsetTop;
  external double get scale;
  external void addEventListener(String type, JSFunction listener);
}

extension type _Window._(JSObject _) implements JSObject {
  external _CssStyle getComputedStyle(_Element element);
  external void addEventListener(String type, JSFunction listener);
  external _VisualViewport? get visualViewport;
}

@JS('document')
external _Document get _document;

@JS('window')
external _Window get _window;

final ValueNotifier<EdgeInsets> _insets = ValueNotifier(EdgeInsets.zero);

ValueListenable<EdgeInsets> get displayInsets => _insets;

final ValueNotifier<KeyboardInset> _keyboard = ValueNotifier(KeyboardInset.none);

ValueListenable<KeyboardInset> get keyboardInset => _keyboard;

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
  // Independent of the safe-area probe below, and started first: a phone with
  // no safe area at all (an older iPhone, most Android hardware) still has a
  // keyboard, and the probe failing must not take keyboard tracking down with
  // it.
  _startKeyboardTracking();

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

// ---------------------------------------------------------------------------
// On-screen keyboard
// ---------------------------------------------------------------------------

/// Subscribes to the visual viewport and publishes a keyboard inset whenever
/// it moves.
///
/// Degrades to doing nothing at all when `window.visualViewport` is missing
/// (Firefox < 91, Safari < 13), which leaves [keyboardInset] at
/// [KeyboardInset.none] forever and the app on exactly today's behaviour.
bool _keyboardTracked = false;

void _startKeyboardTracking() {
  // Idempotent: hot restart re-runs main, and there is no removeEventListener
  // pairing for these to be torn down by.
  if (_keyboardTracked) return;

  final viewport = _window.visualViewport;
  if (viewport == null) return;
  _keyboardTracked = true;

  void handler(JSAny _) => _keyboard.value = _measureKeyboardInset();

  // `resize` fires when the keyboard opens or closes. `scroll` matters
  // separately: iOS scrolls the visual viewport within the layout viewport to
  // bring a focused field above the keyboard, which moves `offsetTop` without
  // changing `height`.
  viewport.addEventListener('resize', handler.toJS);
  viewport.addEventListener('scroll', handler.toJS);

  _keyboard.value = _measureKeyboardInset();
}

/// Measures how much of the layout viewport's bottom edge is currently hidden.
///
/// The relationship, verified in a browser rather than assumed: the visual
/// viewport is a window onto the layout viewport, positioned at `offsetTop`
/// and `height` tall, so the layout-viewport y-coordinate of its bottom edge
/// is `offsetTop + height`, and everything below that is covered:
///
///     bottom = documentElement.clientHeight - offsetTop - height
///
/// Two things about that were checked directly (Chrome, mobile viewport) and
/// are the reason the formula is written this way:
///
///  * At rest the expression is exactly `0`, not merely small, and it stays
///    exactly `0` across viewport resizes. That matters more than the keyboard
///    case does: a formula that drifts a pixel or two would push the whole app
///    up permanently for a keyboard that is not there.
///  * `offsetTop` is *not* the page scroll offset — that is `pageTop`, which
///    tracks `window.scrollY` while `offsetTop` stays `0`. Subtracting
///    `offsetTop` therefore cannot accidentally subtract how far the user has
///    scrolled the document.
///
/// `documentElement.clientHeight` is the reference rather than
/// `window.innerHeight` because it is the same quantity the engine measures
/// the Flutter view against on iOS (`FullPageDimensionsProvider`
/// `.computePhysicalSize`), so the inset and `MediaQuery.size` are guaranteed
/// to be expressed against the same viewport there.
KeyboardInset _measureKeyboardInset() {
  final viewport = _window.visualViewport;
  final reference = _document.documentElement?.clientHeight.toDouble() ?? 0;
  if (viewport == null || !reference.isFinite || reference <= 0) {
    return KeyboardInset.none;
  }

  // Pinch-zoom shrinks the visual viewport in exactly the way a keyboard does,
  // and a zoomed page would otherwise read as a keyboard several hundred
  // pixels tall. A scaled viewport is simply not a measurement this can
  // interpret, so report no keyboard rather than a wrong one.
  final scale = viewport.scale;
  if (!scale.isFinite || (scale - 1).abs() > 0.01) {
    return KeyboardInset(bottom: 0, referenceHeight: reference);
  }

  return KeyboardInset(
    bottom: _keyboardPx(reference - viewport.offsetTop - viewport.height, reference),
    referenceHeight: reference,
  );
}

/// The keyboard-sized sibling of [_px]: refuses to trust a value that is not
/// physically plausible instead of feeding it into the layout.
double _keyboardPx(double value, double reference) {
  if (!value.isFinite || value < 1) {
    // Negative means the visual viewport is taller than the layout viewport
    // (scrollbar rounding, Safari toolbar transitions); sub-pixel means
    // rounding noise. Neither is a keyboard.
    return 0;
  }
  // No keyboard covers essentially the whole viewport. A reading that large
  // means the two heights are not describing the same box.
  if (value > reference * 0.9) return 0;
  return value;
}
