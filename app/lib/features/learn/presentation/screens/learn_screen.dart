import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/curriculum_repository.dart';
import '../../domain/curriculum_unit.dart';

/// Reference screen for the presentation layer pattern: watch a provider,
/// handle loading/error/data explicitly (AsyncValue.when), no business
/// logic here — that all lives in CurriculumRepository. Real unit-node
/// visuals (locked/in-progress/completed/mastered states from
/// docs/design-system.md) land when the Learn tab is actually built out
/// in implementation-plan.md milestone M2; this proves the data path end
/// to end with a plain list first.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(curriculumUnitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
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
        data: (units) => units.isEmpty
            ? Center(
                child: Text(
                  'No units yet — content is seeded per '
                  'implementation-plan.md milestone M1.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: units.length,
                itemBuilder: (context, index) => _UnitTile(unit: units[index]),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _statusIcon(context, unit.status),
        title: Text(unit.title, style: AppTypography.accent(fontSize: 18)),
        subtitle: Text(unit.status.name),
      ),
    );
  }

  Widget _statusIcon(BuildContext context, UnitStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case UnitStatus.mastered:
        return Icon(Icons.star_rounded, color: scheme.secondary);
      case UnitStatus.completed:
        return const Icon(Icons.check_circle_rounded, color: Colors.green);
      case UnitStatus.inProgress:
        return Icon(Icons.play_circle_outline_rounded, color: scheme.primary);
      case UnitStatus.locked:
        return const Icon(Icons.lock_outline_rounded, color: Colors.grey);
    }
  }
}
