/// The converter and star finder behind the site's JavaScript API, as
/// plain Dart over JSON-like maps, so it is tested on the VM.
library;

import 'package:kollavarsham/kollavarsham.dart';

/// The identifier of an enum value; several engine enums shadow `name`.
String _id(Enum e) => EnumName(e).name;

String _two(int n) => n.toString().padLeft(2, '0');

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// The calendar for an optional place; Thiruvananthapuram by default.
KollavarshamCalendar calendarFor({
  double? latitude,
  double? longitude,
  int? utcOffsetMinutes,
}) =>
    latitude == null || longitude == null
        ? KollavarshamCalendar.standard
        : KollavarshamCalendar(
            location: ObserverLocation(
              latitude: latitude,
              longitude: longitude,
              utcOffset: Duration(minutes: utcOffsetMinutes ?? 330),
            ),
          );

/// [date] as a map: both dates, names in both scripts, star and tithi at
/// sunrise.
Map<String, Object> describe(MalayalamDate date) {
  final star = date.nakshatra;
  final tithi = date.tithi;
  return {
    'gregorian': _iso(date.toGregorian()),
    'year': date.year,
    'month': _id(date.month),
    'day': date.day,
    'monthMl': date.month.malayalam,
    'monthEn': date.month.english,
    'weekdayMl': date.weekday.malayalam,
    'weekdayEn': date.weekday.english,
    'textMl': date.format('EEEE, d MMMM y', script: MalayalamScript.malayalam),
    'textEn': date.format('EEEE, d MMMM y', script: MalayalamScript.english),
    'star': _id(star),
    'starMl': star.malayalam,
    'starEn': star.english,
    'tithi': tithi.number,
    'tithiMl': tithi.name(MalayalamScript.malayalam),
    'tithiEn': tithi.name(MalayalamScript.english),
  };
}

/// The Malayalam date of a Gregorian `yyyy-mm-dd`, or null if malformed.
Map<String, Object>? toMalayalam(String isoDate,
    [KollavarshamCalendar? calendar]) {
  final d = DateTime.tryParse(isoDate);
  if (d == null) return null;
  final cal = calendar ?? KollavarshamCalendar.standard;
  return describe(cal.fromGregorian(DateTime(d.year, d.month, d.day)));
}

/// The Gregorian date of Malayalam [year], [month] (an id such as
/// `thulam`) and [day], or null if there is no such day.
Map<String, Object>? toGregorian(int year, String month, int day,
    [KollavarshamCalendar? calendar]) {
  final m = MalayalamMonth.values.where((v) => _id(v) == month).firstOrNull;
  if (m == null) return null;
  final cal = calendar ?? KollavarshamCalendar.standard;
  if (day < 1 || day > cal.monthLength(year, m)) return null;
  return describe(MalayalamDate(year, m, day, calendar: cal));
}

/// Birth star, pada, rashi, tithi and Malayalam date for a local
/// `yyyy-mm-ddThh:mm` at the calendar's place, or null if malformed.
Map<String, Object>? findStar(String localDateTime,
    [KollavarshamCalendar? calendar]) {
  final t = DateTime.tryParse(localDateTime);
  if (t == null) return null;
  final details = BirthDetails.fromLocalTime(t, calendar: calendar);
  return {
    'star': _id(details.nakshatra),
    'starMl': details.nakshatra.malayalam,
    'starEn': details.nakshatra.english,
    'pada': details.pada,
    'rashi': _id(details.rashi),
    'rashiMl': details.rashi.name(MalayalamScript.malayalam),
    'rashiEn': details.rashi.name(MalayalamScript.english),
    'tithiMl': details.tithi.name(MalayalamScript.malayalam),
    'tithiEn': details.tithi.name(MalayalamScript.english),
    'date': describe(details.date),
  };
}
