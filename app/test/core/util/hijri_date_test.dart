import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur/core/util/hijri_date.dart';

void main() {
  // Fixed so the assertions describe a real conversion rather than
  // whatever today happens to be.
  final now = DateTime(2026, 8, 25);

  group('hijriToday', () {
    test('offsets of +1 and -1 land on the neighbouring Hijri days', () {
      final before = hijriToday(dayOffset: -1, now: now);
      final unshifted = hijriToday(dayOffset: 0, now: now);
      final after = hijriToday(dayOffset: 1, now: now);

      expect(unshifted, hijriToday(dayOffset: 0, now: now.subtract(const Duration(days: 0))));
      expect(before, hijriToday(dayOffset: 0, now: now.subtract(const Duration(days: 1))));
      expect(after, hijriToday(dayOffset: 0, now: now.add(const Duration(days: 1))));
      expect({before, unshifted, after}, hasLength(3));
    });

    test('shifts across a Hijri month boundary, not just the day number', () {
      // The last day of Safar 1448: +1 has to roll the month name over
      // rather than print a 31st.
      final endOfMonth = DateTime(2026, 8, 13);

      expect(hijriToday(dayOffset: 0, now: endOfMonth), contains('Safar'));
      expect(hijriToday(dayOffset: 1, now: endOfMonth), startsWith('1 '));
      expect(hijriToday(dayOffset: 1, now: endOfMonth), isNot(contains('Safar')));
    });
  });

  group('hijriTodayShort', () {
    test('drops the year but still honours the offset', () {
      final unshifted = hijriTodayShort(dayOffset: 0, now: now);
      final after = hijriTodayShort(dayOffset: 1, now: now);

      expect(unshifted, isNot(contains('144')));
      expect(after, isNot(unshifted));
      expect(after, hijriTodayShort(dayOffset: 0, now: now.add(const Duration(days: 1))));
    });
  });

  group('hijriDayOffsetProvider', () {
    test('defaults to no correction', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(hijriDayOffsetProvider), 0);
    });

    test('an override reaches the rendered date', () {
      // The seam a settings screen would use: nothing else has to change
      // for every Hijri date in the app to shift.
      final container = ProviderContainer(
        overrides: [hijriDayOffsetProvider.overrideWithValue(1)],
      );
      addTearDown(container.dispose);

      final offset = container.read(hijriDayOffsetProvider);

      expect(hijriToday(dayOffset: offset, now: now), hijriToday(dayOffset: 0, now: now.add(const Duration(days: 1))));
    });
  });
}
