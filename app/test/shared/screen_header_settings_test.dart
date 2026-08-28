// The redesign removed AppBars, so the settings entry point moved into
// ScreenHeader — but only inside a SettingsScope, which the router puts
// around the tab shell and nothing else. These pin both halves: a gear on
// the tabs, and no gear on a full-screen takeover like the lesson player
// or the placement result.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/shared/widgets/screen_header.dart';
import 'package:tadabbur/shared/widgets/settings_scope.dart';

late List<String> _opened;

/// A top-level function, mirroring how `app_router.dart` passes its own —
/// an inline closure would be a new object each rebuild and defeat
/// [SettingsScope.updateShouldNotify].
void _open(BuildContext context) => _opened.add('opened');

Future<void> _pump(
  WidgetTester tester, {
  required bool inScope,
  Widget? trailing,
  double textScale = 1.0,
}) async {
  const header = ScreenHeader(eyebrow: 'Today', title: 'Keep going,', emphasis: 'Al-Fatiha');

  final body = ScreenHeader(
    eyebrow: header.eyebrow,
    title: header.title,
    emphasis: header.emphasis,
    trailing: trailing,
  );

  // A phone-shaped surface rather than the 800x600 default — the header
  // has to fit a title, whatever the screen puts in the trailing slot, and
  // now the gear, in a phone's width.
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final scoped = inScope ? SettingsScope(open: _open, child: body) : body;

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: textScale == 1.0
            ? scoped
            : MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: scoped,
              ),
      ),
    ),
  );
}

void main() {
  setUp(() => _opened = []);

  testWidgets('offers no settings affordance outside a SettingsScope', (tester) async {
    await _pump(tester, inScope: false);

    expect(find.byIcon(Icons.settings_rounded), findsNothing);
  });

  testWidgets('inside a SettingsScope the header opens settings', (tester) async {
    await _pump(tester, inScope: true);

    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pump();

    expect(_opened, ['opened']);
  });

  testWidgets('sits beside a header that already carries a trailing widget', (tester) async {
    // Learn's streak ring and Prayer's location pill both occupy the
    // trailing slot; the gear has to land in the same corner on every
    // screen rather than replacing whatever is there.
    await _pump(tester, inScope: true, trailing: const Text('STREAK'));

    expect(find.text('STREAK'), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('still fits beside a streak-ring-sized trailing at 2x text', (tester) async {
    // The widest real case: Learn's ring grows with the text scale and
    // the gear sits to its right. An overflow here fails the test by
    // throwing.
    await _pump(
      tester,
      inScope: true,
      trailing: const SizedBox(width: 93, height: 93),
      textScale: 2.0,
    );

    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('is announced as Settings to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, inScope: true);

    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    handle.dispose();
  });
}
