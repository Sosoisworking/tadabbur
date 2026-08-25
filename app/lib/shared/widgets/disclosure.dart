import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// A collapsed "there's more if you want it" section.
///
/// Several exercise types deliberately hold back their advanced detail —
/// makhraj (articulation point) on a letter card, the full explanation on
/// a grammar or knowledge card. That's a persona decision, not styling: a
/// beginner shouldn't have to read past advanced phonetic detail to
/// recognize the letter in front of them, but the detail still has to be
/// reachable for someone who wants it.
///
/// A bare [ExpansionTile] is deliberately not used — it brings Material
/// list-tile chrome (its own dividers, 56px min height, leading/trailing
/// slots) that fights the deck card's layout. This keeps the same
/// behavior with the card's own type and spacing, and manages its own
/// open/closed state so callers stay stateless.
class Disclosure extends StatefulWidget {
  const Disclosure({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  State<Disclosure> createState() => _DisclosureState();
}

class _DisclosureState extends State<Disclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flexible, not a bare Text: the label is a short
                  // question ("Why would this be off?") that runs out of
                  // room at a large text scale, and a Row clips rather
                  // than wraps. Loose fit, so a label that already fits
                  // lays out exactly as before.
                  Flexible(
                    child: Text(
                      widget.label,
                      style: AppTypography.label(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 18,
                    color: AppColors.brandPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: widget.child,
          ),
      ],
    );
  }
}
