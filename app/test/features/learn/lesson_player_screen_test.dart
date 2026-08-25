// LessonPlayerScreen is the app's most complex screen: it owns the deck
// chrome (progress dots + counter), nine exercise views, the recall-quiz
// answer gate, and the completion hand-off. None of that was covered, so
// these pin the behaviour that a redesign or a refactor would break
// silently — most of all the stacked-deck ghost layers, which are pure
// decoration and therefore invisible to every other kind of check.
//
// Everything runs against fake repositories (no Supabase, no network):
// LessonRepository/SrsRepository are implemented rather than subclassed so
// the fakes never need a SupabaseClient.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tadabbur/core/theme/app_colors.dart';
import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/features/learn/data/curriculum_repository.dart';
import 'package:tadabbur/features/learn/data/lesson_repository.dart';
import 'package:tadabbur/features/learn/domain/curriculum_unit.dart';
import 'package:tadabbur/features/learn/domain/lesson.dart';
import 'package:tadabbur/features/learn/domain/lesson_exercise.dart';
import 'package:tadabbur/features/learn/presentation/screens/lesson_player_screen.dart';
import 'package:tadabbur/features/review/data/srs_repository.dart';
import 'package:tadabbur/features/review/domain/srs_item.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Serves a fixed exercise list and records every write the player makes,
/// so a test can assert what the player *saved*, not just what it drew.
class _FakeLessonRepository implements LessonRepository {
  _FakeLessonRepository({required this.exercises, this.failRecording = false});

  final List<LessonExercise> exercises;

  /// Makes recordExerciseAttempt throw, exercising the player's
  /// "Could not save your progress" recovery path.
  final bool failRecording;

  final recordedAttempts = <({int exerciseId, bool isCorrect})>[];
  ({int correct, int total})? completedWith;
  int startedAttempts = 0;

  @override
  Future<List<LessonExercise>> fetchExercisesForLesson(int lessonId) async => exercises;

  @override
  Future<List<Lesson>> fetchLessonsForUnit(int unitId) async => const [];

  @override
  Future<int> startLessonAttempt(int lessonId) async {
    startedAttempts++;
    return 77;
  }

  @override
  Future<void> recordExerciseAttempt({
    required int lessonAttemptId,
    required int exerciseId,
    required bool isCorrect,
  }) async {
    if (failRecording) throw StateError('offline');
    recordedAttempts.add((exerciseId: exerciseId, isCorrect: isCorrect));
  }

  @override
  Future<void> completeLessonAttempt({
    required int lessonAttemptId,
    required int unitId,
    required int correctCount,
    required int totalCount,
  }) async {
    completedWith = (correct: correctCount, total: totalCount);
  }
}

/// The SRS calls the player makes are fire-and-forget, so the fake only
/// has to not explode — but it records them so the quiz test can prove the
/// grade actually reached the scheduler.
class _FakeSrsRepository implements SrsRepository {
  final exposedVocabIds = <int>[];
  final exposedLetterIds = <int>[];
  final exposedAyahIds = <int>[];
  final quizGrades = <({int? vocabItemId, int? letterId, bool isCorrect})>[];

  @override
  Future<void> exposeVocabItem(int vocabItemId) async => exposedVocabIds.add(vocabItemId);

  @override
  Future<void> exposeLetter(int letterId) async => exposedLetterIds.add(letterId);

  @override
  Future<void> exposeAyah(int ayahId) async => exposedAyahIds.add(ayahId);

  @override
  Future<void> gradeFromQuiz({int? vocabItemId, int? letterId, required bool isCorrect}) async {
    quizGrades.add((vocabItemId: vocabItemId, letterId: letterId, isCorrect: isCorrect));
  }

  @override
  Future<List<DueSrsItem>> fetchDueItems() async => const [];

  @override
  Future<SrsReviewResult> submitReview({required int srsItemId, required int qualityRating}) async {
    return SrsReviewResult(intervalDays: 1, dueAt: DateTime.now());
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _letterCard = LetterCardExercise(
  id: 101,
  sequenceOrder: 1,
  letterId: 5,
  isolatedForm: 'ب',
  initialForm: 'بـ',
  medialForm: 'ـبـ',
  finalForm: 'ـب',
  isEmphatic: false,
  nameArabic: 'بَاء',
  nameTransliteration: 'Ba',
  pronunciationGuide: 'Like the b in book',
  articulationPoint: 'Both lips pressed together',
);

const _vocabCard = VocabCardExercise(
  id: 102,
  sequenceOrder: 2,
  vocabItemId: 31,
  arabicText: 'كِتَاب',
  transliteration: 'kitab',
  meaningEn: 'book',
);

const _vocabCardWithMeta = VocabCardExercise(
  id: 106,
  sequenceOrder: 6,
  vocabItemId: 32,
  arabicText: 'كَتَبَ',
  transliteration: 'kataba',
  meaningEn: 'he wrote',
  rootLetters: 'ك ت ب',
  waznPattern: 'فَعَلَ',
);

const _readingPassage = ReadingPassageExercise(
  id: 107,
  sequenceOrder: 7,
  ayat: [
    ReadingPassageAyah(
      ayahId: 900,
      ayahNumber: 1,
      textDiacritized: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
      translationEn: 'In the name of Allah',
    ),
  ],
);

const _quiz = RecallQuizExercise(
  id: 103,
  sequenceOrder: 3,
  question: 'Which letter is Ba?',
  options: ['ب', 'ت', 'ث'],
  correctOptionIndex: 0,
  testedLetterId: 5,
);

const _knowledgeCard = KnowledgeCardExercise(
  id: 104,
  sequenceOrder: 4,
  titleEn: 'Why we say Bismillah',
  explanationShort: 'A short reason.',
  explanationFull: 'The longer version, held back behind a disclosure.',
);

/// A full 28-form grid, the real shape the diacritic view has to lay out.
DiacriticIntroExercise _diacriticIntro() => DiacriticIntroExercise(
      id: 105,
      sequenceOrder: 5,
      nameEn: 'Fathah',
      markUnicode: 'َ',
      placement: 'above',
      soundDescription: 'A short "a" sound',
      explanationShort: 'A small slanted stroke above the letter.',
      readingSuffix: 'a',
      allLetterForms: [
        for (var i = 0; i < 28; i++)
          DiacriticLetterForm(isolatedForm: String.fromCharCode(0x0628 + i), baseConsonant: 'B'),
      ],
    );

const _units = [
  CurriculumUnit(
    id: 1,
    title: 'The Arabic Alphabet',
    sequenceOrder: 1,
    status: UnitStatus.inProgress,
    lessonCount: 3,
    completedLessonCount: 1,
    minutesRemaining: 12,
  ),
];

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

/// Pumps the player over a fake backend.
///
/// A tall phone-shaped surface rather than the 800x600 default: this is a
/// modal takeover, and in a landscape window the Next pill sits outside
/// the viewport where taps can't reach it.
///
/// 480 logical px wide rather than a literal phone width because the test
/// font draws every glyph as a full em square — roughly twice a real
/// font's width — so this is still a narrower bar than a real handset.
/// See the two overflow bugs noted at the bottom of this file for what
/// that harsher-than-life measurement turns up.
Future<({_FakeLessonRepository lessons, _FakeSrsRepository srs})> _pumpPlayer(
  WidgetTester tester, {
  required List<LessonExercise> exercises,
  bool failRecording = false,
  double textScale = 1.0,
  Size surface = const Size(480, 920),
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final lessons = _FakeLessonRepository(exercises: exercises, failRecording: failRecording);
  final srs = _FakeSrsRepository();

  const screen = LessonPlayerScreen(lessonId: 9, unitId: 1, lessonTitle: 'Letters: Ba');

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lessonRepositoryProvider.overrideWithValue(lessons),
        srsRepositoryProvider.overrideWithValue(srs),
        // Invalidated by the player on completion; overridden so that
        // invalidation can never reach a real Supabase client.
        curriculumUnitsProvider.overrideWith((ref) async => _units),
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

  await _settle(tester);
  return (lessons: lessons, srs: srs);
}

/// One pump to let the exercise fetch resolve, one long pump to run the
/// card's 340ms deal-in tween to completion. pumpAndSettle is unusable
/// here: the loading state is a CircularProgressIndicator, which never
/// settles.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _tapNext(WidgetTester tester, {String label = 'Next'}) async {
  await tester.tap(find.widgetWithText(FilledButton, label));
  await _settle(tester);
}

// ---------------------------------------------------------------------------
// Structural probes
// ---------------------------------------------------------------------------

/// The deck header's per-exercise progress dots: 3px-tall Containers,
/// filled with the brand colour up to and including the current index.
Iterable<Container> _progressDots(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .where((c) => c.constraints?.minHeight == 3 && c.constraints?.maxHeight == 3);

int _filledDots(WidgetTester tester) => _progressDots(tester)
    .where((c) => (c.decoration as BoxDecoration).color == AppColors.brandPrimary)
    .length;

/// The one Stack in the deck card scaffold — identified by the two
/// properties only it sets (Clip.none so the ghosts can hang past the
/// card's bottom edge, passthrough so the card keeps its original
/// constraints).
final _deckStack = find.byWidgetPredicate(
  (w) => w is Stack && w.clipBehavior == Clip.none && w.fit == StackFit.passthrough,
);

/// The ghost layers' exact fills, straight off _DeckCardScaffold._ghosts.
final _ghostFills = {
  AppColors.fillSubtle.withValues(alpha: 0.05),
  AppColors.fillSubtle.withValues(alpha: 0.03),
};

int _paintedGhostCount(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .where((d) => _ghostFills.contains((d.decoration as BoxDecoration).color))
    .length;

BoxDecoration _decorationAround(WidgetTester tester, String text) {
  final container = tester.widget<Container>(
    find.ancestor(of: find.text(text), matching: find.byType(Container)).first,
  );
  return container.decoration! as BoxDecoration;
}

Color? _nextButtonColor(WidgetTester tester, String label) {
  final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, label));
  return button.style?.backgroundColor?.resolve(<WidgetState>{});
}

// ---------------------------------------------------------------------------

void main() {
  group('deck progress', () {
    testWidgets('advancing updates the counter and fills one more dot', (tester) async {
      final fakes = await _pumpPlayer(
        tester,
        exercises: const [_letterCard, _vocabCard, _knowledgeCard],
      );

      expect(find.text('1/3'), findsOneWidget);
      expect(_progressDots(tester).length, 3);
      expect(_filledDots(tester), 1);
      // The lesson title is the deck's only other chrome, uppercased.
      expect(find.text('LETTERS: BA'), findsOneWidget);

      await _tapNext(tester);
      expect(find.text('2/3'), findsOneWidget);
      expect(_filledDots(tester), 2);
      expect(find.text('كِتَاب'), findsOneWidget);

      await _tapNext(tester);
      expect(find.text('3/3'), findsOneWidget);
      expect(_filledDots(tester), 3);
      expect(find.text('Why we say Bismillah'), findsOneWidget);

      // Each advance wrote an exercise_attempt, in order.
      expect(
        fakes.lessons.recordedAttempts.map((a) => a.exerciseId),
        [_letterCard.id, _vocabCard.id],
      );
      // ...and the ungraded cards exposed their items to the SRS queue.
      expect(fakes.srs.exposedLetterIds, [_letterCard.letterId]);
      expect(fakes.srs.exposedVocabIds, [_vocabCard.vocabItemId]);
    });

    testWidgets('a failed progress write surfaces an error and holds position', (tester) async {
      await _pumpPlayer(
        tester,
        exercises: const [_letterCard, _vocabCard],
        failRecording: true,
      );

      await _tapNext(tester);

      expect(find.textContaining('Could not save your progress'), findsOneWidget);
      // Still on the first exercise — the player didn't advance past an
      // exercise whose attempt never saved.
      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('بَاء'), findsOneWidget);
    });
  });

  group('recall quiz gate', () {
    testWidgets('Next is disabled until an option is picked', (tester) async {
      await _pumpPlayer(tester, exercises: const [_quiz, _vocabCard]);

      final nextButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull, reason: 'unanswered quiz must not be skippable');

      // Nothing is coloured yet: every option carries the neutral border.
      expect(_decorationAround(tester, 'ب').border!.top.color, AppColors.borderSubtle);
    });

    testWidgets('a correct pick turns the option and the button green', (tester) async {
      final fakes = await _pumpPlayer(tester, exercises: const [_quiz, _vocabCard]);

      await tester.tap(find.text('ب'));
      await tester.pump();

      expect(find.text('Correct — Next'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
      expect(_nextButtonColor(tester, 'Correct — Next'), AppColors.success);
      expect(_decorationAround(tester, 'ب').border!.top.color, AppColors.success);
      // A second tap can't change the answer once graded.
      expect(
        tester.widget<InkWell>(find.ancestor(of: find.text('ت'), matching: find.byType(InkWell)).first).onTap,
        isNull,
      );

      await _tapNext(tester, label: 'Correct — Next');

      expect(fakes.srs.quizGrades, [(vocabItemId: null, letterId: 5, isCorrect: true)]);
      expect(fakes.lessons.recordedAttempts.single.isCorrect, isTrue);
    });

    testWidgets('a wrong pick reds the choice, greens the answer, and relabels Next', (tester) async {
      final fakes = await _pumpPlayer(tester, exercises: const [_quiz, _vocabCard]);

      await tester.tap(find.text('ث'));
      await tester.pump();

      expect(find.text('Not quite — Next'), findsOneWidget);
      expect(_nextButtonColor(tester, 'Not quite — Next'), AppColors.error);
      // The wrong choice is marked wrong, and the right answer is still
      // shown as right — a learner has to see which one it was.
      expect(_decorationAround(tester, 'ث').border!.top.color, AppColors.error);
      expect(_decorationAround(tester, 'ب').border!.top.color, AppColors.success);
      // The untouched third option stays neutral.
      expect(_decorationAround(tester, 'ت').border!.top.color, AppColors.borderSubtle);

      await _tapNext(tester, label: 'Not quite — Next');

      expect(fakes.srs.quizGrades, [(vocabItemId: null, letterId: 5, isCorrect: false)]);
      expect(fakes.lessons.recordedAttempts.single.isCorrect, isFalse);
    });
  });

  group('stacked-deck ghost layers', () {
    testWidgets('two ghosts render behind the card while exercises remain', (tester) async {
      await _pumpPlayer(tester, exercises: const [_letterCard, _vocabCard, _knowledgeCard]);

      final stack = tester.widget<Stack>(_deckStack);
      // Ghosts first, active card last — paint order is what puts them
      // behind rather than on top of the card.
      expect(stack.children.length, 3);
      expect(stack.children[0], isA<Positioned>());
      expect(stack.children[1], isA<Positioned>());
      expect(stack.children.last, isA<TweenAnimationBuilder<double>>());
      expect(_paintedGhostCount(tester), 2);

      // The stagger is a perspective cue: the layer further back is
      // inset more, starts lower, and peeks out less.
      final front = stack.children[1] as Positioned;
      final back = stack.children[0] as Positioned;
      expect(back.left, greaterThan(front.left!));
      expect(back.top, greaterThan(front.top!));
      expect(back.bottom, greaterThan(front.bottom!)); // less negative = shorter overhang
      // Both hang past the card's bottom edge — that overhang is the effect.
      expect(front.bottom, lessThan(0));
    });

    testWidgets('the ghosts are gone on the final exercise', (tester) async {
      await _pumpPlayer(tester, exercises: const [_letterCard, _vocabCard]);

      expect(_paintedGhostCount(tester), 2);

      await _tapNext(tester);

      expect(find.text('2/2'), findsOneWidget);
      final stack = tester.widget<Stack>(_deckStack);
      expect(stack.children.length, 1, reason: 'nothing is left stacked behind the last card');
      expect(stack.children.single, isA<TweenAnimationBuilder<double>>());
      expect(_paintedGhostCount(tester), 0);
    });

    testWidgets('a single-exercise lesson never shows ghosts', (tester) async {
      await _pumpPlayer(tester, exercises: const [_letterCard]);

      expect(tester.widget<Stack>(_deckStack).children.length, 1);
      expect(_paintedGhostCount(tester), 0);
    });
  });

  group('diacritic intro grid', () {
    // scrollable: false exists solely so this GridView gets a bounded
    // height. If that ever regresses, the grid is handed unbounded height
    // and the whole screen throws instead of rendering.
    testWidgets('lays out its 28-cell grid inside the card without overflowing', (tester) async {
      await _pumpPlayer(tester, exercises: [_diacriticIntro(), _vocabCard]);

      expect(tester.takeException(), isNull);
      expect(find.text('Fathah'), findsOneWidget);
      expect(find.text('A short "a" sound'), findsOneWidget);

      final grid = find.byType(GridView);
      expect(grid, findsOneWidget);
      // Bounded, and inside the card rather than spilling past it.
      final gridSize = tester.getSize(grid);
      expect(gridSize.height, greaterThan(0));
      expect(gridSize.height, lessThan(tester.getSize(find.byType(Scaffold)).height));

      // The grid scrolls itself, so the cells past the fold still lay out.
      await tester.drag(grid, const Offset(0, -400));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the grid still lays out on the last exercise, with no ghosts', (tester) async {
      await _pumpPlayer(tester, exercises: [_diacriticIntro()]);

      expect(tester.takeException(), isNull);
      expect(find.byType(GridView), findsOneWidget);
      expect(_paintedGhostCount(tester), 0);
    });
  });

  group('completion', () {
    testWidgets('finishing the last exercise shows the completion card and saves the score', (tester) async {
      final fakes = await _pumpPlayer(tester, exercises: const [_letterCard, _quiz]);

      await _tapNext(tester);
      await tester.tap(find.text('ب'));
      await tester.pump();
      await _tapNext(tester, label: 'Correct — Next');

      expect(find.text('Lesson complete'), findsOneWidget);
      // Only the quiz is graded, so the score counts one of one.
      expect(find.text('1 / 1 correct'), findsOneWidget);
      expect(find.text('+10 XP'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      expect(fakes.lessons.completedWith, (correct: 1, total: 1));
      expect(fakes.lessons.startedAttempts, 1);

      // The deck chrome is gone — the completion state replaces it, it
      // doesn't sit on top of a still-live exercise.
      expect(find.text('2/2'), findsNothing);
      expect(_deckStack, findsNothing);
    });

    testWidgets('a wrong final answer still completes, scored honestly', (tester) async {
      final fakes = await _pumpPlayer(tester, exercises: const [_quiz]);

      await tester.tap(find.text('ت'));
      await tester.pump();
      await _tapNext(tester, label: 'Not quite — Next');

      expect(find.text('Lesson complete'), findsOneWidget);
      expect(find.text('0 / 1 correct'), findsOneWidget);
      expect(find.text('+0 XP'), findsOneWidget);
      expect(fakes.lessons.completedWith, (correct: 0, total: 1));
    });

    testWidgets('an empty lesson says so rather than rendering an empty deck', (tester) async {
      await _pumpPlayer(tester, exercises: const []);

      expect(find.text('This lesson has no exercises yet.'), findsOneWidget);
      expect(_deckStack, findsNothing);
    });
  });

  group('Disclosure', () {
    // Advanced detail (makhraj, full explanations) is deliberately held
    // back from beginners — collapsed by default is the whole point of
    // the component, not a styling choice.
    testWidgets('starts collapsed and expands on tap', (tester) async {
      await _pumpPlayer(tester, exercises: const [_letterCard]);

      expect(find.text('Where is this pronounced?'), findsOneWidget);
      expect(find.text(_letterCard.articulationPoint), findsNothing);
      expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Where is this pronounced?'));
      await tester.pump();

      expect(find.text(_letterCard.articulationPoint), findsOneWidget);
      expect(find.byIcon(Icons.expand_less_rounded), findsOneWidget);
      expect(find.byIcon(Icons.expand_more_rounded), findsNothing);

      await tester.tap(find.widgetWithText(InkWell, 'Where is this pronounced?'));
      await tester.pump();

      expect(find.text(_letterCard.articulationPoint), findsNothing);
    });

    testWidgets('a knowledge card holds its full explanation behind Learn more', (tester) async {
      await _pumpPlayer(tester, exercises: const [_knowledgeCard]);

      expect(find.text(_knowledgeCard.explanationShort), findsOneWidget);
      expect(find.text(_knowledgeCard.explanationFull), findsNothing);

      await tester.tap(find.widgetWithText(InkWell, 'Learn more'));
      await tester.pump();

      expect(find.text(_knowledgeCard.explanationFull), findsOneWidget);
    });
  });

  group('text scale', () {
    // Fixed-height containers clipping at large text has been a real bug
    // class on this screen. Note the test font makes every glyph a full
    // em square — roughly twice a real font's width — so passing at 2.0x
    // here is a harder bar than 2.0x on a device.
    testWidgets('a quiz lays out at 2.0x without overflowing', (tester) async {
      await _pumpPlayer(tester, exercises: const [_quiz, _vocabCard], textScale: 2.0);

      expect(tester.takeException(), isNull);
      expect(find.text('1/2'), findsOneWidget);

      // The card body scrolls, so options below the fold still lay out
      // — and an overflow anywhere in there fails by throwing.
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a knowledge card lays out at 2.0x, expanded disclosure included', (tester) async {
      await _pumpPlayer(tester, exercises: const [_knowledgeCard, _vocabCard], textScale: 2.0);

      expect(tester.takeException(), isNull);

      await tester.tap(find.widgetWithText(InkWell, 'Learn more'));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a vocab card and a reading passage lay out at 2.0x', (tester) async {
      await _pumpPlayer(
        tester,
        exercises: [_vocabCardWithMeta, _readingPassage],
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
      // The root/pattern chips are a Wrap, so they reflow rather than
      // running off the card edge.
      expect(find.text('Root: ك ت ب'), findsOneWidget);

      await _tapNext(tester);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    // Deliberately NOT covered: the diacritic grid and the letter card at
    // large text scales. Both overflow today — see the bug notes below.
    // Asserting the overflow would lock the defect in as expected
    // behaviour, so these stay uncovered rather than wrong.
  });
}

// ---------------------------------------------------------------------------
// Known layout defects, found while writing the tests above and left
// unfixed here (this file may only touch test code):
//
// 1. lesson_player_screen.dart:615-619 — _DiacriticIntroView's GridView
//    fixes childAspectRatio at 0.8, so each cell's height is derived from
//    the column width and never from the text it has to hold. Its content
//    is Arabic at AppTypography.arabicCompact (40, line height 1.8 = 72px)
//    plus a 11px reading label, which fits a ~94px cell at 1.0x and blows
//    straight through it once the user scales text up: at 2.0x the cell
//    Column (line 629) overflows by 232px. scrollable: false correctly
//    bounds the *grid*; nothing bounds the cell.
//
// 2. disclosure.dart:48 — the header Row puts the label Text and the
//    chevron side by side with no Flexible on either, so a long label has
//    nowhere to wrap. "Where is this pronounced?" (the letter card's) at
//    2.0x needs ~332px against ~293px of card interior on a 393pt phone,
//    and overflows to the right. Every other Disclosure label in the app
//    is short enough ("Learn more") to stay under the limit today.
//
// 3. lesson_player_screen.dart:734 — _PositionalFormsRow lays its three
//    labelled columns out with MainAxisAlignment.spaceEvenly and no flex,
//    so "Beginning"/"Middle"/"End" can't wrap or ellipsize. Marginal on a
//    real font (it still fits a 393pt phone at 2.0x); it overflows here
//    from 1.5x up because the test font is about twice as wide. Same
//    shape of defect as (2) — worth a Flexible either way.
// ---------------------------------------------------------------------------
