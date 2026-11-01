import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  group('Christian feasts', () {
    // Kerala Government holiday lists (see panchanga_test.dart). Known
    // extremes: 22 March 1818, 25 April 2038.
    const easters = {
      1818: (3, 22),
      2019: (4, 21),
      2020: (4, 12),
      2021: (4, 4),
      2022: (4, 17),
      2025: (4, 20),
      2038: (4, 25),
    };
    for (final MapEntry(key: year, value: (m, d)) in easters.entries) {
      test('Easter $year', () {
        expect(easterSunday(year), DateTime(year, m, d));
      });
    }

    test('Good Friday and Maundy Thursday', () {
      // Kerala Government holiday lists.
      const goodFridays = {
        2019: (4, 19),
        2020: (4, 10),
        2021: (4, 2),
        2022: (4, 15),
        2023: (4, 7),
        2024: (3, 29),
        2025: (4, 18),
      };
      for (final MapEntry(key: year, value: (m, d)) in goodFridays.entries) {
        final feasts = Map.fromEntries(
            christianFeastsIn(year).map((e) => MapEntry(e.$1, e.$2)));
        expect(feasts[ChristianFeast.goodFriday], DateTime(year, m, d));
      }
      final feasts = Map.fromEntries(
          christianFeastsIn(2025).map((e) => MapEntry(e.$1, e.$2)));
      expect(feasts[ChristianFeast.maundyThursday], DateTime(2025, 4, 17));
      expect(feasts[ChristianFeast.palmSunday], DateTime(2025, 4, 13));
    });

    test('every feast, in order, on the right weekday', () {
      for (var year = 1900; year <= 2100; year++) {
        final feasts = christianFeastsIn(year);
        expect(feasts, hasLength(ChristianFeast.values.length));
        for (var i = 1; i < feasts.length; i++) {
          expect(feasts[i - 1].$2.isBefore(feasts[i].$2), isTrue);
        }
        expect(easterSunday(year).weekday, DateTime.sunday);
        expect(feasts.last.$2, DateTime(year, 12, 25));
      }
    });

    test('names', () {
      expect(ChristianFeast.easter.name(MalayalamScript.english), 'Easter');
      expect(ChristianFeast.christmas.name(MalayalamScript.malayalam),
          'ക്രിസ്മസ്');
    });
  });

  group('tabular Hijri', () {
    test('epoch and a known date', () {
      expect(tabularHijriToGregorian(1, 1, 1), DateTime(622, 7, 19));
      expect(tabularHijriToGregorian(1447, 1, 1), DateTime(2025, 6, 27));
    });

    test('months alternate 30 and 29 days', () {
      for (var month = 1; month < 12; month++) {
        final length = tabularHijriToGregorian(1446, month, 1)
            .difference(tabularHijriToGregorian(1446, month + 1, 1))
            .inDays
            .abs();
        expect(length, month.isOdd ? 30 : 29);
      }
    });

    // Kerala Government holiday lists, which are themselves subject to the
    // moon: 2019 and 2020 from gconnect.in, 2021 from G.O. (P) No.
    // 16/2020/GAD, 2022 and 2025 from onmanorama.com, 2023 and 2024 from
    // greythr.com. The tabular date must fall within two days.
    const dates = {
      HijriFestival.eidUlFitr: [
        (2019, 6, 5),
        (2020, 5, 24),
        (2021, 5, 13),
        (2022, 5, 2),
        (2023, 4, 21),
        (2024, 4, 10),
        (2025, 3, 31),
      ],
      HijriFestival.bakrid: [
        (2019, 8, 11),
        (2020, 7, 31),
        (2021, 7, 20),
        (2022, 7, 9),
        (2023, 6, 28),
        (2024, 6, 17),
        (2025, 6, 6),
      ],
      HijriFestival.muharram: [
        (2021, 8, 19),
        (2022, 8, 8),
        (2023, 7, 28),
        (2024, 7, 16),
        (2025, 7, 6),
      ],
      HijriFestival.miladISherif: [
        (2019, 11, 9),
        (2020, 10, 29),
        (2021, 10, 19),
        (2022, 10, 8),
        (2023, 9, 27),
        (2024, 9, 16),
        (2025, 9, 5),
      ],
    };
    for (final MapEntry(key: festival, value: list) in dates.entries) {
      test('${festival.english} within two days of Kerala lists', () {
        for (final (y, m, d) in list) {
          final found = [
            for (final (f, date) in hijriFestivalsIn(y))
              if (f == festival) date,
          ];
          final published = DateTime(y, m, d);
          expect(
            found.any((date) => date.difference(published).inDays.abs() <= 2),
            isTrue,
            reason: '$festival $published, computed $found',
          );
        }
      });
    }

    test('hijriFestivalsIn is sorted and each festival recurs yearly', () {
      for (var year = 1900; year <= 2100; year++) {
        final festivals = hijriFestivalsIn(year);
        expect(festivals, hasLength(inInclusiveRange(4, 8)));
        for (var i = 1; i < festivals.length; i++) {
          expect(festivals[i - 1].$2.isBefore(festivals[i].$2), isTrue);
        }
        for (final (_, date) in festivals) {
          expect(date.year, year);
        }
      }
    });

    test('a festival can occur twice in a Gregorian year', () {
      final eids = [
        for (final (f, date) in hijriFestivalsIn(2033))
          if (f == HijriFestival.eidUlFitr) date,
      ];
      expect(eids, [DateTime(2033, 1, 3), DateTime(2033, 12, 23)]);
    });

    test('names', () {
      expect(HijriFestival.bakrid.name(MalayalamScript.english), 'Bakrid');
      expect(HijriFestival.bakrid.name(MalayalamScript.malayalam), 'ബക്രീദ്');
    });
  });
}
