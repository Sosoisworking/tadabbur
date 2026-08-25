// ReviewSessionScreen: tap-to-reveal, grade, see when the item comes
// back, advance. The third group here is a regression lock rather than
// new coverage — a failed grade used to strand the session with the card
// already flown off-screen, no error and no way forward.
//
// Runs against a fake SrsRepository (implemented, not subclassed, so it
// never needs a SupabaseClient) — no Supabase, no Edge Function, no
// network.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/features/review/data/srs_repository.dart';
import 'package:tadabbur/features/review/domain/srs_item.dart';
import 'package:tadabbur/features/review/presentation/screens/review_session_screen.dart';

/// Serves a fixed due queue and a fixed scheduling result, and records the
/// quality ratings it was handed so a test can prove which grade a given
/// gesture or button actually submitted.
class _FakeSrsRepository implements SrsRepository {
  _FakeSrsRepository({
    required this.dueItems,
    this.intervalDays = 6,
    this.failReviews = false,
  });

  final List<DueSrsItem> dueItems;
  final int intervalDays;

  /// Makes submitReview throw — the Edge Function being unreachable
  /// mid-session.
  final bool failReviews;

  final submitted = <({int srsItemId, int qualityRating})>[];

  @override
  Future<List<DueSrsItem>> fetchDueItems() async => dueItems;

  @override
  Future<SrsReviewResult> submitReview({
    required int srsItemId,
    required int qualityRating,
  }) async {
    if (failReviews) throw StateError('edge function unreachable');
    submitted.add((srsItemId: srsItemId, qualityRating: qualityRating));
    return SrsReviewResult(
      intervalDays: intervalDays,
      dueAt: DateTime.now().add(Duration(days: intervalDays)),
    );
  }

  @override
  Future<void> exposeVocabItem(int vocabItemId) async {}

  @override
  Future<void> exposeLetter(int letterId) async {}

  @override
  Future<void> exposeAyah(int ayahId) async {}

  @override
  Future<void> gradeFromQuiz({int? vocabItemId, int? letterId, required bool isCorrect}) async {}
}

const _kitab = DueSrsItem(
  srsItemId: 501,
  kind: SrsItemKind.vocab,
  arabicText: 'كِتَاب',
  label: 'kitab',
  detail: 'book',
);

const _qalam = DueSrsItem(
  srsItemId: 502,
  kind: SrsItemKind.vocab,
  arabicText: 'قَلَم',
  label: 'qalam',
  detail: 'pen',
);

/// Same reasoning as the lesson-player harness: a tall phone-shaped
/// surface (the 800x600 default puts the rating row out of reach), sized
/// with headroom because the test font draws every glyph as a full em
/// square.
Future<_FakeSrsRepository> _pumpSession(
  WidgetTester tester, {
  required List<DueSrsItem> items,
  int intervalDays = 6,
  bool failReviews = false,
}) async {
  tester.view.physicalSize = const Size(480, 920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final srs = _FakeSrsRepository(
    dueItems: items,
    intervalDays: intervalDays,
    failReviews: failReviews,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        srsRepositoryProvider.overrideWithValue(srs),
        // Invalidated by the screen once the queue is finished; overridden
        // so that invalidation can never reach a real Supabase client.
        dueSrsItemsProvider.overrideWith((ref) async => items),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const ReviewSessionScreen(),
      ),
    ),
  );

  // One pump resolves the due-items fetch; the second lets the card build.
  // pumpAndSettle is unusable — the pre-fetch state is a
  // CircularProgressIndicator, which never settles.
  await tester.pump();
  await tester.pump();
  return srs;
}

/// The screen's grade flow holds the interval label for 550ms before
/// advancing; the card's snap-back/fly-away animation runs 220-260ms.
Future<void> _runGrade(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 300));
}

/// The one card currently on screen, keyed by its srs_items id — the
/// same key the screen uses so a stale card can't be mistaken for the
/// live one.
Finder _card(DueSrsItem item) => find.byKey(ValueKey(item.srsItemId));

Matrix4 _cardTransform(WidgetTester tester, DueSrsItem item) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(of: _card(item), matching: find.byType(AnimatedContainer)),
  );
  return container.transform!;
}

void main() {
  group('tap to reveal', () {
    testWidgets('the answer is hidden until the card is tapped', (tester) async {
      await _pumpSession(tester, items: const [_kitab, _qalam]);

      expect(find.text('كِتَاب'), findsOneWidget);
      expect(find.text('TAP TO REVEAL'), findsOneWidget);
      expect(find.text('kitab'), findsNothing);
      expect(find.text('book'), findsNothing);
      // No grade can be given before the answer has been seen.
      expect(find.text('Hard'), findsNothing);
      expect(find.text('Easy'), findsNothing);
      expect(find.text('1/2'), findsOneWidget);

      await tester.tap(_card(_kitab));
      await tester.pump();

      expect(find.text('TAP TO REVEAL'), findsNothing);
      expect(find.text('kitab'), findsOneWidget);
      expect(find.text('book'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Drag right for Good · left for Again'), findsOneWidget);
    });

    testWidgets('an empty queue says so instead of showing a blank card', (tester) async {
      await _pumpSession(tester, items: const []);

      expect(find.text('Nothing due right now.'), findsOneWidget);
      expect(find.text('TAP TO REVEAL'), findsNothing);
    });
  });

  group('grading', () {
    testWidgets('shows the next-review interval, then advances to the next card', (tester) async {
      final srs = await _pumpSession(tester, items: const [_kitab, _qalam], intervalDays: 6);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Easy'));
      await tester.pump();

      // The scheduling result replaces the controls rather than sitting
      // beside them — the card is on its way out.
      expect(find.text('Next review in 6 days'), findsOneWidget);
      expect(find.text('Hard'), findsNothing);
      expect(find.text('Easy'), findsNothing);
      expect(srs.submitted, [(srsItemId: 501, qualityRating: 5)]);

      await _runGrade(tester);

      expect(find.text('قَلَم'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);
      // The next card starts face down, with the previous interval label
      // cleared.
      expect(find.text('TAP TO REVEAL'), findsOneWidget);
      expect(find.textContaining('Next review in'), findsNothing);
    });

    testWidgets('a one-day interval reads "day", not "days"', (tester) async {
      await _pumpSession(tester, items: const [_kitab], intervalDays: 1);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Hard'));
      await tester.pump();

      expect(find.text('Next review in 1 day'), findsOneWidget);

      // Drain the screen's 550ms hold, or the test ends with a pending timer.
      await _runGrade(tester);
    });

    testWidgets('Hard and Easy submit different SM-2 ratings', (tester) async {
      final srs = await _pumpSession(tester, items: const [_kitab, _qalam]);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Hard'));
      await _runGrade(tester);

      await tester.tap(_card(_qalam));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Easy'));
      await _runGrade(tester);

      expect(srs.submitted, [
        (srsItemId: 501, qualityRating: 3),
        (srsItemId: 502, qualityRating: 5),
      ]);
    });

    testWidgets('a right swipe grades Good and a left swipe grades Again', (tester) async {
      final srs = await _pumpSession(tester, items: const [_kitab, _qalam]);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.drag(_card(_kitab), const Offset(200, 0));
      await _runGrade(tester);

      expect(find.text('قَلَم'), findsOneWidget);

      await tester.tap(_card(_qalam));
      await tester.pump();
      await tester.drag(_card(_qalam), const Offset(-200, 0));
      await _runGrade(tester);

      expect(srs.submitted, [
        (srsItemId: 501, qualityRating: 4),
        (srsItemId: 502, qualityRating: 1),
      ]);
    });

    testWidgets('a drag short of the threshold snaps back without grading', (tester) async {
      final srs = await _pumpSession(tester, items: const [_kitab, _qalam]);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.drag(_card(_kitab), const Offset(40, 0));
      await tester.pump();

      expect(srs.submitted, isEmpty);
      expect(_cardTransform(tester, _kitab).getTranslation().x, 0);
      expect(find.text('كِتَاب'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('grading the last card completes the session', (tester) async {
      await _pumpSession(tester, items: const [_kitab]);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Easy'));
      await _runGrade(tester);

      expect(find.text('Review complete'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('كِتَاب'), findsNothing);
    });
  });

  group('a failed grade never strands the session', () {
    // The regression this group exists for: on the swipe path the card has
    // already flown off-screen by the time the write fails, so without the
    // snap-back the user is left staring at empty space with no card, no
    // error, and no way forward.
    testWidgets('a failed swipe grade snaps the card back and says what happened', (tester) async {
      await _pumpSession(tester, items: const [_kitab, _qalam], failReviews: true);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.drag(_card(_kitab), const Offset(200, 0));
      await _runGrade(tester);

      expect(find.textContaining('Could not save that review'), findsOneWidget);
      // Same card, back at rest, still revealed and still gradable.
      expect(find.text('كِتَاب'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
      expect(_cardTransform(tester, _kitab).getTranslation().x, 0);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      // It did not silently advance or silently finish.
      expect(find.text('قَلَم'), findsNothing);
      expect(find.text('Review complete'), findsNothing);
      expect(find.textContaining('Next review in'), findsNothing);
    });

    testWidgets('a failed button grade leaves the rating row usable', (tester) async {
      await _pumpSession(tester, items: const [_kitab], failReviews: true);

      await tester.tap(_card(_kitab));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Easy'));
      await _runGrade(tester);

      expect(find.textContaining('Could not save that review'), findsOneWidget);
      expect(find.text('Review complete'), findsNothing);
      expect(find.text('Easy'), findsOneWidget);

      // The _grading latch was released, so a retry is actually possible
      // rather than the session being wedged after one failure.
      await tester.tap(find.widgetWithText(FilledButton, 'Easy'));
      await _runGrade(tester);
      expect(find.textContaining('Could not save that review'), findsWidgets);
      expect(find.text('كِتَاب'), findsOneWidget);
    });
  });
}
