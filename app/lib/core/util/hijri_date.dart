import 'package:hijri/hijri_calendar.dart';

/// Today's Hijri date, as one source of truth for every screen that shows
/// it (the Learn header, the Prayer header) — so they can never disagree.
///
/// [dayOffset] exists because the conversion is arithmetic (tabular), while
/// the date actually observed in a given place follows local moon sighting.
/// The two routinely differ by a day, and for this app that's a
/// credibility detail rather than a rounding error: showing the wrong day
/// of Ramadan is the kind of mistake a user notices immediately. Held at 0
/// until there's a settings screen to expose it — the point of routing
/// every caller through here is that adding one later is a one-file change.
const int hijriDayOffset = 0;

/// Formatted as "11 Rabi' al-Awwal 1448".
String hijriToday({DateTime? now}) {
  final date = _adjusted(now ?? DateTime.now());
  return '${date.hDay} ${date.longMonthName} ${date.hYear}';
}

/// Day and month only ("11 Rabi' al-Awwal") — for places already carrying
/// the year in nearby copy, or too tight to spare it.
String hijriTodayShort({DateTime? now}) {
  final date = _adjusted(now ?? DateTime.now());
  return '${date.hDay} ${date.longMonthName}';
}

HijriCalendar _adjusted(DateTime now) =>
    HijriCalendar.fromDate(now.add(Duration(days: hijriDayOffset)));
