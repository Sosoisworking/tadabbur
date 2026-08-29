// The Learn tab is the other half of the text-scale regression story:
// its unit carousel is a fixed-height strip and its cards are a fixed
// width, so a large text setting has nowhere to grow into except out of
// the layout. Fixed-height containers clipping at large text has been a
// real bug class on this screen, hence the 2.0x pass at the bottom.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/features/learn/data/curriculum_repository.dart';
import 'package:tadabbur/features/learn/data/lesson_repository.dart';
import 'package:tadabbur/features/learn/domain/curriculum_unit.dart';
import 'package:tadabbur/features/learn/domain/lesson.dart';
import 'package:tadabbur/features/learn/domain/lesson_exercise.dart';
import 'package:tadabbur/features/learn/presentation/screens/learn_screen.dart';

/// Only fetchLessonsForUnit is exercised here — the Learn tab reads
/// lessons through lessonsForUnitProvider, and nothing on this screen
/// writes.
class _FakeLessonRepository implements LessonRepository {
  _FakeLessonRepository(this.lessons);

  final Map<int, List<Lesson>> lessons;

  @override
  Future<List<Lesson>> fetchLessonsForUnit(int unitId) async => lessons[unitId] ?? const [];

  @override
  Future<List<LessonExercise>> fetchExercisesForLesson(int lessonId) async => const [];

  @override
  Future<int> startLessonAttempt(int lessonId) async => 1;

  @override
  Future<void> recordExerciseAttempt({
    required int lessonAttemptId,
    required int exerciseId,
    required bool isCorrect,
  }) async {}

  @override
  Future<void> completeLessonAttempt({
    required int lessonAttemptId,
    required int unitId,
    required int correctCount,
    required int totalCount,
  }) async {}
}

const _units = [
  CurriculumUnit(
    id: 1,
    title: 'The Arabic Alphabet',
    sequenceOrder: 1,
    status: UnitStatus.inProgress,
    lessonCount: 4,
    completedLessonCount: 1,
    minutesRemaining: 18,
  ),
  CurriculumUnit(
    id: 2,
    title: 'Al-Fatiha',
    sequenceOrder: 2,
    status: UnitStatus.completed,
    lessonCount: 2,
    completedLessonCount: 2,
    minutesRemaining: 0,
  ),
];

final _lessons = {
  1: const [
    Lesson(id: 11, title: 'Alif, Ba, Ta', sequenceOrder: 1, estimatedMinutes: 6, isCompleted: true),
    Lesson(id: 12, title: 'Fathah Quiz', sequenceOrder: 2, estimatedMinutes: 4),
  ],
  2: const [
    Lesson(id: 21, title: 'The Opening', sequenceOrder: 1, estimatedMinutes: 9),
  ],
};

/// curriculumUnitsProvider and streakDaysProvider are overridden directly
/// rather than through CurriculumRepository: both watch authStateProvider,
/// which resolves the real Supabase client and would throw in a test.
Future<void> _pumpLearn(WidgetTester tester, {double textScale = 1.0}) async {
  tester.view.physicalSize = const Size(480, 920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  const screen = LearnScreen();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        curriculumUnitsProvider.overrideWith((ref) async => _units),
        streakDaysProvider.overrideWith((ref) async => 5),
        lessonRepositoryProvider.overrideWithValue(_FakeLessonRepository(_lessons)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: textScale == 1.0
            ? screen
            : MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: screen,
              ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('renders the unit carousel, the streak, and the selected unit lessons', (tester) async {
    await _pumpLearn(tester);

    expect(find.text('The Arabic Alphabet'), findsWidgets);
    expect(find.text('Al-Fatiha'), findsOneWidget);
    expect(find.text('5'), findsOneWidget); // streak ring
    expect(find.text('DAYS'), findsOneWidget);

    // The first unit is selected by default, so its lessons are listed.
    expect(find.text('Alif, Ba, Ta'), findsOneWidget);
    expect(find.text('Fathah Quiz'), findsOneWidget);
    expect(find.text('The Opening'), findsNothing);
    // A completed unit drops the "min left" half of its meta line.
    expect(find.text('1/4 lessons · 18 min left'), findsOneWidget);
    expect(find.text('2 lessons'), findsOneWidget);
  });

  testWidgets('tapping a unit card swaps the lesson list under it', (tester) async {
    await _pumpLearn(tester);

    await tester.tap(find.text('Al-Fatiha'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('The Opening'), findsOneWidget);
    expect(find.text('Alif, Ba, Ta'), findsNothing);
  });

  testWidgets('lays out at 2.0x text scale without overflowing', (tester) async {
    // The carousel strip and the streak ring both scale with the user's
    // text size (clamped), and the unit card's title is Flexible so it
    // ellipsizes rather than pushing the progress bar out the bottom.
    await _pumpLearn(tester, textScale: 2.0);

    expect(tester.takeException(), isNull);

    // Scrolling forces the offscreen slivers to lay out too — an overflow
    // anywhere below the fold fails the test by throwing.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // ...and the horizontal carousel, which is the fixed-height strip.
    await tester.drag(find.byType(ListView), const Offset(-300, 0));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  group('completed lessons', () {
    testWidgets('a finished lesson reads as completed, an unfinished one shows its length', (tester) async {
      await _pumpLearn(tester);

      // The point of the marker is scanning: the finished row must not still
      // advertise a duration as though it were work left to do.
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('6 min'), findsNothing);
      expect(find.text('4 min'), findsOneWidget);
    });

    testWidgets('the completed row is marked with a tick', (tester) async {
      await _pumpLearn(tester);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
