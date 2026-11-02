import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

/// Kalams shown on the Today and Day screens, in display order.
const shownKalams = [Kalam.rahu, Kalam.gulika, Kalam.yamagandam];

/// The panchangam of one civil day at a calendar's location.
///
/// Instants are UTC; show them with [localTime].
class DayInfo {
  DayInfo._({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.nakshatras,
    required this.tithis,
    required this.yogas,
    required this.karanas,
    required this.kalams,
    required this.festivals,
    required this.monthStartMargin,
  });

  /// Computes the panchangam of [date] in its calendar.
  factory DayInfo.of(MalayalamDate date) {
    final calendar = date.calendar;
    final day = date.toGregorian();
    final next = day.add(const Duration(days: 1));
    final sunrise = calendar.sunrise(day);
    // Without a sunrise, read the day from 06:00 local time.
    DateTime start(DateTime d) =>
        calendar.sunrise(d) ??
        DateTime.utc(d.year, d.month, d.day, 6)
            .subtract(calendar.location.utcOffset);
    final from = start(day);
    final to = start(next);
    return DayInfo._(
      date: date,
      sunrise: sunrise,
      sunset: calendar.sunset(day),
      moonrise: calendar.moonrise(day),
      moonset: calendar.moonset(day),
      nakshatras: spansBetween(calendar.nakshatraSpanAt, from, to),
      tithis: spansBetween(calendar.tithiSpanAt, from, to),
      yogas: spansBetween(calendar.yogaSpanAt, from, to),
      karanas: spansBetween(calendar.karanaSpanAt, from, to),
      kalams: [
        for (final k in shownKalams)
          if (calendar.kalamOn(day, k) case final span?) span,
      ],
      festivals: calendar.festivalsOn(date),
      monthStartMargin: date.day == 1
          ? calendar.monthStartMargin(date.year, date.month)
          : null,
    );
  }

  /// The day.
  final MalayalamDate date;

  /// Sunrise, or null if the Sun does not rise.
  final DateTime? sunrise;

  /// Sunset, or null if the Sun does not set.
  final DateTime? sunset;

  /// Moonrise, or null on the day each month without one.
  final DateTime? moonrise;

  /// Moonset, or null on the day each month without one.
  final DateTime? moonset;

  /// Nakshatras from this sunrise to the next, in order; the first is the
  /// day's star.
  final List<PanchangaSpan<Nakshatra>> nakshatras;

  /// Tithis from this sunrise to the next, in order.
  final List<PanchangaSpan<Tithi>> tithis;

  /// Yogas from this sunrise to the next, in order.
  final List<PanchangaSpan<Yoga>> yogas;

  /// Karanas from this sunrise to the next, in order.
  final List<PanchangaSpan<Karana>> karanas;

  /// Rahu kalam, Gulika kalam and Yamagandam, where the Sun rises and sets.
  final List<PanchangaSpan<Kalam>> kalams;

  /// Kerala festivals on the day.
  final List<KeralaFestival> festivals;

  /// On a month's first day, how far the sankranti was from the cut-off
  /// that decides the month start; null on other days.
  final Duration? monthStartMargin;

  /// The paksha at sunrise.
  Paksha get paksha => tithis.first.value.paksha;

  /// Whether almanacs may put the month start a day off: within ten
  /// minutes of the cut-off (see design.md, Day detail).
  bool get monthStartIsClose =>
      monthStartMargin != null && monthStartMargin!.abs().inMinutes < 10;
}

/// The spans that overlap [from]–[to], in order, found by stepping from one
/// span's end to the next with [spanAt].
List<PanchangaSpan<T>> spansBetween<T>(
  PanchangaSpan<T> Function(DateTime) spanAt,
  DateTime from,
  DateTime to,
) {
  final spans = [spanAt(from)];
  while (spans.last.end.isBefore(to)) {
    spans.add(spanAt(spans.last.end.add(const Duration(seconds: 1))));
  }
  return spans;
}

/// [instant] as a wall-clock time at [calendar]'s location, in a DateTime
/// whose fields hold that local time.
DateTime localTime(DateTime instant, KollavarshamCalendar calendar) =>
    instant.toUtc().add(calendar.location.utcOffset);

/// The first Kerala festival after [date], within the next two years.
(KeralaFestival, MalayalamDate)? nextFestival(MalayalamDate date) {
  final calendar = date.calendar;
  for (var year = date.year; year <= date.year + 2; year++) {
    for (final entry in calendar.festivalsIn(year)) {
      if (entry.$2.isAfter(date)) return entry;
    }
  }
  return null;
}
