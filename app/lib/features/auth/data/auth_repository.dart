import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

/// Scaffold covers email magic-link sign-in only. Apple/Google sign-in
/// (PRD §4.1, IA onboarding step 9) need native platform configuration
/// (Sign in with Apple capability, Google OAuth client IDs) that belongs
/// with the M2 onboarding milestone, not the architecture scaffold —
/// adding those here now would be guessing at config that doesn't exist
/// yet in the actual Apple/Google developer accounts.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<void> sendMagicLink(String email) {
    return _client.auth.signInWithOtp(email: email);
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
