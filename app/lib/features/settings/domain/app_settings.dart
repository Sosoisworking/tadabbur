import 'package:adhan_dart/adhan_dart.dart';

import '../../prayer_times/domain/prayer_calculation_settings.dart';

/// Everything the Settings screen can change, as one immutable value.
///
/// Deliberately *not* the same object as [PrayerCalculationSettings]: that
/// one carries a parameters factory and exists to be handed to adhan_dart,
/// while this one has to survive a round trip through shared_preferences,
/// which can only store the enum name. Keeping them apart is what lets the
/// stored form stay a pair of strings while the computed form stays a
/// ready-to-resolve factory.
class AppSettings {
  const AppSettings({
    required this.hijriDayOffset,
    required this.calculationMethod,
    required this.madhab,
  });

  /// Days to shift the tabular Hijri conversion by — see
  /// `hijriDayOffsetProvider`, the seam this feeds.
  final int hijriDayOffset;

  final CalculationMethod calculationMethod;

  /// Only affects Asr: shafi at one shadow length, hanafi at two.
  final Madhab madhab;

  /// The correction is a moon-sighting discrepancy, which is at most a day
  /// in either direction in practice. ±2 leaves room for a locale that
  /// announces late without turning the control into a free-form date
  /// picker, which would let a user silently put every Hijri date in the
  /// app a month out.
  static const int minHijriDayOffset = -2;
  static const int maxHijriDayOffset = 2;

  /// Matches [defaultPrayerCalculationSettings] — pinned by a test rather
  /// than by a comment, since the two are declared in different files and
  /// nothing about the types would catch them drifting apart.
  static const AppSettings defaults = AppSettings(
    hijriDayOffset: 0,
    calculationMethod: CalculationMethod.muslimWorldLeague,
    madhab: Madhab.shafi,
  );

  /// The prayer-calculation half of these settings in the form adhan_dart
  /// wants. Resolved on demand rather than stored, so the mutable
  /// [CalculationParameters] this eventually produces is never shared.
  PrayerCalculationSettings get prayerCalculation =>
      PrayerCalculationSettings.forMethod(method: calculationMethod, madhab: madhab);

  AppSettings copyWith({
    int? hijriDayOffset,
    CalculationMethod? calculationMethod,
    Madhab? madhab,
  }) {
    return AppSettings(
      hijriDayOffset: hijriDayOffset ?? this.hijriDayOffset,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.hijriDayOffset == hijriDayOffset &&
      other.calculationMethod == calculationMethod &&
      other.madhab == madhab;

  @override
  int get hashCode => Object.hash(hijriDayOffset, calculationMethod, madhab);
}
