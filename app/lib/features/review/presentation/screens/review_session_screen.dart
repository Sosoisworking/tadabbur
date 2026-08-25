import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/completion_card.dart';
import '../../../../shared/widgets/pill.dart';
import '../../data/srs_repository.dart';
import '../../domain/srs_item.dart';

/// How far (in logical px) a drag has to travel before release counts as
/// a grade rather than a snap-back. Also the distance the edge-rail
/// hints reach full opacity over.
const _dragThreshold = 110.0;

/// Full-screen modal takeover, same pattern as the lesson player
/// (docs/design-system.md) — a focused review session, not something
/// bolted into the due-queue screen. Tap-to-reveal, then grade by
/// dragging the card left (Again) or right (Good), or tapping Hard/Easy
/// below it — all four map onto the SM-2 quality_rating the srs-review
/// Edge Function grades on (docs/feature-specs.md §3).
class ReviewSessionScreen extends ConsumerStatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  ConsumerState<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  List<DueSrsItem>? _items;
  int _index = 0;
  bool _revealed = false;
  bool _completed = false;

  double _dragX = 0;
  bool _dragging = false;
  bool _grading = false;

  /// When the item just graded schedules its next appearance — shown
  /// briefly before advancing so a learner sees concretely *when* they'll
  /// meet this item again, not just that the grade saved
  /// (docs/feature-specs.md §3).
  String? _nextDueLabel;

  @override
  void initState() {
    super.initState();
    // Fetched fresh at session start rather than reusing the Review tab's
    // cached provider value — the queue may have changed since that
    // screen was last shown, and a stale list here would let a review
    // session include an item that's no longer due (or miss one that
    // just became due).
    ref.read(srsRepositoryProvider).fetchDueItems().then((items) {
      if (mounted) setState(() => _items = items);
    });
  }

  Future<void> _grade(int qualityRating) async {
    if (_grading) return;
    _grading = true;
    final item = _items![_index];

    final SrsReviewResult result;
    try {
      result = await ref.read(srsRepositoryProvider).submitReview(
            srsItemId: item.srsItemId,
            qualityRating: qualityRating,
          );
    } catch (e) {
      // A failed grade must not strand the session. On the swipe path the
      // card has already flown off-screen by now, so without this the user
      // is left staring at empty space with no card, no error, and no way
      // forward — snap it back and say what happened, matching how the
      // lesson player surfaces a failed progress write.
      if (!mounted) return;
      setState(() {
        _dragX = 0;
        _dragging = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save that review. Please try again.\n$e')),
      );
      return;
    } finally {
      _grading = false;
    }
    if (!mounted) return;

    final days = result.intervalDays;
    setState(() => _nextDueLabel = 'Next review in $days ${days == 1 ? 'day' : 'days'}');
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    if (_index + 1 >= _items!.length) {
      ref.invalidate(dueSrsItemsProvider);
      setState(() => _completed = true);
    } else {
      setState(() {
        _index++;
        _revealed = false;
        _dragX = 0;
        _dragging = false;
        _nextDueLabel = null;
      });
    }
  }

  /// Animates the card the rest of the way off-screen, then grades once
  /// it's clear. [good] picks Good (drag right) vs Again (drag left) —
  /// the two ratings a swipe can express; Hard/Easy stay button-only
  /// (see [_RatingRow]) since there's no natural swipe direction for a
  /// 4-way rating.
  Future<void> _flyAway({required bool good}) async {
    // Derived from the viewport rather than a fixed constant: a hardcoded
    // distance that clears a phone leaves the card half on-screen on a
    // tablet or a wide browser window.
    final offscreen = MediaQuery.sizeOf(context).width + 120;
    setState(() {
      _dragging = false;
      _dragX = good ? offscreen : -offscreen;
    });
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    await _grade(good ? 4 : 1);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_revealed || _grading) return;
    setState(() {
      _dragging = true;
      _dragX += details.delta.dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_revealed || _grading) return;
    if (_dragX.abs() > _dragThreshold) {
      _flyAway(good: _dragX > 0);
    } else {
      setState(() {
        _dragging = false;
        _dragX = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildBody()));
  }

  Widget _buildBody() {
    if (_items == null) return const Center(child: CircularProgressIndicator());
    if (_completed) {
      return CompletionCard(headline: 'Review complete', onDone: () => Navigator.of(context).pop());
    }
    if (_items!.isEmpty) {
      return Center(child: Text('Nothing due right now.', style: AppTypography.label(fontSize: 14)));
    }

    final item = _items![_index];
    final leftOpacity = (-_dragX / _dragThreshold).clamp(0.0, 1.0);
    final rightOpacity = (_dragX / _dragThreshold).clamp(0.0, 1.0);
    final borderColor = _dragX < 0
        ? Color.lerp(AppColors.borderSubtle, AppColors.error, leftOpacity)!
        : Color.lerp(AppColors.borderSubtle, AppColors.success, rightOpacity)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenInset, AppSpacing.sm, AppSpacing.screenInset, 0),
          child: Row(
            children: [
              CircleIconButton(icon: Icons.close_rounded, onPressed: () => Navigator.of(context).pop()),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / _items!.length,
                    minHeight: 3,
                    backgroundColor: AppColors.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('${_index + 1}/${_items!.length}', style: AppTypography.label(fontSize: 11)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 30,
                  bottom: 96,
                  width: 56,
                  child: _EdgeRail(
                    icon: Icons.replay_rounded,
                    label: 'AGAIN',
                    color: AppColors.error,
                    opacity: leftOpacity,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 30,
                  bottom: 96,
                  width: 56,
                  child: _EdgeRail(
                    icon: Icons.done_all_rounded,
                    label: 'GOOD',
                    color: AppColors.success,
                    opacity: rightOpacity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 46),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        key: ValueKey(item.srsItemId),
                        onTap: _revealed ? null : () => setState(() => _revealed = true),
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: AnimatedContainer(
                          duration: _dragging ? Duration.zero : const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          transform: Matrix4.identity()
                            ..translateByDouble(_dragX, 0, 0, 1)
                            ..rotateZ(_dragX / 900),
                          // Grows with the user's text size rather than
                          // clipping the answer; the surrounding Column
                          // scrolls if the card outgrows the viewport.
                          constraints: BoxConstraints(
                            minHeight: 420 *
                                MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.arabicText,
                                style: AppTypography.arabic(
                                  fontSize: AppTypography.arabicLarge,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_revealed) ...[
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  item.label,
                                  style: AppTypography.label(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  item.detail,
                                  style: AppTypography.display(fontSize: 17),
                                  textAlign: TextAlign.center,
                                ),
                              ] else ...[
                                const SizedBox(height: AppSpacing.xxl),
                                Text('TAP TO REVEAL', style: AppTypography.eyebrow(color: AppColors.textMuted)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Once graded, the scheduling result replaces the
                      // controls rather than sitting alongside them — the
                      // card is on its way out, so offering another grade
                      // would be a control that no longer does anything.
                      if (_nextDueLabel != null)
                        Center(
                          child: Text(
                            _nextDueLabel!,
                            style: AppTypography.label(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        )
                      else if (_revealed) ...[
                        _RatingRow(onHard: () => _grade(3), onEasy: () => _grade(5)),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: Text(
                            'Drag right for Good · left for Again',
                            style: AppTypography.label(fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EdgeRail extends StatelessWidget {
  const _EdgeRail({required this.icon, required this.label, required this.color, required this.opacity});

  final IconData icon;
  final String label;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.label(fontSize: 9, fontWeight: FontWeight.w600, color: color).copyWith(letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.onHard, required this.onEasy});

  final VoidCallback onHard;
  final VoidCallback onEasy;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PillButton(label: 'Hard', tone: PillTone.outline, onPressed: onHard),
        const SizedBox(width: AppSpacing.md),
        PillButton(label: 'Easy', tone: PillTone.accent, onPressed: onEasy),
      ],
    );
  }
}
