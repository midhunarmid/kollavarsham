import 'astro/moon.dart';
import 'astro/time.dart';
import 'calendar.dart';
import 'malayalam_date.dart';
import 'panchanga.dart';

/// The Moon's position and the calendar date at a moment of birth: what a
/// horoscope calls the birth star, used to set up a pirannal.
///
/// The [nakshatra], [pada], [rashi] and [tithi] depend only on the moment;
/// the [date] also depends on the calendar's location.
class BirthDetails {
  /// Creates birth details from their parts. Use [BirthDetails.fromInstant]
  /// to compute them.
  const BirthDetails({
    required this.instant,
    required this.nakshatra,
    required this.pada,
    required this.rashi,
    required this.tithi,
    required this.date,
  });

  /// The details at [instant], an exact moment. [calendar] defaults to
  /// [KollavarshamCalendar.standard].
  ///
  /// A [DateTime] that isn't UTC is read in the device's time zone. To enter
  /// a clock time from a birth record, use [BirthDetails.fromLocalTime].
  factory BirthDetails.fromInstant(
    DateTime instant, {
    KollavarshamCalendar? calendar,
  }) {
    final cal = calendar ?? KollavarshamCalendar.standard;
    final utc = instant.toUtc();
    final longitude = moonSiderealLongitude(julianDayFromDateTime(utc));
    // Whole padas since 0° Mesha. There are 108: 4 to a nakshatra, 9 to a
    // rashi.
    final padas = (longitude / (Nakshatra.span / 4)).floor() % 108;
    return BirthDetails(
      instant: utc,
      nakshatra: Nakshatra.values[padas ~/ 4],
      pada: padas % 4 + 1,
      rashi: Rashi.values[padas ~/ 9],
      tithi: cal.tithiAt(utc),
      date: cal.fromGregorian(utc.add(cal.location.utcOffset)),
    );
  }

  /// The details at the clock time in [time] at the calendar's location,
  /// whatever the device's time zone. Only the fields of [time] are read, so
  /// `DateTime(1990, 1, 15, 6, 30)` means 06:30 at that location.
  ///
  /// [calendar] defaults to [KollavarshamCalendar.standard].
  factory BirthDetails.fromLocalTime(
    DateTime time, {
    KollavarshamCalendar? calendar,
  }) {
    final cal = calendar ?? KollavarshamCalendar.standard;
    final utc = DateTime.utc(time.year, time.month, time.day, time.hour,
            time.minute, time.second)
        .subtract(cal.location.utcOffset);
    return BirthDetails.fromInstant(utc, calendar: cal);
  }

  /// The moment of birth (UTC).
  final DateTime instant;

  /// The birth star: the nakshatra of the Moon.
  final Nakshatra nakshatra;

  /// The quarter of the [nakshatra] the Moon was in, 1 to 4.
  final int pada;

  /// The Moon's sign (Chandra rashi, or koor).
  final Rashi rashi;

  /// The tithi at the moment of birth.
  final Tithi tithi;

  /// The Malayalam date of the civil day of birth at the calendar's location.
  /// A birth after midnight and before sunrise has the new day's date.
  final MalayalamDate date;

  @override
  String toString() =>
      'BirthDetails(${nakshatra.english} pada $pada, ${rashi.sanskrit}, '
      '$tithi, $date)';
}
