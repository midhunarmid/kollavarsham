import 'dart:io';

import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:site_data/feeds.dart';
import 'package:test/test.dart';

final _holidays = HolidayData.parse([
  for (final f in Directory('../../data/holidays').listSync().whereType<File>())
    if (f.path.endsWith('.json')) f.readAsStringSync(),
]);

void main() {
  final cal = KollavarshamCalendar.standard;
  final feedsByPath =
      icsFeeds(2026, 2027, cal, _holidays, now: DateTime.utc(2026, 11, 23));

  List<String> events(String path) => feedsByPath[path]!
      .split('BEGIN:VEVENT')
      .skip(1)
      .map((e) => e.replaceAll('\r\n ', ''))
      .toList();

  test('five feeds in each language, named for subscriptions', () {
    expect(feedsByPath.keys, hasLength(10));
    for (final f in feeds) {
      expect(feedsByPath['en/${f.id}.ics'], contains('X-WR-CALNAME:'));
      expect(feedsByPath['ml/${f.id}.ics'], contains('REFRESH-INTERVAL'));
    }
  });

  test('Thiruvonam 2026 and 2027 fall on the computed days', () {
    final onam = events('en/hindu.ics')
        .where((e) => e.contains('SUMMARY:Thiruvonam'))
        .toList();
    expect(onam, hasLength(2));
    for (final year in [1202, 1203]) {
      final day = festivalDaysBetween(
              cal,
              MalayalamDate(year, MalayalamMonth.chingam, 1, calendar: cal),
              MalayalamDate(year, MalayalamMonth.chingam, 31, calendar: cal)
                  .lastDayOfMonth)
          .firstWhere((d) => d.english == 'Thiruvonam');
      final g = day.date.toGregorian();
      final stamp = '${g.year}${g.month.toString().padLeft(2, '0')}'
          '${g.day.toString().padLeft(2, '0')}';
      expect(onam.where((e) => e.contains('DTSTART;VALUE=DATE:$stamp')),
          hasLength(1));
    }
  });

  test('UIDs are unique and keyed by festival and year', () {
    final uids = [
      for (final e in events('en/all.ics'))
        RegExp(r'UID:(\S+)').firstMatch(e)!.group(1)!,
    ];
    expect(uids.toSet(), hasLength(uids.length));
    expect(uids, everyElement(endsWith('@calendar.armid.in')));
    final onam2026 = events('en/all.ics').firstWhere((e) =>
        e.contains('SUMMARY:Thiruvonam') &&
        e.contains('DTSTART;VALUE=DATE:2026'));
    expect(RegExp(r'UID:(\S+)').firstMatch(onam2026)!.group(1),
        endsWith('-2026@calendar.armid.in'));
  });

  test('feeds hold their category only; Muslim dates are marked tentative', () {
    expect(events('en/christian.ics'),
        everyElement(isNot(contains('SUMMARY:Thiruvonam'))));
    final muslim = events('en/muslim.ics');
    expect(muslim, isNotEmpty);
    expect(muslim.where((e) => e.contains('(tentative)')), isNotEmpty);
    expect(
        events('en/holidays.ics'),
        everyElement(
            anyOf(contains('Public holiday'), contains('Bank holiday'))));
    expect(events('ml/all.ics').first, contains('calendar.armid.in/ml/day/'));
  });
}
