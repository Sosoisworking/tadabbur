import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/util/hijri_date.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../review/data/srs_repository.dart';
import '../../domain/manual_city.dart';
import '../providers/prayer_times_providers.dart';
import '../widgets/city_picker_sheet.dart';

const _rows = [Prayer.fajr, Prayer.sunrise, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];

/// Timeline geometry. The dots are positioned *outside* the row content's
/// left padding, so the connecting line has to be placed from the same
/// numbers or the two stop lining up.
const double _timelineGutter = 34;
const double _dotSize = 12;
const double _lineWidth = 1.5;

/// Arabic names for the five daily prayers plus sunrise — static
/// translation data, not content from the database (Prayer's own
/// [Prayer.displayName] is English-only). Per docs/design-system.md
/// Brand Principle 2, every prayer row shows its Arabic name alongside
/// the English one, not just on dedicated Quran-reading screens.
const _arabicNames = {
  Prayer.fajr: 'الفجر',
  Prayer.sunrise: 'الشروق',
  Prayer.dhuhr: 'الظهر',
  Prayer.asr: 'العصر',
  Prayer.maghrib: 'المغرب',
  Prayer.isha: 'العشاء',
};

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Today's prayer times only change once a day, but the "next prayer"
    // countdown and which row is highlighted as current both depend on
    // the clock — without this they'd freeze at whatever was true when
    // the provider last resolved, drifting more wrong the longer the tab
    // stays open.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final locationLabel = ref.watch(activePrayerLocationProvider).valueOrNull?.label;
    final hijriDayOffset = ref.watch(hijriDayOffsetProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: prayerTimesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            error: error,
            onRetry: () => ref.refresh(activePrayerLocationProvider.future),
            onPickCity: () => showCityPickerSheet(context),
          ),
          data: (prayerTimes) {
            final next = prayerTimes.nextPrayer();
            final remaining = prayerTimes.timeForPrayer(next).toLocal().difference(DateTime.now());

            return RefreshIndicator(
              onRefresh: () => ref.refresh(activePrayerLocationProvider.future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenInset,
                  AppSpacing.md,
                  AppSpacing.screenInset,
                  AppSpacing.navOverlayInsetOf(context),
                ),
                children: [
                  ScreenHeader(
                    eyebrow: 'Today · ${hijriTodayShort(dayOffset: hijriDayOffset)}',
                    title: next.displayName,
                    emphasis: _formatCountdown(remaining),
                    emphasisColor: AppColors.textSecondary,
                    trailing: PillChip(
                      icon: Icons.place_rounded,
                      label: locationLabel ?? defaultCity.displayName,
                      onTap: () => showCityPickerSheet(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _PrayerTimeline(prayerTimes: prayerTimes),
                  _ReviewBeforePrayerCallout(nextPrayer: next),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// "Read before Asr — 3 items due" with a shortcut straight into a review
/// session.
///
/// The one place the two halves of the app meet: it turns the gap before
/// the next prayer into a concrete, already-sized reason to review, rather
/// than leaving Review as a tab the user has to remember on their own.
/// Renders nothing when the queue is empty — an empty prompt to review
/// nothing is worse than no prompt.
class _ReviewBeforePrayerCallout extends ConsumerWidget {
  const _ReviewBeforePrayerCallout({required this.nextPrayer});

  final Prayer nextPrayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCount = ref.watch(dueSrsItemsProvider).valueOrNull?.length ?? 0;
    if (dueCount == 0) return const SizedBox.shrink();

    // Same ~10s-per-item estimate the Review tab shows, so the two can't
    // quote different numbers for the same queue.
    final minutes = (dueCount * 10 / 60).ceil().clamp(1, 999);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Read before ${nextPrayer.displayName}',
                    style: AppTypography.display(fontSize: 17),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$dueCount ${dueCount == 1 ? 'item' : 'items'} due · about '
                    '$minutes ${minutes == 1 ? 'minute' : 'minutes'}',
                    style: AppTypography.label(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            CircleIconButton(
              icon: Icons.east_rounded,
              filled: true,
              size: 46,
              onPressed: () => context.push('/review-session'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimeline extends StatelessWidget {
  const _PrayerTimeline({required this.prayerTimes});

  final PrayerTimes prayerTimes;

  @override
  Widget build(BuildContext context) {
    final current = prayerTimes.currentPrayer();
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(left: _timelineGutter),
      child: Stack(
        // Both the line and the dots sit at negative offsets, in the
        // gutter this Padding creates. Stack clips to its own bounds by
        // default, which erases them entirely.
        clipBehavior: Clip.none,
        children: [
          Positioned(
            // Derived from the dot geometry rather than eyeballed: the
            // dots hang outside this padding (see _PrayerRow), so a
            // literal offset here silently drifts away from them — which
            // is exactly what had happened, leaving the line running
            // beside the dots instead of through them.
            left: -_timelineGutter + _dotSize / 2 - _lineWidth / 2,
            top: 8,
            bottom: 8,
            child: Container(
              width: _lineWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.brandAccent.withValues(alpha: 0.5),
                    AppColors.brandPrimary.withValues(alpha: 0.5),
                    AppColors.borderSubtle,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final prayer in _rows) ...[
                _PrayerRow(
                  prayer: prayer,
                  time: prayerTimes.timeForPrayer(prayer).toLocal(),
                  isCurrent: prayer == current,
                  isPast: prayer != current && prayerTimes.timeForPrayer(prayer).toLocal().isBefore(now),
                  note: _noteFor(prayer, prayerTimes),
                ),
                if (prayer == current) _NowConnector(time: now),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.time,
    required this.isCurrent,
    required this.isPast,
    this.note,
  });

  final Prayer prayer;
  final DateTime time;
  final bool isCurrent;
  final bool isPast;

  /// Second line under the prayer name, for the rows that have a real
  /// calculated time to name there. Most don't, and get none.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final dotColor = isCurrent ? AppColors.brandPrimary : AppColors.brandAccent;

    return Opacity(
      opacity: isPast ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -_timelineGutter,
              top: 5,
              child: Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgBase, width: 2),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      prayer.displayName,
                      style: AppTypography.display(fontSize: 21, color: isCurrent ? AppColors.textPrimary : null),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _arabicNames[prayer] ?? '',
                      style: AppTypography.arabic(fontSize: 24, color: dotColor),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(time),
                      style: AppTypography.numeric(fontSize: 15, color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary),
                    ),
                  ],
                ),
                if (note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(note!, style: AppTypography.label(fontSize: 11)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NowConnector extends StatelessWidget {
  const _NowConnector({required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(height: 1.5, color: AppColors.brandAccent),
                Positioned(
                  left: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.brandAccent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'NOW ${_formatTime(time)}',
            style: AppTypography.label(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.brandAccent)
                .copyWith(letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

/// Shown when the times themselves can't be produced — never when the
/// location is unknown. [activePrayerLocationProvider] absorbs GPS failure
/// and falls back to [defaultCity], so a `LocationFailureException` can no
/// longer reach this widget; blaming location here would send the user
/// chasing a permission prompt that isn't the problem.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry, required this.onPickCity});

  final Object error;
  final VoidCallback onRetry;
  final VoidCallback onPickCity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Couldn't work out today's times",
                    style: AppTypography.display(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Something went wrong calculating them.\n$error',
                    textAlign: TextAlign.center,
                    style: AppTypography.label(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PillButton(label: 'Try again', onPressed: onRetry),
                  const SizedBox(height: AppSpacing.sm),
                  // Kept because the surviving failure modes are tied to the
                  // location in use — a different city recalculates from
                  // scratch — not because location lookup can fail.
                  PillButton(label: 'Choose another city', tone: PillTone.outline, onPressed: onPickCity),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Isha is the only row with a second time worth naming: [SunnahTimes]
/// derives the last third of the night from the same calculation, so it
/// costs nothing extra and is real data rather than decoration. The other
/// prayers have no comparable figure, so they get no note at all.
String? _noteFor(Prayer prayer, PrayerTimes prayerTimes) {
  if (prayer != Prayer.isha) return null;
  final lastThird = SunnahTimes(prayerTimes).lastThirdOfTheNight.toLocal();
  return 'Last third begins ${_formatTime(lastThird)}';
}

String _formatTime(DateTime time) {
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

String _formatCountdown(Duration remaining) {
  if (remaining.isNegative) return 'now';
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes % 60;
  if (hours > 0) return 'in ${hours}h ${minutes}m';
  if (minutes > 0) return 'in ${minutes}m';
  return 'in less than a minute';
}
