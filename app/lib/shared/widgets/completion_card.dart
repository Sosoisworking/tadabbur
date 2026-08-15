import 'package:flutter/material.dart';

import '../../core/theme/app_semantic_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Shared "you finished" moment — was two near-identical copies (lesson
/// completion, review-session completion). One component so a future
/// third completion moment (a mastery challenge, per design-system.md)
/// doesn't become a third copy.
class CompletionCard extends StatelessWidget {
  const CompletionCard({
    super.key,
    required this.headline,
    this.detailLines = const [],
    this.buttonLabel = 'Done',
    required this.onDone,
  });

  final String headline;
  final List<String> detailLines;
  final String buttonLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final success = Theme.of(context).extension<AppSemanticColors>()!.success;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 64, color: success),
            const SizedBox(height: AppSpacing.lg),
            Text(
              headline,
              style: AppTypography.accent(fontSize: 28, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            for (final line in detailLines) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(line, textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(onPressed: onDone, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
