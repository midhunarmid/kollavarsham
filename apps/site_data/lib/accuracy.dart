/// The accuracy checklist (docs/accuracy-checklist.md): the app's values for
/// month starts, festivals and pirannal edge cases, with blank columns for
/// an almanac, and a comparison of the holiday list with the computed
/// festivals.
library;

import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';

import 'site_data.dart';

/// 6 nazhika: the time after sunrise at which a day's star is read (R3).
const _sixNazhika = Duration(minutes: 144);

String _time(DateTime utc, KollavarshamCalendar cal) =>
    localTime(utc, cal).replaceFirst('T', ' ');

String _weekday(DateTime d) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

/// Rows of a markdown table.
String _table(List<String> header, List<List<String>> rows) => [
      '| ${header.join(' | ')} |',
      '|${header.map((_) => '---').join('|')}|',
      for (final r in rows) '| ${r.join(' | ')} |',
    ].join('\n');

/// The days of [month] in Kollavarsham [year] on which [star] is read at
/// sunrise + 6 nazhika.
List<MalayalamDate> starDays(
    KollavarshamCalendar cal, int year, MalayalamMonth month, Nakshatra star) {
  final first = MalayalamDate(year, month, 1, calendar: cal);
  return [
    for (var d = first; d.month == month; d = d.addDays(1))
      if (cal.sunrise(d.toGregorian()) case final rise?
          when cal.nakshatraAt(rise.add(_sixNazhika)) == star)
        d,
  ];
}

/// The checklist for Gregorian years [from] to [to].
String accuracyChecklist(
    int from, int to, KollavarshamCalendar cal, HolidayData holidays) {
  final out = StringBuffer();

  // Month starts.
  final months = <List<String>>[];
  var m = cal.fromGregorian(DateTime(from)).firstDayOfMonth;
  if (m.toGregorian().year < from) m = m.lastDayOfMonth.addDays(1);
  for (; m.toGregorian().year <= to; m = m.lastDayOfMonth.addDays(1)) {
    final g = m.toGregorian();
    final margin = cal.monthStartMargin(m.year, m.month).inMinutes;
    months.add([
      '${m.month.english} ${m.year}',
      '${isoDate(g)} ${_weekday(g)}',
      _time(cal.sankranti(m.year, m.month), cal),
      '${margin.abs() < 30 ? '⚠ ' : ''}$margin',
      '',
    ]);
  }
  out
    ..writeln('## Month starts\n')
    ..writeln('Margin: minutes from the sankranti to the cut-off of its day '
        '(three-fifths of the daytime); positive means the month starts that '
        'day. ⚠ marks months within 30 minutes, where almanacs may differ.\n')
    ..writeln(_table(
        ['Month', 'App: day 1', 'Sankranti (IST)', 'Margin (min)', 'Almanac'],
        months))
    ..writeln();

  // Festivals.
  final festivals = festivalDaysBetween(
    cal,
    cal.fromGregorian(DateTime(from)),
    cal.fromGregorian(DateTime(to, 12, 31)),
    holidays: holidays,
    categories: {
      FestivalCategory.hindu,
      FestivalCategory.christian,
      FestivalCategory.muslim,
    },
  );
  out
    ..writeln('## Festivals\n')
    ..writeln('"Listed" is the Kerala holiday list\'s kind for that day, where '
        'the list names the festival. Muslim dates are tentative until '
        'announced.\n')
    ..writeln(_table([
      'Festival',
      'App date',
      'Malayalam date',
      'Listed',
      'Almanac',
    ], [
      for (final f in festivals)
        [
          f.english,
          '${isoDate(f.date.toGregorian())} ${_weekday(f.date.toGregorian())}',
          '${f.date.day} ${f.date.month.english} ${f.date.year}',
          [
            if (f.holiday != null) f.holiday!.name,
            if (f.tentative) 'tentative',
          ].join(', '),
          '',
        ],
    ]))
    ..writeln();

  // Holiday list vs computed.
  final mismatches = <List<String>>[];
  for (var y = from; y <= to; y++) {
    final computed = festivalDaysBetween(
      cal,
      cal.fromGregorian(DateTime(y)),
      cal.fromGregorian(DateTime(y, 12, 31)),
    );
    for (final e in holidays.inYear(y)) {
      final id = computedFestivalIdOf(e);
      if (id == null || id.startsWith('muslim.')) continue;
      final dates = [
        for (final f in computed)
          if (f.id == id) isoDate(f.date.toGregorian()),
      ];
      final listed = isoDate(e.date);
      if (!dates.contains(listed)) {
        mismatches
            .add([e.name, listed, dates.isEmpty ? '—' : dates.join(', ')]);
      }
    }
  }
  out
    ..writeln('## Holiday list against the computed festivals\n')
    ..writeln('Entries of `data/holidays/` that name a computed festival but '
        'fall on another day. Muslim festivals are left out: the list '
        'replaces their tentative dates by design.\n')
    ..writeln(mismatches.isEmpty
        ? 'None: every listed festival falls on its computed day.'
        : _table(['Holiday list entry', 'Listed', 'Computed'], mismatches))
    ..writeln();

  // Pirannal edge cases.
  final firstYear = cal.fromGregorian(DateTime(from)).year;
  final lastYear = cal.fromGregorian(DateTime(to, 12, 31)).year;
  final cases = <List<String>>[];
  for (var y = firstYear; y <= lastYear; y++) {
    for (final month in MalayalamMonth.values) {
      final start = MalayalamDate(y, month, 1, calendar: cal).toGregorian();
      if (start.year < from || start.year > to) continue;
      for (final star in Nakshatra.values) {
        final days = starDays(cal, y, month, star);
        if (days.length == 1) continue;
        // The rule gives one day per year; with the star absent (R2) it is
        // in the previous month, so look from a month before.
        final rule = NakshatraInMonth(star, month);
        final chosen = rule.occurrencesBetween(
            start.subtract(const Duration(days: 32)),
            start.add(const Duration(days: 31)),
            calendar: cal);
        final pick = chosen.isEmpty ? null : chosen.last;
        cases.add([
          '${star.english} in ${month.english} $y',
          days.isEmpty
              ? 'none (R2)'
              : days.map((d) => isoDate(d.toGregorian())).join(', '),
          days.isEmpty ? 'previous month' : 'second day (R1)',
          pick == null
              ? '—'
              : '${isoDate(pick.toGregorian())} (${pick.day} ${pick.month.english})',
          '',
        ]);
      }
    }
  }
  final pooradam = [
    for (var y = firstYear; y <= lastYear; y++)
      for (final d in NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu)
          .occurrencesBetween(DateTime(from), DateTime(to, 12, 31),
              calendar: cal))
        if (d.year == y) d,
  ];
  out
    ..writeln('## Pirannal\n')
    ..writeln('Stars are read at sunrise + 6 nazhika (R3). Worked example 1 '
        '(`docs/pirannal-rules.md`): Pooradam in Dhanu.\n')
    ..writeln(_table([
      'Pirannal',
      'App date',
      'Almanac'
    ], [
      for (final d in pooradam.toSet())
        [
          'Pooradam in Dhanu ${d.year}',
          '${isoDate(d.toGregorian())} (${d.day} Dhanu)',
          ''
        ],
    ]))
    ..writeln()
    ..writeln('Every star that falls on two days of a month (R1, worked '
        'example 2) or on none (R2, example 4) in these years, with the day '
        'the app chooses:\n')
    ..writeln(_table([
      'Star and month',
      'Days read with the star',
      'Rule',
      'App pirannal',
      'Almanac'
    ], cases))
    ..writeln();

  // Shraddham.
  out
    ..writeln('## Shraddham by tithi\n')
    ..writeln(
        'Worked example 5: Ekadashi in Karkidakam, by the larger share of '
        'the afternoon (R4).\n')
    ..writeln(_table([
      'Shraddham',
      'App date',
      'Almanac'
    ], [
      for (final (label, tithi) in [('waxing', 11), ('waning', 26)])
        for (final d in TithiInMonth(Tithi(tithi), MalayalamMonth.karkidakam)
            .occurrencesBetween(DateTime(from), DateTime(to, 12, 31),
                calendar: cal))
          [
            'Ekadashi ($label), Karkidakam ${d.year}',
            '${isoDate(d.toGregorian())} (${d.day} Karkidakam)',
            ''
          ],
    ]));
  return out.toString();
}
