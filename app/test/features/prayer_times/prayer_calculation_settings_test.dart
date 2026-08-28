import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur/features/prayer_times/domain/prayer_calculation_settings.dart';

void main() {
  group('defaultPrayerCalculationSettings', () {
    test('resolves to Muslim World League with the Shafi madhab', () {
      final params = defaultPrayerCalculationSettings.resolve();

      expect(params.method, CalculationMethod.muslimWorldLeague);
      expect(params.madhab, Madhab.shafi);
    });

    test('hands out a fresh parameters object each call', () {
      // CalculationParameters is mutable and the madhab is written into it,
      // so a shared instance would let one caller's edit reach another's
      // prayer times.
      final first = defaultPrayerCalculationSettings.resolve();
      final second = defaultPrayerCalculationSettings.resolve();

      first.madhab = Madhab.hanafi;

      expect(second.madhab, Madhab.shafi);
    });
  });
}
