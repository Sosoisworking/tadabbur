import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/srs_item.dart';

/// Everything SRS-related goes through the srs-review Edge Function for
/// writes (docs/api-design.md §2) — this repository never inserts/updates
/// srs_items directly, since RLS deliberately grants the client
/// SELECT-only on that table (the SM-2 math and "first exposure" checks
/// have to be trusted server-side, not client-side).
class SrsRepository {
  SrsRepository(this._client);

  final SupabaseClient _client;

  /// Called when a user advances past a vocab_card exercise for the
  /// first time — idempotent, so calling it again for an item already in
  /// the queue is a harmless no-op (docs/feature-specs.md §3).
  Future<void> exposeVocabItem(int vocabItemId) {
    return _invokeExpose({'vocab_item_id': vocabItemId});
  }

  Future<void> exposeLetter(int letterId) {
    return _invokeExpose({'letter_id': letterId});
  }

  Future<int> _invokeExpose(Map<String, dynamic> idField) async {
    final response = await _client.functions.invoke(
      'srs-review',
      body: {'action': 'expose', ...idField},
    );
    return (response.data as Map<String, dynamic>)['srs_item_id'] as int;
  }

  /// Grades a quiz answer directly into that item's SRS schedule — right
  /// or wrong, not just the passive "seen it" signal from exposure. A
  /// wrong answer resets the item's spacing (SM-2 quality < 3), so it
  /// resurfaces for review soon rather than drifting on whatever interval
  /// its last passive exposure happened to set.
  ///
  /// Calls expose first (idempotent) rather than assuming the matching
  /// card was already shown earlier in the lesson — holds even if a
  /// future content change puts a quiz before its card.
  Future<void> gradeFromQuiz({
    int? vocabItemId,
    int? letterId,
    required bool isCorrect,
  }) async {
    if (vocabItemId == null && letterId == null) return;

    final srsItemId = await _invokeExpose(
      vocabItemId != null ? {'vocab_item_id': vocabItemId} : {'letter_id': letterId},
    );
    await submitReview(srsItemId: srsItemId, qualityRating: isCorrect ? 4 : 1);
  }

  Future<List<DueSrsItem>> fetchDueItems() async {
    final userId = _client.auth.currentUser!.id;

    final rows = await _client
        .from('srs_items')
        .select(
          'id, '
          'vocab_items(arabic_text, transliteration, meaning_en), '
          'letters(isolated_form, name_transliteration, pronunciation_guide)',
        )
        .eq('user_id', userId)
        .lte('due_at', DateTime.now().toUtc().toIso8601String())
        .order('due_at', ascending: true) as List;

    return rows.map(_parseDueItem).toList();
  }

  DueSrsItem _parseDueItem(dynamic row) {
    final vocab = _unwrapEmbed(row['vocab_items']);
    if (vocab != null) {
      return DueSrsItem(
        srsItemId: row['id'] as int,
        kind: SrsItemKind.vocab,
        arabicText: vocab['arabic_text'] as String,
        label: vocab['transliteration'] as String,
        detail: vocab['meaning_en'] as String,
      );
    }

    final letter = _unwrapEmbed(row['letters'])!;
    return DueSrsItem(
      srsItemId: row['id'] as int,
      kind: SrsItemKind.letter,
      arabicText: letter['isolated_form'] as String,
      label: letter['name_transliteration'] as String,
      detail: letter['pronunciation_guide'] as String,
    );
  }

  Map<String, dynamic>? _unwrapEmbed(dynamic embed) {
    if (embed == null) return null;
    if (embed is List) return embed.isEmpty ? null : embed.first as Map<String, dynamic>;
    return embed as Map<String, dynamic>;
  }

  Future<SrsReviewResult> submitReview({
    required int srsItemId,
    required int qualityRating,
  }) async {
    final response = await _client.functions.invoke(
      'srs-review',
      body: {
        'action': 'review',
        'srs_item_id': srsItemId,
        'quality_rating': qualityRating,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return SrsReviewResult(
      intervalDays: data['interval_days'] as int,
      dueAt: DateTime.parse(data['due_at'] as String),
    );
  }
}

final srsRepositoryProvider = Provider<SrsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SrsRepository(client);
});

final dueSrsItemsProvider = FutureProvider<List<DueSrsItem>>((ref) {
  return ref.watch(srsRepositoryProvider).fetchDueItems();
});
