import 'package:converter_js/converter.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  test('Gregorian to Malayalam', () {
    final r = toMalayalam('2026-08-26')!;
    expect(r['year'], 1202);
    expect(r['month'], 'chingam');
    expect(r['day'], 10);
    expect(r['textEn'], 'Budhan, 10 Chingam 1202');
    expect(r['gregorian'], '2026-08-26');
    expect(toMalayalam('not a date'), isNull);
  });

  test('Malayalam to Gregorian, and back', () {
    expect(toGregorian(1202, 'chingam', 10)!['gregorian'], '2026-08-26');
    expect(toGregorian(1202, 'chingam', 40), isNull);
    expect(toGregorian(1202, 'nope', 1), isNull);
    for (final iso in ['2024-02-29', '2026-04-14', '2030-12-31']) {
      final m = toMalayalam(iso)!;
      expect(
          toGregorian(m['year']! as int, m['month']! as String,
              m['day']! as int)!['gregorian'],
          iso);
    }
  });

  test('star finder matches the engine', () {
    final r = findStar('1990-01-15T06:30')!;
    final d = BirthDetails.fromLocalTime(DateTime(1990, 1, 15, 6, 30));
    expect(r['starEn'], d.nakshatra.english);
    expect(r['pada'], d.pada);
    expect(findStar('x'), isNull);
  });

  test('another place', () {
    final cal =
        calendarFor(latitude: 51.5, longitude: -0.1, utcOffsetMinutes: 0);
    expect(cal.location.utcOffset, Duration.zero);
    expect(toMalayalam('2026-08-26', cal), isNotNull);
  });
}
