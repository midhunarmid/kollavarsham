import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  group('equality', () {
    test('dates from separately created, equivalent calendars are equal', () {
      final a = MalayalamDate(1201, MalayalamMonth.chingam, 1,
          calendar: KollavarshamCalendar());
      final b = MalayalamDate(1201, MalayalamMonth.chingam, 1,
          calendar: KollavarshamCalendar());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect({a, b}, hasLength(1));
    });

    test('locations compare by value, ignoring the name', () {
      const named = ObserverLocation.thiruvananthapuram;
      const unnamed = ObserverLocation(
        latitude: 8.5241,
        longitude: 76.9366,
        utcOffset: Duration(hours: 5, minutes: 30),
      );
      expect(unnamed, named);
      expect(KollavarshamCalendar(location: unnamed), KollavarshamCalendar());
    });

    test('different locations or overrides are not equal', () {
      final tvm = KollavarshamCalendar();
      expect(
          KollavarshamCalendar(location: ObserverLocation.kochi), isNot(tvm));
      expect(
          KollavarshamCalendar(monthStartOverrides: {
            (1201, MalayalamMonth.thulam): DateTime(2025, 10, 18),
          }),
          isNot(tvm));
      final kochiDate = MalayalamDate(1201, MalayalamMonth.chingam, 1,
          calendar: KollavarshamCalendar(location: ObserverLocation.kochi));
      final tvmDate = MalayalamDate(1201, MalayalamMonth.chingam, 1);
      expect(kochiDate, isNot(tvmDate));
      expect(kochiDate.isAtSameDayAs(tvmDate), isTrue);
    });
  });

  test('verified month starts cannot be modified', () {
    expect(
        () => KollavarshamCalendar
                .verifiedMonthStarts[(1201, MalayalamMonth.thulam)] =
            DateTime(2025, 10, 17),
        throwsUnsupportedError);
  });

  group('YearStart.kanni (North Malabar)', () {
    final north = KollavarshamCalendar(yearStart: YearStart.kanni);

    test('Chingam belongs to the previous year', () {
      final d = north.fromGregorian(DateTime(2025, 8, 17));
      expect((d.year, d.month, d.day), (1200, MalayalamMonth.chingam, 1));
      expect(d.toString(), '1200 Chingam 1');
    });

    test('the year number changes at Kanni 1', () {
      final lastOfChingam = north.fromGregorian(DateTime(2025, 9, 16));
      final kanni1 = north.fromGregorian(DateTime(2025, 9, 17));
      expect((lastOfChingam.year, lastOfChingam.month),
          (1200, MalayalamMonth.chingam));
      expect((kanni1.year, kanni1.month, kanni1.day),
          (1201, MalayalamMonth.kanni, 1));
    });

    test('other months keep the same number', () {
      final d = north.fromGregorian(DateTime(2026, 4, 14));
      expect((d.year, d.month), (1201, MalayalamMonth.medam));
    });

    test('round trips and month arithmetic', () {
      final chingam =
          MalayalamDate(1200, MalayalamMonth.chingam, 1, calendar: north);
      expect(chingam.toGregorian(), DateTime(2025, 8, 17));
      expect(chingam.addMonths(1).month, MalayalamMonth.kanni);
      expect(chingam.addMonths(1).year, 1201);
      expect(chingam.addMonths(-1).year, 1200); // Karkidakam 1200
      expect(north.monthStart(1200, MalayalamMonth.chingam),
          DateTime(2025, 8, 17));
      expect(north.yearLength(1201), anyOf(365, 366));
      expect(north.onam(1200).toGregorian(), DateTime(2025, 9, 5));
    });

    test('overrides use the calendar numbering', () {
      final cal = KollavarshamCalendar(
        yearStart: YearStart.kanni,
        monthStartOverrides: {
          (1200, MalayalamMonth.chingam): DateTime(2025, 8, 18),
        },
      );
      expect(
          cal.monthStart(1200, MalayalamMonth.chingam), DateTime(2025, 8, 18));
    });
  });
}
