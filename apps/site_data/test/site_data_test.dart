import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:site_data/site_data.dart';
import 'package:test/test.dart';

final _cal = KollavarshamCalendar.standard;

void main() {
  test('names cover every id the days use', () {
    final names = namesJson();
    expect((names['stars']! as Map).length, 27);
    expect((names['tithis']! as Map).length, 30);
    expect((names['months']! as Map).length, 12);
  });

  group('days of 2026', () {
    final days = daysJson(2026, _cal, HolidayData.empty);

    test('one per date, in order', () {
      expect(days, hasLength(365));
      expect(days.first['date'], '2026-01-01');
      expect(days.last['date'], '2026-12-31');
    });

    test('match the engine', () {
      final onam = days.firstWhere((d) => d['date'] == '2026-08-26');
      expect(onam['ml'], {'y': 1202, 'm': 'chingam', 'd': 10});
      expect(onam['weekday'], 'budhan');
      expect(
          (onam['stars']! as List).first,
          containsPair(
              'id', EnumName(_cal.nakshatraOn(DateTime(2026, 8, 26))).name));
      expect(onam['festivals'], contains('hindu.onam'));
      expect(onam['sunrise'], startsWith('2026-08-26T06:'));
      expect((onam['kalams']! as Map).keys,
          containsAll(['rahu', 'gulika', 'yamagandam']));
    });
  });

  test('months start where the engine says', () {
    final months = monthsJson(2026, 2026, _cal);
    expect(months.length, inInclusiveRange(12, 13));
    final chingam =
        months.firstWhere((m) => (m['ml']! as Map)['m'] == 'chingam');
    expect(chingam['start'],
        isoDate(_cal.monthStart(1202, MalayalamMonth.chingam)));
    expect(chingam['marginMinutes'],
        _cal.monthStartMargin(1202, MalayalamMonth.chingam).inMinutes);
  });

  test('vrat days match the engine and stay in their Gregorian year', () {
    final vrats = vratsJson(2026, 2026, _cal);
    final ekadashi =
        ((vrats['ekadashi']! as Map)['days'] as Map)['2026'] as List<String>;
    expect(ekadashi.length, inInclusiveRange(23, 26));
    expect(ekadashi, everyElement(startsWith('2026-')));
    final fromEngine = [
      for (final y in [1201, 1202])
        for (final d in _cal.vratDays(Vrat.ekadashi, y))
          if (d.toGregorian().year == 2026) isoDate(d.toGregorian()),
    ]..sort();
    expect(ekadashi, fromEngine);
  });

  test('nakshatram days: about one a lunar month, each a day of the star', () {
    final days = (nakshatraDaysJson(2026, 2026, _cal)['2026']! as Map)
        .cast<String, List<String>>();
    expect(days.keys, hasLength(27));
    for (final list in days.values) {
      expect(list.length, inInclusiveRange(12, 16));
    }
  });

  test('Kerala today is the IST date', () {
    // 20:00 UTC on 31 December is 01:30 on 1 January in Kerala.
    expect(keralaToday(DateTime.utc(2026, 12, 31, 20)), DateTime.utc(2027));
    expect(keralaToday(DateTime.utc(2026, 12, 31, 18)),
        DateTime.utc(2026, 12, 31));
  });

  test('festivals carry descriptions and every date', () {
    final festivals = festivalsJson(2026, 2027, _cal, HolidayData.empty);
    final onam = festivals.firstWhere((f) => f['id'] == 'hindu.onam');
    expect((onam['about']! as Map)['en'], isNotEmpty);
    expect(onam['dates'], hasLength(2));
    expect(festivals.map((f) => f['id']).toSet(), hasLength(festivals.length));
  });
}
