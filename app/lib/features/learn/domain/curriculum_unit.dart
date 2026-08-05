/// Mirrors docs/database-schema.md `units` joined with the current user's
/// `user_unit_progress` row. Kept as a plain immutable class (no codegen)
/// to keep the scaffold dependency-light — revisit with freezed if the
/// domain layer grows enough to justify the build_runner step.
class CurriculumUnit {
  const CurriculumUnit({
    required this.id,
    required this.title,
    required this.sequenceOrder,
    required this.status,
  });

  final int id;
  final String title;
  final int sequenceOrder;
  final UnitStatus status;

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    return CurriculumUnit(
      id: json['id'] as int,
      title: json['title'] as String,
      sequenceOrder: json['sequence_order'] as int,
      status: UnitStatus.fromDb(json['status'] as String? ?? 'locked'),
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
}
