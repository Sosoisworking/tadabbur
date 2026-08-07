// Smoke test for OnboardingScreen — the one screen in this scaffold that
// doesn't require a live Supabase connection to render, since main.dart
// now does async setup (dotenv + Supabase.initialize) that a plain
// pumpWidget() can't satisfy. See app/README.md for how to run the full
// app against a real Supabase project.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tadabbur/features/auth/data/auth_repository.dart';
import 'package:tadabbur/features/onboarding/presentation/screens/onboarding_screen.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

/// Overrides signUpWithPassword so the test never touches a real client —
/// the mock client above only exists to satisfy AuthRepository's
/// constructor. Returns a session-less response to exercise the
/// "check your email to confirm" branch, since that's reachable without
/// a real backend (a successful sign-in immediately hands off to the
/// router, which isn't under test here).
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(_MockSupabaseClient());

  @override
  Future<AuthResponse> signUpWithPassword({required String email, required String password}) async {
    return AuthResponse(session: null);
  }
}

void main() {
  testWidgets('shows email/password fields and confirms after signing up', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepository())],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('Tadabbur'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'aisha@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'a-real-password');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign Up'));
    await tester.pump();

    expect(
      find.text('Check your email to confirm your account, then log in below.'),
      findsOneWidget,
    );
  });
}
