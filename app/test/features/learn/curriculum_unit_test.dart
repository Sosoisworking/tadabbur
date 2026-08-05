import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur/features/learn/domain/curriculum_unit.dart';

void main() {
  group('UnitStatus.fromDb', () {
    test('maps known db values correctly', () {
      expect(UnitStatus.fromDb('in_progress'), UnitStatus.inProgress);
      expect(UnitStatus.fromDb('completed'), UnitStatus.completed);
      expect(UnitStatus.fromDb('mastered'), UnitStatus.mastered);
      expect(UnitStatus.fromDb('locked'), UnitStatus.locked);
    });

    test('defaults to locked for null/unknown values', () {
      // A unit with no user_unit_progress row at all (the common case for
      // a unit the user hasn't reached yet) must read as locked, not throw.
      expect(UnitStatus.fromDb('something_unexpected'), UnitStatus.locked);
    });
  });

  group('CurriculumUnit.fromJson', () {
    test('parses a well-formed row', () {
      final unit = CurriculumUnit.fromJson({
        'id': 1,
        'title': 'Al-Fatiha',
        'sequence_order': 1,
        'status': 'in_progress',
      });

      expect(unit.id, 1);
      expect(unit.title, 'Al-Fatiha');
      expect(unit.status, UnitStatus.inProgress);
    });

    test('defaults status to locked when absent (no progress row yet)', () {
      final unit = CurriculumUnit.fromJson({
        'id': 2,
        'title': 'An-Nas',
        'sequence_order': 2,
      });

      expect(unit.status, UnitStatus.locked);
    });
  });
}
