import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur/features/learn/data/curriculum_repository.dart';

/// The streak figure is derived, not stored (see CurriculumRepository) —
/// which makes its calendar edge cases the only place it can go wrong, and
/// they're invisible in the UI until a user complains that a streak they
/// earned disappeared.
void main() {
  Set<DateTime> days(List<DateTime> values) =>
      values.map(CurriculumRepository.dayOf).toSet();

  final now = DateTime(2026, 8, 24, 14, 30);
  DateTime daysAgo(int n) => DateTime(2026, 8, 24 - n);

  group('streakFromActiveDays', () {
    test('no activity is no streak', () {
      expect(CurriculumRepository.streakFromActiveDays({}, now), 0);
    });

    test('counts a run ending today', () {
      final active = days([daysAgo(0), daysAgo(1), daysAgo(2)]);
      expect(CurriculumRepository.streakFromActiveDays(active, now), 3);
    });

    test('a run ending yesterday still counts, so the streak does not reset at midnight', () {
      final active = days([daysAgo(1), daysAgo(2)]);
      expect(CurriculumRepository.streakFromActiveDays(active, now), 2);
    });

    test('a gap of a full day ends the run', () {
      // Practised today, then nothing yesterday — the older run is over.
      final active = days([daysAgo(0), daysAgo(2), daysAgo(3)]);
      expect(CurriculumRepository.streakFromActiveDays(active, now), 1);
    });

    test('activity that stopped before yesterday is not a live streak', () {
      final active = days([daysAgo(2), daysAgo(3), daysAgo(4)]);
      expect(CurriculumRepository.streakFromActiveDays(active, now), 0);
    });

    test('several attempts on one day count once, not once each', () {
      final active = days([
        DateTime(2026, 8, 24, 9),
        DateTime(2026, 8, 24, 18),
        DateTime(2026, 8, 23, 12),
      ]);
      expect(CurriculumRepository.streakFromActiveDays(active, now), 2);
    });

    test('walks back across a month boundary', () {
      final septNow = DateTime(2026, 9, 2, 8);
      final active = days([
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 1),
        DateTime(2026, 8, 31),
        DateTime(2026, 8, 30),
      ]);
      expect(CurriculumRepository.streakFromActiveDays(active, septNow), 4);
    });
  });

  group('dayOf', () {
    test('collapses any instant to local midnight', () {
      expect(
        CurriculumRepository.dayOf(DateTime(2026, 8, 24, 23, 59, 59)),
        DateTime(2026, 8, 24),
      );
    });

    test('stepping back a day stays on midnight even when the day is not 24h', () {
      // 2026-10-25 is the UK DST fall-back (a 25-hour day). Subtracting a
      // flat 24h from midnight the 26th lands at 01:00 the 25th; without
      // re-normalizing, that never matches a midnight-bucketed entry and
      // the streak ends a day early.
      final stepped = CurriculumRepository.dayOf(
        DateTime(2026, 10, 26).subtract(const Duration(days: 1)),
      );
      expect(stepped, DateTime(2026, 10, 25));
    });
  });
}
