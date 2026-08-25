import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/util/hijri_date.dart';
import '../../../../shared/widgets/row_icon_dot.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../data/curriculum_repository.dart';
import '../../data/lesson_repository.dart';
import '../../domain/curriculum_unit.dart';
import '../../domain/lesson.dart';
import '../unit_theme_icon.dart';

/// Learn tab: a horizontal unit carousel (tap a card to bring it forward)
/// with that unit's lesson list underneath. Reference screen for the
/// presentation layer pattern — watch a provider, handle loading/error/
/// data explicitly (AsyncValue.when), no business logic here — that all
/// lives in CurriculumRepository/LessonRepository. "See unit" pushes the
/// full UnitDetailScreen grid; tapping a lesson row pushes the player.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  int? _selectedUnitId;

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(curriculumUnitsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: unitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Could not load your curriculum path.\n$error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          data: (units) => units.isEmpty
              ? RefreshIndicator(
                  onRefresh: () => ref.refresh(curriculumUnitsProvider.future),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'No units yet — content is seeded per '
                          'implementation-plan.md milestone M1. Pull down to refresh.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )
              : _LearnBody(
                  units: units,
                  selectedUnitId: _selectedUnitId ?? units.first.id,
                  onSelectUnit: (id) => setState(() => _selectedUnitId = id),
                ),
        ),
      ),
    );
  }
}

class _LearnBody extends ConsumerStatefulWidget {
  const _LearnBody({
    required this.units,
    required this.selectedUnitId,
    required this.onSelectUnit,
  });

  final List<CurriculumUnit> units;
  final int selectedUnitId;
  final ValueChanged<int> onSelectUnit;

  @override
  ConsumerState<_LearnBody> createState() => _LearnBodyState();
}

class _LearnBodyState extends ConsumerState<_LearnBody> {
  final _carouselController = ScrollController();

  /// Card width plus the gap between cards — the distance one step of the
  /// carousel moves.
  static const _cardStride = 214 + 14.0;

  @override
  void didUpdateWidget(_LearnBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedUnitId != widget.selectedUnitId) _revealSelected();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  /// Brings the selected card fully into view. Tapping a card that's only
  /// half on-screen otherwise selects it without moving the strip, so the
  /// thing the user just chose stays clipped at the edge.
  void _revealSelected() {
    if (!_carouselController.hasClients) return;
    final index = widget.units.indexWhere((u) => u.id == widget.selectedUnitId);
    if (index < 0) return;
    final target = (index * _cardStride).clamp(
      _carouselController.position.minScrollExtent,
      _carouselController.position.maxScrollExtent,
    );
    _carouselController.animateTo(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.units;
    final selectedUnitId = widget.selectedUnitId;
    final onSelectUnit = widget.onSelectUnit;
    final selectedIndex = units.indexWhere((u) => u.id == selectedUnitId);
    final selectedUnit = units[selectedIndex < 0 ? 0 : selectedIndex];
    final streakAsync = ref.watch(streakDaysProvider);

    return RefreshIndicator(
      // Everything the screen shows, not just the unit list: the streak
      // and the visible unit's lessons are separate providers, and
      // refreshing only the units left both visibly stale after a pull.
      onRefresh: () async {
        ref.invalidate(streakDaysProvider);
        ref.invalidate(lessonsForUnitProvider(selectedUnit.id));
        ref.invalidate(curriculumUnitsProvider);
        // Awaited so the spinner stays up until the list this screen is
        // actually built from has come back, not just until the
        // invalidations are queued.
        await ref.read(curriculumUnitsProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenInset,
              AppSpacing.md,
              AppSpacing.screenInset,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: ScreenHeader(
                eyebrow: hijriToday(dayOffset: ref.watch(hijriDayOffsetProvider)),
                title: 'Keep going,',
                emphasis: selectedUnit.title,
                trailing: _StreakRing(days: streakAsync.valueOrNull),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: SizedBox(
                // Grows with the user's text size instead of clipping.
                // Bounded because the carousel is a fixed-height strip by
                // design — past ~1.7x the cards would eat the whole
                // screen, and the lesson list below is the more useful
                // thing to keep reachable.
                height: 238 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.7),
                child: ListView.separated(
                  controller: _carouselController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenInset),
                  itemCount: units.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    return _UnitCard(
                      unit: unit,
                      selected: unit.id == selectedUnit.id,
                      onTap: () => onSelectUnit(unit.id),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < units.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 3,
                      width: i == selectedIndex ? 18 : 6,
                      decoration: BoxDecoration(
                        color: i == selectedIndex
                            ? AppColors.brandPrimary
                            : AppColors.borderStrong,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenInset,
              0,
              AppSpacing.screenInset,
              AppSpacing.navOverlayInset,
            ),
            sliver: SliverToBoxAdapter(
              child: _LessonsSection(unit: selectedUnit),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakRing extends StatelessWidget {
  const _StreakRing({required this.days});

  /// Null while the streak is still loading, or if the fetch failed.
  /// Rendered as a dash rather than falling back to 0 — "0 DAYS" is a
  /// claim about the user's practice, and showing it because a query
  /// failed tells them something untrue about their own record.
  final int? days;

  @override
  Widget build(BuildContext context) {
    // Scales with the user's text size so the number and its label stay
    // inside the ring; bounded so it can't crowd out the title beside it.
    final size = 62 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandAccent.withValues(alpha: 0.45), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            days?.toString() ?? '—',
            style: AppTypography.numeric(fontSize: 18, color: AppColors.brandAccent),
          ),
          const SizedBox(height: 3),
          Text(
            'DAYS',
            style: AppTypography.label(fontSize: 8, fontWeight: FontWeight.w500)
                .copyWith(letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit, required this.selected, required this.onTap});

  final CurriculumUnit unit;
  final bool selected;
  final VoidCallback onTap;

  Color _statusColor() => switch (unit.status) {
        UnitStatus.locked => AppColors.locked,
        UnitStatus.inProgress => AppColors.brandPrimary,
        UnitStatus.completed => AppColors.success,
        UnitStatus.mastered => AppColors.brandAccent,
      };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final glyph = unitGlyph(unit.title);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        scale: selected ? 1 : 0.95,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          opacity: selected ? 1 : 0.6,
          child: Container(
            // Height comes from the carousel strip (which scales with the
            // user's text size) rather than being pinned here, so the
            // card can't be shorter than the text it has to hold.
            width: 214,
            padding: const EdgeInsets.all(22),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: selected ? statusColor.withValues(alpha: 0.14) : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(
                color: selected ? statusColor.withValues(alpha: 0.5) : AppColors.borderSubtle,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -6,
                  bottom: -30,
                  child: glyph != null
                      ? Text(
                          glyph,
                          style: AppTypography.glyphMark(
                            fontSize: 120,
                            color: statusColor.withValues(alpha: 0.16),
                          ),
                        )
                      : Icon(
                          Icons.auto_stories_rounded,
                          size: 90,
                          color: statusColor.withValues(alpha: 0.16),
                        ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flexible so the title inside can ellipsize: a plain
                    // Column child gets unbounded height, which would let
                    // the title grow past the card instead of clipping.
                    Flexible(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            unit.status.label.toUpperCase(),
                            style: AppTypography.label(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ).copyWith(letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Flexible so a long title at a large text size
                        // ellipsizes instead of pushing the meta row and
                        // progress bar out the bottom of the card.
                        Flexible(
                          child: Text(
                            unit.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.display(fontSize: 21),
                          ),
                        ),
                      ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.progress >= 1
                              ? '${unit.lessonCount} lessons'
                              : '${unit.completedLessonCount}/${unit.lessonCount} lessons · ${unit.minutesRemaining} min left',
                          style: AppTypography.label(fontSize: 11),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: unit.progress,
                            minHeight: 4,
                            backgroundColor: AppColors.textPrimary.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation(statusColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonsSection extends ConsumerWidget {
  const _LessonsSection({required this.unit});

  final CurriculumUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsForUnitProvider(unit.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LESSONS', style: AppTypography.eyebrow(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => context.push('/learn/unit/${unit.id}', extra: unit.title),
              child: Text(
                'See unit',
                style: AppTypography.label(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        lessonsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(
            'Could not load lessons.',
            style: AppTypography.label(),
          ),
          data: (lessons) => Column(
            children: [
              for (final lesson in lessons.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LessonRow(lesson: lesson, unitId: unit.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.unitId});

  final Lesson lesson;
  final int unitId;

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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.display(fontSize: 16),
                  ),
                  const SizedBox(height: 3),
                  Text('${lesson.estimatedMinutes} min', style: AppTypography.label(fontSize: 11)),
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
