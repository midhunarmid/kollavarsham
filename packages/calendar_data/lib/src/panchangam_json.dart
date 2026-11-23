import 'package:kollavarsham/kollavarsham.dart';

/// The identifier of an enum value; several engine enums shadow `name`
/// with a method that takes a script.
String _id(Enum e) => EnumName(e).name;

String _two(int n) => n.toString().padLeft(2, '0');

/// `yyyy-mm-dd` of a date.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// The local wall-clock time of [instant] at [calendar]'s location, as
/// `yyyy-mm-ddThh:mm`.
String localTime(DateTime instant, KollavarshamCalendar calendar) {
  final t = instant.toUtc().add(calendar.location.utcOffset);
  return '${isoDate(t)}T${_two(t.hour)}:${_two(t.minute)}';
}

List<Map<String, Object>> _spans<T>(
  PanchangaSpan<T> Function(DateTime) spanAt,
  DateTime from,
  DateTime to,
  Object Function(T) id,
  KollavarshamCalendar calendar,
) {
  final spans = [spanAt(from)];
  while (spans.last.end.isBefore(to)) {
    spans.add(spanAt(spans.last.end.add(const Duration(seconds: 1))));
  }
  return [
    for (final s in spans)
      {'id': id(s.value), 'until': localTime(s.end, calendar)},
  ];
}

/// The panchangam of Gregorian [day] at [calendar]'s place, as plain data:
/// every star and tithi from sunrise to the next sunrise with its end time,
/// the paksha at sunrise, sun and moon times, and the kalams. Times are
/// local wall-clock times (`yyyy-mm-ddThh:mm`); a missing sunrise (polar
/// places) counts from 06:00.
///
/// The website's day pages are built from this, and its in-browser
/// recomputation for other places runs the same code, compiled to JS.
Map<String, Object?> panchangamJson(
    DateTime day, KollavarshamCalendar calendar) {
  final g = day;
  final next = day.isUtc
      ? day.add(const Duration(days: 1))
      : DateTime(day.year, day.month, day.day + 1);
  DateTime start(DateTime d) =>
      calendar.sunrise(d) ??
      DateTime.utc(d.year, d.month, d.day, 6)
          .subtract(calendar.location.utcOffset);
  final from = start(g);
  final to = start(next);
  String? time(DateTime? t) => t == null ? null : localTime(t, calendar);
  return {
    'stars': _spans(
        calendar.nakshatraSpanAt, from, to, (Nakshatra n) => _id(n), calendar),
    'tithis':
        _spans(calendar.tithiSpanAt, from, to, (Tithi t) => t.number, calendar),
    'paksha': _id(calendar.tithiAt(from).paksha),
    'sunrise': time(calendar.sunrise(g)),
    'sunset': time(calendar.sunset(g)),
    'moonrise': time(calendar.moonrise(g)),
    'moonset': time(calendar.moonset(g)),
    'kalams': {
      for (final k in Kalam.values)
        if (calendar.kalamOn(g, k) case final span?)
          _id(k): [time(span.start), time(span.end)],
    },
  };
}
