import 'calendar.dart';
import 'format.dart';
import 'names.dart';

/// A date in the Malayalam calendar (Kollavarsham / Malayalam Era).
///
/// ```dart
/// final date = MalayalamDate.fromGregorian(DateTime(2025, 8, 17));
/// print(date); // 1201 Chingam 1
/// print(date.format('d MMMM yyyy')); // 1 ചിങ്ങം 1201
/// ```
///
/// Instances are immutable and compare by the day they denote.
class MalayalamDate implements Comparable<MalayalamDate> {
  /// Creates a date from its Kollavarsham [year], [month] and [day].
  ///
  /// Throws a [RangeError] if [day] is not within the month.
  factory MalayalamDate(
    int year,
    MalayalamMonth month,
    int day, {
    KollavarshamCalendar? calendar,
  }) {
    final cal = calendar ?? KollavarshamCalendar.standard;
    return MalayalamDate.internal(
        year, month, day, cal.dayNumberOf(year, month, day), cal);
  }

  /// Converts a Gregorian date (only its year, month and day are used).
  factory MalayalamDate.fromGregorian(
    DateTime date, {
    KollavarshamCalendar? calendar,
  }) =>
      (calendar ?? KollavarshamCalendar.standard).fromGregorian(date);

  /// Today's date in the calendar's time zone (IST by default).
  factory MalayalamDate.today({KollavarshamCalendar? calendar}) =>
      (calendar ?? KollavarshamCalendar.standard).today();

  /// Internal constructor; use the public factories instead.
  const MalayalamDate.internal(
      this.year, this.month, this.day, this.dayNumber, this.calendar);

  /// Kollavarsham (Malayalam Era) year, e.g. 1201.
  final int year;

  /// Month of the year.
  final MalayalamMonth month;

  /// Day of the month, starting at 1.
  final int day;

  /// Days since 1970-01-01 in local civil time.
  final int dayNumber;

  /// The calendar (location) this date was computed for.
  final KollavarshamCalendar calendar;

  /// The Gregorian date, as a local [DateTime] at midnight.
  DateTime toGregorian() => calendar.dateOfDayNumber(dayNumber);

  /// Day of the week.
  MalayalamWeekday get weekday =>
      MalayalamWeekday.fromDateTimeWeekday(toGregorian().weekday);

  /// Number of days in this date's month (29–32).
  int get monthLength => calendar.monthLength(year, month);

  /// Number of days in this date's Kollavarsham year (365 or 366).
  int get yearLength => calendar.yearLength(year);

  /// The first day of this date's month.
  MalayalamDate get firstDayOfMonth =>
      MalayalamDate.internal(year, month, 1, dayNumber - day + 1, calendar);

  /// The last day of this date's month.
  MalayalamDate get lastDayOfMonth => MalayalamDate.internal(
      year, month, monthLength, dayNumber - day + monthLength, calendar);

  /// The date [days] days later (or earlier, if negative).
  MalayalamDate addDays(int days) {
    if (days == 0) return this;
    final target = day + days;
    if (target >= 1 && target <= monthLength) {
      return MalayalamDate.internal(
          year, month, target, dayNumber + days, calendar);
    }
    return calendar.fromDayNumber(dayNumber + days);
  }

  /// Same day of the month, [months] months later (or earlier). The day is
  /// clamped to the length of the target month.
  MalayalamDate addMonths(int months) {
    final total = year * 12 + month.index + months;
    final y = total ~/ 12;
    final m = MalayalamMonth.values[total % 12];
    final len = calendar.monthLength(y, m);
    return MalayalamDate(y, m, day > len ? len : day, calendar: calendar);
  }

  /// Days from this date to [other] (positive if [other] is later).
  int daysUntil(MalayalamDate other) => other.dayNumber - dayNumber;

  bool isBefore(MalayalamDate other) => dayNumber < other.dayNumber;
  bool isAfter(MalayalamDate other) => dayNumber > other.dayNumber;
  bool isAtSameDayAs(MalayalamDate other) => dayNumber == other.dayNumber;

  /// Formats this date with a pattern.
  ///
  /// | Token  | Meaning                 | Example      |
  /// |--------|-------------------------|--------------|
  /// | `y`    | year                    | 1201         |
  /// | `M`    | month number            | 1            |
  /// | `MM`   | month number, 2 digits  | 01           |
  /// | `MMMM` | month name              | ചിങ്ങം       |
  /// | `d`    | day                     | 7            |
  /// | `dd`   | day, 2 digits           | 07           |
  /// | `EEEE` | weekday name            | ഞായർ         |
  ///
  /// Text in single quotes is copied as-is (`''` is a literal quote).
  /// Names use [script]; set [malayalamDigits] to render numbers as ൧൨൩.
  String format(
    String pattern, {
    MalayalamScript script = MalayalamScript.malayalam,
    bool malayalamDigits = false,
  }) =>
      formatMalayalamDate(this, pattern,
          script: script, malayalamDigits: malayalamDigits);

  @override
  int compareTo(MalayalamDate other) => dayNumber.compareTo(other.dayNumber);

  bool operator <(MalayalamDate other) => dayNumber < other.dayNumber;
  bool operator <=(MalayalamDate other) => dayNumber <= other.dayNumber;
  bool operator >(MalayalamDate other) => dayNumber > other.dayNumber;
  bool operator >=(MalayalamDate other) => dayNumber >= other.dayNumber;

  @override
  bool operator ==(Object other) =>
      other is MalayalamDate &&
      other.dayNumber == dayNumber &&
      identical(other.calendar, calendar);

  @override
  int get hashCode => dayNumber.hashCode;

  @override
  String toString() => '$year ${month.english} $day';
}

/// Converts [DateTime] values to the Malayalam calendar.
extension DateTimeToMalayalam on DateTime {
  /// The Malayalam date for this Gregorian date (time of day is ignored).
  MalayalamDate toMalayalamDate({KollavarshamCalendar? calendar}) =>
      MalayalamDate.fromGregorian(this, calendar: calendar);
}
