import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/util/hijri_date.dart';
import '../../../prayer_times/presentation/providers/prayer_times_providers.dart';
import '../../data/settings_repository.dart';
import '../../domain/app_settings.dart';

/// The user's saved preferences, readable synchronously.
///
/// Synchronous because the two seams it feeds are synchronous providers
/// that screens read inline while building a header — making them async
/// would put a loading state on top of every Hijri date in the app for
/// the sake of a disk read that takes a millisecond. Until the store
/// resolves this reports [AppSettings.defaults], and rebuilds once with
/// the stored values; a first frame of the default date is the honest
/// cost of that, and it is one frame.
class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    // Re-runs when the store resolves, so the persisted values arrive
    // without this notifier having to write state from an async gap.
    final store = ref.watch(appSettingsStoreProvider).valueOrNull;
    return store?.read() ?? AppSettings.defaults;
  }

  Future<void> setHijriDayOffset(int offset) async {
    final clamped = offset.clamp(AppSettings.minHijriDayOffset, AppSettings.maxHijriDayOffset);
    if (clamped == state.hijriDayOffset) return;
    // Awaited before the state write, not after: [build] re-reads the
    // store when it resolves, so writing state first would let that
    // rebuild overwrite a change made during the very first frames.
    final store = await ref.read(appSettingsStoreProvider.future);
    await store.saveHijriDayOffset(clamped);
    state = state.copyWith(hijriDayOffset: clamped);
  }

  Future<void> setCalculationMethod(CalculationMethod method) async {
    final store = await ref.read(appSettingsStoreProvider.future);
    await store.saveCalculationMethod(method);
    state = state.copyWith(calculationMethod: method);
  }

  Future<void> setMadhab(Madhab madhab) async {
    final store = await ref.read(appSettingsStoreProvider.future);
    await store.saveMadhab(madhab);
    state = state.copyWith(madhab: madhab);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(
  AppSettingsController.new,
);

/// Points the app's two configuration seams at the persisted settings.
///
/// Overrides rather than rewritten provider bodies, because that is what
/// both seams were built for — see `hijriDayOffsetProvider` and
/// `prayerCalculationSettingsProvider`, each of which documents itself as
/// the single point a settings screen replaces. Keeping the wiring here
/// means neither `core/util` nor the prayer feature has to know this
/// feature exists, and a test can opt into the real persisted behaviour
/// by applying this same list.
///
/// Applied at the root [ProviderScope] in `main.dart`.
final List<Override> settingsOverrides = [
  hijriDayOffsetProvider.overrideWith((ref) => ref.watch(appSettingsProvider).hijriDayOffset),
  prayerCalculationSettingsProvider.overrideWith(
    (ref) => ref.watch(appSettingsProvider).prayerCalculation,
  ),
];
