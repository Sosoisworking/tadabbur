import 'package:adhan_dart/adhan_dart.dart';

/// The calculation method + madhab pairing every prayer time in the app is
/// computed from. Bundled into one object so the choice lives in a single
/// named place instead of being spelled out at the call site.
class PrayerCalculationSettings {
  const PrayerCalculationSettings({required this.buildParameters, required this.madhab});

  /// A `CalculationMethodParameters` factory (e.g.
  /// `CalculationMethodParameters.muslimWorldLeague`) rather than a ready-made
  /// [CalculationParameters], because that object is mutable and gets a madhab
  /// written into it — sharing one instance would leak edits between callers.
  final CalculationParameters Function() buildParameters;

  final Madhab madhab;

  CalculationParameters resolve() => buildParameters()..madhab = madhab;
}

/// Muslim World League + Shafi madhab — the most globally common default
/// pairing. Changing the app-wide default is a one-line edit here; a future
/// per-user setting would override `prayerCalculationSettingsProvider`
/// instead of touching this constant.
const defaultPrayerCalculationSettings = PrayerCalculationSettings(
  buildParameters: CalculationMethodParameters.muslimWorldLeague,
  madhab: Madhab.shafi,
);
