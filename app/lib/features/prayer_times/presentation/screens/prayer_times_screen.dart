import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/location_repository.dart';
import '../../domain/manual_city.dart';
import '../providers/prayer_times_providers.dart';
import '../widgets/city_picker_sheet.dart';

const _rows = [Prayer.fajr, Prayer.sunrise, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];

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
    final manualCity = ref.watch(prayerLocationControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.mosque_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Prayer Times'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_alt_outlined),
            tooltip: 'Change location',
            onPressed: () => showCityPickerSheet(context),
          ),
        ],
      ),
      body: prayerTimesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          error: error,
          onRetry: () => ref.refresh(activeCoordinatesProvider.future),
          onPickCity: () => showCityPickerSheet(context),
        ),
        data: (prayerTimes) => RefreshIndicator(
          onRefresh: () => ref.refresh(activeCoordinatesProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _LocationHeader(manualCity: manualCity, onChange: () => showCityPickerSheet(context)),
              const SizedBox(height: AppSpacing.lg),
              _NextPrayerCard(prayerTimes: prayerTimes),
              const SizedBox(height: AppSpacing.lg),
              for (final prayer in _rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PrayerRow(
                    prayer: prayer,
                    time: prayerTimes.timeForPrayer(prayer),
                    isCurrent: prayer == prayerTimes.currentPrayer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.manualCity, required this.onChange});

  final ManualCity? manualCity;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.place_outlined, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            manualCity?.displayName ?? 'Current Location',
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(onPressed: onChange, child: const Text('Change')),
      ],
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.prayerTimes});

  final PrayerTimes prayerTimes;

  @override
  Widget build(BuildContext context) {
    final next = prayerTimes.nextPrayer();
    final time = prayerTimes.timeForPrayer(next).toLocal();
    final remaining = time.difference(DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;
    final onContainer = colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text('Next Prayer', style: TextStyle(color: onContainer, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            next.displayName,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: onContainer),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(_formatTime(time), style: TextStyle(color: onContainer, fontSize: 18)),
          const SizedBox(height: AppSpacing.xs),
          Text(_formatCountdown(remaining), style: TextStyle(color: onContainer.withValues(alpha: 0.75))),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.prayer, required this.time, required this.isCurrent});

  final Prayer prayer;
  final DateTime time;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(_iconFor(prayer), color: isCurrent ? colorScheme.primary : colorScheme.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              prayer.displayName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600),
            ),
          ),
          Text(_formatTime(time.toLocal()), style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  IconData _iconFor(Prayer prayer) => switch (prayer) {
    Prayer.fajr => Icons.nightlight_outlined,
    Prayer.sunrise => Icons.wb_twilight_outlined,
    Prayer.dhuhr => Icons.wb_sunny_outlined,
    Prayer.asr => Icons.sunny,
    Prayer.maghrib => Icons.wb_twilight,
    Prayer.isha => Icons.nights_stay_outlined,
    _ => Icons.access_time,
  };
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry, required this.onPickCity});

  final Object error;
  final VoidCallback onRetry;
  final VoidCallback onPickCity;

  @override
  Widget build(BuildContext context) {
    final message = error is LocationFailureException
        ? (error as LocationFailureException).message
        : 'Could not determine your location.\n$error';

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
                  Icon(Icons.location_off_outlined, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Can't find your location",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(onPressed: onRetry, child: const Text('Try Again')),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(onPressed: onPickCity, child: const Text('Choose a City Instead')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
