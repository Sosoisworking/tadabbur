import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/row_icon_dot.dart';
import '../../data/curriculum_repository.dart';
import '../../data/lesson_repository.dart';
import '../../domain/curriculum_unit.dart';
import '../../domain/lesson.dart';
import '../unit_theme_icon.dart';

/// The full lesson list for one unit, reached from "See unit" on the Learn
/// tab (which only shows the first few). Pushed over the shell rather than
/// nested in it, so it owns its own back affordance.
class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({super.key, required this.unitId, this.unitTitle});

  final int unitId;
  final String? unitTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsForUnitProvider(unitId));
    // Already fetched for the Learn tab — read from the same provider
    // rather than re-querying, so the header stats here can't disagree
    // with the card the user just tapped through from.
    final unit = ref
        .watch(curriculumUnitsProvider)
        .valueOrNull
        ?.where((u) => u.id == unitId)
        .firstOrNull;
    final title = unit?.title ?? unitTitle ?? 'Unit';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: lessonsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Could not load lessons.\n$error',
                textAlign: TextAlign.center,
                style: AppTypography.label(fontSize: 14),
              ),
            ),
          ),
          data: (lessons) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(lessonsForUnitProvider(unitId));
              await ref.read(lessonsForUnitProvider(unitId).future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _UnitHeader(title: title, unit: unit),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenInset,
                    AppSpacing.xxl,
                    AppSpacing.screenInset,
                    AppSpacing.navOverlayInset,
                  ),
                  sliver: SliverList.separated(
                    itemCount: lessons.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _LessonRow(
                      lesson: lessons[index],
                      unitId: unitId,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitHeader extends StatelessWidget {
  const _UnitHeader({required this.title, required this.unit});

  final String title;

  /// Null only if the units list hasn't resolved yet (deep link, cold
  /// start) — the stats row is dropped rather than showing placeholder
  /// numbers that would be wrong.
  final CurriculumUnit? unit;

  @override
  Widget build(BuildContext context) {
    final glyph = unitGlyph(title);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenInset,
        AppSpacing.sm,
        AppSpacing.screenInset,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: AppSpacing.md),
              if (unit != null)
                Text(
                  'UNIT ${unit!.sequenceOrder}',
                  style: AppTypography.eyebrow(color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Stack(
            clipBehavior: Clip.none,
            children: [
              // The unit's glyph, oversized and translucent behind the
              // title — the same identity mark the Learn carousel card
              // uses, so a unit looks like itself in both places.
              if (glyph != null)
                Positioned(
                  right: -8,
                  top: -30,
                  child: Text(
                    glyph,
                    style: AppTypography.glyphMark(
                      fontSize: 150,
                      color: AppColors.brandPrimary.withValues(alpha: 0.13),
                    ),
                  ),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(title, style: AppTypography.display(fontSize: 34)),
              ),
            ],
          ),
          if (unit != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _Stat(
                  value: '${(unit!.progress * 100).round()}%',
                  label: 'Complete',
                  color: AppColors.brandAccent,
                ),
                const SizedBox(width: AppSpacing.xl),
                _Stat(
                  value: '${unit!.minutesRemaining}',
                  label: 'Minutes left',
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.numeric(fontSize: 22, color: color)),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.label(fontSize: 10.5).copyWith(letterSpacing: 1),
        ),
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.unitId});

  final Lesson lesson;
  final int unitId;

  /// Inferred from the naming convention established across every Qaida
  /// migration so far (e.g. "Fathah Quiz") — the domain model doesn't
  /// carry an explicit lesson "kind" yet, so this is a display-only hint
  /// (which icon/color to show), not something any core logic depends on.
  bool get _isQuiz => lesson.title.toLowerCase().contains('quiz');

  @override
  Widget build(BuildContext context) {
    final accent = _isQuiz ? AppColors.brandAccent : AppColors.brandPrimary;

    return GestureDetector(
      onTap: () => context.push(
        '/lesson/${lesson.id}',
        extra: (unitId: unitId, lessonTitle: lesson.title),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            RowIconDot(
              icon: _isQuiz ? Icons.quiz_rounded : Icons.menu_book_rounded,
              background: accent.withValues(alpha: 0.16),
              foreground: accent,
              size: 42,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppTypography.display(fontSize: 17),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${lesson.estimatedMinutes} min',
                    style: AppTypography.label(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
