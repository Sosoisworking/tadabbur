import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/lesson_repository.dart';
import '../../domain/lesson.dart';

class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({super.key, required this.unitId, this.unitTitle});

  final int unitId;
  final String? unitTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsForUnitProvider(unitId));

    return Scaffold(
      appBar: AppBar(title: Text(unitTitle ?? 'Unit')),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load lessons.\n$error', textAlign: TextAlign.center)),
        data: (lessons) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) => _LessonTile(lesson: lessons[index], unitId: unitId),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.unitId});

  final Lesson lesson;
  final int unitId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline_rounded),
        title: Text(lesson.title),
        subtitle: Text('${lesson.estimatedMinutes} min'),
        onTap: () => context.push(
          '/lesson/${lesson.id}',
          extra: (unitId: unitId, lessonTitle: lesson.title),
        ),
      ),
    );
  }
}
