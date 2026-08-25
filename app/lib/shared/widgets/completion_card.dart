import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'pill.dart';

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.brandAccent.withValues(alpha: 0.16), Colors.transparent],
                      stops: const [0, 0.7],
                    ),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brandAccent.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: const Icon(Icons.star_rounded, size: 38, color: AppColors.brandAccent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(headline, style: AppTypography.display(fontSize: 30), textAlign: TextAlign.center),
            for (final line in detailLines) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                line,
                textAlign: TextAlign.center,
                style: AppTypography.label(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            PillButton(label: buttonLabel, tone: PillTone.accent, onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
