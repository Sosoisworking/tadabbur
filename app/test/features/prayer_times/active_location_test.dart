import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur/features/prayer_times/data/location_repository.dart';
import 'package:tadabbur/features/prayer_times/domain/manual_city.dart';
import 'package:tadabbur/features/prayer_times/presentation/providers/prayer_times_providers.dart';

/// Declining the location prompt is the *common* path on web and a normal
/// one on mobile, and it used to replace the whole Prayer tab with an
/// error — no prayer times at all. These pin the fallback order so that
/// can't come back.
class _StubLocationRepository implements LocationRepository {
  _StubLocationRepository({this.coordinates});

  final Coordinates? coordinates;

  @override
  Future<Coordinates> getCurrentCoordinates() async {
    final value = coordinates;
    if (value == null) {
      throw const LocationFailureException(LocationFailure.permissionDenied);
    }
    return value;
  }
}

/// Reports whichever city the test wants persisted, without touching
/// shared_preferences.
class _StubLocationController extends PrayerLocationController {
  _StubLocationController(this._city);

  final ManualCity? _city;

  @override
  Future<ManualCity?> build() async => _city;
}

ProviderContainer _containerWith({
  ManualCity? savedCity,
  Coordinates? deviceCoordinates,
}) {
  final container = ProviderContainer(
    overrides: [
      locationRepositoryProvider.overrideWithValue(
        _StubLocationRepository(coordinates: deviceCoordinates),
      ),
      prayerLocationControllerProvider.overrideWith(
        () => _StubLocationController(savedCity),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('activePrayerLocationProvider', () {
    test('falls back to the default city when the device location is refused', () async {
      final container = _containerWith();

      final location = await container.read(activePrayerLocationProvider.future);

      expect(location.label, 'Toronto, Canada');
      expect(location.coordinates.latitude, defaultCity.coordinates.latitude);
      expect(location.coordinates.longitude, defaultCity.coordinates.longitude);
    });

    test('prefers the device location when it is available', () async {
      final container = _containerWith(
        deviceCoordinates: Coordinates(51.5072, -0.1276),
      );

      final location = await container.read(activePrayerLocationProvider.future);

      expect(location.coordinates.latitude, closeTo(51.5072, 0.0001));
      expect(location.label, 'Current location');
    });

    test('a saved city wins over both the device location and the default', () async {
      final cairo = manualCities.firstWhere((c) => c.id == 'cairo');
      final container = _containerWith(
        savedCity: cairo,
        deviceCoordinates: Coordinates(51.5072, -0.1276),
      );

      final location = await container.read(activePrayerLocationProvider.future);

      expect(location.label, 'Cairo, Egypt');
      expect(location.coordinates.latitude, closeTo(cairo.coordinates.latitude, 0.0001));
    });

    test('prayer times still resolve with no device location', () async {
      final container = _containerWith();

      final times = await container.read(prayerTimesProvider.future);

      // Every daily prayer has a time — the screen has something to show
      // rather than an error state.
      for (final prayer in [Prayer.fajr, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha]) {
        expect(times.timeForPrayer(prayer), isNotNull, reason: '${prayer.name} should be calculated');
      }
    });
  });
}
