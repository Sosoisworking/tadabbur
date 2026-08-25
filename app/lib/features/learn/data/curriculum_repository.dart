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
    final userId = _requireUserId();

    // Units left-joined with this user's progress row, if one exists yet.
    // A unit the user hasn't reached has no user_unit_progress row at all
    // — that reads as in_progress (units are never locked), not 'locked'.
    final response = await _client
        .from('units')
        .select('id, title, sequence_order, user_unit_progress!left(status)')
        .eq('user_unit_progress.user_id', userId)
        .order('sequence_order', ascending: true);

    final progress = await _fetchLessonProgress(userId);

    return (response as List).map((row) {
      final progressRows = row['user_unit_progress'] as List?;
      final status = progressRows != null && progressRows.isNotEmpty
          ? progressRows.first['status'] as String
          : 'in_progress';
      final counts = progress[row['id'] as int] ?? const _UnitLessonProgress();
      return CurriculumUnit.fromJson({
        ...row,
        'status': status,
        'lesson_count': counts.total,
        'completed_lesson_count': counts.completed,
        'minutes_remaining': counts.minutesRemaining,
      });
    }).toList();
  }

  /// Per-unit lesson totals, derived rather than stored: the schema keeps
  /// only a coarse status on `user_unit_progress`, so "62% · 18 min left"
  /// has to be counted from `lessons` against completed `lesson_attempts`.
  ///
  /// Two flat queries plus a client-side fold, rather than a grouped
  /// aggregate — PostgREST can't express this join-and-group without a
  /// database view or RPC. Both are paged via [_fetchAllRows]; see there
  /// for why reading them in one shot is not safe.
  Future<Map<int, _UnitLessonProgress>> _fetchLessonProgress(String userId) async {
    final lessonRows = await _fetchAllRows(
      (from, to) => _client
          .from('lessons')
          .select('id, unit_id, estimated_minutes')
          .order('id', ascending: true)
          .range(from, to),
    );

    final attemptRows = await _fetchAllRows(
      (from, to) => _client
          .from('lesson_attempts')
          .select('lesson_id')
          .eq('user_id', userId)
          .not('completed_at', 'is', null)
          .order('id', ascending: true)
          .range(from, to),
    );

    final completedLessonIds = {
      for (final row in attemptRows) row['lesson_id'] as int,
    };

    final byUnit = <int, _UnitLessonProgress>{};
    for (final row in lessonRows) {
      final unitId = row['unit_id'] as int;
      final done = completedLessonIds.contains(row['id'] as int);
      final current = byUnit[unitId] ?? const _UnitLessonProgress();
      byUnit[unitId] = _UnitLessonProgress(
        total: current.total + 1,
        completed: current.completed + (done ? 1 : 0),
        minutesRemaining:
            current.minutesRemaining + (done ? 0 : row['estimated_minutes'] as int),
      );
    }
    return byUnit;
  }

  /// Consecutive days up to and including today on which the user
  /// completed at least one lesson. A gap of one full day ends the run;
  /// yesterday-but-not-today still counts, so the streak doesn't visibly
  /// reset at midnight before the user has had a chance to practise.
  ///
  /// Dates are bucketed in local time — a streak is about the user's days,
  /// not UTC's.
  Future<int> fetchStreakDays() async {
    final userId = _requireUserId();

    // Paged for the same reason as the progress counts: a truncated read
    // here silently shortens the streak rather than failing.
    final rows = await _fetchAllRows(
      (from, to) => _client
          .from('lesson_attempts')
          .select('completed_at')
          .eq('user_id', userId)
          .not('completed_at', 'is', null)
          .order('completed_at', ascending: false)
          .range(from, to),
    );

    final activeDays = <DateTime>{
      for (final row in rows) dayOf(DateTime.parse(row['completed_at'] as String).toLocal()),
    };
    return streakFromActiveDays(activeDays, DateTime.now());
  }

  /// The consecutive-day count itself, split out from the query so the
  /// calendar edge cases (a gap, a yesterday-only run, a DST boundary) are
  /// provable without a Supabase client. [activeDays] must already be
  /// bucketed through [dayOf]; [now] is any instant on the current day.
  static int streakFromActiveDays(Set<DateTime> activeDays, DateTime now) {
    if (activeDays.isEmpty) return 0;

    final today = dayOf(now);
    // Yesterday-but-not-today still counts, so the streak doesn't visibly
    // reset at midnight before the user has had a chance to practise.
    var cursor = activeDays.contains(today) ? today : dayOf(today.subtract(const Duration(days: 1)));
    if (!activeDays.contains(cursor)) return 0;

    var streak = 0;
    while (activeDays.contains(cursor)) {
      streak++;
      cursor = dayOf(cursor.subtract(const Duration(days: 1)));
    }
    return streak;
  }

  /// Midnight-local for a timestamp. Every step back through the calendar
  /// is re-normalized through this rather than trusting `subtract(1 day)`
  /// alone: on a DST transition a "day" isn't 24 hours, so plain
  /// subtraction lands at 23:00 or 01:00 and would silently fail to match
  /// a midnight-bucketed entry — ending the streak a day early.
  static DateTime dayOf(DateTime value) => DateTime(value.year, value.month, value.day);

  /// Rows per request when paging. Below PostgREST's default cap so a
  /// full page is always the server honouring the range rather than the
  /// cap truncating it.
  static const _pageSize = 500;

  /// Reads every row of a query, a page at a time.
  ///
  /// Load-bearing rather than defensive: PostgREST caps a single response
  /// (Supabase ships a 1000-row default), and it does so *silently* — the
  /// response is a normal 200 with fewer rows than exist. An unpaged read
  /// of `lessons` therefore doesn't fail once the curriculum outgrows the
  /// cap; it quietly starts reporting wrong lesson counts, wrong
  /// percentages and wrong minutes-remaining, with nothing in the app to
  /// indicate the numbers are made up. Paging keeps the derived figures
  /// correct as content grows.
  ///
  /// [page] receives an inclusive `from`/`to` row range. The query must
  /// impose a stable sort, or rows can repeat or be skipped across pages.
  Future<List<dynamic>> _fetchAllRows(
    Future<dynamic> Function(int from, int to) page,
  ) async {
    final all = <dynamic>[];
    var from = 0;
    while (true) {
      final rows = await page(from, from + _pageSize - 1) as List;
      all.addAll(rows);
      // A short page means the server ran out of rows, not that it
      // truncated: the last full page is followed by an empty one.
      if (rows.length < _pageSize) break;
      from += _pageSize;
    }
    return all;
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('CurriculumRepository used with no signed-in user');
    }
    return userId;
  }
}

class _UnitLessonProgress {
  const _UnitLessonProgress({
    this.total = 0,
    this.completed = 0,
    this.minutesRemaining = 0,
  });

  final int total;
  final int completed;
  final int minutesRemaining;
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

final streakDaysProvider = FutureProvider<int>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(curriculumRepositoryProvider).fetchStreakDays();
});
