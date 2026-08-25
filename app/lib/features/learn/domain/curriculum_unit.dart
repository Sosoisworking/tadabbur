/// Mirrors docs/database-schema.md `units` joined with the current user's
/// `user_unit_progress` row, plus the lesson-level progress the Learn tab
/// needs. Kept as a plain immutable class (no codegen) to keep the
/// scaffold dependency-light — revisit with freezed if the domain layer
/// grows enough to justify the build_runner step.
class CurriculumUnit {
  const CurriculumUnit({
    required this.id,
    required this.title,
    required this.sequenceOrder,
    required this.status,
    required this.lessonCount,
    required this.completedLessonCount,
    required this.minutesRemaining,
  });

  final int id;
  final String title;
  final int sequenceOrder;
  final UnitStatus status;

  /// Lesson totals are derived, not stored: `user_unit_progress` only
  /// carries a coarse status, so the percentage and time-left figures the
  /// Learn tab shows come from counting `lessons` against the user's
  /// completed `lesson_attempts`. See [CurriculumRepository].
  final int lessonCount;
  final int completedLessonCount;

  /// Summed `estimated_minutes` over this unit's not-yet-completed lessons.
  final int minutesRemaining;

  /// 0..1. A unit with no lessons yet reads as 0 rather than dividing by
  /// zero — that happens for units seeded ahead of their content.
  double get progress => lessonCount == 0 ? 0 : completedLessonCount / lessonCount;

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    return CurriculumUnit(
      id: json['id'] as int,
      title: json['title'] as String,
      sequenceOrder: json['sequence_order'] as int,
      // No user_unit_progress row (a unit the user hasn't touched yet)
      // reads as in_progress, not locked — per product decision, units
      // are never gated behind completing earlier ones.
      status: UnitStatus.fromDb(json['status'] as String? ?? 'in_progress'),
      lessonCount: json['lesson_count'] as int? ?? 0,
      completedLessonCount: json['completed_lesson_count'] as int? ?? 0,
      minutesRemaining: json['minutes_remaining'] as int? ?? 0,
    );
  }
}

/// Matches the `status` check constraint on `user_unit_progress` in
/// docs/database-schema.md. `mastered` is derived client-side from a
/// passed mastery_challenges row — see feature-specs.md §9 on why "seen"
/// and "understood" must never share a visual state.
enum UnitStatus {
  locked,
  inProgress,
  completed,
  mastered;

  static UnitStatus fromDb(String value) {
    switch (value) {
      case 'in_progress':
        return UnitStatus.inProgress;
      case 'completed':
        return UnitStatus.completed;
      case 'mastered':
        return UnitStatus.mastered;
      default:
        return UnitStatus.locked;
    }
  }

  String get label => switch (this) {
        UnitStatus.locked => 'Locked',
        UnitStatus.inProgress => 'In progress',
        UnitStatus.completed => 'Completed',
        UnitStatus.mastered => 'Mastered',
      };
}
