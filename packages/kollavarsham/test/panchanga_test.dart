import 'package:kollavarsham/kollavarsham.dart';
import 'package:kollavarsham/src/astro/moon.dart';
import 'package:test/test.dart';

void main() {
  final cal = KollavarshamCalendar.standard;

  group('moon', () {
    test('matches Meeus example 47.a (1992-04-12 0h TT)', () {
      expect(
          moonGeometricLongitude(-0.077221081451), closeTo(133.162655, 1e-4));
    });
  });

  group('tithi', () {
    test('changes at full and new moon', () {
      // Full moon 2025-01-13 22:27 UTC; new moon 2025-01-29 12:36 UTC.
      expect(cal.tithiAt(DateTime.utc(2025, 1, 13, 22)).number, 15);
      expect(cal.tithiAt(DateTime.utc(2025, 1, 13, 23)).number, 16);
      expect(cal.tithiAt(DateTime.utc(2025, 1, 29, 12)).isAmavasya, isTrue);
      expect(cal.tithiAt(DateTime.utc(2025, 1, 29, 13)).number, 1);
    });

    test('span ends at the full moon', () {
      final span = cal.tithiSpanAt(DateTime.utc(2025, 1, 13, 12));
      expect(span.value.isPournami, isTrue);
      expect(span.end.difference(DateTime.utc(2025, 1, 13, 22, 27)).inMinutes,
          inInclusiveRange(-3, 3));
      expect(span.end.difference(span.start).inHours, inInclusiveRange(19, 27));
    });

    test('names and paksha', () {
      expect(Tithi(11).name(MalayalamScript.malayalam), 'ഏകാദശി');
      expect(Tithi(26).isEkadashi, isTrue);
      expect(Tithi(26).paksha, Paksha.krishna);
      expect(Tithi(15).name(MalayalamScript.english), 'Pournami');
      expect(Tithi(30).name(MalayalamScript.malayalam), 'അമാവാസി');
      expect(() => Tithi(31), throwsRangeError);
    });
  });

  group('nakshatra', () {
    test('span is contiguous and about a day long', () {
      final now = DateTime.utc(2025, 9, 5, 1);
      final span = cal.nakshatraSpanAt(now);
      expect(span.contains(now), isTrue);
      expect(span.end.difference(span.start).inHours, inInclusiveRange(20, 28));
      final next =
          cal.nakshatraSpanAt(span.end.add(const Duration(minutes: 1)));
      expect(next.value, span.value.next);
      expect(next.start.difference(span.end).inSeconds.abs(), lessThan(5));
    });

    test('names', () {
      expect(Nakshatra.thiruvonam.malayalam, 'തിരുവോണം');
      expect(Nakshatra.fromSiderealLongitude(0), Nakshatra.ashwathi);
      expect(Nakshatra.fromSiderealLongitude(359.9), Nakshatra.revathi);
      expect(Nakshatra.values.length, 27);
    });
  });

  group('festivals', () {
    // Thiruvonam as celebrated in Kerala.
    const onamDates = {
      1185: (2009, 9, 2),
      1186: (2010, 8, 23),
      1187: (2011, 9, 9),
      1188: (2012, 8, 29),
      1189: (2013, 9, 16), // Thiruvonam also on Chingam 4
      1190: (2014, 9, 7),
      1191: (2015, 8, 28),
      1193: (2017, 9, 4),
      1194: (2018, 8, 25),
      1195: (2019, 9, 11),
      1196: (2020, 8, 31),
      1197: (2021, 8, 21),
      1198: (2022, 9, 8),
      1199: (2023, 8, 29),
      1200: (2024, 9, 15), // Thiruvonam also on Chingam 3
      1201: (2025, 9, 5),
    };
    for (final MapEntry(key: year, value: (y, m, d)) in onamDates.entries) {
      test('Onam $year', () {
        final onam = cal.onam(year);
        expect(onam.toGregorian(), DateTime(y, m, d));
        expect(onam.nakshatra, Nakshatra.thiruvonam);
        expect(cal.atham(year).daysUntil(onam), 9);
      });
    }

    // Published dates (news reports and Kerala almanacs).
    const pongala = {
      1190: (2015, 3, 5),
      1191: (2016, 2, 23),
      1192: (2017, 3, 11),
      1193: (2018, 3, 2),
      1194: (2019, 2, 20),
      1195: (2020, 3, 9),
      1196: (2021, 2, 27),
      1197: (2022, 2, 17),
      1198: (2023, 3, 7),
      1199: (2024, 2, 25),
      1200: (2025, 3, 13),
    };
    // 2015 is omitted: sources give both 28 and 29 April.
    const pooram = {
      1191: (2016, 4, 17),
      1192: (2017, 5, 5),
      1193: (2018, 4, 25),
      1194: (2019, 5, 13),
      1196: (2021, 4, 23),
      1197: (2022, 5, 10),
      1198: (2023, 4, 30),
      1199: (2024, 4, 19),
      1200: (2025, 5, 6),
    };
    const vavu = {
      1190: (2015, 8, 14),
      1191: (2016, 8, 2),
      1192: (2017, 7, 23),
      1193: (2018, 8, 11),
      1194: (2019, 7, 31),
      1195: (2020, 7, 20),
      1196: (2021, 8, 8),
      1197: (2022, 7, 28),
      1198: (2023, 7, 17),
      1199: (2024, 8, 3),
      1200: (2025, 7, 24),
    };
    // Kerala Government holiday lists unless noted: 2019 and 2020 from
    // gconnect.in, 2021 from G.O. (P) No. 16/2020/GAD, 2022 and 2025 from
    // onmanorama.com, 2023 and 2024 from greythr.com, 2026 from
    // data/holidays/2026.json.
    const sivaratri = {
      1194: (2019, 3, 4),
      1195: (2020, 2, 21),
      1196: (2021, 3, 11),
      1197: (2022, 3, 1),
      1198: (2023, 2, 18),
      1199: (2024, 3, 8),
      1200: (2025, 2, 26),
      1201: (2026, 2, 15),
      1204: (2029, 2, 11), // drikpanchang.com; falls in Makaram
    };
    const ashtamiRohini = {
      1197: (2021, 8, 30),
      1198: (2022, 8, 18),
      1199: (2023, 9, 6),
      1200: (2024, 8, 26),
      1201: (2025, 9, 14),
    };
    // Not in Kerala's lists: calendarific.com and timeanddate.com.
    const vinayaka = {
      1195: (2019, 9, 2),
      1196: (2020, 8, 22),
      1197: (2021, 9, 10),
      1198: (2022, 8, 31),
      1199: (2023, 9, 19),
      1200: (2024, 9, 7),
      1201: (2025, 8, 27),
      1202: (2026, 9, 14),
    };
    const vijayadasami = {
      1195: (2019, 10, 8),
      1196: (2020, 10, 26),
      1197: (2021, 10, 15),
      1198: (2022, 10, 5),
      1199: (2023, 10, 24),
      1200: (2024, 10, 13),
      1201: (2025, 10, 2),
      1202: (2026, 10, 21),
    };
    // 2020 is left out: the list gives 24 October, when the tithi at sunrise
    // was still Ashtami, and the package gives the 25th.
    const mahanavami = {
      1195: (2019, 10, 7),
      1197: (2021, 10, 14),
      1198: (2022, 10, 4),
      1199: (2023, 10, 23),
      1200: (2024, 10, 12),
      1201: (2025, 10, 1),
      1202: (2026, 10, 20),
    };
    // calendarific.com, and Kerala's own orders for 2024 and 2026
    // (onmanorama.com). 2020 is left out: calendarific.com gives 23 October
    // and the package gives the 24th.
    const durgashtami = {
      1195: (2019, 10, 6),
      1197: (2021, 10, 13),
      1198: (2022, 10, 3),
      1199: (2023, 10, 22),
      1200: (2024, 10, 11),
      1201: (2025, 9, 30),
      1202: (2026, 10, 19),
    };
    const deepavali = {
      1195: (2019, 10, 27),
      1196: (2020, 11, 14),
      1197: (2021, 11, 4), // the Chathurdashi ends just before sunrise
      1198: (2022, 10, 24),
      1199: (2023, 11, 12),
      1200: (2024, 10, 31),
      1201: (2025, 10, 20),
      1202: (2026, 11, 8),
    };
    // templesinindiainfo.com, tapioca.co.in and drikpanchang.com. Sources
    // differ by a day in 2019 (7 or 8 December) and 2022 (3 or 4 December);
    // the dates kept are those with the Ekadashi at sunrise in Kerala.
    const guruvayurEkadashi = {
      1195: (2019, 12, 8),
      1196: (2020, 11, 25),
      1197: (2021, 12, 14),
      1198: (2022, 12, 3),
      1199: (2023, 11, 23),
      1200: (2024, 12, 11),
      1201: (2025, 12, 1),
    };
    // Tamil and Malaysian lists (timeanddate.com, officeholidays.com,
    // sambadenglish.com, calendarific.com): no Kerala list was found.
    const thaipooyam = {
      1195: (2020, 2, 8),
      1196: (2021, 1, 28),
      1197: (2022, 1, 18),
      1198: (2023, 2, 5),
      1199: (2024, 1, 25),
      1200: (2025, 2, 11),
      1201: (2026, 2, 1),
      1202: (2027, 1, 22),
    };
    for (final (name, dates, compute) in [
      ('Attukal Pongala', pongala, cal.attukalPongala),
      ('Thrissur Pooram', pooram, cal.thrissurPooram),
      ('Karkidaka Vavu', vavu, cal.karkidakaVavu),
      ('Sivaratri', sivaratri, cal.sivaratri),
      ('Ashtami Rohini', ashtamiRohini, cal.ashtamiRohini),
      ('Vinayaka Chathurthi', vinayaka, cal.vinayakaChathurthi),
      ('Vijayadasami', vijayadasami, cal.vijayadasami),
      ('Mahanavami', mahanavami, cal.mahanavami),
      ('Durgashtami', durgashtami, cal.durgashtami),
      ('Deepavali', deepavali, cal.deepavali),
      ('Guruvayur Ekadashi', guruvayurEkadashi, cal.guruvayurEkadashi),
      ('Thaipooyam', thaipooyam, cal.thaipooyam),
    ]) {
      test(name, () {
        for (final MapEntry(key: year, value: (y, m, d)) in dates.entries) {
          expect(compute(year).toGregorian(), DateTime(y, m, d),
              reason: '$name $year');
        }
      });
    }

    test('festivalsIn lists every festival of the year in order', () {
      final list = cal.festivalsIn(1200);
      expect(list, hasLength(KeralaFestival.values.length));
      expect(list.first.$1, KeralaFestival.newYear);
      expect(list.first.$2.toGregorian(), DateTime(2024, 8, 17));
      for (var i = 1; i < list.length; i++) {
        expect(list[i - 1].$2 <= list[i].$2, isTrue);
      }
      expect(identical(cal.festivalsIn(1200), list), isTrue); // cached
      expect(cal.festivalsOn(cal.onam(1200)), [KeralaFestival.onam]);
      expect(cal.festivalsOn(cal.onam(1200).addDays(1)), isEmpty);
      expect(KeralaFestival.vishu.name(MalayalamScript.malayalam), 'വിഷു');
    });

    test('every festival falls in its season, 1900-2100', () {
      for (var year = 1076; year <= 1275; year++) {
        for (final (festival, date) in cal.festivalsIn(year)) {
          expect(date.year, inInclusiveRange(year - 1, year),
              reason: '$festival $year');
        }
        expect(cal.sivaratri(year).month,
            anyOf(MalayalamMonth.makaram, MalayalamMonth.kumbham));
        expect(
            cal.deepavali(year).month,
            anyOf(MalayalamMonth.kanni, MalayalamMonth.thulam,
                MalayalamMonth.vrischikam));
        expect(cal.vijayadasami(year).month,
            anyOf(MalayalamMonth.kanni, MalayalamMonth.thulam));
        expect(cal.ashtamiRohini(year).month, MalayalamMonth.chingam);
        expect(cal.guruvayurEkadashi(year).month,
            anyOf(MalayalamMonth.vrischikam, MalayalamMonth.dhanu));
        expect(cal.thaipooyam(year).month,
            anyOf(MalayalamMonth.makaram, MalayalamMonth.kumbham));
      }
    });

    test('festivalsOn finds a festival listed under the next year', () {
      final kanniCal = KollavarshamCalendar(yearStart: YearStart.kanni);
      final date = kanniCal.vinayakaChathurthi(1201);
      expect(date.toGregorian(), DateTime(2025, 8, 27));
      expect(date.year, 1200);
      expect(kanniCal.festivalsOn(date),
          contains(KeralaFestival.vinayakaChathurthi));
    });

    test('Vishu, Mandala and Makaravilakku', () {
      expect(cal.vishu(1200).toGregorian(), DateTime(2025, 4, 14));
      expect(cal.mandalaKalamStart(1200).toGregorian(), DateTime(2024, 11, 16));
      expect(cal.mandalaPooja(1200).toGregorian(), DateTime(2024, 12, 26));
      expect(cal.makaravilakku(1200).toGregorian(), DateTime(2025, 1, 14));
    });

    test('birthday lookup by star', () {
      final days = cal.daysWithNakshatra(
          1200, MalayalamMonth.chingam, Nakshatra.thiruvonam);
      expect(days.map((d) => d.day), [3, 30]);
    });
  });

  group('format', () {
    test('nakshatra, tithi and paksha tokens', () {
      final onam = cal.onam(1201);
      expect(onam.format('NNNN'), 'തിരുവോണം');
      expect(
          onam.format('NNNN', script: MalayalamScript.english), 'Thiruvonam');
      expect(
          onam.format('TTTT, PPPP'),
          '${onam.tithi.name(MalayalamScript.malayalam)}, '
          '${onam.tithi.paksha.malayalam}');
    });
  });
}
