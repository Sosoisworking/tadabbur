import 'package:flutter/foundation.dart';

/// One on-screen-keyboard measurement, carried together with the viewport
/// height it was measured against.
///
/// The reference height is not incidental — it is what makes the measurement
/// safe to apply. A keyboard inset only means anything relative to a known
/// viewport, and browsers disagree about whether the keyboard shrinks the
/// layout viewport (Android Chrome's default `resizes-content`) or floats over
/// it (iOS). When the layout viewport shrinks, the Flutter view has already
/// been resized and the covered strip is gone rather than merely hidden;
/// injecting an inset on top of that would take the space away twice. Pairing
/// the number with the height it came from lets the consumer check that both
/// are talking about the same viewport before trusting it.
@immutable
class KeyboardInset {
  const KeyboardInset({required this.bottom, required this.referenceHeight});

  /// The reading that means "nothing measured", used before the first probe
  /// and on every platform that has no visual viewport to probe.
  static const KeyboardInset none = KeyboardInset(bottom: 0, referenceHeight: 0);

  /// Logical pixels of the viewport's bottom edge that the keyboard covers.
  final double bottom;

  /// The viewport height, in logical pixels, that [bottom] was measured
  /// against.
  final double referenceHeight;

  @override
  bool operator ==(Object other) =>
      other is KeyboardInset &&
      other.bottom == bottom &&
      other.referenceHeight == referenceHeight;

  @override
  int get hashCode => Object.hash(bottom, referenceHeight);

  @override
  String toString() =>
      'KeyboardInset(bottom: $bottom, referenceHeight: $referenceHeight)';
}
