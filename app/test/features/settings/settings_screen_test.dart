// Drives the Settings screen the way a user does — taps a control, then
// checks the change both reached the app (the live Hijri preview, which
// renders through the same provider every other screen reads) and reached
// disk. AppTheme.dark() is passed explicitly because the screen reads text
// styles the default MaterialApp theme wouldn't supply.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/core/util/hijri_date.dart';
import 'package:tadabbur/features/auth/data/auth_repository.dart';
import 'package:tadabbur/features/settings/presentation/providers/settings_providers.dart';
import 'package:tadabbur/features/settings/presentation/screens/settings_screen.dart';

/// Enough of an account for the Account card to render; these tests are
/// about the prayer and Hijri controls.
class _StubAuthRepository implements AuthRepository {
  @override
  bool get isAnonymous => false;

  @override
  String? get email => 'aisha@example.com';

  @override
  bool get isSignedIn => true;

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, {double textScale = 1.0}) async {
  // A phone-shaped surface rather than the 800x600 default — this is a
  // tall mobile layout, and the lower cards sit below the fold in a
  // landscape window.
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      // The app's own override list, so a break in the real wiring fails
      // here rather than passing against a test-only arrangement. The auth
      // stub is the one addition: the Account card reads the signed-in
      // identity, and the real repository reaches for a Supabase client that
      // no widget test initialises. Sign-out behaviour itself is covered in
      // sign_out_test.dart.
      overrides: [
        ...settingsOverrides,
        authRepositoryProvider.overrideWithValue(_StubAuthRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: textScale == 1.0
            ? const SettingsScreen()
            : MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: const SettingsScreen(),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a Hijri correction changes the rendered date and is persisted', (tester) async {
    await _pump(tester);

    expect(find.text(hijriToday(dayOffset: 0)), findsOneWidget);
    expect(find.text('No correction'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // The preview is rendered from hijriDayOffsetProvider, so seeing
    // tomorrow's Hijri date here is the same thing the Learn and Prayer
    // headers will show.
    expect(find.text(hijriToday(dayOffset: 1)), findsOneWidget);
    expect(find.text(hijriToday(dayOffset: 0)), findsNothing);
    expect(find.text('1 day later'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('settings_hijri_day_offset'), 1);
  });

  testWidgets('the correction stops at the end of the supported range', (tester) async {
    await _pump(tester);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();
    }

    expect(find.text('2 days earlier'), findsOneWidget);
    // The control is disabled at the limit rather than silently ignoring
    // taps, so the user can see they've reached the end.
    final decrement = tester.widget<InkWell>(
      find.ancestor(of: find.byIcon(Icons.remove_rounded), matching: find.byType(InkWell)).first,
    );
    expect(decrement.onTap, isNull);
  });

  testWidgets('picking a madhab drives and persists the choice', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Hanafi'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings_prayer_madhab'), Madhab.hanafi.name);
  });

  testWidgets('picking a calculation method names it on the row and persists it', (tester) async {
    await _pump(tester);

    expect(find.text(CalculationMethod.muslimWorldLeague.displayName), findsOneWidget);

    await tester.tap(find.text(CalculationMethod.muslimWorldLeague.displayName));
    await tester.pumpAndSettle();

    await tester.tap(find.text(CalculationMethod.karachi.displayName));
    await tester.pumpAndSettle();

    expect(find.text(CalculationMethod.karachi.displayName), findsOneWidget);
    expect(find.text(CalculationMethod.muslimWorldLeague.displayName), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings_prayer_calculation_method'), CalculationMethod.karachi.name);
  });

  testWidgets('lays out at a large text scale without clipping', (tester) async {
    await _pump(tester, textScale: 2.0);

    // Scrolling forces the offscreen children to lay out too — an
    // overflow anywhere in the list fails the test by throwing. Note the
    // test font makes every glyph a full em square, roughly twice a real
    // font's width, so this is a harder bar than 2x on a device.
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();
  });
}
