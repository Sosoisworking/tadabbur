/// Mirrors docs/database-schema.md `lessons`.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.sequenceOrder,
    required this.estimatedMinutes,
  });

  final int id;
  final String title;
  final int sequenceOrder;
  final int estimatedMinutes;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      title: json['title'] as String,
      sequenceOrder: json['sequence_order'] as int,
      estimatedMinutes: json['estimated_minutes'] as int,
    );
  }
}
