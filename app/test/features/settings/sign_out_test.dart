// Signing out has two genuinely different meanings in this app, and the
// dangerous one is easy to lose in a refactor: an anonymous session is the
// only key to the progress stored under its auth.uid(), so logging out of one
// destroys it with no way back. These pin that the destructive case is named
// as destructive, and that neither case can fire from a single tap.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/features/auth/data/auth_repository.dart';
import 'package:tadabbur/features/settings/presentation/providers/settings_providers.dart';
import 'package:tadabbur/features/settings/presentation/screens/settings_screen.dart';

/// Reports a chosen session shape and records whether sign-out happened,
/// without needing a SupabaseClient.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.isAnonymous, this.email, this.failSignOut = false});

  @override
  final bool isAnonymous;

  @override
  final String? email;

  final bool failSignOut;
  int signOutCalls = 0;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (failSignOut) throw StateError('network down');
  }

  @override
  bool get isSignedIn => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeAuthRepository> _pump(
  WidgetTester tester, {
  required bool isAnonymous,
  String? email,
  bool failSignOut = false,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final auth = _FakeAuthRepository(
    isAnonymous: isAnonymous,
    email: email,
    failSignOut: failSignOut,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [...settingsOverrides, authRepositoryProvider.overrideWithValue(auth)],
      child: MaterialApp(theme: AppTheme.dark(), home: const SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

/// The Account card sits at the bottom of the list, below the fold on a
/// phone-sized surface, so every assertion about it has to scroll first.
Future<void> _revealAccountCard(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('Log out'), 200);
  await tester.pumpAndSettle();
}

Future<void> _tapLogOut(WidgetTester tester) async {
  await _revealAccountCard(tester);
  await tester.tap(find.text('Log out'));
  await tester.pumpAndSettle();
}

void main() {
  _versionTests();

  testWidgets('an account holder sees their email and a reassuring confirmation', (tester) async {
    final auth = await _pump(tester, isAnonymous: false, email: 'aisha@example.com');

    await _revealAccountCard(tester);
    expect(find.text('aisha@example.com'), findsOneWidget);

    await _tapLogOut(tester);

    expect(find.text('Log out?'), findsOneWidget);
    expect(find.textContaining('sign back in any time'), findsOneWidget);
    // Confirmation is mandatory — the tap alone must not sign anyone out.
    expect(auth.signOutCalls, 0);
  });

  testWidgets('an anonymous session is warned that progress is lost for good', (tester) async {
    final auth = await _pump(tester, isAnonymous: true);

    await _revealAccountCard(tester);
    expect(find.text('Signed in without an account'), findsOneWidget);

    await _tapLogOut(tester);

    // The wording has to name the consequence, not ask a generic "are you
    // sure" — this is the assertion that stops the two cases being collapsed
    // into one neutral dialog.
    expect(find.text('Log out and lose your progress?'), findsOneWidget);
    expect(find.textContaining('gone for good'), findsOneWidget);
    expect(find.text('Log out anyway'), findsOneWidget);
    expect(auth.signOutCalls, 0);
  });

  testWidgets('cancelling leaves the session alone', (tester) async {
    final auth = await _pump(tester, isAnonymous: true);
    await _tapLogOut(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(auth.signOutCalls, 0);
    expect(find.text('Log out and lose your progress?'), findsNothing);
  });

  testWidgets('confirming signs out', (tester) async {
    final auth = await _pump(tester, isAnonymous: false, email: 'aisha@example.com');
    await _tapLogOut(tester);

    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();

    expect(auth.signOutCalls, 1);
  });

  testWidgets('a failed sign-out is reported rather than swallowed', (tester) async {
    await _pump(tester, isAnonymous: false, email: 'aisha@example.com', failSignOut: true);
    await _tapLogOut(tester);

    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();

    // Silently failing here would leave someone believing they had logged out
    // on a shared device.
    expect(find.textContaining('Could not log out'), findsOneWidget);
  });
}

/// The build identifier has to be on screen unconditionally, not only when an
/// update happens to be waiting. Without it "the change didn't show up" can
/// only be answered by guessing, which is exactly what it cost before.
void _versionTests() {
  testWidgets('the running build is always shown', (tester) async {
    await _pump(tester, isAnonymous: false, email: 'aisha@example.com');
    await tester.scrollUntilVisible(find.text('Version'), 200);

    expect(find.text('Version'), findsOneWidget);
    // A local build reports 'dev' rather than a zero that would look real.
    expect(find.textContaining('1.0.0 · build'), findsOneWidget);
  });
}
