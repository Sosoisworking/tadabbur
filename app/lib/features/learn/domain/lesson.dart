/// Mirrors docs/database-schema.md `lessons`.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.sequenceOrder,
    required this.estimatedMinutes,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  final int sequenceOrder;
  final int estimatedMinutes;

  /// Whether this user has finished the lesson at least once.
  ///
  /// Not a column on `lessons` — that table is shared content, identical for
  /// everyone. It is joined on per user from a completed `lesson_attempts`
  /// row (see LessonRepository.fetchLessonsForUnit), which is also why it
  /// defaults to false: a Lesson built straight from content JSON has no
  /// user attached to be complete *for*.
  final bool isCompleted;

  factory Lesson.fromJson(Map<String, dynamic> json, {bool isCompleted = false}) {
    return Lesson(
      id: json['id'] as int,
      title: json['title'] as String,
      sequenceOrder: json['sequence_order'] as int,
      estimatedMinutes: json['estimated_minutes'] as int,
      isCompleted: isCompleted,
    );
  }
}
