import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/curriculum_unit.dart';

/// This is the reference example for the data layer pattern used
/// throughout the app: a thin class that only knows how to talk to
/// Supabase, returning domain models — no widget code, no Riverpod state
/// beyond exposing itself via [curriculumRepositoryProvider]. Every other
/// feature's data layer should follow this same shape.
///
/// Reads go straight through PostgREST + RLS per docs/api-design.md §1 —
/// there is deliberately no custom backend endpoint for "list my units,"
/// since RLS alone (user_id = auth.uid()) is enough to make this safe.
class CurriculumRepository {
  CurriculumRepository(this._client);

  final SupabaseClient _client;

  Future<List<CurriculumUnit>> fetchUnitsForCurrentUser() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('fetchUnitsForCurrentUser called with no signed-in user');
    }

    // Units left-joined with this user's progress row, if one exists yet
    // (a unit the user hasn't reached has no user_unit_progress row at
    // all, per the schema — absence means "locked").
    final response = await _client
        .from('units')
        .select('id, title, sequence_order, user_unit_progress!left(status)')
        .eq('user_unit_progress.user_id', userId)
        .order('sequence_order', ascending: true);

    return (response as List).map((row) {
      final progressRows = row['user_unit_progress'] as List?;
      final status = progressRows != null && progressRows.isNotEmpty
          ? progressRows.first['status'] as String
          : 'locked';
      return CurriculumUnit.fromJson({...row, 'status': status});
    }).toList();
  }
}

final curriculumRepositoryProvider = Provider<CurriculumRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CurriculumRepository(client);
});

final curriculumUnitsProvider = FutureProvider<List<CurriculumUnit>>((ref) {
  // Refetch whenever auth state changes (sign-in, sign-out, or — the bug
  // this specifically guards against — ending up authenticated as a
  // *different* user mid-session without this screen ever being told).
  // Without this, a stale fetch from an earlier session can sit cached
  // indefinitely and show the wrong user's progress.
  ref.watch(authStateProvider);
  return ref.watch(curriculumRepositoryProvider).fetchUnitsForCurrentUser();
});
