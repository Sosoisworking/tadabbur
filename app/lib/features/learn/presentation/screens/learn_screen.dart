import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
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
            padding: const EdgeInsets.all(24),
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
                      padding: const EdgeInsets.all(24),
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
                  padding: const EdgeInsets.all(16),
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
    final badgeColor = switch (unit.status) {
      UnitStatus.locked => scheme.onSurface.withValues(alpha: 0.35),
      UnitStatus.inProgress || UnitStatus.completed => scheme.primary,
      UnitStatus.mastered => scheme.secondary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        enabled: !locked,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: unitThematicBadge(unit.title, size: 24, color: Colors.white),
        ),
        title: Text(unit.title, style: AppTypography.accent(fontSize: 18)),
        subtitle: Text(locked ? 'Complete earlier units to unlock' : unit.status.name),
        trailing: _statusBadge(context, unit.status),
        onTap: locked ? null : () => context.push('/learn/unit/${unit.id}', extra: unit.title),
      ),
    );
  }

  Widget? _statusBadge(BuildContext context, UnitStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case UnitStatus.mastered:
        return Icon(Icons.star_rounded, color: scheme.secondary);
      case UnitStatus.completed:
        return Icon(Icons.check_circle_rounded, color: scheme.primary);
      case UnitStatus.locked:
        return const Icon(Icons.lock_outline_rounded, color: Colors.grey);
      case UnitStatus.inProgress:
        return null; // the badge color + subtitle already say "active"
    }
  }
}
