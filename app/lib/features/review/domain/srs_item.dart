/// What kind of content this SRS item schedules — mirrors the three
/// mutually-exclusive FK columns on srs_items (docs/database-schema.md).
/// grammar_points isn't wired up client-side yet since no grammar
/// content exists to review (docs/feature-specs.md's grammar
/// explanations land in a later milestone).
enum SrsItemKind { vocab, letter }

/// One due item in a user's review queue, already resolved to its
/// display content (the underlying vocab_item or letter row).
class DueSrsItem {
  const DueSrsItem({
    required this.srsItemId,
    required this.kind,
    required this.arabicText,
    required this.label,
    required this.detail,
  });

  final int srsItemId;
  final SrsItemKind kind;
  final String arabicText;
  final String label; // transliteration
  final String detail; // meaning_en (vocab) or pronunciation_guide (letter)
}

/// Result of grading one review — surfaced in the UI so a learner sees
/// concretely when they'll see this item again, not just "saved."
class SrsReviewResult {
  const SrsReviewResult({required this.intervalDays, required this.dueAt});

  final int intervalDays;
  final DateTime dueAt;
}
