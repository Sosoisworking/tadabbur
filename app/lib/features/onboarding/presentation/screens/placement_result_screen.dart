import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../learn/presentation/unit_theme_icon.dart';
import '../../domain/placement_result.dart';

/// Step 7 of the onboarding flow in docs/information-architecture.md: the
/// recommended starting unit, "shown with a short rationale". The whole
/// job of this screen is to make the routing decision feel earned rather
/// than assigned — so the three axes are shown as evidence before the unit
/// is named.
///
/// Takes a finished [PlacementResult] and nothing else: no provider, no
/// fetching, and no navigation of its own (see [onStartFirstLesson]). That
/// keeps it renderable in isolation from a constructed model, and lets
/// whoever builds the real placement test decide where the result comes
/// from without touching this file.
///
/// No back affordance on purpose — a placement result isn't something you
/// navigate away from and return to, and the only forward move is the CTA.
class PlacementResultScreen extends StatelessWidget {
  const PlacementResultScreen({
    super.key,
    required this.result,
    required this.onStartFirstLesson,
  });

  final PlacementResult result;
  final VoidCallback onStartFirstLesson;

  /// The "short rationale" the IA doc asks for, with one line per row of
  /// docs/feature-specs.md §1's routing table — those three routes are the
  /// only shapes a result can take, so the copy branches on the same thing
  /// the server routed on rather than re-reading the raw scores.
  ///
  /// Split into a plain lead and a trailing clause because [ScreenHeader]
  /// styles the emphasis as the *end* of the sentence; the clause is the
  /// half that names what the user is being given, which is the point of
  /// the screen.
  ({String title, String emphasis}) get _rationale {
    return switch (result.entryPoint) {
      PlacementAxis.scriptLiteracy => (
          title: 'We\'ll start where reading starts —',
          emphasis: 'the letters themselves.',
        ),
      PlacementAxis.recitationFluency => (
          title: 'You can read the script already — so we\'ll build',
          emphasis: 'fluency and meaning together.',
        ),
      PlacementAxis.vocabGrammar => (
          title: 'You already recite fluently — so we\'ll start with',
          emphasis: 'meaning, not letters.',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final rationale = _rationale;

    return Scaffold(
      body: SafeArea(
        // A ListView rather than a Column: the headline, three rows, and
        // the unit card comfortably outgrow a phone at large text scales,
        // and nothing here has a fixed height to give up.
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenInset,
            AppSpacing.xl,
            AppSpacing.screenInset,
            AppSpacing.xxl,
          ),
          children: [
            ScreenHeader(
              eyebrow: 'Placement complete',
              title: rationale.title,
              emphasis: rationale.emphasis,
              titleSize: 28,
            ),
            const SizedBox(height: AppSpacing.xxl),
            for (final outcome in result.axes) ...[
              _VerdictRow(axis: outcome.axis, verdict: outcome.verdict),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.lg),
            _FirstUnitCard(unit: result.recommendedUnit),
            const SizedBox(height: AppSpacing.xl),
            PillButton(
              label: 'Start my first lesson',
              tone: PillTone.accent,
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: onStartFirstLesson,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No account needed yet — we\'ll save your progress after.',
              textAlign: TextAlign.center,
              style: AppTypography.label(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// One axis of evidence: a tinted row whose colour carries the verdict
/// before any of its words are read.
class _VerdictRow extends StatelessWidget {
  const _VerdictRow({required this.axis, required this.verdict});

  final PlacementAxis axis;
  final PlacementVerdict verdict;

  @override
  Widget build(BuildContext context) {
    // Emerald for what the user already has, gold for where they're being
    // taken next — the same split the rest of the app uses for "done" vs
    // "the thing to do now". `comesLater` gets the muted step instead of a
    // third brand colour: it's context, not an outcome, and tinting it
    // would put three rows in competition for the same glance.
    final tint = switch (verdict) {
      PlacementVerdict.strong => AppColors.brandPrimary,
      PlacementVerdict.startingHere => AppColors.brandAccent,
      PlacementVerdict.comesLater => AppColors.textMuted,
    };
    final icon = switch (verdict) {
      PlacementVerdict.strong => Icons.check_circle_rounded,
      PlacementVerdict.startingHere => Icons.trending_up_rounded,
      PlacementVerdict.comesLater => Icons.schedule_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          // Gold sits lighter than emerald at the same alpha and its
          // border all but vanishes, so it gets a touch more.
          color: tint.withValues(
            alpha: verdict == PlacementVerdict.startingHere ? 0.24 : 0.2,
          ),
        ),
      ),
      child: Row(
        children: [
          // A bare icon, not a RowIconDot: the row is already a tinted
          // surface, and a tinted dot inside it doubles the same wash.
          Icon(icon, size: 20, color: tint),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Text(axis.label, style: AppTypography.display(fontSize: 16)),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Flexible rather than a bare Text so the verdict wraps instead
          // of pushing the row past its own edge at a large text scale —
          // the axis label gets the larger share of what's left, since
          // it's the longer string of the two.
          Flexible(
            child: Text(
              verdict.label,
              textAlign: TextAlign.end,
              style: AppTypography.label(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The one thing on the screen the user is meant to walk away remembering.
/// Gets the gold outline and the oversized identity glyph — the same
/// treatment the Learn carousel gives a selected unit, so this unit
/// already looks like itself before it's ever been opened.
class _FirstUnitCard extends StatelessWidget {
  const _FirstUnitCard({required this.unit});

  final RecommendedUnit unit;

  @override
  Widget build(BuildContext context) {
    final glyph = unitGlyph(unit.title);
    final glyphColor = AppColors.brandAccent.withValues(alpha: 0.16);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      // Clipped rather than allowed to overflow: the glyph is positioned
      // past the corner precisely so it bleeds off it.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: AppColors.brandAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            bottom: -30,
            child: glyph != null
                ? Text(glyph, style: AppTypography.glyphMark(fontSize: 120, color: glyphColor))
                : Icon(Icons.auto_stories_rounded, size: 90, color: glyphColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR FIRST UNIT', style: AppTypography.eyebrow()),
              const SizedBox(height: AppSpacing.md),
              Text(unit.title, style: AppTypography.display(fontSize: 24)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${unit.lessonCount} ${unit.lessonCount == 1 ? 'lesson' : 'lessons'} '
                '· ${unit.firstLessonTitle} first',
                style: AppTypography.label(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
