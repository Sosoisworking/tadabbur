import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Every top-level screen opens the same way: a tracked-out uppercase
/// kicker, then a large flush-left serif title whose final clause is
/// italic and coloured. Screens build that pair through this widget so
/// the rhythm can't drift apart one screen at a time.
///
/// [emphasis] is appended to [title] as an italic accent-coloured run —
/// pass it as a separate string rather than pre-composing a TextSpan, so
/// the two never disagree about size or leading.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.emphasis,
    this.emphasisColor,
    this.titleSize = 30,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? emphasis;
  final Color? emphasisColor;
  final double titleSize;

  /// Sits opposite the title, vertically top-aligned with the eyebrow —
  /// the streak ring on Learn, the location pill on Prayer.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.display(fontSize: titleSize);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow.toUpperCase(), style: AppTypography.eyebrow()),
              const SizedBox(height: AppSpacing.sm),
              Text.rich(
                TextSpan(
                  style: base,
                  children: [
                    TextSpan(text: title),
                    if (emphasis != null)
                      TextSpan(
                        // The mock breaks the emphasis onto its own line
                        // on Learn but keeps it inline on Prayer; a
                        // leading space lets the paragraph wrap decide,
                        // which is what actually holds up across the
                        // real (variable-length) unit and prayer names.
                        text: ' ${emphasis!}',
                        style: AppTypography.emphasis(
                          emphasisColor ?? AppColors.brandPrimary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.lg),
          trailing!,
        ],
      ],
    );
  }
}
