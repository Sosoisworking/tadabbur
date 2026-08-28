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

  /// Builds from a [CalculationMethod] the user picked, which is all that
  /// can survive persistence — the factory itself is a function reference
  /// and can't be stored, so it's looked back up here.
  ///
  /// An unknown method falls back to the app default rather than throwing:
  /// the stored value comes from a previous launch, and a method adhan_dart
  /// later renames or drops would otherwise turn a stale preference into a
  /// crash on the Prayer tab.
  factory PrayerCalculationSettings.forMethod({
    required CalculationMethod method,
    required Madhab madhab,
  }) {
    return PrayerCalculationSettings(
      buildParameters: calculationMethodFactories[method] ?? CalculationMethodParameters.muslimWorldLeague,
      madhab: madhab,
    );
  }

  CalculationParameters resolve() => buildParameters()..madhab = madhab;
}

/// Every method adhan_dart ships, paired with its parameters factory —
/// the list the settings picker offers and the lookup a persisted choice
/// is restored through.
///
/// `CalculationMethod.other` is deliberately absent: it's adhan_dart's
/// escape hatch for hand-supplied angles, and offering "Other" to a user
/// with no angles to supply would be a dead option.
const Map<CalculationMethod, CalculationParameters Function()> calculationMethodFactories = {
  CalculationMethod.muslimWorldLeague: CalculationMethodParameters.muslimWorldLeague,
  CalculationMethod.ummAlQura: CalculationMethodParameters.ummAlQura,
  CalculationMethod.egyptian: CalculationMethodParameters.egyptian,
  CalculationMethod.karachi: CalculationMethodParameters.karachi,
  CalculationMethod.northAmerica: CalculationMethodParameters.northAmerica,
  CalculationMethod.moonsightingCommittee: CalculationMethodParameters.moonsightingCommittee,
  CalculationMethod.dubai: CalculationMethodParameters.dubai,
  CalculationMethod.gulfRegion: CalculationMethodParameters.gulfRegion,
  CalculationMethod.qatar: CalculationMethodParameters.qatar,
  CalculationMethod.kuwait: CalculationMethodParameters.kuwait,
  CalculationMethod.turkiye: CalculationMethodParameters.turkiye,
  CalculationMethod.jordan: CalculationMethodParameters.jordan,
  CalculationMethod.indonesian: CalculationMethodParameters.indonesian,
  CalculationMethod.singapore: CalculationMethodParameters.singapore,
  CalculationMethod.morocco: CalculationMethodParameters.morocco,
  CalculationMethod.algerian: CalculationMethodParameters.algerian,
  CalculationMethod.tunisia: CalculationMethodParameters.tunisia,
  CalculationMethod.france: CalculationMethodParameters.france,
  CalculationMethod.portugal: CalculationMethodParameters.portugal,
  CalculationMethod.russia: CalculationMethodParameters.russia,
  CalculationMethod.jafari: CalculationMethodParameters.jafari,
  CalculationMethod.tehran: CalculationMethodParameters.tehran,
};

/// Muslim World League + Shafi madhab — the most globally common default
/// pairing. Changing the app-wide default is a one-line edit here; a future
/// per-user setting would override `prayerCalculationSettingsProvider`
/// instead of touching this constant.
const defaultPrayerCalculationSettings = PrayerCalculationSettings(
  buildParameters: CalculationMethodParameters.muslimWorldLeague,
  madhab: Madhab.shafi,
);
