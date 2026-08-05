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

  Future<void> signOut() => _client.auth.signOut();

  bool get isSignedIn => _client.auth.currentUser != null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});
