import 'package:kollavarsham/kollavarsham.dart';
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

const _ist = Duration(hours: 5, minutes: 30);

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
}
