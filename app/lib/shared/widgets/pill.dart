import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// The design has exactly one button shape — a full pill — in three
/// weights. Screens pick a weight rather than assembling their own
/// container, so a new call site can't invent a fourth.
enum PillTone {
  /// Emerald fill. The single primary action on a screen.
  primary,

  /// Gold fill. Reserved for celebratory / terminal actions (finishing a
  /// lesson, starting the first lesson after placement) so it never
  /// competes with [primary] on the same screen.
  accent,

  /// Hairline border, no fill. Everything secondary.
  outline,
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = PillTone.primary,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillTone tone;
  final IconData? icon;

  /// Stretch to the available width. Off by default — the mock's CTAs
  /// hug their label almost everywhere.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      PillTone.primary => (AppColors.brandPrimary, AppColors.onPrimary),
      PillTone.accent => (AppColors.brandAccent, AppColors.onAccent),
      PillTone.outline => (Colors.transparent, AppColors.textSecondary),
    };

    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        side: tone == PillTone.outline
            ? const BorderSide(color: AppColors.borderStrong)
            : null,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        shape: const StadiumBorder(),
        textStyle: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flexible, not a bare Text: a full-width pill carrying a long
          // label ("Start my first lesson") has no room left at a large
          // text scale, and a Row would clip it rather than wrap. Loose
          // fit, so a label that already fits is laid out exactly as
          // before — this only engages once the width runs out.
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          if (icon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, size: 20),
          ],
        ],
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// A small non-interactive status pill — the "IN PROGRESS" / "MASTERED"
/// marker on unit cards, the exercise-kind marker on the deck card.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.foreground,
    this.background,
  });

  final String label;
  final Color foreground;

  /// Defaults to a 14%-alpha wash of [foreground], which is what the
  /// design does for every tinted pill.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? foreground.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: foreground,
        ).copyWith(letterSpacing: 1),
      ),
    );
  }
}

/// An outlined pill carrying an icon and a short label — the location
/// chip on Prayer, the platform switcher on Install, the tag chips under
/// the review counter.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.onPrimary : AppColors.textSecondary;

    return Material(
      color: selected ? AppColors.brandPrimary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.brandPrimary : AppColors.borderSubtle,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              // Flexible for the same reason as [PillButton]'s label: a
              // chip carrying a long city or madhab name has no room left
              // at a large text scale, and a Row clips rather than wraps.
              // Loose fit, so a label that already fits is unaffected.
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.label(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The circular icon button used for back/close affordances, and as the
/// round arrow on inline callouts.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  /// Emerald fill instead of a hairline outline.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.brandPrimary : Colors.transparent,
      shape: CircleBorder(
        side: filled
            ? BorderSide.none
            : const BorderSide(color: AppColors.borderStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.5,
            color: filled ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
