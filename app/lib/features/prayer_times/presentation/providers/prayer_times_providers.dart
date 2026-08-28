import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/location_repository.dart';
import '../../domain/manual_city.dart';
import '../../domain/prayer_calculation_settings.dart';

/// The user's chosen location override — null means "use device GPS".
/// Backed by [PrayerLocationStore] so the choice survives app restarts.
class PrayerLocationController extends AsyncNotifier<ManualCity?> {
  @override
  Future<ManualCity?> build() async {
    final store = await ref.watch(prayerLocationStoreProvider.future);
    return store.readManualCity();
  }

  Future<void> selectCity(ManualCity city) async {
    final store = await ref.read(prayerLocationStoreProvider.future);
    await store.saveManualCity(city);
    state = AsyncData(city);
  }

  /// Switches back to device GPS and forces a fresh position fetch —
  /// without the invalidate, re-selecting "use my location" after a
  /// previous GPS failure would keep showing that cached failure.
  Future<void> useDeviceLocation() async {
    final store = await ref.read(prayerLocationStoreProvider.future);
    await store.saveUseDeviceLocation();
    state = const AsyncData(null);
    ref.invalidate(deviceCoordinatesProvider);
  }
}

final prayerLocationControllerProvider = AsyncNotifierProvider<PrayerLocationController, ManualCity?>(
  PrayerLocationController.new,
);

final deviceCoordinatesProvider = FutureProvider<Coordinates>((ref) {
  return ref.watch(locationRepositoryProvider).getCurrentCoordinates();
});

/// The location prayer times are actually being calculated for, and the
/// name to show for it.
class ActivePrayerLocation {
  const ActivePrayerLocation({required this.coordinates, required this.label});

  final Coordinates coordinates;

  /// Always a real place name — "Toronto, Canada", not "Current location"
  /// — except when the device's own position is in use and there is no
  /// city name to attach to it.
  final String label;
}

/// Resolves, in order: the manually-picked city, the device's GPS fix, or
/// [defaultCity].
///
/// The GPS step is allowed to fail. It routinely does — permission denied,
/// no hardware, or a browser that simply never answers — and previously
/// that failure propagated and replaced the whole tab with an error state,
/// so a user who declined the location prompt could never see a prayer
/// time at all. Falling through to a named default keeps the screen
/// useful; the header shows which city is in use, and the location pill
/// changes it.
final activePrayerLocationProvider = FutureProvider<ActivePrayerLocation>((ref) async {
  final manualCity = await ref.watch(prayerLocationControllerProvider.future);
  if (manualCity != null) {
    return ActivePrayerLocation(
      coordinates: manualCity.coordinates,
      label: manualCity.displayName,
    );
  }

  try {
    final coordinates = await ref.watch(deviceCoordinatesProvider.future);
    return ActivePrayerLocation(coordinates: coordinates, label: 'Current location');
  } catch (error) {
    // Not rethrown: see the doc comment above on why an unusable location
    // is a fallback rather than an error for this screen.
    return ActivePrayerLocation(
      coordinates: defaultCity.coordinates,
      label: defaultCity.displayName,
    );
  }
});

/// Not user-configurable yet, but exposed as a provider so a settings screen
/// only has to override this one seam — every calculation follows from it.
final prayerCalculationSettingsProvider = Provider<PrayerCalculationSettings>(
  (ref) => defaultPrayerCalculationSettings,
);

final prayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final location = await ref.watch(activePrayerLocationProvider.future);
  final settings = ref.watch(prayerCalculationSettingsProvider);
  return PrayerTimes(
    date: DateTime.now(),
    coordinates: location.coordinates,
    calculationParameters: settings.resolve(),
  );
});
