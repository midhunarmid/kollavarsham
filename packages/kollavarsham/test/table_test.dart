import 'dart:io';

import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

import '../tool/generate_table.dart';

void main() {
  test('shipped month-start table matches the engine', () {
    expect(File('lib/src/data/month_starts.dart').readAsStringSync(),
        generateMonthStartTable(),
        reason: 'Run `dart run tool/generate_table.dart` to regenerate.');
  }, testOn: 'vm');

  test('table and engine agree on every day 1900–2100', () {
    final fast = KollavarshamCalendar();
    final slow = KollavarshamCalendar(usePrecomputedTable: false);
    final end = DateTime.utc(2100, 12, 31);
    for (var d = DateTime.utc(1900, 1, 1);
        !d.isAfter(end);
        d = d.add(const Duration(days: 1))) {
      final a = fast.fromGregorian(d), b = slow.fromGregorian(d);
      if (a.year != b.year || a.month != b.month || a.day != b.day) {
        fail('$d: table $a, engine $b');
      }
    }
  });

  test('user overrides still win over the table', () {
    final cal = KollavarshamCalendar(monthStartOverrides: {
      (1201, MalayalamMonth.thulam): DateTime(2025, 10, 17),
    });
    expect(cal.monthStart(1201, MalayalamMonth.thulam), DateTime(2025, 10, 17));
    expect(
        cal.fromGregorian(DateTime(2025, 10, 17)).month, MalayalamMonth.thulam);
  });

  test('other locations compute instead of using the table', () {
    final kozhikode =
        KollavarshamCalendar(location: ObserverLocation.kozhikode);
    // Simha sankranti 2023-08-17 13:44 IST is before Kozhikode's later
    // cut-off, so it agrees with the verified start without needing one.
    expect(kozhikode.monthStart(1199, MalayalamMonth.chingam),
        DateTime(2023, 8, 17));
  });
}
