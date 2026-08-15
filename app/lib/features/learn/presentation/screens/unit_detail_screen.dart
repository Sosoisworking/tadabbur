import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/lesson_repository.dart';
import '../../domain/lesson.dart';
import '../unit_theme_icon.dart';

class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({super.key, required this.unitId, this.unitTitle});

  final int unitId;
  final String? unitTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsForUnitProvider(unitId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            unitThematicBadge(unitTitle ?? '', size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Text(unitTitle ?? 'Unit'),
          ],
        ),
      ),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load lessons.\n$error', textAlign: TextAlign.center)),
        data: (lessons) => RefreshIndicator(
          onRefresh: () => ref.refresh(lessonsForUnitProvider(unitId).future),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
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

    return AppCard(
      onTap: () => context.push(
        '/lesson/${lesson.id}',
        extra: (unitId: unitId, lessonTitle: lesson.title),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(
            color: accentColor,
            child: Icon(
              _isQuiz ? Icons.quiz_rounded : Icons.menu_book_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            lesson.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: AppSpacing.xs),
              Text('${lesson.estimatedMinutes} min', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
