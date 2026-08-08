import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/srs_repository.dart';

/// Due-queue entry point (docs/information-architecture.md: "Due-today
/// queue (count + estimated time)"). The actual review session is a
/// separate full-screen route (see core/router/app_router.dart), same
/// pattern as the lesson player — a focused, distraction-free activity,
/// not something to build inline into this tab.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueItemsAsync = ref.watch(dueSrsItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Review'),
          ],
        ),
      ),
      body: dueItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load your review queue.\n$error', textAlign: TextAlign.center),
          ),
        ),
        data: (items) {
          final Widget content;
          if (items.isEmpty) {
            content = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text('All caught up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  'Nothing is due for review right now — come back after a lesson or two.',
                  textAlign: TextAlign.center,
                ),
              ],
            );
          } else {
            // ~10s per item is a rough placeholder estimate; worth tuning
            // against real session timing data once this is live.
            final estimatedMinutes = (items.length * 10 / 60).ceil().clamp(1, 999);
            content = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${items.length}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                Text(items.length == 1 ? 'item due' : 'items due'),
                const SizedBox(height: 4),
                Text('~$estimatedMinutes min', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push('/review-session'),
                  child: const Text('Start Review'),
                ),
              ],
            );
          }

          // Same reasoning as LearnScreen's RefreshIndicator: the
          // IndexedStack bottom-nav shell keeps this screen alive when
          // switching tabs, so a stale due-queue (e.g. right after
          // finishing a lesson elsewhere) needs an explicit way to
          // refresh rather than relying on a rebuild that may not come.
          return RefreshIndicator(
            onRefresh: () => ref.refresh(dueSrsItemsProvider.future),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(padding: const EdgeInsets.all(24), child: content),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
