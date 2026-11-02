/// An age or span in whole years, months and days.
typedef Ymd = ({int years, int months, int days});

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Calendar days from [from] to [to] (negative if [to] is earlier); times
/// of day are ignored.
int daysBetween(DateTime from, DateTime to) =>
    _day(to).difference(_day(from)).inDays;

/// The span from [from] to [to] (not earlier) in years, months and days,
/// counted the usual way: 31 Jan + 1 month is the last day of February.
Ymd ymdBetween(DateTime from, DateTime to) {
  final a = _day(from);
  final b = _day(to);
  if (b.isBefore(a)) throw ArgumentError('to is before from');
  var months = (b.year - a.year) * 12 + b.month - a.month;
  if (_addMonths(a, months).isAfter(b)) months--;
  final anchor = _addMonths(a, months);
  return (
    years: months ~/ 12,
    months: months % 12,
    days: b.difference(anchor).inDays,
  );
}

/// [d] plus [months], clamped to the end of the month.
DateTime _addMonths(DateTime d, int months) {
  final y = d.year + (d.month - 1 + months) ~/ 12;
  final m = (d.month - 1 + months) % 12 + 1;
  final last = DateTime.utc(y, m + 1, 0).day;
  return DateTime.utc(y, m, d.day > last ? last : d.day);
}

/// The next [birthday] anniversary on or after [today] (29 February falls
/// on 28 February in common years).
DateTime nextAnniversary(DateTime birthday, DateTime today) {
  DateTime inYear(int y) {
    final last = DateTime.utc(y, birthday.month + 1, 0).day;
    return DateTime.utc(
        y, birthday.month, birthday.day > last ? last : birthday.day);
  }

  final t = _day(today);
  final thisYear = inYear(t.year);
  return thisYear.isBefore(t) ? inYear(t.year + 1) : thisYear;
}
