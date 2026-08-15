import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/location_repository.dart';
import '../../domain/manual_city.dart';

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

/// Resolves to the manually-picked city's coordinates when one is set,
/// otherwise falls back to a fresh device GPS fix.
final activeCoordinatesProvider = FutureProvider<Coordinates>((ref) async {
  final manualCity = await ref.watch(prayerLocationControllerProvider.future);
  if (manualCity != null) return manualCity.coordinates;
  return ref.watch(deviceCoordinatesProvider.future);
});

/// Muslim World League + Shafi madhab — the most globally common default
/// pairing. Not user-configurable yet; a settings screen to change method/
/// madhab is a natural follow-up once this tab ships.
final prayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final coordinates = await ref.watch(activeCoordinatesProvider.future);
  final params = CalculationMethodParameters.muslimWorldLeague()..madhab = Madhab.shafi;
  return PrayerTimes(date: DateTime.now(), coordinates: coordinates, calculationParameters: params);
});
