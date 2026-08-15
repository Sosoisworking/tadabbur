import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/curriculum_repository.dart';
import '../../domain/curriculum_unit.dart';
import '../unit_theme_icon.dart';

/// Reference screen for the presentation layer pattern: watch a provider,
/// handle loading/error/data explicitly (AsyncValue.when), no business
/// logic here — that all lives in CurriculumRepository. Tapping a unit
/// pushes UnitDetailScreen (see core/router/app_router.dart). Units are
/// never locked (see CurriculumUnit.fromJson) — the UnitStatus.locked
/// branches below are a dead-but-harmless fallback for a status value
/// the schema still technically allows, not a reachable product state.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(curriculumUnitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Learn'),
          ],
        ),
      ),
      body: unitsAsync.when(
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
        data: (units) => RefreshIndicator(
          // Without this, new content added server-side (a new unit, a
          // newly-unlocked one) never appears until something else
          // happens to invalidate this provider — StatefulShellRoute's
          // IndexedStack keeps this screen alive in the background when
          // switching tabs, so simply revisiting Learn doesn't refetch
          // the way it would with a normal push/pop navigation.
          onRefresh: () => ref.refresh(curriculumUnitsProvider.future),
          child: units.isEmpty
              ? ListView(
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
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: units.length,
                  itemBuilder: (context, index) => _UnitTile(unit: units[index]),
                ),
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.unit});

  final CurriculumUnit unit;

  @override
  Widget build(BuildContext context) {
    final locked = unit.status == UnitStatus.locked;
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    // Completed and in-progress used to share scheme.primary — the same
    // color for "still working on it" and "done" fails brand principle 3
    // ("seen vs understood must look different, everywhere"). Completed
    // now gets the dedicated success token instead of reusing primary.
    final badgeColor = switch (unit.status) {
      UnitStatus.locked => semantic.locked,
      UnitStatus.inProgress => scheme.primary,
      UnitStatus.completed => semantic.success,
      UnitStatus.mastered => scheme.secondary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Opacity(
        opacity: locked ? 0.6 : 1,
        child: AppCard(
          onTap: locked ? null : () => context.push('/learn/unit/${unit.id}', extra: unit.title),
          child: Row(
            children: [
              StatusBadge(
                color: badgeColor,
                child: unitThematicBadge(unit.title, size: 24, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      locked ? 'Complete earlier units to unlock' : unit.status.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _trailingIcon(context, unit.status, semantic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trailingIcon(BuildContext context, UnitStatus status, AppSemanticColors semantic) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      UnitStatus.mastered => Icon(Icons.star_rounded, color: scheme.secondary),
      UnitStatus.completed => Icon(Icons.check_circle_rounded, color: semantic.success),
      UnitStatus.locked => Icon(Icons.lock_outline_rounded, color: semantic.locked),
      // The badge color + subtitle already say "active" — no trailing
      // icon needed, but an empty SizedBox keeps the Row's spacing
      // identical across all four states instead of the layout jumping.
      UnitStatus.inProgress => const SizedBox(width: 24),
    };
  }
}
