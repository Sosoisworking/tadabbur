import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/lesson.dart';
import '../domain/lesson_exercise.dart';

/// Data layer for taking a lesson: fetching its exercises and recording
/// attempts. Reads and writes here all go through PostgREST + RLS
/// directly (docs/api-design.md §1) — lesson_attempts/exercise_attempts
/// are "own rows, full read/write" tables, unlike srs_items or
/// tutor_messages, which need a trusted server-side gate. No Edge
/// Function involved anywhere in this file.
class LessonRepository {
  LessonRepository(this._client);

  final SupabaseClient _client;

  Future<List<Lesson>> fetchLessonsForUnit(int unitId) async {
    final rows = await _client.from('lessons').select().eq('unit_id', unitId).order('sequence_order');
    return (rows as List).map((row) => Lesson.fromJson(row as Map<String, dynamic>)).toList();
  }

  Future<List<LessonExercise>> fetchExercisesForLesson(int lessonId) async {
    final rows = await _client
        .from('exercises')
        .select(
          'id, exercise_type, sequence_order, '
          'exercise_vocab_card(vocab_items(arabic_text, transliteration, meaning_en, root_letters, wazn_pattern)), '
          'exercise_reading_passage(start_ayah_id, end_ayah_id), '
          'exercise_recall_quiz(question, options, correct_option_index), '
          'exercise_letter_card(letters(isolated_form, name_arabic, name_transliteration, pronunciation_guide))',
        )
        .eq('lesson_id', lessonId)
        .order('sequence_order') as List;

    // Reading passages need a second round trip — a passage spans a
    // *range* of ayat, which a single-row FK embed can't express — so
    // resolve every passage in this lesson up front, keyed by exercise id.
    final pendingPassages = <int, ({int startAyahId, int endAyahId})>{};
    for (final row in rows) {
      if (row['exercise_type'] == 'reading_passage') {
        final rp = _unwrapEmbed(row['exercise_reading_passage']);
        pendingPassages[row['id'] as int] = (
          startAyahId: rp['start_ayah_id'] as int,
          endAyahId: rp['end_ayah_id'] as int,
        );
      }
    }
    final resolvedPassages = await _resolvePassageRanges(pendingPassages);

    return rows.map((row) {
      final id = row['id'] as int;
      final seq = row['sequence_order'] as int;

      switch (row['exercise_type']) {
        case 'vocab_card':
          final vocab = _unwrapEmbed(row['exercise_vocab_card'])['vocab_items'] as Map<String, dynamic>;
          return VocabCardExercise(
            id: id,
            sequenceOrder: seq,
            arabicText: vocab['arabic_text'] as String,
            transliteration: vocab['transliteration'] as String,
            meaningEn: vocab['meaning_en'] as String,
            rootLetters: vocab['root_letters'] as String?,
            waznPattern: vocab['wazn_pattern'] as String?,
          );
        case 'recall_quiz':
          final quiz = _unwrapEmbed(row['exercise_recall_quiz']);
          return RecallQuizExercise(
            id: id,
            sequenceOrder: seq,
            question: quiz['question'] as String,
            options: List<String>.from(quiz['options'] as List),
            correctOptionIndex: quiz['correct_option_index'] as int,
          );
        case 'reading_passage':
          return resolvedPassages[id]!;
        case 'letter_card':
          final letter = _unwrapEmbed(row['exercise_letter_card'])['letters'] as Map<String, dynamic>;
          return LetterCardExercise(
            id: id,
            sequenceOrder: seq,
            isolatedForm: letter['isolated_form'] as String,
            nameArabic: letter['name_arabic'] as String,
            nameTransliteration: letter['name_transliteration'] as String,
            pronunciationGuide: letter['pronunciation_guide'] as String,
          );
        default:
          return UnsupportedExercise(id: id, sequenceOrder: seq, exerciseType: row['exercise_type'] as String);
      }
    }).toList();
  }

  /// PostgREST returns a 1:1 embed as a plain object when the child
  /// table's PK is the FK itself (true of every exercise_* extension
  /// table here) — handled defensively as a single-item list too, in
  /// case that relationship detection ever changes.
  Map<String, dynamic> _unwrapEmbed(dynamic embed) {
    if (embed is List) return embed.first as Map<String, dynamic>;
    return embed as Map<String, dynamic>;
  }

  Future<Map<int, ReadingPassageExercise>> _resolvePassageRanges(
    Map<int, ({int startAyahId, int endAyahId})> ranges,
  ) async {
    final result = <int, ReadingPassageExercise>{};

    for (final entry in ranges.entries) {
      final bounds = await _client
          .from('ayat')
          .select('surah_number, ayah_number')
          .inFilter('id', [entry.value.startAyahId, entry.value.endAyahId])
          .order('ayah_number') as List;

      final surahNumber = bounds.first['surah_number'] as int;
      final startAyah = bounds.first['ayah_number'] as int;
      final endAyah = bounds.last['ayah_number'] as int;

      final ayatRows = await _client
          .from('ayat')
          .select('ayah_number, text_diacritized, translation_en')
          .eq('surah_number', surahNumber)
          .gte('ayah_number', startAyah)
          .lte('ayah_number', endAyah)
          .order('ayah_number') as List;

      result[entry.key] = ReadingPassageExercise(
        id: entry.key,
        sequenceOrder: 0, // caller doesn't need this — only looked up by exercise id
        ayat: ayatRows
            .map((row) => ReadingPassageAyah(
                  ayahNumber: row['ayah_number'] as int,
                  textDiacritized: row['text_diacritized'] as String,
                  translationEn: row['translation_en'] as String,
                ))
            .toList(),
      );
    }

    return result;
  }

  Future<int> startLessonAttempt(int lessonId) async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from('lesson_attempts')
        .insert({'user_id': userId, 'lesson_id': lessonId})
        .select('id')
        .single();
    return row['id'] as int;
  }

  Future<void> recordExerciseAttempt({
    required int lessonAttemptId,
    required int exerciseId,
    required bool isCorrect,
  }) {
    return _client.from('exercise_attempts').insert({
      'lesson_attempt_id': lessonAttemptId,
      'exercise_id': exerciseId,
      'is_correct': isCorrect,
    });
  }

  Future<void> completeLessonAttempt({
    required int lessonAttemptId,
    required int unitId,
    required int correctCount,
    required int totalCount,
  }) async {
    await _client.from('lesson_attempts').update({
      'completed_at': DateTime.now().toIso8601String(),
      'exercises_correct': correctCount,
      'exercises_total': totalCount,
      'xp_earned': correctCount * 10,
    }).eq('id', lessonAttemptId);

    await _maybeMarkUnitCompleted(unitId);
  }

  /// A unit is "completed" once every one of its lessons has a completed
  /// attempt — checked freshly each time rather than assumed, so this
  /// keeps working correctly as units grow beyond Al-Fatiha's single
  /// lesson without needing to change.
  Future<void> _maybeMarkUnitCompleted(int unitId) async {
    final userId = _client.auth.currentUser!.id;

    final lessonRows = await _client.from('lessons').select('id').eq('unit_id', unitId) as List;
    final lessonIds = lessonRows.map((row) => row['id'] as int).toList();
    if (lessonIds.isEmpty) return;

    final attemptRows = await _client
        .from('lesson_attempts')
        .select('lesson_id')
        .eq('user_id', userId)
        .inFilter('lesson_id', lessonIds)
        .not('completed_at', 'is', null) as List;
    final completedLessonIds = attemptRows.map((row) => row['lesson_id'] as int).toSet();

    if (lessonIds.every(completedLessonIds.contains)) {
      await _client
          .from('user_unit_progress')
          .update({'status': 'completed', 'completed_at': DateTime.now().toIso8601String()})
          .match({'user_id': userId, 'unit_id': unitId});
    }
  }
}

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LessonRepository(client);
});

final lessonsForUnitProvider = FutureProvider.family<List<Lesson>, int>((ref, unitId) {
  return ref.watch(lessonRepositoryProvider).fetchLessonsForUnit(unitId);
});

final exercisesForLessonProvider = FutureProvider.family<List<LessonExercise>, int>((ref, lessonId) {
  return ref.watch(lessonRepositoryProvider).fetchExercisesForLesson(lessonId);
});
