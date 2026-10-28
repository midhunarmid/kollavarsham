import 'package:kollavarsham/src/astro/sun.dart';
import 'package:kollavarsham/src/astro/sunrise.dart';
import 'package:kollavarsham/src/astro/time.dart';
import 'package:test/test.dart';

const _ist = Duration(hours: 5, minutes: 30);

DateTime _ist2utc(int y, int m, int d, int h, int min) =>
    DateTime.utc(y, m, d, h, min).subtract(_ist);

void main() {
  group('sun position', () {
    test('matches Meeus example 25.b (1992-10-13 0h TT)', () {
      final t = (2448908.5 - j2000) / 36525.0;
      expect(sunGeometricLongitude(t), closeTo(199.907347, 0.0002));
    });

    test('apparent longitude matches Meeus example 25.b', () {
      final jdUT = 2448908.5 - deltaTSeconds(2448908.5) / 86400.0;
      expect(sunApparentLongitude(jdUT), closeTo(199.906061, 0.001));
    });
  });

  group('sankranti', () {
    // Sankranti moments (IST) published by drikpanchang.com for 2024–2025.
    // (sign index, y, m, d, h, min)
    const cases = [
      [0, 2024, 4, 13, 21, 15],
      [1, 2024, 5, 14, 18, 4],
      [2, 2024, 6, 15, 0, 38],
      [3, 2024, 7, 16, 11, 29],
      [4, 2024, 8, 16, 19, 54],
      [5, 2024, 9, 16, 19, 53],
      [6, 2024, 10, 17, 7, 52],
      [8, 2024, 12, 15, 22, 19],
      [10, 2024, 2, 13, 15, 54],
      [11, 2024, 3, 14, 12, 46],
      [0, 2025, 4, 14, 3, 30],
      [1, 2025, 5, 15, 0, 21],
      [2, 2025, 6, 15, 6, 53],
      [3, 2025, 7, 16, 17, 40],
      [4, 2025, 8, 17, 2, 0],
      [5, 2025, 9, 17, 1, 55],
      [6, 2025, 10, 17, 13, 54],
      [8, 2025, 12, 16, 4, 27],
      [10, 2025, 2, 12, 22, 4],
      [11, 2025, 3, 14, 18, 59],
    ];
    for (final c in cases) {
      test('sign ${c[0]} in ${c[1]}', () {
        final expected = _ist2utc(c[1], c[2], c[3], c[4], c[5]);
        final guess = julianDayFromDateTime(expected) + 2.5;
        final found =
            dateTimeFromJulianDay(findSunSiderealLongitude(c[0] * 30.0, guess));
        expect(found.difference(expected).inSeconds.abs(), lessThan(120),
            reason: 'found ${found.add(_ist)} IST');
      });
    }
  });

  group('sunrise', () {
    test('Thiruvananthapuram, 2025-04-14', () {
      final midnight = julianDayFromDateTime(_ist2utc(2025, 4, 14, 0, 0));
      final rise = dateTimeFromJulianDay(sunEvent(midnight,
              latitude: 8.5241, longitude: 76.9366, rising: true)!)
          .add(_ist);
      final set = dateTimeFromJulianDay(sunEvent(midnight,
              latitude: 8.5241, longitude: 76.9366, rising: false)!)
          .add(_ist);
      expect(rise.hour * 60 + rise.minute, closeTo(6 * 60 + 13, 5));
      expect(set.hour * 60 + set.minute, closeTo(18 * 60 + 33, 5));
    });
  });
}
