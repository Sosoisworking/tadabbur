import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../data/srs_repository.dart';
import '../../domain/srs_item.dart';

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
      body: SafeArea(
        bottom: false,
        child: dueItemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Could not load your review queue.\n$error',
                textAlign: TextAlign.center,
                style: AppTypography.label(fontSize: 14),
              ),
            ),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () => ref.refresh(dueSrsItemsProvider.future),
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
                  sliver: const SliverToBoxAdapter(
                    child: ScreenHeader(eyebrow: "Muraja'ah", title: 'Due today'),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenInset,
                      0,
                      AppSpacing.screenInset,
                      AppSpacing.navOverlayInsetOf(context),
                    ),
                    child: items.isEmpty ? const _AllCaughtUp() : _DueQueue(items: items),
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

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 1.5),
            ),
            child: const Icon(Icons.check_rounded, size: 38, color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('All caught up', style: AppTypography.display(fontSize: 26), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Nothing is due for review right now — come back after a lesson or two.',
            textAlign: TextAlign.center,
            style: AppTypography.label(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DueQueue extends StatelessWidget {
  const _DueQueue({required this.items});

  final List<DueSrsItem> items;

  @override
  Widget build(BuildContext context) {
    // ~10s per item is a rough placeholder estimate; worth tuning against
    // real session timing data once this is live.
    final estimatedMinutes = (items.length * 10 / 60).ceil().clamp(1, 999);
    final vocabCount = items.where((i) => i.kind == SrsItemKind.vocab).length;
    final letterCount = items.where((i) => i.kind == SrsItemKind.letter).length;
    final ayahCount = items.where((i) => i.kind == SrsItemKind.ayah).length;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 212,
            height: 212,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.28), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${items.length}', style: AppTypography.numeric(fontSize: 62, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${items.length == 1 ? 'item' : 'items'} · ~$estimatedMinutes min',
                  style: AppTypography.label(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              if (vocabCount > 0) _CountChip(label: 'word', count: vocabCount),
              if (letterCount > 0) _CountChip(label: 'letter', count: letterCount),
              if (ayahCount > 0) _CountChip(label: 'ayah', count: ayahCount),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          PillButton(
            label: 'Start review',
            icon: Icons.east_rounded,
            onPressed: () => context.push('/review-session'),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        '$count $label${count == 1 ? '' : 's'}',
        style: AppTypography.label(fontSize: 11.5),
      ),
    );
  }
}
