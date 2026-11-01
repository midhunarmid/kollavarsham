import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  // The published lists below are for New Delhi.
  final delhi = KollavarshamCalendar(
    location: const ObserverLocation(
      latitude: 28.6356,
      longitude: 77.2244,
      utcOffset: Duration(hours: 5, minutes: 30),
    ),
  );

  Set<(int, int)> daysOf2025(Vrat vrat) => {
        for (final year in [1200, 1201])
          for (final day in delhi.vratDays(vrat, year))
            if (day.toGregorian().year == 2025)
              (day.toGregorian().month, day.toGregorian().day),
      };

  // drikpanchang.com/vrats, New Delhi, 2025. Ekadashi is the Smarta list,
  // except 2 November: the Ekadashi holds at that sunrise, which is the
  // page's Vaishnava day, and its Smarta day is the 1st. Pournami takes the
  // fasting day.
  const published = {
    Vrat.ekadashi: {
      (1, 10), (1, 25), (2, 8), (2, 24), (3, 10), (3, 25), (4, 8), (4, 24),
      (5, 8), (5, 23), (6, 6), (6, 21), (7, 6), (7, 21), (8, 5), (8, 19),
      (9, 3), (9, 17), (10, 3), (10, 17), (11, 2), (11, 15), (12, 1),
      (12, 15), (12, 30), //
    },
    Vrat.pradosham: {
      (1, 11), (1, 27), (2, 9), (2, 25), (3, 11), (3, 27), (4, 10), (4, 25),
      (5, 9), (5, 24), (6, 8), (6, 23), (7, 8), (7, 22), (8, 6), (8, 20),
      (9, 5), (9, 19), (10, 4), (10, 18), (11, 3), (11, 17), (12, 2),
      (12, 17), //
    },
    Vrat.shashti: {
      (1, 5), (2, 3), (3, 4), (4, 3), (5, 2), (6, 1), (6, 30), (7, 30),
      (8, 28), (9, 27), (10, 27), (11, 26), (12, 25), //
    },
    Vrat.pournami: {
      (1, 13), (2, 12), (3, 13), (4, 12), (5, 12), (6, 10), (7, 10), (8, 9),
      (9, 7), (10, 6), (11, 5), (12, 4), //
    },
    Vrat.amavasya: {
      (1, 29), (2, 27), (3, 29), (4, 27), (5, 27), (6, 25), (7, 24), (8, 23),
      (9, 21), (10, 21), (11, 20), (12, 19), //
    },
  };

  for (final MapEntry(key: vrat, value: dates) in published.entries) {
    test('${vrat.english} 2025 matches drikpanchang', () {
      final days = daysOf2025(vrat);
      expect(days.difference(dates), isEmpty, reason: 'extra');
      expect(dates.difference(days), isEmpty, reason: 'missing');
    });
  }

  test('Pradosham 2026 at Thiruvananthapuram', () {
    // dailycalendartamil.com/pradosham-2026, a Tamil Nadu list, except that
    // it has 1 March and 29 April, a day later than these two.
    const dates = {
      (1, 1), (1, 16), (1, 30), (2, 14), (2, 28), (3, 16), (3, 30), (4, 15),
      (4, 28), (5, 14), (5, 28), (6, 12), (6, 27), (7, 12), (7, 26), (8, 10),
      (8, 25), (9, 8), (9, 24), (10, 8), (10, 23), (11, 6), (11, 22), (12, 6),
      (12, 21), //
    };
    final days = {
      for (final year in [1201, 1202])
        for (final day
            in KollavarshamCalendar.standard.vratDays(Vrat.pradosham, year))
          if (day.toGregorian().year == 2026)
            (day.toGregorian().month, day.toGregorian().day),
    };
    expect(days.difference(dates), isEmpty, reason: 'extra');
    expect(dates.difference(days), isEmpty, reason: 'missing');
  });

  test('one day per lunar day, 1900-2100', () {
    final cal = KollavarshamCalendar.standard;
    const gaps = {
      Vrat.ekadashi: (13, 17),
      Vrat.pradosham: (13, 17),
      Vrat.shashti: (28, 31),
      Vrat.pournami: (28, 31),
      Vrat.amavasya: (28, 31),
    };
    for (final MapEntry(key: vrat, value: (low, high)) in gaps.entries) {
      for (var year = 1076; year <= 1275; year += 7) {
        final days = cal.vratDays(vrat, year);
        expect(days.every((d) => d.year == year), isTrue);
        for (var i = 1; i < days.length; i++) {
          expect(days[i - 1].daysUntil(days[i]), inInclusiveRange(low, high),
              reason: '${vrat.english} ${days[i]}');
        }
      }
    }
  });

  test('names', () {
    expect(Vrat.ekadashi.name(MalayalamScript.malayalam), 'ഏകാദശി');
    expect(Vrat.amavasya.name(MalayalamScript.english), 'Amavasya');
  });
}
