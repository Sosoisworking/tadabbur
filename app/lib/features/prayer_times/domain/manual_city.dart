import 'package:adhan_dart/adhan_dart.dart';

/// A manually-selectable location for prayer time calculation — the
/// fallback when GPS is denied/unavailable, or simply preferred over the
/// device's current position (e.g. calculating for a hometown).
class ManualCity {
  const ManualCity({
    required this.id,
    required this.name,
    required this.country,
    required this.coordinates,
  });

  final String id;
  final String name;
  final String country;
  final Coordinates coordinates;

  String get displayName => '$name, $country';
}

/// Where prayer times are calculated for when the device's own location
/// can't be used — permission denied, hardware unavailable, or a browser
/// that never answers the request.
///
/// A real city rather than an error: prayer times are the kind of thing a
/// user opens the tab to glance at, and a screen that refuses to show any
/// until a permission dialog is satisfied is worse than one showing a
/// clearly-labelled default they can change. The label is always visible
/// in the header, so the times on screen are never anonymous.
ManualCity get defaultCity =>
    manualCities.firstWhere((city) => city.id == 'toronto');

/// A curated spread of Muslim-majority capitals/major cities plus large
/// diaspora cities — not exhaustive, but enough to cover most users
/// without pulling in a geocoding dependency (which also wouldn't work on
/// Flutter web, unlike this static list).
const List<ManualCity> manualCities = [
  ManualCity(id: 'mecca', name: 'Mecca', country: 'Saudi Arabia', coordinates: Coordinates(21.3891, 39.8579)),
  ManualCity(id: 'medina', name: 'Medina', country: 'Saudi Arabia', coordinates: Coordinates(24.5247, 39.5692)),
  ManualCity(id: 'riyadh', name: 'Riyadh', country: 'Saudi Arabia', coordinates: Coordinates(24.7136, 46.6753)),
  ManualCity(id: 'jeddah', name: 'Jeddah', country: 'Saudi Arabia', coordinates: Coordinates(21.4858, 39.1925)),
  ManualCity(id: 'istanbul', name: 'Istanbul', country: 'Turkiye', coordinates: Coordinates(41.0082, 28.9784)),
  ManualCity(id: 'ankara', name: 'Ankara', country: 'Turkiye', coordinates: Coordinates(39.9334, 32.8597)),
  ManualCity(id: 'cairo', name: 'Cairo', country: 'Egypt', coordinates: Coordinates(30.0444, 31.2357)),
  ManualCity(id: 'alexandria', name: 'Alexandria', country: 'Egypt', coordinates: Coordinates(31.2001, 29.9187)),
  ManualCity(id: 'dubai', name: 'Dubai', country: 'UAE', coordinates: Coordinates(25.2048, 55.2708)),
  ManualCity(id: 'abu_dhabi', name: 'Abu Dhabi', country: 'UAE', coordinates: Coordinates(24.4539, 54.3773)),
  ManualCity(id: 'doha', name: 'Doha', country: 'Qatar', coordinates: Coordinates(25.2854, 51.5310)),
  ManualCity(id: 'kuwait_city', name: 'Kuwait City', country: 'Kuwait', coordinates: Coordinates(29.3759, 47.9774)),
  ManualCity(id: 'manama', name: 'Manama', country: 'Bahrain', coordinates: Coordinates(26.2285, 50.5860)),
  ManualCity(id: 'muscat', name: 'Muscat', country: 'Oman', coordinates: Coordinates(23.5880, 58.3829)),
  ManualCity(id: 'amman', name: 'Amman', country: 'Jordan', coordinates: Coordinates(31.9454, 35.9284)),
  ManualCity(id: 'beirut', name: 'Beirut', country: 'Lebanon', coordinates: Coordinates(33.8938, 35.5018)),
  ManualCity(id: 'baghdad', name: 'Baghdad', country: 'Iraq', coordinates: Coordinates(33.3152, 44.3661)),
  ManualCity(id: 'damascus', name: 'Damascus', country: 'Syria', coordinates: Coordinates(33.5138, 36.2765)),
  ManualCity(id: 'karachi', name: 'Karachi', country: 'Pakistan', coordinates: Coordinates(24.8607, 67.0011)),
  ManualCity(id: 'lahore', name: 'Lahore', country: 'Pakistan', coordinates: Coordinates(31.5497, 74.3436)),
  ManualCity(id: 'islamabad', name: 'Islamabad', country: 'Pakistan', coordinates: Coordinates(33.6844, 73.0479)),
  ManualCity(id: 'dhaka', name: 'Dhaka', country: 'Bangladesh', coordinates: Coordinates(23.8103, 90.4125)),
  ManualCity(id: 'jakarta', name: 'Jakarta', country: 'Indonesia', coordinates: Coordinates(-6.2088, 106.8456)),
  ManualCity(id: 'kuala_lumpur', name: 'Kuala Lumpur', country: 'Malaysia', coordinates: Coordinates(3.1390, 101.6869)),
  ManualCity(id: 'singapore', name: 'Singapore', country: 'Singapore', coordinates: Coordinates(1.3521, 103.8198)),
  ManualCity(id: 'tehran', name: 'Tehran', country: 'Iran', coordinates: Coordinates(35.6892, 51.3890)),
  ManualCity(id: 'rabat', name: 'Rabat', country: 'Morocco', coordinates: Coordinates(34.0209, -6.8416)),
  ManualCity(id: 'casablanca', name: 'Casablanca', country: 'Morocco', coordinates: Coordinates(33.5731, -7.5898)),
  ManualCity(id: 'algiers', name: 'Algiers', country: 'Algeria', coordinates: Coordinates(36.7538, 3.0588)),
  ManualCity(id: 'tunis', name: 'Tunis', country: 'Tunisia', coordinates: Coordinates(36.8065, 10.1815)),
  ManualCity(id: 'khartoum', name: 'Khartoum', country: 'Sudan', coordinates: Coordinates(15.5007, 32.5599)),
  ManualCity(id: 'lagos', name: 'Lagos', country: 'Nigeria', coordinates: Coordinates(6.5244, 3.3792)),
  ManualCity(id: 'abuja', name: 'Abuja', country: 'Nigeria', coordinates: Coordinates(9.0765, 7.3986)),
  ManualCity(id: 'london', name: 'London', country: 'United Kingdom', coordinates: Coordinates(51.5072, -0.1276)),
  ManualCity(id: 'paris', name: 'Paris', country: 'France', coordinates: Coordinates(48.8566, 2.3522)),
  ManualCity(id: 'berlin', name: 'Berlin', country: 'Germany', coordinates: Coordinates(52.5200, 13.4050)),
  ManualCity(id: 'new_york', name: 'New York', country: 'United States', coordinates: Coordinates(40.7128, -74.0060)),
  ManualCity(id: 'chicago', name: 'Chicago', country: 'United States', coordinates: Coordinates(41.8781, -87.6298)),
  ManualCity(id: 'houston', name: 'Houston', country: 'United States', coordinates: Coordinates(29.7604, -95.3698)),
  ManualCity(id: 'toronto', name: 'Toronto', country: 'Canada', coordinates: Coordinates(43.6532, -79.3832)),
  ManualCity(id: 'sydney', name: 'Sydney', country: 'Australia', coordinates: Coordinates(-33.8688, 151.2093)),
  ManualCity(id: 'johannesburg', name: 'Johannesburg', country: 'South Africa', coordinates: Coordinates(-26.2041, 28.0473)),
];
