import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

final _cal = KollavarshamCalendar.standard;

MalayalamDate _d(int y, int m, int d) => _cal.fromGregorian(DateTime(y, m, d));

const _file = '''
{"year": 2026, "holidays": [
  {"date": "2026-08-26", "name": "Thiruvonam", "name_ml": "തിരുവോണം",
   "category": "hindu", "kind": "public", "tentative": false,
   "source": "https://example.org/a"},
  {"date": "2026-10-02", "name": "Gandhi Jayanthi", "name_ml": "ഗാന്ധി ജയന്തി",
   "category": "national", "kind": "public", "tentative": false,
   "source": "https://example.org/b"}
]}''';

void main() {
  test('parse keeps good files and lists the bad ones', () {
    final data = HolidayData.parse([_file, 'not json']);
    expect(data.inYear(2026), hasLength(2));
    expect(data.errors, hasLength(1));
    expect(data.inYear(2026).last.id, 'holiday.gandhijayanthi');
  });

  test('a listed festival is marked, other entries stand alone', () {
    final data = HolidayData.parse([_file]);
    final onam = festivalDaysBetween(_cal, _d(2026, 8, 26), _d(2026, 8, 26),
        holidays: data, categories: {FestivalCategory.hindu});
    expect(onam.single.id, 'hindu.onam');
    expect(onam.single.holiday, HolidayKind.public);
    final gandhi = festivalDaysBetween(_cal, _d(2026, 10, 2), _d(2026, 10, 2),
        holidays: data, categories: {FestivalCategory.national});
    expect(gandhi.single.malayalam, 'ഗാന്ധി ജയന്തി');
  });

  test('every computed festival has a description', () {
    for (final f in KeralaFestival.values) {
      expect(festivalInfo('hindu.${EnumName(f).name}').aboutEn, isNotEmpty);
    }
  });
}
