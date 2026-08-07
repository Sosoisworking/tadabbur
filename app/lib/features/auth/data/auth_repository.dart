import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

/// Email/password rather than magic-link: a magic link redirects back to
/// a URL that has to exactly match the dev server's port, which is a
/// real point of friction during local development (see app/README.md
/// §4) — password auth has no redirect step at all, and only needs an
/// email round-trip once, for the initial signup confirmation, not on
/// every sign-in. Apple/Google sign-in (PRD §4.1, IA onboarding step 9)
/// need native platform configuration (Sign in with Apple capability,
/// Google OAuth client IDs) that belongs with the M2 onboarding
/// milestone, not the architecture scaffold — adding those here now
/// would be guessing at config that doesn't exist yet in the actual
/// Apple/Google developer accounts.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Returns the resulting session — null if the project has "Confirm
  /// email" enabled and the account needs email verification before
  /// it's usable, non-null if the user is signed in immediately. The
  /// caller (OnboardingScreen) branches on this rather than assuming one
  /// or the other, since it depends on a project setting neither of us
  /// controls from here.
  Future<AuthResponse> signUpWithPassword({required String email, required String password}) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signInWithPassword({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// This is the real mechanism behind "first lesson before signup" in
  /// information-architecture.md — an anonymous session still gets a
  /// stable auth.uid(), so progress recorded before the user ever creates
  /// an account isn't lost; it's the same row once they later link an
  /// email (Supabase supports upgrading an anonymous session in place).
  /// Requires "Allow anonymous sign-ins" enabled in the Supabase
  /// dashboard under Authentication settings.
  Future<void> continueAnonymously() {
    return _client.auth.signInAnonymously();
  }

  Future<void> signOut() => _client.auth.signOut();

  bool get isSignedIn => _client.auth.currentUser != null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});
