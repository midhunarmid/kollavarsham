import 'dart:io';

import 'package:kollavarsham/src/astro/sun.dart';
import 'package:kollavarsham/src/astro/time.dart';
import 'package:test/test.dart';

/// Cross-checks the solar theory against an independent ephemeris.
///
/// `test/fixtures/sankranti_1900_2100.csv` holds every sankranti from 1900
/// to 2100 computed by the Swiss Ephemeris in its "Lahiri" mode (see
/// `tool/generate_reference.py`). That mode differs from the convention of
/// published Kerala panchangams, which this package follows, by a known
/// amount: our sidereal longitude = Swiss longitude + Δψ − 0.006°. After
/// removing that difference the two must agree to well within a minute.
void main() {
  final rows = File('test/fixtures/sankranti_1900_2100.csv')
      .readAsLinesSync()
      .skip(1)
      .where((l) => l.isNotEmpty)
      .toList();

  test('fixture covers 1900–2100', () {
    expect(rows.length, 201 * 12);
  });

  test('every sankranti 1900–2100 within 1 minute of Swiss Ephemeris', () {
    final failures = <String>[];
    for (final row in rows) {
      final parts = row.split(',');
      final sign = int.parse(parts[0]);
      final jdRef = julianDayFromDateTime(DateTime.parse(parts[1]));
      final jd = findSunSiderealLongitude(sign * 30.0, jdRef);
      final t = julianCenturiesTT(jdRef);
      final conventionMinutes =
          -(nutationInLongitude(t) - 0.006) / 0.98564736 * 1440;
      final residual = (jd - jdRef) * 1440 - conventionMinutes;
      if (residual.abs() > 1.0) {
        failures.add('$row: ${residual.toStringAsFixed(2)} min');
      }
    }
    expect(failures, isEmpty);
  });
}
