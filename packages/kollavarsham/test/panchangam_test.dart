import 'package:kollavarsham/kollavarsham.dart';
import 'package:kollavarsham/src/astro/moon.dart';
import 'package:test/test.dart';

/// A day of the panchangam published at drikpanchang.com for
/// Thiruvananthapuram (geoname 1254163), in IST: the yoga and karana at
/// sunrise and their end times.
typedef _Day = ({
  String date,
  String yoga,
  String yogaEnd,
  String karana,
  String karanaEnd,
});

/// `https://www.drikpanchang.com/panchang/day-panchang.html?geoname-id=1254163`
/// with `&date=DD/MM/YYYY`.
const List<_Day> _days = [
  (
    date: '2025-01-15',
    yoga: 'Priti',
    yogaEnd: '2025-01-16 01:47',
    karana: 'Taitila',
    karanaEnd: '2025-01-15 15:17'
  ),
  (
    date: '2025-02-01',
    yoga: 'Parigha',
    yogaEnd: '2025-02-01 12:25',
    karana: 'Garaja',
    karanaEnd: '2025-02-01 11:38'
  ),
  (
    date: '2025-02-16',
    yoga: 'Dhriti',
    yogaEnd: '2025-02-16 08:06',
    karana: 'Bava',
    karanaEnd: '2025-02-16 13:01'
  ),
  (
    date: '2025-03-03',
    yoga: 'Shukla',
    yogaEnd: '2025-03-03 08:57',
    karana: 'Vanija',
    karanaEnd: '2025-03-03 07:30'
  ),
  (
    date: '2025-03-18',
    yoga: 'Vyaghata',
    yogaEnd: '2025-03-18 16:44',
    karana: 'Bava',
    karanaEnd: '2025-03-18 08:51'
  ),
  (
    date: '2025-04-03',
    yoga: 'Saubhagya',
    yogaEnd: '2025-04-04 00:01',
    karana: 'Kaulava',
    karanaEnd: '2025-04-03 10:40'
  ),
  (
    date: '2025-04-18',
    yoga: 'Parigha',
    yogaEnd: '2025-04-19 01:04',
    karana: 'Taitila',
    karanaEnd: '2025-04-18 17:07'
  ),
  (
    date: '2025-05-03',
    yoga: 'Shula',
    yogaEnd: '2025-05-04 01:41',
    karana: 'Taitila',
    karanaEnd: '2025-05-03 07:51'
  ),
  (
    date: '2025-05-18',
    yoga: 'Shubha',
    yogaEnd: '2025-05-18 06:43',
    karana: 'Garaja',
    karanaEnd: '2025-05-18 18:08'
  ),
  (
    date: '2025-06-02',
    yoga: 'Vyaghata',
    yogaEnd: '2025-06-02 08:21',
    karana: 'Garaja',
    karanaEnd: '2025-06-02 08:11'
  ),
  (
    date: '2025-06-17',
    yoga: 'Vishkambha',
    yogaEnd: '2025-06-17 09:34',
    karana: 'Vanija',
    karanaEnd: '2025-06-17 14:46'
  ),
  (
    date: '2025-07-02',
    yoga: 'Variyana',
    yogaEnd: '2025-07-02 17:47',
    karana: 'Vanija',
    karanaEnd: '2025-07-02 11:58'
  ),
  (
    date: '2025-07-17',
    yoga: 'Atiganda',
    yogaEnd: '2025-07-17 09:29',
    karana: 'Vishti',
    karanaEnd: '2025-07-17 08:07'
  ),
  (
    date: '2025-08-01',
    yoga: 'Shubha',
    yogaEnd: '2025-08-02 05:30',
    karana: 'Vishti',
    karanaEnd: '2025-08-01 18:10'
  ),
  (
    date: '2025-08-16',
    yoga: 'Vriddhi',
    yogaEnd: '2025-08-16 07:21',
    karana: 'Balava',
    karanaEnd: '2025-08-16 10:41'
  ),
  (
    date: '2025-08-31',
    yoga: 'Vaidhriti',
    yogaEnd: '2025-08-31 15:59',
    karana: 'Vishti',
    karanaEnd: '2025-08-31 11:54'
  ),
  (
    date: '2025-09-15',
    yoga: 'Vyatipata',
    yogaEnd: '2025-09-16 02:34',
    karana: 'Taitila',
    karanaEnd: '2025-09-15 14:15'
  ),
  (
    date: '2025-09-30',
    yoga: 'Shobhana',
    yogaEnd: '2025-10-01 01:03',
    karana: 'Bava',
    karanaEnd: '2025-09-30 18:06'
  ),
  (
    date: '2025-10-15',
    yoga: 'Sadhya',
    yogaEnd: '2025-10-16 02:57',
    karana: 'Garaja',
    karanaEnd: '2025-10-15 10:33'
  ),
  (
    date: '2025-10-30',
    yoga: 'Shula',
    yogaEnd: '2025-10-30 07:21',
    karana: 'Bava',
    karanaEnd: '2025-10-30 10:06'
  ),
  (
    date: '2025-11-14',
    yoga: 'Indra',
    yogaEnd: '2025-11-14 06:28',
    karana: 'Vanija',
    karanaEnd: '2025-11-14 12:07'
  ),
  (
    date: '2025-11-29',
    yoga: 'Harshana',
    yogaEnd: '2025-11-29 09:27',
    karana: 'Balava',
    karanaEnd: '2025-11-29 11:50'
  ),
  (
    date: '2025-12-14',
    yoga: 'Saubhagya',
    yogaEnd: '2025-12-14 11:45',
    karana: 'Vishti',
    karanaEnd: '2025-12-14 18:49'
  ),
  (
    date: '2025-12-29',
    yoga: 'Parigha',
    yogaEnd: '2025-12-29 07:36',
    karana: 'Kaulava',
    karanaEnd: '2025-12-29 10:12'
  ),
  (
    date: '2026-01-13',
    yoga: 'Shula',
    yogaEnd: '2026-01-13 19:05',
    karana: 'Vishti',
    karanaEnd: '2026-01-13 15:17'
  ),
  (
    date: '2026-01-28',
    yoga: 'Brahma',
    yogaEnd: '2026-01-28 23:54',
    karana: 'Garaja',
    karanaEnd: '2026-01-28 16:35'
  ),
  (
    date: '2026-02-12',
    yoga: 'Harshana',
    yogaEnd: '2026-02-13 03:06',
    karana: 'Vishti',
    karanaEnd: '2026-02-12 12:22'
  ),
  (
    date: '2026-02-27',
    yoga: 'Ayushman',
    yogaEnd: '2026-02-27 19:44',
    karana: 'Vanija',
    karanaEnd: '2026-02-27 11:31'
  ),
  (
    date: '2026-03-14',
    yoga: 'Variyana',
    yogaEnd: '2026-03-14 10:43',
    karana: 'Vishti',
    karanaEnd: '2026-03-14 08:10'
  ),
  (
    date: '2026-03-29',
    yoga: 'Dhriti',
    yogaEnd: '2026-03-29 18:20',
    karana: 'Vishti',
    karanaEnd: '2026-03-29 07:46'
  ),
];

/// The same 30 days, in IST: date, sunrise, sunset, then the start and end
/// of Rahu kalam, Gulika kalam and Yamagandam, then moonrise and moonset. A
/// `+` marks a moon event on the next civil day: drikpanchang's day runs from
/// sunrise to sunrise.
const _times = '''
2025-01-15 06:41 18:22 12:32 13:59 11:04 12:32 08:09 09:36 19:51 07:44
2025-02-01 06:43 18:29 09:39 11:08 06:43 08:11 14:04 15:32 08:57 21:08
2025-02-16 06:40 18:32 17:03 18:32 15:34 17:03 12:36 14:05 21:32 08:58
2025-03-03 06:35 18:33 08:05 09:34 14:04 15:34 11:04 12:34 09:06 21:41
2025-03-18 06:27 18:33 15:32 17:02 12:30 14:01 09:29 11:00 21:43 08:48
2025-04-03 06:19 18:32 13:57 15:29 09:22 10:54 06:19 07:51 10:34 23:35
2025-04-18 06:12 18:32 10:49 12:22 07:44 09:17 15:27 16:59 23:05 09:50
2025-05-03 06:06 18:32 09:13 10:46 06:06 07:39 13:52 15:26 11:24 +00:15
2025-05-18 06:03 18:34 17:01 18:34 15:27 17:01 12:19 13:53 23:34 10:30
2025-06-02 06:03 18:38 07:37 09:11 13:55 15:29 10:46 12:20 11:52 +00:20
2025-06-17 06:05 18:42 15:32 17:07 12:23 13:58 09:14 10:49 23:46 11:04
2025-07-02 06:08 18:45 12:26 14:01 10:52 12:26 07:43 09:17 12:01 +00:08
2025-07-17 06:12 18:45 14:03 15:37 09:20 10:54 06:12 07:46 23:54 11:33
2025-08-01 06:14 18:43 10:55 12:29 07:48 09:21 15:36 17:09 12:08 23:58
2025-08-16 06:15 18:38 09:21 10:53 06:15 07:48 13:59 15:32 +00:23 12:17
2025-08-31 06:14 18:31 16:59 18:31 15:27 16:59 12:22 13:55 12:28 +00:08
2025-09-15 06:12 18:22 07:44 09:15 13:49 15:20 10:46 12:17 +01:19 13:17
2025-09-30 06:11 18:14 15:13 16:43 12:12 13:42 09:11 10:42 12:57 +00:38
2025-10-15 06:10 18:06 12:08 13:37 10:38 12:08 07:39 09:09 +02:04 13:55
2025-10-30 06:11 18:01 13:35 15:03 09:08 10:37 06:11 07:39 13:15 +01:08
2025-11-14 06:14 17:59 10:39 12:07 07:42 09:10 15:03 16:31 +02:23 13:59
2025-11-29 06:20 18:01 09:15 10:43 06:20 07:48 13:38 15:06 13:17 +01:30
2025-12-14 06:28 18:06 16:39 18:06 15:12 16:39 12:17 13:44 +02:33 13:49
2025-12-29 06:35 18:13 08:03 09:30 13:52 15:19 10:57 12:24 13:23 +02:00
2026-01-13 06:41 18:21 15:26 16:54 12:31 13:58 09:36 11:03 +02:51 13:47
2026-01-28 06:43 18:28 12:35 14:03 11:07 12:35 08:11 09:39 13:56 +02:54
2026-02-12 06:41 18:32 14:05 15:34 09:39 11:08 06:41 08:10 +03:18 14:05
2026-02-27 06:37 18:33 11:05 12:35 08:06 09:36 15:34 17:04 14:55 +03:50
2026-03-14 06:30 18:33 09:31 11:01 06:30 08:00 14:02 15:32 +03:37 14:33
2026-03-29 06:22 18:32 17:01 18:32 15:30 17:01 12:27 13:58 15:40 +04:12
''';

const _ist = Duration(hours: 5, minutes: 30);

/// One row of [_times] split into columns.
final _rows = [
  for (final line in _times.trim().split('\n')) line.split(' '),
];

/// The instant of a [_times] column on [date]; a leading `+` is the next day.
DateTime _at(String date, String time) {
  final next = time.startsWith('+');
  final clock = next ? time.substring(1) : time;
  final day = DateTime.parse('${date}T$clock:00Z').subtract(_ist);
  return next ? day.add(const Duration(days: 1)) : day;
}

/// The instant of `YYYY-MM-DD HH:MM` in IST.
DateTime _instant(String text) =>
    DateTime.parse('${text.replaceFirst(' ', 'T')}:00Z').subtract(_ist);

Matcher _within(DateTime expected, int minutes) => predicate<DateTime>(
    (t) => t.difference(expected).inSeconds.abs() <= minutes * 60,
    'within $minutes min of $expected');

void main() {
  final cal = KollavarshamCalendar.standard;

  group('yoga', () {
    for (final day in _days) {
      test('${day.date}: ${day.yoga} ends ${day.yogaEnd}', () {
        final date = DateTime.parse(day.date);
        expect(cal.yogaOn(date).english, day.yoga);
        final span = cal.yogaSpanAt(cal.sunrise(date)!);
        expect(span.value.english, day.yoga);
        expect(span.end, _within(_instant(day.yogaEnd), 2));
      });
    }

    test('spans are contiguous', () {
      final span = cal.yogaSpanAt(DateTime.utc(2025, 9, 5, 1));
      final next = cal.yogaSpanAt(span.end.add(const Duration(minutes: 1)));
      expect(next.value, span.value.next);
      expect(next.start.difference(span.end).inSeconds.abs(), lessThan(5));
      expect(span.contains(DateTime.utc(2025, 9, 5, 1)), isTrue);
      expect(cal.yogaAt(DateTime.utc(2025, 9, 5, 1)), span.value);
    });

    test('names and wrap-around', () {
      expect(Yoga.values.length, 27);
      expect(Yoga.fromLongitudeSum(0), Yoga.vishkambha);
      expect(Yoga.fromLongitudeSum(359.9), Yoga.vaidhriti);
      expect(Yoga.vaidhriti.next, Yoga.vishkambha);
      expect(Yoga.shiva.name(MalayalamScript.malayalam), 'ശിവം');
      expect(Yoga.shiva.name(MalayalamScript.english), 'Shiva');
    });
  });

  group('karana', () {
    for (final day in _days) {
      test('${day.date}: ${day.karana} ends ${day.karanaEnd}', () {
        final date = DateTime.parse(day.date);
        expect(cal.karanaOn(date).english, day.karana);
        final span = cal.karanaSpanAt(cal.sunrise(date)!);
        expect(span.value.english, day.karana);
        expect(span.end, _within(_instant(day.karanaEnd), 2));
      });
    }

    test('the 60 half tithis hold the fixed karanas once each', () {
      final slots = [for (var i = 0; i < 60; i++) Karana.ofSlot(i)];
      expect(slots.first, Karana.kimstughna);
      expect(slots.sublist(57), [
        Karana.shakuni,
        Karana.chatushpada,
        Karana.naga,
      ]);
      for (var i = 1; i < 57; i++) {
        expect(slots[i], Karana.values[(i - 1) % 7]);
      }
      for (var i = 0; i < 7; i++) {
        expect(slots.where((k) => k == Karana.values[i]).length, 8);
      }
    });

    test('elongation picks the half tithi', () {
      expect(Karana.fromElongation(0), Karana.kimstughna);
      expect(Karana.fromElongation(6), Karana.bava);
      expect(Karana.fromElongation(359), Karana.naga);
      expect(Karana.fromElongation(342), Karana.shakuni);
    });

    test('two karanas fill a tithi', () {
      const at = '2025-09-05 12:00';
      final tithi = cal.tithiSpanAt(_instant(at));
      final first =
          cal.karanaSpanAt(tithi.start.add(const Duration(minutes: 1)));
      final second =
          cal.karanaSpanAt(first.end.add(const Duration(minutes: 1)));
      expect(first.start.difference(tithi.start).inSeconds.abs(), lessThan(5));
      expect(second.end.difference(tithi.end).inSeconds.abs(), lessThan(5));
    });

    test('names', () {
      expect(Karana.values.length, 11);
      expect(Karana.vishti.name(MalayalamScript.malayalam), 'വിഷ്ടി');
      expect(Karana.vishti.name(MalayalamScript.english), 'Vishti');
    });
  });

  group('sun and kalams', () {
    for (final row in _rows) {
      final date = DateTime.parse(row[0]);
      test('${row[0]}: sunrise and sunset', () {
        expect(cal.sunrise(date), _within(_at(row[0], row[1]), 1));
        expect(cal.sunset(date), _within(_at(row[0], row[2]), 1));
      });

      for (final (i, kalam) in Kalam.values.indexed) {
        test('${row[0]}: ${kalam.english}', () {
          final span = cal.kalamOn(date, kalam)!;
          expect(span.value, kalam);
          expect(span.start, _within(_at(row[0], row[3 + 2 * i]), 2));
          expect(span.end, _within(_at(row[0], row[4 + 2 * i]), 2));
        });
      }
    }

    test('the kalams take different parts of every weekday', () {
      for (var weekday = 1; weekday <= 7; weekday++) {
        final parts = {for (final k in Kalam.values) k.partOn(weekday)};
        expect(parts.length, 3);
      }
    });

    test('no sunrise, no kalam', () {
      final arctic = KollavarshamCalendar(
        location: const ObserverLocation(
          latitude: 78.2,
          longitude: 15.6,
          utcOffset: Duration(hours: 1),
        ),
      );
      expect(arctic.kalamOn(DateTime(2025, 6, 21), Kalam.rahu), isNull);
    });

    test('names', () {
      expect(Kalam.rahu.name(MalayalamScript.malayalam), 'രാഹുകാലം');
      expect(Kalam.yamagandam.name(MalayalamScript.english), 'Yamagandam');
    });
  });

  group('moon rise and set', () {
    for (final row in _rows) {
      final date = DateTime.parse(row[0]);
      test('${row[0]}: moonrise ${row[9]}, moonset ${row[10]}', () {
        DateTime? event(String time, DateTime? Function(DateTime) find) => find(
            time.startsWith('+') ? date.add(const Duration(days: 1)) : date);

        expect(event(row[9], cal.moonrise), _within(_at(row[0], row[9]), 2));
        expect(event(row[10], cal.moonset), _within(_at(row[0], row[10]), 2));
      });
    }

    test('rises on all but about one day a month', () {
      var missing = 0;
      for (var d = 0; d < 365; d++) {
        final date = DateTime.utc(2026).add(Duration(days: d));
        if (cal.moonrise(date) == null) missing++;
      }
      expect(missing, inInclusiveRange(10, 14));
    });

    test('no moonset through a polar day of the Moon', () {
      final arctic = KollavarshamCalendar(
        location: const ObserverLocation(
          latitude: 78.2,
          longitude: 15.6,
          utcOffset: Duration(hours: 1),
        ),
      );
      final missing = [
        for (var d = 0; d < 30; d++)
          if (arctic.moonset(DateTime.utc(2026, 1, 1 + d)) == null) d,
      ];
      expect(missing.length, greaterThan(5));
    });

    test('moon latitude and distance match Meeus example 47.a', () {
      const t = -0.077221081451;
      expect(moonLatitude(t), closeTo(-3.229126, 0.005));
      // The series is shortened: 25 km is 0.0004° of parallax.
      expect(moonDistance(t), closeTo(368409.7, 25));
    });
  });

  group('chandrashtamam', () {
    // Mesha rashi, 2026, in IST, from hindupad.com/chandrashtama-mesha and
    // panchangbodh.com/mesha-chandrashtama (which agree within a minute).
    const mesha2026 = [
      ('2026-01-13 17:21', '2026-01-16 05:48'),
      ('2026-02-10 01:11', '2026-02-12 13:42'),
      ('2026-03-09 09:30', '2026-03-11 22:00'),
      ('2026-04-05 17:28', '2026-04-08 05:54'),
      ('2026-05-03 00:30', '2026-05-05 12:54'),
      ('2026-05-30 06:39', '2026-06-01 19:08'),
      ('2026-06-26 12:33', '2026-06-29 01:09'),
      ('2026-07-23 19:01', '2026-07-26 07:35'),
      ('2026-08-20 02:30', '2026-08-22 14:49'),
      ('2026-09-16 10:49', '2026-09-18 22:45'),
      ('2026-10-13 19:12', '2026-10-16 06:47'),
      ('2026-11-10 02:48', '2026-11-12 14:19'),
      ('2026-12-07 09:14', '2026-12-09 21:00'),
    ];

    test('matches the published 2026 dates for Mesha', () {
      final spans = cal.chandrashtamam(
          Rashi.mesha, DateTime.utc(2026), DateTime.utc(2027));
      expect(spans.length, mesha2026.length);
      for (final (i, span) in spans.indexed) {
        expect(span.value, Rashi.vrischika);
        expect(span.start, _within(_instant(mesha2026[i].$1), 2));
        expect(span.end, _within(_instant(mesha2026[i].$2), 2));
      }
    });

    test('spans overlapping the edges are included', () {
      final inside = _instant('2026-01-14 12:00');
      final spans = cal.chandrashtamam(
          Rashi.mesha, inside, inside.add(const Duration(hours: 1)));
      expect(spans.length, 1);
      expect(spans.single.contains(inside), isTrue);
      expect(
          cal.chandrashtamam(Rashi.mesha, _instant('2026-01-20 00:00'),
              _instant('2026-01-25 00:00')),
          isEmpty);
    });

    test('is the sixth rashi back', () {
      for (final rashi in Rashi.values) {
        expect(rashi.eighth.index, (rashi.index + 7) % 12);
      }
      expect(Rashi.mesha.eighth, Rashi.vrischika);
      expect(Rashi.meena.eighth, Rashi.tula);
      expect(Rashi.fromSiderealLongitude(359.9), Rashi.meena);
    });

    test('rashiOf follows the 108 padas', () {
      for (var i = 0; i < 108; i++) {
        final star = Nakshatra.values[i ~/ 4];
        expect(star.rashiOf(i % 4 + 1), Rashi.values[i ~/ 9]);
      }
      expect(Nakshatra.karthika.rashiOf(1), Rashi.mesha);
      expect(Nakshatra.karthika.rashiOf(2), Rashi.vrishabha);
      expect(Nakshatra.pooradam.rashiOf(4), Rashi.dhanu);
      expect(() => Nakshatra.rohini.rashiOf(5), throwsRangeError);
    });
  });
}
