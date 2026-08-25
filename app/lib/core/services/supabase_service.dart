import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Call once from main() before runApp(). Everything else in the app reads
/// the client via [supabaseClientProvider] rather than calling
/// Supabase.instance.client directly, so tests can override the provider
/// with a fake client instead of hitting a real backend.
///
/// Deliberately *not* wrapped in a timeout: `setInitialSession` only parses
/// the stored session and assigns it, with no network call, so there is
/// nothing here for a timeout to rescue. Session refresh happens after this
/// returns, and its failure mode is handled by [authFailureRecoveryProvider]
/// instead.
///
/// Safe to call again after a failure: `Supabase.initialize` early-returns
/// if it already completed, so [main]'s retry path can't double-initialize.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Streams auth state so the router (see app_router.dart) can redirect
/// between the onboarding flow and the main app shell reactively, instead
/// of checking auth state only once at startup.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Clears a session that can no longer be refreshed.
///
/// A restored session is set from local storage without contacting the
/// server, so `currentUser` is non-null even when its refresh token has
/// been revoked or has expired. The router reads that as "signed in" and
/// lands the user in the app shell — where every screen then queries with a
/// dead token and can only fail. Nothing recovers on its own, because
/// supabase_flutter's own listener swallows the refresh error.
///
/// Signing out locally on that error converts a stuck, half-authenticated
/// shell into the ordinary signed-out path: the router redirects to
/// onboarding and the user can sign in again. Scope is local-only —
/// contacting the server to revoke is pointless when the credential the
/// call would need is the very thing that just failed.
final authFailureRecoveryProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (previous, next) {
    if (!next.hasError) return;
    final client = ref.read(supabaseClientProvider);
    if (client.auth.currentSession == null) return;
    debugPrint('Auth refresh failed; clearing the stale local session.');
    client.auth.signOut(scope: SignOutScope.local).catchError(
          (Object e) => debugPrint('Local sign-out after auth failure failed: $e'),
        );
  });
});
