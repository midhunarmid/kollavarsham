/// Builds the JSON documents the calendar.armid.in site is generated from.
///
/// Everything is computed for one calendar (by default Thiruvananthapuram,
/// Chingam year start, the Kerala standard) and written as plain data:
/// names, days with their panchangam, Malayalam months, and festivals.
/// Times are local wall-clock times at the calendar's location.
library;

import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';

export 'package:calendar_data/calendar_data.dart'
    show isoDate, localTime, panchangamJson;

/// The identifier of an enum value; several engine enums shadow `name`
/// with a method that takes a script.
String _id(Enum e) => EnumName(e).name;

/// Today's date in Kerala (IST, UTC+05:30), at midnight UTC.
DateTime keralaToday([DateTime? now]) {
  final t = (now ?? DateTime.now()).toUtc().add(
        const Duration(hours: 5, minutes: 30),
      );
  return DateTime.utc(t.year, t.month, t.day);
}

/// A Malayalam date as `{y, m, d}`, `m` the month id (e.g. `thulam`).
Map<String, Object> malayalamJson(MalayalamDate d) =>
    {'y': d.year, 'm': _id(d.month), 'd': d.day};

/// Names of months, weekdays, stars, tithis, pakshas and kalams in both
/// scripts, keyed by the ids the other documents use.
Map<String, Object> namesJson() {
  Map<String, String> both(String ml, String en) => {'ml': ml, 'en': en};
  return {
    'months': {
      for (final m in MalayalamMonth.values)
        _id(m): both(m.malayalam, m.english),
    },
    'weekdays': {
      for (final w in MalayalamWeekday.values)
        _id(w): {
          ...both(w.malayalam, w.english),
          'gregorian': w.gregorianName,
        },
    },
    'stars': {
      for (final n in Nakshatra.values) _id(n): both(n.malayalam, n.english),
    },
    'tithis': {
      for (var t = 1; t <= 30; t++)
        '$t': both(Tithi(t).name(MalayalamScript.malayalam),
            Tithi(t).name(MalayalamScript.english)),
    },
    'pakshas': {
      for (final p in Paksha.values) _id(p): both(p.malayalam, p.english),
    },
    'kalams': {
      for (final k in Kalam.values) _id(k): both(k.malayalam, k.english),
    },
    'categories': {
      for (final c in FestivalCategory.values) _id(c): _id(c),
    },
  };
}

/// The days of Gregorian [year]: dates, panchangam and festival ids.
List<Map<String, Object?>> daysJson(
  int year,
  KollavarshamCalendar calendar,
  HolidayData holidays,
) {
  final first = calendar.fromGregorian(DateTime(year));
  final last = calendar.fromGregorian(DateTime(year, 12, 31));
  final festivals = <int, List<FestivalDay>>{};
  for (final f
      in festivalDaysBetween(calendar, first, last, holidays: holidays)) {
    (festivals[f.date.dayNumber] ??= []).add(f);
  }
  final days = <Map<String, Object?>>[];
  for (var d = first; !d.isAfter(last); d = d.addDays(1)) {
    final g = d.toGregorian();
    days.add({
      'date': isoDate(g),
      'weekday': _id(d.weekday),
      'ml': malayalamJson(d),
      ...panchangamJson(g, calendar),
      'festivals': [
        for (final f in festivals[d.dayNumber] ?? const <FestivalDay>[]) f.id,
      ],
    });
  }
  return days;
}

/// The Malayalam months that start from [from] to [to] (Gregorian years).
List<Map<String, Object>> monthsJson(
    int from, int to, KollavarshamCalendar calendar) {
  final months = <Map<String, Object>>[];
  var m = calendar.fromGregorian(DateTime(from)).firstDayOfMonth;
  if (m.toGregorian().year < from) m = m.lastDayOfMonth.addDays(1);
  while (m.toGregorian().year <= to) {
    months.add({
      'ml': malayalamJson(m),
      'start': isoDate(m.toGregorian()),
      'days': m.monthLength,
      'sankranti': localTime(calendar.sankranti(m.year, m.month), calendar),
      // Minutes from the sankranti to the cut-off that decides day 1;
      // under 10 either way, almanacs may start the month a day apart.
      'marginMinutes': calendar.monthStartMargin(m.year, m.month).inMinutes,
    });
    m = m.lastDayOfMonth.addDays(1);
  }
  return months;
}

/// Every festival from Gregorian year [from] to [to], with its names,
/// description, rule and dates.
List<Map<String, Object?>> festivalsJson(
  int from,
  int to,
  KollavarshamCalendar calendar,
  HolidayData holidays,
) {
  final byId = <String, List<FestivalDay>>{};
  for (final f in festivalDaysBetween(
      calendar,
      calendar.fromGregorian(DateTime(from)),
      calendar.fromGregorian(DateTime(to, 12, 31)),
      holidays: holidays)) {
    (byId[f.id] ??= []).add(f);
  }
  final ids = byId.keys.toList()..sort();
  return [
    for (final id in ids)
      {
        'id': id,
        'category': byId[id]!.first.category.name,
        // The latest names: list entries can be respelt between years.
        'ml': byId[id]!.last.malayalam,
        'en': byId[id]!.last.english,
        'about': {
          'ml': festivalInfo(id).aboutMl,
          'en': festivalInfo(id).aboutEn
        },
        'rule': {'ml': festivalInfo(id).ruleMl, 'en': festivalInfo(id).ruleEn},
        'dates': [
          for (final f in byId[id]!)
            {
              'date': isoDate(f.date.toGregorian()),
              'ml': malayalamJson(f.date),
              if (f.holiday != null) 'holiday': f.holiday!.name,
              if (f.tentative) 'tentative': true,
              if (f.source != null) 'source': f.source,
            },
        ],
      },
  ];
}

/// Fasting days (Ekadashi, Pradosham, Shashti, Pournami, Amavasya) in
/// Gregorian years [from] to [to], as `{vrat: {year: [yyyy-mm-dd]}}`, by
/// the engine's `vratDays`.
Map<String, Object> vratsJson(int from, int to, KollavarshamCalendar calendar) {
  final first = calendar.fromGregorian(DateTime(from)).year;
  final last = calendar.fromGregorian(DateTime(to, 12, 31)).year;
  return {
    for (final v in Vrat.values)
      _id(v): {
        'ml': v.malayalam,
        'en': v.english,
        'days': () {
          final byYear = <String, List<String>>{};
          for (var y = first; y <= last; y++) {
            for (final d in calendar.vratDays(v, y)) {
              final g = d.toGregorian();
              if (g.year < from || g.year > to) continue;
              (byYear['${g.year}'] ??= []).add(isoDate(g));
            }
          }
          for (final list in byYear.values) {
            list.sort();
          }
          return byYear;
        }(),
      },
  };
}

/// Each star's monthly nakshatram days (the app's monthly recurrence: the
/// star read at sunrise + 6 nazhika) in Gregorian years [from] to [to], as
/// `{year: {star: [yyyy-mm-dd]}}`.
Map<String, Object> nakshatraDaysJson(
    int from, int to, KollavarshamCalendar calendar) {
  return {
    for (var y = from; y <= to; y++)
      '$y': {
        for (final n in Nakshatra.values)
          _id(n): [
            for (final d in NakshatraMonthly(n).occurrencesBetween(
                DateTime(y), DateTime(y, 12, 31),
                calendar: calendar))
              isoDate(d.toGregorian()),
          ],
      },
  };
}

/// What the documents were computed for.
Map<String, Object> metaJson(int from, int to, KollavarshamCalendar calendar) =>
    {
      'from': from,
      'to': to,
      'location': {
        'name': calendar.location.name ?? 'custom',
        'latitude': calendar.location.latitude,
        'longitude': calendar.location.longitude,
        'utcOffsetMinutes': calendar.location.utcOffset.inMinutes,
      },
      'yearStart': calendar.yearStart.name,
    };
