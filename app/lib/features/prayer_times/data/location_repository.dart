import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/manual_city.dart';

enum LocationFailure { serviceDisabled, permissionDenied, permissionDeniedForever }

/// Thrown by [LocationRepository.getCurrentCoordinates] — a typed reason
/// instead of a bare error string, so the screen can show the right
/// recovery action (retry vs. "open Settings" vs. "pick a city instead")
/// rather than a generic failure message.
class LocationFailureException implements Exception {
  const LocationFailureException(this.reason);

  final LocationFailure reason;

  String get message => switch (reason) {
    LocationFailure.serviceDisabled => 'Location services are turned off on this device.',
    LocationFailure.permissionDenied => 'Location permission was denied.',
    LocationFailure.permissionDeniedForever =>
      'Location permission is permanently denied. Enable it from system settings to use your current location.',
  };

  @override
  String toString() => message;
}

/// Fetches a single device position for prayer time calculation — a
/// one-off fix, not a continuous stream, since prayer times only need
/// recalculating once per tab visit, not on every meter of movement.
class LocationRepository {
  const LocationRepository();

  Future<Coordinates> getCurrentCoordinates() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailureException(LocationFailure.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailureException(LocationFailure.permissionDenied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailureException(LocationFailure.permissionDeniedForever);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
    return Coordinates(position.latitude, position.longitude);
  }
}

/// Persists whether the Prayer Times tab should use device GPS or a
/// manually-picked city, so reopening the tab doesn't re-prompt for
/// location permission or silently drop back to GPS every time.
class PrayerLocationStore {
  PrayerLocationStore(this._prefs);

  static const _modeKey = 'prayer_location_mode';
  static const _cityIdKey = 'prayer_location_city_id';

  final SharedPreferences _prefs;

  /// The persisted manual city, or null if the store has no saved
  /// selection (either never set, or explicitly set to "use device").
  ManualCity? readManualCity() {
    if (_prefs.getString(_modeKey) != 'manual') return null;
    final id = _prefs.getString(_cityIdKey);
    for (final city in manualCities) {
      if (city.id == id) return city;
    }
    return null;
  }

  Future<void> saveManualCity(ManualCity city) async {
    await _prefs.setString(_modeKey, 'manual');
    await _prefs.setString(_cityIdKey, city.id);
  }

  Future<void> saveUseDeviceLocation() async {
    await _prefs.setString(_modeKey, 'device');
    await _prefs.remove(_cityIdKey);
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) => const LocationRepository());

final _sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

final prayerLocationStoreProvider = FutureProvider<PrayerLocationStore>((ref) async {
  final prefs = await ref.watch(_sharedPreferencesProvider.future);
  return PrayerLocationStore(prefs);
});
