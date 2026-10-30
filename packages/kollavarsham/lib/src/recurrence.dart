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
      'tithiInMonth' => TithiInMonth(
          Tithi(_intField(json, 'tithi', min: 1, max: 30)),
          _enumField(json, 'month', MalayalamMonth.values),
          duplicateRule:
              _enumField(json, 'duplicateRule', DuplicateRule.values),
          absentRule: _enumField(json, 'absentRule', AbsentRule.values),
        ),
      'tithiEveryPaksha' => TithiEveryPaksha(
          _intField(json, 'dayOfPaksha', min: 1, max: 15),
          paksha: json['paksha'] == null
              ? null
              : _enumField(json, 'paksha', Paksha.values),
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
    return _dayInMonth(
      cal,
      year,
      month,
      duplicateRule,
      absentRule,
      (start, length) =>
          _passingDays(cal, start, length, _starTest(cal, nakshatra)),
    );
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

/// A yearly observance by lunar day, such as a shraddham (rule R4 in
/// `docs/pirannal-rules.md`): the day of [month] on which [tithi] falls, with
/// the rules for days that are doubled or missing.
///
/// A tithi belongs to the day on which it covers more of the afternoon
/// (aparahna, the fourth of the five equal parts of the daytime), the first
/// day on a tie. A tithi that misses the afternoon of both days belongs to
/// the later day, the one it covers at sunrise. Every tithi therefore has
/// exactly one day.
///
/// With the default rules a tithi that falls twice in the month uses the
/// later day (R1); when there is none, it falls on the last such day of the
/// previous month (R2).
final class TithiInMonth extends Recurrence {
  /// Creates a yearly occurrence of [tithi] in [month].
  TithiInMonth(
    this.tithi,
    this.month, {
    this.duplicateRule = DuplicateRule.second,
    this.absentRule = AbsentRule.previousMonth,
  });

  /// The lunar day, which includes its fortnight: `Tithi(26)` is Ekadashi of
  /// the waning fortnight.
  final Tithi tithi;

  /// The Malayalam (solar) month.
  final MalayalamMonth month;

  /// Which day counts when [tithi] falls on two days of [month].
  final DuplicateRule duplicateRule;

  /// Where the occurrence falls when [tithi] falls on no day of [month].
  final AbsentRule absentRule;

  @override
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year) {
    return _dayInMonth(
      cal,
      year,
      month,
      duplicateRule,
      absentRule,
      (start, length) => _tithiDays(cal, tithi, start, length),
    );
  }

  @override
  Map<String, Object?> toJson() => {
        'type': 'tithiInMonth',
        'tithi': tithi.number,
        'month': _enumName(month),
        'duplicateRule': duplicateRule.name,
        'absentRule': absentRule.name,
      };

  @override
  bool operator ==(Object other) =>
      other is TithiInMonth &&
      other.tithi == tithi &&
      other.month == month &&
      other.duplicateRule == duplicateRule &&
      other.absentRule == absentRule;

  @override
  int get hashCode =>
      Object.hash(TithiInMonth, tithi, month, duplicateRule, absentRule);
}

/// The same lunar day in every fortnight, such as every Ekadashi, or in one
/// fortnight only, such as every waxing Shashti.
///
/// This uses the tithi at sunrise, as a day's tithi does in an almanac. One
/// tithi gives one day: a tithi present at two sunrises counts on the first,
/// and a tithi that falls wholly between two sunrises counts on the earlier
/// day.
final class TithiEveryPaksha extends Recurrence {
  /// Creates an occurrence on [dayOfPaksha] of each fortnight, or of [paksha]
  /// only if given.
  const TithiEveryPaksha(this.dayOfPaksha, {this.paksha})
      : assert(dayOfPaksha >= 1 && dayOfPaksha <= 15);

  /// The day of the fortnight, from 1 to 15. 11 is Ekadashi, and 15 is
  /// Pournami in the waxing fortnight and Amavasya in the waning one.
  final int dayOfPaksha;

  /// The only fortnight that counts, or `null` for both.
  final Paksha? paksha;

  bool _matches(int tithiNumber) {
    final tithi = Tithi(tithiNumber);
    return tithi.dayOfPaksha == dayOfPaksha &&
        (paksha == null || tithi.paksha == paksha);
  }

  @override
  Iterable<int> _dayNumbersIn(KollavarshamCalendar cal, int year) {
    final start = cal.dayNumberOf(year, cal.firstMonth, 1);
    final end = start + cal.yearLength(year);
    final days = <int>[];
    int tithiOn(int n) => cal.tithiOn(cal.dateOfDayNumber(n)).number;
    var previous = tithiOn(start - 1);
    var current = tithiOn(start);
    for (var n = start; n < end; n++) {
      final following = tithiOn(n + 1);
      final skipped = (following - current) % 30 == 2 ? current % 30 + 1 : null;
      if ((current != previous && _matches(current)) ||
          (skipped != null && _matches(skipped))) {
        days.add(n);
      }
      previous = current;
      current = following;
    }
    return days;
  }

  @override
  Map<String, Object?> toJson() => {
        'type': 'tithiEveryPaksha',
        'dayOfPaksha': dayOfPaksha,
        if (paksha case final paksha?) 'paksha': _enumName(paksha),
      };

  @override
  bool operator ==(Object other) =>
      other is TithiEveryPaksha &&
      other.dayOfPaksha == dayOfPaksha &&
      other.paksha == paksha;

  @override
  int get hashCode => Object.hash(TithiEveryPaksha, dayOfPaksha, paksha);
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

/// The day numbers in a month that qualify, given its first day and length.
typedef _DaysInMonth = List<int> Function(int start, int length);

/// The day of [month] in [year] picked from [daysIn] by [duplicateRule], or
/// by [absentRule] when the month has none.
List<int> _dayInMonth(
  KollavarshamCalendar cal,
  int year,
  MalayalamMonth month,
  DuplicateRule duplicateRule,
  AbsentRule absentRule,
  _DaysInMonth daysIn,
) {
  final start = cal.dayNumberOf(year, month, 1);
  final days = daysIn(start, cal.monthLength(year, month));
  if (days.isNotEmpty) {
    return [duplicateRule == DuplicateRule.second ? days.last : days.first];
  }
  return switch (absentRule) {
    AbsentRule.previousMonth => _lastInPreviousMonth(cal, start, daysIn),
    AbsentRule.nextMonth => _firstInNextMonth(cal, start, daysIn),
    AbsentRule.skip => const [],
  };
}

/// The last qualifying day of the month before the one starting at [start],
/// as a one-element list, or an empty list.
List<int> _lastInPreviousMonth(
  KollavarshamCalendar cal,
  int start,
  _DaysInMonth daysIn,
) {
  final length = cal.fromDayNumber(start - 1).monthLength;
  final days = daysIn(start - length, length);
  return days.isEmpty ? const [] : [days.last];
}

/// The first qualifying day of the month after the one starting at [start],
/// as a one-element list, or an empty list.
List<int> _firstInNextMonth(
  KollavarshamCalendar cal,
  int start,
  _DaysInMonth daysIn,
) {
  final nextStart = start + cal.fromDayNumber(start).monthLength;
  final length = cal.fromDayNumber(nextStart).monthLength;
  final days = daysIn(nextStart, length);
  return days.isEmpty ? const [] : [days.first];
}

/// Fewer hours than the shortest tithi, so stepping by this many hours per
/// tithi never passes the one being looked for.
const _shortestTithiHours = 19;

/// The day numbers in `[start, start + length)` that [tithi] belongs to.
List<int> _tithiDays(
  KollavarshamCalendar cal,
  Tithi tithi,
  int start,
  int length,
) {
  final days = <int>[];
  // A tithi's day is at most a day after it begins, so start one day early.
  final first = cal.dateOfDayNumber(start - 1);
  final last = cal.dateOfDayNumber(start + length);
  var instant = DateTime.utc(first.year, first.month, first.day);
  final end = DateTime.utc(last.year, last.month, last.day);
  while (instant.isBefore(end)) {
    final gap = (tithi.number - cal.tithiAt(instant).number) % 30;
    if (gap > 1) {
      instant = instant.add(
        Duration(hours: (gap - 1) * _shortestTithiHours),
      );
      continue;
    }
    final span = cal.tithiSpanAt(instant);
    if (gap == 0) {
      final day = _afternoonDay(cal, span);
      if (day >= start && day < start + length) days.add(day);
    }
    instant = span.end.add(const Duration(minutes: 1));
  }
  return days;
}

/// The day [span] belongs to by its share of the afternoon.
int _afternoonDay(KollavarshamCalendar cal, PanchangaSpan<Tithi> span) {
  final first =
      cal.dayNumberOfGregorian(span.start.add(cal.location.utcOffset));
  final share = _afternoonShare(cal, first, span);
  final nextShare = _afternoonShare(cal, first + 1, span);
  if (share == Duration.zero && nextShare == Duration.zero) return first + 1;
  return nextShare > share ? first + 1 : first;
}

/// How much of the afternoon of [dayNumber] lies within [span].
Duration _afternoonShare(
  KollavarshamCalendar cal,
  int dayNumber,
  PanchangaSpan<Tithi> span,
) {
  final date = cal.dateOfDayNumber(dayNumber);
  final sunrise = cal.sunrise(date);
  final sunset = cal.sunset(date);
  if (sunrise == null || sunset == null) return Duration.zero;
  final daytime = sunset.difference(sunrise);
  final from = sunrise.add(daytime * (3 / 5));
  final to = sunrise.add(daytime * (4 / 5));
  final overlapStart = span.start.isAfter(from) ? span.start : from;
  final overlapEnd = span.end.isBefore(to) ? span.end : to;
  return overlapEnd.isAfter(overlapStart)
      ? overlapEnd.difference(overlapStart)
      : Duration.zero;
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

int _intField(Map<String, Object?> json, String key, {int? min, int? max}) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('$key must be an integer in recurrence: $value');
  }
  if ((min != null && value < min) || (max != null && value > max)) {
    throw FormatException('$key is out of range in recurrence: $value');
  }
  return value;
}
