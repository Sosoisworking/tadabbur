import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../prayer_times/domain/prayer_calculation_settings.dart';
import '../domain/app_settings.dart';

/// Persists the Settings screen's choices, following the same
/// shared_preferences shape as `PrayerLocationStore` — flat primitive keys
/// rather than a serialized blob, so a single added setting can't fail to
/// parse the ones already stored.
///
/// Every read is defensive. The values come from a previous launch of a
/// possibly older build, and a preference that can't be understood has an
/// obvious right answer (the default) — falling back beats throwing during
/// startup, where the failure would surface as a blank app rather than a
/// wrong setting.
class AppSettingsStore {
  AppSettingsStore(this._prefs);

  static const _hijriDayOffsetKey = 'settings_hijri_day_offset';
  static const _calculationMethodKey = 'settings_prayer_calculation_method';
  static const _madhabKey = 'settings_prayer_madhab';

  final SharedPreferences _prefs;

  AppSettings read() {
    return AppSettings(
      hijriDayOffset: _readHijriDayOffset(),
      calculationMethod: _readEnum(
        _calculationMethodKey,
        // Only the methods the picker actually offers are restorable — a
        // key holding anything else (hand-edited, or written by a build
        // that offered more) reverts to the default.
        calculationMethodFactories.keys,
        AppSettings.defaults.calculationMethod,
      ),
      madhab: _readEnum(_madhabKey, Madhab.values, AppSettings.defaults.madhab),
    );
  }

  Future<void> saveHijriDayOffset(int offset) =>
      _prefs.setInt(_hijriDayOffsetKey, _clampOffset(offset));

  Future<void> saveCalculationMethod(CalculationMethod method) =>
      _prefs.setString(_calculationMethodKey, method.name);

  Future<void> saveMadhab(Madhab madhab) => _prefs.setString(_madhabKey, madhab.name);

  int _readHijriDayOffset() {
    final stored = _prefs.getInt(_hijriDayOffsetKey);
    if (stored == null) return AppSettings.defaults.hijriDayOffset;
    return _clampOffset(stored);
  }

  static int _clampOffset(int offset) =>
      offset.clamp(AppSettings.minHijriDayOffset, AppSettings.maxHijriDayOffset);

  T _readEnum<T extends Enum>(String key, Iterable<T> values, T fallback) {
    final stored = _prefs.getString(key);
    if (stored == null) return fallback;
    for (final value in values) {
      if (value.name == stored) return value;
    }
    return fallback;
  }
}

/// Separate from the prayer feature's own SharedPreferences provider on
/// purpose: `SharedPreferences.getInstance()` hands back the same
/// instance either way, and duplicating the one-line future keeps this
/// feature from importing the prayer feature's data layer for plumbing.
final _sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final appSettingsStoreProvider = FutureProvider<AppSettingsStore>((ref) async {
  return AppSettingsStore(await ref.watch(_sharedPreferencesProvider.future));
});
