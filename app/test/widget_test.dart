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

/// Overrides sendMagicLink so the test never touches a real client — the
/// mock client above only exists to satisfy AuthRepository's constructor.
class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(_MockSupabaseClient());

  @override
  Future<void> sendMagicLink(String email) async {}
}

void main() {
  testWidgets('shows email field and confirms after sending a sign-in link', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepository())],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('Tadabbur'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'aisha@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Send sign-in link'));
    await tester.pump();

    expect(find.text('Check your email for a sign-in link.'), findsOneWidget);
  });
}
