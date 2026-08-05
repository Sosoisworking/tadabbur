import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Call once from main() before runApp(). Everything else in the app reads
/// the client via [supabaseClientProvider] rather than calling
/// Supabase.instance.client directly, so tests can override the provider
/// with a fake client instead of hitting a real backend.
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
