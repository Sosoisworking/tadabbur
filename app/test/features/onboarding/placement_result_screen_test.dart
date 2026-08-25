// PlacementResultScreen renders entirely from the model it's handed — no
// provider, no Supabase — so these pump a constructed PlacementResult
// directly. AppTheme.dark() is passed explicitly because the screen reads
// text styles the default MaterialApp theme wouldn't supply.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/features/onboarding/domain/placement_result.dart';
import 'package:tadabbur/features/onboarding/presentation/screens/placement_result_screen.dart';

const _juzAmma = RecommendedUnit(
  id: 7,
  title: 'Juz Amma — Meaning',
  lessonCount: 12,
  firstLessonTitle: 'Essential Particles',
);

Future<void> _pump(
  WidgetTester tester,
  PlacementResult result, {
  double textScale = 1.0,
}) async {
  // A phone-shaped surface rather than the 800x600 default — this is a
  // tall mobile layout, and the CTA sits below the fold in a landscape
  // window.
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final screen = PlacementResultScreen(result: result, onStartFirstLesson: () {});

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: textScale == 1.0
          ? screen
          : MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
              child: screen,
            ),
    ),
  );
}

void main() {
  testWidgets('renders a verdict per axis and names the recommended unit', (tester) async {
    // The Omar persona from docs/PRD.md: recites fluently, understands
    // little — the case the whole three-axis placement exists to catch.
    await _pump(
      tester,
      const PlacementResult(
        scriptLiteracyScore: 92,
        recitationFluencyScore: 88,
        vocabGrammarScore: 24,
        recommendedUnit: _juzAmma,
      ),
    );

    expect(find.text('Script literacy'), findsOneWidget);
    expect(find.text('Recitation fluency'), findsOneWidget);
    expect(find.text('Vocabulary & grammar'), findsOneWidget);

    // Two strong axes, and the gap is the one the curriculum picks up on.
    expect(find.text('Strong'), findsNWidgets(2));
    expect(find.text('Starting here'), findsOneWidget);

    expect(find.text('Juz Amma — Meaning'), findsOneWidget);
    expect(find.text('12 lessons · Essential Particles first'), findsOneWidget);
    expect(find.text('Start my first lesson'), findsOneWidget);
  });

  testWidgets('marks axes downstream of the gap as coming later', (tester) async {
    // The Aisha persona: no script literacy yet, so fluency and vocabulary
    // are downstream of a gap she hasn't closed — they must not read as
    // two more simultaneous starting points.
    await _pump(
      tester,
      const PlacementResult(
        scriptLiteracyScore: 8,
        recitationFluencyScore: 5,
        vocabGrammarScore: 11,
        recommendedUnit: _juzAmma,
      ),
    );

    expect(find.text('Starting here'), findsOneWidget);
    expect(find.text('Comes later'), findsNWidgets(2));
    expect(find.text('Strong'), findsNothing);
  });

  testWidgets('lays out at a large text scale without clipping', (tester) async {
    // The screen has no fixed-height element to sacrifice, so everything
    // has to wrap or scroll. Note the test font makes every glyph a full
    // em square — roughly twice a real font's width — so passing here is
    // a harder bar than 2x on a device.
    await _pump(
      tester,
      const PlacementResult(
        scriptLiteracyScore: 92,
        recitationFluencyScore: 88,
        vocabGrammarScore: 24,
        recommendedUnit: _juzAmma,
      ),
      textScale: 2.0,
    );

    // Scrolling forces the offscreen children to lay out too — an
    // overflow anywhere in the list fails the test by throwing.
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();
  });
}
