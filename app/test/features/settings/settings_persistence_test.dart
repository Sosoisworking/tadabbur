// The Settings screen is only worth anything if a change (a) survives the
// next launch and (b) actually reaches the providers every other screen
// reads. These pin both ends of that, not just the store round trip —
// a saved offset that never reaches `hijriDayOffsetProvider` would pass a
// storage-only test and still do nothing on screen.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tadabbur/core/util/hijri_date.dart';
import 'package:tadabbur/features/prayer_times/domain/manual_city.dart';
import 'package:tadabbur/features/prayer_times/domain/prayer_calculation_settings.dart';
import 'package:tadabbur/features/prayer_times/presentation/providers/prayer_times_providers.dart';
import 'package:tadabbur/features/settings/data/settings_repository.dart';
import 'package:tadabbur/features/settings/domain/app_settings.dart';
import 'package:tadabbur/features/settings/presentation/providers/settings_providers.dart';

/// A container wired exactly as `main.dart` wires the app, so these tests
/// exercise the real override list rather than a parallel arrangement
/// that could pass while the app's own wiring is broken.
ProviderContainer _container() {
  final container = ProviderContainer(overrides: settingsOverrides);
  addTearDown(container.dispose);
  return container;
}

/// The store resolves asynchronously; until it does the controller
/// reports defaults. Awaiting it is the "app has finished launching"
/// point.
Future<ProviderContainer> _launched() async {
  final container = _container();
  await container.read(appSettingsStoreProvider.future);
  return container;
}

/// Fixed so the assertions describe a real conversion rather than
/// whatever today happens to be.
final _now = DateTime(2026, 8, 25);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AppSettings.defaults', () {
    test('agrees with the prayer feature\'s own default pairing', () {
      // Declared in two files with nothing in the type system tying them
      // together, so a change to one that forgets the other would
      // silently make a fresh install disagree with itself.
      final fromSettings = AppSettings.defaults.prayerCalculation.resolve();
      final fromPrayerFeature = defaultPrayerCalculationSettings.resolve();

      expect(fromSettings.method, fromPrayerFeature.method);
      expect(fromSettings.madhab, fromPrayerFeature.madhab);
      expect(AppSettings.defaults.hijriDayOffset, 0);
    });
  });

  group('hijri day offset', () {
    test('a change reaches hijriDayOffsetProvider and the rendered date', () async {
      final container = await _launched();
      expect(container.read(hijriDayOffsetProvider), 0);

      await container.read(appSettingsProvider.notifier).setHijriDayOffset(1);

      expect(container.read(hijriDayOffsetProvider), 1);
      expect(
        hijriToday(dayOffset: container.read(hijriDayOffsetProvider), now: _now),
        hijriToday(dayOffset: 0, now: _now.add(const Duration(days: 1))),
      );
    });

    test('survives a relaunch', () async {
      final first = await _launched();
      await first.read(appSettingsProvider.notifier).setHijriDayOffset(-1);

      // A second container over the same preferences is what the next
      // cold start actually looks like.
      final second = await _launched();

      expect(second.read(hijriDayOffsetProvider), -1);
      expect(second.read(appSettingsProvider).hijriDayOffset, -1);
    });

    test('is clamped to the supported correction range', () async {
      final container = await _launched();

      await container.read(appSettingsProvider.notifier).setHijriDayOffset(9);
      expect(container.read(hijriDayOffsetProvider), AppSettings.maxHijriDayOffset);

      await container.read(appSettingsProvider.notifier).setHijriDayOffset(-9);
      expect(container.read(hijriDayOffsetProvider), AppSettings.minHijriDayOffset);
    });
  });

  group('prayer calculation', () {
    test('a madhab change reaches prayerCalculationSettingsProvider and moves Asr', () async {
      final container = await _launched();
      final coordinates = defaultCity.coordinates;
      final date = DateTime(2026, 8, 25);

      final shafiAsr = PrayerTimes(
        date: date,
        coordinates: coordinates,
        calculationParameters: container.read(prayerCalculationSettingsProvider).resolve(),
      ).timeForPrayer(Prayer.asr);

      await container.read(appSettingsProvider.notifier).setMadhab(Madhab.hanafi);

      final resolved = container.read(prayerCalculationSettingsProvider).resolve();
      expect(resolved.madhab, Madhab.hanafi);

      final hanafiAsr = PrayerTimes(
        date: date,
        coordinates: coordinates,
        calculationParameters: resolved,
      ).timeForPrayer(Prayer.asr);

      // Hanafi waits for a second shadow length, so Asr is strictly later
      // — the setting is doing real work, not just being stored.
      expect(hanafiAsr.isAfter(shafiAsr), isTrue);
    });

    test('a method change reaches the provider and moves Fajr', () async {
      final container = await _launched();
      final coordinates = defaultCity.coordinates;
      final date = DateTime(2026, 8, 25);

      final defaultFajr = PrayerTimes(
        date: date,
        coordinates: coordinates,
        calculationParameters: container.read(prayerCalculationSettingsProvider).resolve(),
      ).timeForPrayer(Prayer.fajr);

      await container.read(appSettingsProvider.notifier).setCalculationMethod(CalculationMethod.egyptian);

      final resolved = container.read(prayerCalculationSettingsProvider).resolve();
      expect(resolved.method, CalculationMethod.egyptian);

      final egyptianFajr = PrayerTimes(
        date: date,
        coordinates: coordinates,
        calculationParameters: resolved,
      ).timeForPrayer(Prayer.fajr);

      // Egypt uses a steeper Fajr angle (19.5° vs the Muslim World
      // League's 18°), which puts Fajr earlier.
      expect(egyptianFajr.isBefore(defaultFajr), isTrue);
    });

    test('hands out a fresh parameters object per read, even after a change', () async {
      final container = await _launched();
      await container.read(appSettingsProvider.notifier).setMadhab(Madhab.hanafi);

      final first = container.read(prayerCalculationSettingsProvider).resolve();
      final second = container.read(prayerCalculationSettingsProvider).resolve();
      first.madhab = Madhab.shafi;

      expect(second.madhab, Madhab.hanafi);
    });

    test('survives a relaunch', () async {
      final first = await _launched();
      await first.read(appSettingsProvider.notifier).setCalculationMethod(CalculationMethod.karachi);
      await first.read(appSettingsProvider.notifier).setMadhab(Madhab.hanafi);

      final second = await _launched();
      final resolved = second.read(prayerCalculationSettingsProvider).resolve();

      expect(resolved.method, CalculationMethod.karachi);
      expect(resolved.madhab, Madhab.hanafi);
    });
  });

  group('stored values that can\'t be trusted', () {
    test('fall back to the defaults instead of throwing at launch', () async {
      // What an older build, a hand-edited store, or a renamed adhan_dart
      // method leaves behind. The cost of getting this wrong is a blank
      // app at startup, not a wrong setting.
      SharedPreferences.setMockInitialValues({
        'settings_hijri_day_offset': 47,
        'settings_prayer_calculation_method': 'no_such_method',
        'settings_prayer_madhab': 'maliki',
      });

      final container = await _launched();
      final settings = container.read(appSettingsProvider);

      expect(settings.hijriDayOffset, AppSettings.maxHijriDayOffset);
      expect(settings.calculationMethod, AppSettings.defaults.calculationMethod);
      expect(settings.madhab, AppSettings.defaults.madhab);
    });
  });

  group('the method picker\'s catalogue', () {
    test('every offered method resolves to its own parameters', () {
      for (final entry in calculationMethodFactories.entries) {
        final resolved = PrayerCalculationSettings.forMethod(
          method: entry.key,
          madhab: Madhab.shafi,
        ).resolve();

        expect(resolved.method, entry.key, reason: '${entry.key.name} is wired to the wrong factory');
      }
    });

    test('an unknown method falls back rather than throwing', () {
      final resolved = PrayerCalculationSettings.forMethod(
        method: CalculationMethod.other,
        madhab: Madhab.shafi,
      ).resolve();

      expect(resolved.method, CalculationMethod.muslimWorldLeague);
    });
  });
}
