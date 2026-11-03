import 'dart:io';

import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:site_data/accuracy.dart';
import 'package:test/test.dart';

void main() {
  final holidays = HolidayData.parse([
    for (final f
        in Directory('../../data/holidays').listSync().whereType<File>())
      if (f.path.endsWith('.json')) f.readAsStringSync(),
  ]);
  final text =
      accuracyChecklist(2026, 2027, KollavarshamCalendar.standard, holidays);

  test('has every section', () {
    for (final heading in [
      '## Month starts',
      '## Festivals',
      '## Holiday list against the computed festivals',
      '## Pirannal',
      '## Shraddham by tithi',
    ]) {
      expect(text, contains(heading));
    }
  });

  test('every listed festival falls on its computed day', () {
    expect(text,
        contains('None: every listed festival falls on its computed day.'));
  });

  test('lists 24 or 25 month starts and the Vishu fix', () {
    final months = RegExp(r'^\| (\w+) 12\d\d \| 20', multiLine: true)
        .allMatches(text.split('## Festivals').first);
    expect(months.length, inInclusiveRange(24, 25));
    expect(text, contains('| Vishu | 2026-04-15 Wed | 2 Medam 1201 |'));
  });

  test('star days found are star days', () {
    final cal = KollavarshamCalendar.standard;
    final days = starDays(cal, 1202, MalayalamMonth.dhanu, Nakshatra.pooradam);
    expect(days, isNotEmpty);
    for (final d in days) {
      expect(d.month, MalayalamMonth.dhanu);
      final rise = cal.sunrise(d.toGregorian())!;
      expect(cal.nakshatraAt(rise.add(const Duration(minutes: 144))),
          Nakshatra.pooradam);
    }
  });
}
