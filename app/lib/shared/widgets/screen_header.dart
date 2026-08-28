import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'pill.dart';
import 'settings_scope.dart';

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
  /// the streak ring on Learn, the location pill on Prayer. Where Settings
  /// is reachable (see [SettingsScope]) the gear sits to the right of it,
  /// so the entry point lands in the same corner on every screen that has
  /// one instead of moving with whatever else the header carries.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.display(fontSize: titleSize);
    final openSettings = SettingsScope.maybeOf(context);

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
        if (trailing != null || openSettings != null) ...[
          const SizedBox(width: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?trailing,
              if (openSettings != null) ...[
                if (trailing != null) const SizedBox(width: AppSpacing.sm),
                Semantics(
                  label: 'Settings',
                  button: true,
                  container: true,
                  excludeSemantics: true,
                  child: CircleIconButton(
                    icon: Icons.settings_rounded,
                    // The 44pt floor docs/design-system.md calls
                    // non-negotiable, not the widget's 40pt default.
                    size: AppSpacing.minTouchTarget,
                    onPressed: () => openSettings(context),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
