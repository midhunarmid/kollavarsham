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
    for (final (name, dates, compute) in [
      ('Attukal Pongala', pongala, cal.attukalPongala),
      ('Thrissur Pooram', pooram, cal.thrissurPooram),
      ('Karkidaka Vavu', vavu, cal.karkidakaVavu),
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
