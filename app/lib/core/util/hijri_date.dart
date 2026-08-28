import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

/// Days to shift the tabular conversion by, because that conversion is
/// arithmetic while the date actually observed in a given place follows
/// local moon sighting. The two routinely differ by a day, and for this app
/// that's a credibility detail rather than a rounding error: showing the
/// wrong day of Ramadan is the kind of mistake a user notices immediately.
///
/// A provider rather than a constant so the correction can come from the
/// user at runtime — a future settings screen overrides this one seam and
/// every Hijri date in the app follows, with no rebuild and nothing else
/// to rewire. Stays 0 until then.
final hijriDayOffsetProvider = Provider<int>((ref) => 0);

/// Today's Hijri date, as one source of truth for every screen that shows
/// it (the Learn header, the Prayer header) — so they can never disagree.
/// Formatted as "11 Rabi' al-Awwal 1448".
///
/// [dayOffset] is required rather than defaulted: a call site that forgot
/// to pass it would silently ignore the user's correction, which is the
/// one failure this seam exists to prevent.
String hijriToday({required int dayOffset, DateTime? now}) {
  final date = _adjusted(now ?? DateTime.now(), dayOffset);
  return '${date.hDay} ${date.longMonthName} ${date.hYear}';
}

/// Day and month only ("11 Rabi' al-Awwal") — for places already carrying
/// the year in nearby copy, or too tight to spare it.
String hijriTodayShort({required int dayOffset, DateTime? now}) {
  final date = _adjusted(now ?? DateTime.now(), dayOffset);
  return '${date.hDay} ${date.longMonthName}';
}

HijriCalendar _adjusted(DateTime now, int dayOffset) =>
    HijriCalendar.fromDate(now.add(Duration(days: dayOffset)));
