import 'package:calendar_data/calendar_data.dart' show panchangamJson;
import 'package:converter_js/converter.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  test('Gregorian to Malayalam', () {
    final r = toMalayalam('2026-08-26')!;
    expect(r['year'], 1202);
    expect(r['month'], 'chingam');
    expect(r['day'], 10);
    expect(r['textEn'], 'Budhan, 10 Chingam 1202');
    expect(r['gregorian'], '2026-08-26');
    expect(toMalayalam('not a date'), isNull);
  });

  test('Malayalam to Gregorian, and back', () {
    expect(toGregorian(1202, 'chingam', 10)!['gregorian'], '2026-08-26');
    expect(toGregorian(1202, 'chingam', 40), isNull);
    expect(toGregorian(1202, 'nope', 1), isNull);
    for (final iso in ['2024-02-29', '2026-04-14', '2030-12-31']) {
      final m = toMalayalam(iso)!;
      expect(
          toGregorian(m['year']! as int, m['month']! as String,
              m['day']! as int)!['gregorian'],
          iso);
    }
  });

  test('star finder matches the engine', () {
    final r = findStar('1990-01-15T06:30')!;
    final d = BirthDetails.fromLocalTime(DateTime(1990, 1, 15, 6, 30));
    expect(r['starEn'], d.nakshatra.english);
    expect(r['pada'], d.pada);
    expect(findStar('x'), isNull);
  });

  test('another place', () {
    final cal =
        calendarFor(latitude: 51.5, longitude: -0.1, utcOffsetMinutes: 0);
    expect(cal.location.utcOffset, Duration.zero);
    expect(toMalayalam('2026-08-26', cal), isNotNull);
  });

  group('dayOf', () {
    test('equals the site data for every day of 2026', () {
      final cal = KollavarshamCalendar.standard;
      for (var d = DateTime.utc(2026); d.year == 2026; d = d.add(_day)) {
        final iso = d.toIso8601String().substring(0, 10);
        final site = panchangamJson(
            cal.fromGregorian(DateTime(d.year, d.month, d.day)).toGregorian(),
            cal);
        final js = dayOf(iso)!;
        for (final key in site.keys) {
          if (key == 'stars' || key == 'tithis') {
            final ids = (js[key]! as List).map((s) => [s['id'], s['until']]);
            final want = (site[key]! as List).map((s) => [s['id'], s['until']]);
            expect(ids, want, reason: '$iso $key');
          } else {
            expect(js[key], site[key], reason: '$iso $key');
          }
        }
      }
    });

    test('names every star, tithi, paksha and kalam', () {
      final r = dayOf('2026-11-02')!;
      final star = (r['stars']! as List).first as Map;
      expect(star['en'], isNotEmpty);
      expect(star['ml'], isNotEmpty);
      expect(((r['tithis']! as List).first as Map)['ml'], isNotEmpty);
      expect(r['pakshaEn'], isNotEmpty);
      expect((r['kalamNames']! as Map).keys,
          containsAll(['rahu', 'gulika', 'yamagandam']));
      expect(dayOf('nope'), isNull);
    });

    test('Dubai: sunrise later on the clock, in its own time zone', () {
      final dubai = calendarFor(
          latitude: 25.2048, longitude: 55.2708, utcOffsetMinutes: 240);
      final kerala = dayOf('2026-11-02')!;
      final there = dayOf('2026-11-02', dubai)!;
      expect(there['sunrise'], isNot(kerala['sunrise']));
      // The same star ends at the same instant: 1 h 30 min earlier on
      // Dubai's clock than in Kerala.
      final ends = (kerala['stars']! as List).first['until'] as String;
      final endsThere = (there['stars']! as List).firstWhere(
              (s) => s['id'] == (kerala['stars']! as List).first['id'])['until']
          as String;
      expect(DateTime.parse(ends).difference(DateTime.parse(endsThere)),
          const Duration(minutes: 90));
    });
  });
}

const _day = Duration(days: 1);
