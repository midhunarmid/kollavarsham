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
