import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  group('known month starts', () {
    // Dates as observed in Kerala almanacs.
    final cases = <(DateTime, int, MalayalamMonth)>[
      (DateTime(2022, 8, 17), 1198, MalayalamMonth.chingam),
      (DateTime(2023, 8, 17), 1199, MalayalamMonth.chingam),
      (DateTime(2024, 8, 17), 1200, MalayalamMonth.chingam),
      (DateTime(2025, 8, 17), 1201, MalayalamMonth.chingam),
      (DateTime(2023, 4, 15), 1198, MalayalamMonth.medam), // Vishu
      (DateTime(2024, 4, 14), 1199, MalayalamMonth.medam),
      (DateTime(2025, 4, 14), 1200, MalayalamMonth.medam),
      (DateTime(2024, 1, 15), 1199, MalayalamMonth.makaram),
      (DateTime(2025, 1, 14), 1200, MalayalamMonth.makaram),
      (DateTime(2024, 11, 16), 1200, MalayalamMonth.vrischikam), // Mandalam
      (DateTime(2024, 7, 16), 1199, MalayalamMonth.karkidakam),
      (DateTime(2025, 7, 17), 1200, MalayalamMonth.karkidakam),
      (DateTime(2025, 9, 17), 1201, MalayalamMonth.kanni),
    ];
    for (final (greg, year, month) in cases) {
      test('$year ${month.english} 1 = ${greg.toIso8601String().split('T')[0]}',
          () {
        final m = MalayalamDate.fromGregorian(greg);
        expect((m.year, m.month, m.day), (year, month, 1));
        expect(MalayalamDate(year, month, 1).toGregorian(), greg);
        // The day before belongs to the previous month.
        final prev =
            MalayalamDate.fromGregorian(greg.subtract(const Duration(days: 1)));
        expect(prev.month, month.previous);
        expect(prev.day, prev.monthLength);
      });
    }
  });

  group('invariants 1990–2060', () {
    test('consecutive days, valid lengths and round trips', () {
      final cal = KollavarshamCalendar();
      var prev = cal.fromGregorian(DateTime(1990, 1, 1));
      final end = DateTime(2060, 12, 31);
      for (var d = DateTime.utc(1990, 1, 2);
          !d.isAfter(DateTime.utc(end.year, end.month, end.day));
          d = d.add(const Duration(days: 1))) {
        final m = cal.fromGregorian(d);
        if (m.month == prev.month) {
          expect(m.day, prev.day + 1, reason: '$d');
          expect(m.year, prev.year, reason: '$d');
        } else {
          expect(m.day, 1, reason: '$d');
          expect(m.month, prev.month.next, reason: '$d');
          expect(prev.day, inInclusiveRange(29, 32), reason: '$d');
          expect(prev.day, cal.monthLength(prev.year, prev.month));
          expect(m.year,
              m.month == MalayalamMonth.chingam ? prev.year + 1 : prev.year,
              reason: '$d');
        }
        expect(cal.toGregorian(m.year, m.month, m.day),
            DateTime(d.year, d.month, d.day));
        prev = m;
      }
    });

    test('year lengths are 365 or 366', () {
      for (var y = 1165; y < 1235; y++) {
        expect(KollavarshamCalendar.standard.yearLength(y), anyOf(365, 366));
      }
    });
  });

  group('borderline months', () {
    test('1199 Chingam began on 2023-08-17 despite a narrow margin', () {
      final margin = KollavarshamCalendar.standard
          .monthStartMargin(1199, MalayalamMonth.chingam);
      expect(margin.inMinutes.abs(), lessThan(10));
      // Computation alone gives Aug 18; the verified override corrects it.
      final cal = KollavarshamCalendar();
      expect(
          cal.monthStart(1199, MalayalamMonth.chingam), DateTime(2023, 8, 17));
    });

    test('custom overrides take precedence', () {
      final cal = KollavarshamCalendar(monthStartOverrides: {
        (1201, MalayalamMonth.thulam): DateTime(2025, 10, 17),
      });
      expect(cal.fromGregorian(DateTime(2025, 10, 17)).month,
          MalayalamMonth.thulam);
      expect(
          cal.monthLength(1201, MalayalamMonth.kanni),
          KollavarshamCalendar.standard
                  .monthLength(1201, MalayalamMonth.kanni) -
              1);
    });

    test('margins are reported in both directions', () {
      final cal = KollavarshamCalendar.standard;
      // Mesha 2025 at 03:30 IST: well before the cut-off.
      expect(cal.monthStartMargin(1200, MalayalamMonth.medam).inHours,
          greaterThan(9));
      // Mesha 2024 at 21:15 IST: after the cut-off.
      expect(
          cal.monthStartMargin(1199, MalayalamMonth.medam).isNegative, isTrue);
    });
  });

  group('MalayalamDate', () {
    final date = MalayalamDate(1201, MalayalamMonth.chingam, 1);

    test('weekday', () {
      expect(date.weekday, MalayalamWeekday.njayar); // Sunday 2025-08-17
    });

    test('addDays across month and year boundaries', () {
      expect(date.addDays(-1).month, MalayalamMonth.karkidakam);
      expect(date.addDays(-1).year, 1200);
      expect(date.addDays(31 + 30).toGregorian(), DateTime(2025, 10, 17));
      expect(date.addDays(400).addDays(-400), date);
    });

    test('addMonths clamps the day', () {
      final last = date.lastDayOfMonth; // Chingam 31
      expect(last.day, 31);
      final next = last.addMonths(1);
      expect(next.month, MalayalamMonth.kanni);
      expect(next.day, next.monthLength);
      expect(date.addMonths(12).year, 1202);
      expect(date.addMonths(-1).month, MalayalamMonth.karkidakam);
    });

    test('comparison and equality', () {
      expect(date < date.addDays(1), isTrue);
      expect(date.daysUntil(date.addDays(10)), 10);
      expect(date, MalayalamDate.fromGregorian(DateTime(2025, 8, 17, 23, 59)));
      expect(date.toString(), '1201 Chingam 1');
    });

    test('DateTime extension', () {
      expect(DateTime(2025, 8, 17).toMalayalamDate(), date);
    });

    test('rejects days outside the month', () {
      expect(() => MalayalamDate(1201, MalayalamMonth.chingam, 32),
          throwsRangeError);
      expect(() => MalayalamDate(1201, MalayalamMonth.chingam, 0),
          throwsRangeError);
    });
  });

  group('format', () {
    final date = MalayalamDate(1201, MalayalamMonth.chingam, 7);

    test('Malayalam script', () {
      expect(date.format('d MMMM y, EEEE'), '7 ചിങ്ങം 1201, ശനി');
    });

    test('English transliteration', () {
      expect(date.format('dd MMMM y', script: MalayalamScript.english),
          '07 Chingam 1201');
    });

    test('Malayalam digits', () {
      expect(date.format('d MMMM y', malayalamDigits: true), '൭ ചിങ്ങം ൧൨൦൧');
    });

    test('numeric and quoted literals', () {
      expect(date.format("y-MM-dd 'is the' d'th'"), '1201-01-07 is the 7th');
      expect(date.format("''d''"), "'7'");
    });
  });

  group('numerals', () {
    test('round trip', () {
      expect(toMalayalamDigits(1234567890), '൧൨൩൪൫൬൭൮൯൦');
      expect(fromMalayalamDigits('൧൨൦൧ ചിങ്ങം'), '1201 ചിങ്ങം');
    });
  });

  group('names', () {
    test('month order and signs', () {
      expect(MalayalamMonth.chingam.signIndex, 4);
      expect(MalayalamMonth.medam.signIndex, 0);
      expect(MalayalamMonth.fromSignIndex(0), MalayalamMonth.medam);
      expect(MalayalamMonth.fromNumber(12), MalayalamMonth.karkidakam);
    });
  });
}
