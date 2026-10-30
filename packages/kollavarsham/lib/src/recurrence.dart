import 'calendar.dart';
import 'malayalam_date.dart';
import 'names.dart';
import 'panchanga.dart';

/// Which day is used when a star is present on two days of a Malayalam month
/// (rule R1 in `docs/pirannal-rules.md`).
enum DuplicateRule {
  /// The later day. This is the default (Janma nakshatra practice, sources
  /// S1 and S2 in the rules document).
  second,

  /// The earlier day.
  first,
}

/// What a yearly star birthday does when its star is present on no day of
/// the Malayalam month (rule R2 in `docs/pirannal-rules.md`).
enum AbsentRule {
  /// The last day of the previous month on which the star is present. This is
  /// the default; the rules document marks it as unsourced.
  previousMonth,

  /// The first day of the next month on which the star is present.
  nextMonth,

  /// No occurrence in that year.
  skip,
}

/// A rule that yields dates: a star birthday, a monthly star, or an
/// anniversary.
///
/// Occurrences are whole days of the Malayalam calendar. A star counts on a
/// day when it is present six nazhika (about 2 h 24 min) after sunrise, the
/// anchor in rule R3 of `docs/pirannal-rules.md`. A day without a sunrise
/// (polar night or day) does not count for a star.
///
/// Recurrences are immutable values. They compare equal by value and can be
/// stored with [toJson] and read back with [Recurrence.fromJson].
sealed class Recurrence {
  const Recurrence();

  /// Reads a recurrence written by [toJson].
  ///
  /// Throws a [FormatException] if the type is unknown or a field is missing
  /// or invalid.
  factory Recurrence.fromJson(Map<String, Object?> json) {
    return switch (json['type']) {
      'nakshatraInMonth' => NakshatraInMonth(
          _enumField(json, 'nakshatra', Nakshatra.values),
          _enumField(json, 'month', MalayalamMonth.values),
          duplicateRule:
              _enumField(json, 'duplicateRule', DuplicateRule.values),
          absentRule: _enumField(json, 'absentRule', AbsentRule.values),
        ),
      'nakshatraMonthly' => NakshatraMonthly(
          _enumField(json, 'nakshatra', Nakshatra.values),
        ),
      'malayalamDateYearly' => MalayalamDateYearly(
          _enumField(json, 'month', MalayalamMonth.values),
          _intField(json, 'day'),
        ),
      'malayalamDateMonthly' => MalayalamDateMonthly(
          _intField(json, 'day'),
        ),
      'gregorianYearly' => GregorianYearly(
          _intField(json, 'month'),
          _intField(json, 'day'),
        ),
      _ => throw FormatException('Unknown recurrence type: ${json['type']}'),
    };
  }

  /// The occurrences from [from] to [to] (inclusive, by calendar day), in
  /// order and without duplicates.
  ///
  /// Only the year and month of [from] and [to] are used. [calendar] defaults
  /// to [KollavarshamCalendar.standard].
  List<MalayalamDate> occurrencesBetween(
    DateTime from,
    DateTime to, {
    KollavarshamCalendar? calendar,
  }) {
    final cal = calendar ?? KollavarshamCalendar.standard;
    final lo = cal.dayNumberOfGregorian(from);
    final hi = cal.dayNumberOfGregorian(to);
    if (lo > hi) return const [];
    final days = <int>{};
    for (var y = _yearOf(cal, from) - 1; y <= _yearOf(cal, to) + 1; y++) {
      days.addAll(_dayNumbersIn(cal, y).where((n) => n >= lo && n <= hi));
    }
    return [for (final n in days.toList()..sort()) cal.fromDayNumber(n)];
  }

  /// The first occurrence strictly after the day of [after], or `null` if
  /// there is none within [maxYears] years.
  MalayalamDate? next(
    DateTime after, {
    KollavarshamCalendar? calendar,
    int maxYears = 100,
  }) {
    final cal = calendar ?? KollavarshamCalendar.standard;
    final end = _addDays(after, 366 * maxYears);
    for (var start = _addDays(after, 1);
        start.isBefore(end);
        start = _addDays(start, 366)) {
      final found =
          occurrencesBetween(start, _addDays(start, 365), calendar: cal);
      if (found.isNotEmpty) return found.first;
    }
    return null;
  }

  /// This recurrence as a JSON-compatible map, read back by
  /// [Recurrence.fromJson].
  Map<String, Object?> toJson();

  /// The Kollavarsham year (or, for [GregorianYearly], the Gregorian year) of
  /// [date]. Used to pick the year buckets that cover a range.
  int _yearOf(KollavarshamCalendar cal, DateTime date) =>
      cal.fromGregorian(date).year;

  /// The day numbers of the occurrences in the year bucket [year]. The result
  /// may include days outside the bucket; the caller filters by range.
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year);
}

/// A yearly star birthday (pirannal): the day of [month] on which
/// [nakshatra] is present, with the rules for days that are doubled or
/// missing.
///
/// With the default rules the day is the later of two qualifying days (R1);
/// when there is none, it falls on the last qualifying day of the previous
/// month (R2).
final class NakshatraInMonth extends Recurrence {
  /// Creates a yearly occurrence of [nakshatra] in [month].
  const NakshatraInMonth(
    this.nakshatra,
    this.month, {
    this.duplicateRule = DuplicateRule.second,
    this.absentRule = AbsentRule.previousMonth,
  });

  /// The birth star.
  final Nakshatra nakshatra;

  /// The Malayalam month of the birth.
  final MalayalamMonth month;

  /// Which day counts when the star is present on two days of [month].
  final DuplicateRule duplicateRule;

  /// Where the occurrence falls when the star is present on no day of
  /// [month].
  final AbsentRule absentRule;

  @override
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year) {
    final test = _starTest(cal, nakshatra);
    final start = cal.dayNumberOf(year, month, 1);
    final days = _passingDays(cal, start, cal.monthLength(year, month), test);
    if (days.isNotEmpty) {
      return [duplicateRule == DuplicateRule.second ? days.last : days.first];
    }
    return switch (absentRule) {
      AbsentRule.previousMonth => _lastPassingInPreviousMonth(cal, start, test),
      AbsentRule.nextMonth => _firstPassingInNextMonth(cal, start, test),
      AbsentRule.skip => const [],
    };
  }

  @override
  Map<String, Object?> toJson() => {
        'type': 'nakshatraInMonth',
        'nakshatra': _enumName(nakshatra),
        'month': _enumName(month),
        'duplicateRule': duplicateRule.name,
        'absentRule': absentRule.name,
      };

  @override
  bool operator ==(Object other) =>
      other is NakshatraInMonth &&
      other.nakshatra == nakshatra &&
      other.month == month &&
      other.duplicateRule == duplicateRule &&
      other.absentRule == absentRule;

  @override
  int get hashCode => Object.hash(
      NakshatraInMonth, nakshatra, month, duplicateRule, absentRule);
}

/// Every day on which [nakshatra] is present, six nazhika after sunrise: the
/// monthly star day (nakshatram), about every 27 days.
///
/// When the star begins and ends between one day's reading and the next, so
/// that no day has it, the earlier of those two days counts. Every cycle of
/// the Moon therefore has at least one day.
final class NakshatraMonthly extends Recurrence {
  /// Creates a monthly occurrence of [nakshatra].
  const NakshatraMonthly(this.nakshatra);

  /// The birth star.
  final Nakshatra nakshatra;

  @override
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year) {
    final start = cal.dayNumberOf(year, cal.firstMonth, 1);
    final end = start + cal.yearLength(year);
    final days = <int>[];
    var current = _nakshatraAtSixNazhika(cal, start);
    for (var n = start; n < end; n++) {
      final following = _nakshatraAtSixNazhika(cal, n + 1);
      // A star that begins and ends between two days' readings counts on the
      // earlier day (source S3: a short star moves to the previous day).
      if (current == nakshatra ||
          (current != null &&
              following != null &&
              (following.index - current.index) % 27 == 2 &&
              (nakshatra.index - current.index) % 27 == 1)) {
        days.add(n);
      }
      current = following;
    }
    return days;
  }

  @override
  Map<String, Object?> toJson() => {
        'type': 'nakshatraMonthly',
        'nakshatra': _enumName(nakshatra),
      };

  @override
  bool operator ==(Object other) =>
      other is NakshatraMonthly && other.nakshatra == nakshatra;

  @override
  int get hashCode => Object.hash(NakshatraMonthly, nakshatra);
}

/// The same Malayalam [day] of [month] every year, such as an anniversary
/// by Malayalam date (for example Thulam 12).
///
/// A day beyond the end of a shorter month falls on the last day of that
/// month.
final class MalayalamDateYearly extends Recurrence {
  /// Creates a yearly occurrence on [day] of [month].
  const MalayalamDateYearly(this.month, this.day);

  /// The Malayalam month.
  final MalayalamMonth month;

  /// The day of the month, from 1.
  final int day;

  @override
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year) => [
        cal.dayNumberOf(
            year, month, _clampDay(day, cal.monthLength(year, month))),
      ];

  @override
  Map<String, Object?> toJson() => {
        'type': 'malayalamDateYearly',
        'month': _enumName(month),
        'day': day,
      };

  @override
  bool operator ==(Object other) =>
      other is MalayalamDateYearly && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(MalayalamDateYearly, month, day);
}

/// The same Malayalam [day] of every month, such as a monthly reminder.
///
/// A day beyond the end of a shorter month falls on the last day of that
/// month.
final class MalayalamDateMonthly extends Recurrence {
  /// Creates a monthly occurrence on [day].
  const MalayalamDateMonthly(this.day);

  /// The day of the month, from 1.
  final int day;

  @override
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year) => [
        for (final month in MalayalamMonth.values)
          cal.dayNumberOf(
              year, month, _clampDay(day, cal.monthLength(year, month))),
      ];

  @override
  Map<String, Object?> toJson() => {
        'type': 'malayalamDateMonthly',
        'day': day,
      };

  @override
  bool operator ==(Object other) =>
      other is MalayalamDateMonthly && other.day == day;

  @override
  int get hashCode => Object.hash(MalayalamDateMonthly, day);
}

/// The same Gregorian [day] of [month] every year, such as a birthday.
///
/// 29 February falls on 28 February in common years.
final class GregorianYearly extends Recurrence {
  /// Creates a yearly occurrence on [day] of [month] (Gregorian, from 1).
  const GregorianYearly(this.month, this.day);

  /// The Gregorian month, from 1 (January) to 12 (December).
  final int month;

  /// The day of the month, from 1.
  final int day;

  @override
  int _yearOf(KollavarshamCalendar cal, DateTime date) => date.year;

  @override
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return [
      cal.dayNumberOfGregorian(DateTime(year, month, _clampDay(day, lastDay))),
    ];
  }

  @override
  Map<String, Object?> toJson() => {
        'type': 'gregorianYearly',
        'month': month,
        'day': day,
      };

  @override
  bool operator ==(Object other) =>
      other is GregorianYearly && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(GregorianYearly, month, day);
}

/// Six nazhika after sunrise, when a day's star is read (rule R3). One
/// nazhika is 24 minutes.
const _sixNazhika = Duration(minutes: 144);

/// A predicate on the instant six nazhika after sunrise.
typedef _InstantTest = bool Function(DateTime instant);

_InstantTest _starTest(KollavarshamCalendar cal, Nakshatra nakshatra) =>
    (instant) => cal.nakshatraAt(instant) == nakshatra;

/// The day numbers in `[start, start + length)` that satisfy [test] six
/// nazhika after their sunrise.
List<int> _passingDays(
  KollavarshamCalendar cal,
  int start,
  int length,
  _InstantTest test,
) =>
    [
      for (var n = start; n < start + length; n++)
        if (_passesAtSunrise(cal, n, test)) n,
    ];

/// The star six nazhika after sunrise on [dayNumber], or `null` without a
/// sunrise.
Nakshatra? _nakshatraAtSixNazhika(KollavarshamCalendar cal, int dayNumber) {
  final sunrise = cal.sunrise(cal.dateOfDayNumber(dayNumber));
  return sunrise == null ? null : cal.nakshatraAt(sunrise.add(_sixNazhika));
}

bool _passesAtSunrise(
    KollavarshamCalendar cal, int dayNumber, _InstantTest test) {
  final sunrise = cal.sunrise(cal.dateOfDayNumber(dayNumber));
  return sunrise != null && test(sunrise.add(_sixNazhika));
}

/// The last day of the month before the one starting at [start] that passes
/// [test], as a one-element list, or an empty list.
List<int> _lastPassingInPreviousMonth(
  KollavarshamCalendar cal,
  int start,
  _InstantTest test,
) {
  final length = cal.fromDayNumber(start - 1).monthLength;
  final days = _passingDays(cal, start - length, length, test);
  return days.isEmpty ? const [] : [days.last];
}

/// The first day of the month after the one starting at [start] that passes
/// [test], as a one-element list, or an empty list.
List<int> _firstPassingInNextMonth(
  KollavarshamCalendar cal,
  int start,
  _InstantTest test,
) {
  final nextStart = start + cal.fromDayNumber(start).monthLength;
  final length = cal.fromDayNumber(nextStart).monthLength;
  final days = _passingDays(cal, nextStart, length, test);
  return days.isEmpty ? const [] : [days.first];
}

/// The declared name of [value]. [Nakshatra] and [MalayalamMonth] hide
/// `Enum.name` with a `name(script)` method.
String _enumName(Enum value) => value.name;

int _clampDay(int day, int monthLength) =>
    day > monthLength ? monthLength : day;

DateTime _addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

T _enumField<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values,
) {
  final name = json[key];
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Invalid $key in recurrence: $name');
}

int _intField(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw FormatException('$key must be an integer in recurrence: $value');
}
