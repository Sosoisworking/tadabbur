import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
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
        data: (lessons) => RefreshIndicator(
          onRefresh: () => ref.refresh(lessonsForUnitProvider(unitId).future),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: lessons.length,
            itemBuilder: (context, index) => _LessonTile(lesson: lessons[index], unitId: unitId),
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.unitId});

  final Lesson lesson;
  final int unitId;

  /// Inferred from the naming convention established across every Qaida
  /// migration so far (e.g. "Fathah Quiz") — the domain model doesn't
  /// carry an explicit lesson "kind" yet, so this is a display-only
  /// hint (which icon/color to show), not something any core logic
  /// depends on.
  bool get _isQuiz => lesson.title.toLowerCase().contains('quiz');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentColor = _isQuiz ? scheme.secondary : scheme.primary;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          '/lesson/${lesson.id}',
          extra: (unitId: unitId, lessonTitle: lesson.title),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isQuiz ? Icons.quiz_rounded : Icons.menu_book_rounded,
                  color: accentColor,
                ),
              ),
              const Spacer(),
              Text(
                lesson.title,
                style: AppTypography.accent(fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text('${lesson.estimatedMinutes} min', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
