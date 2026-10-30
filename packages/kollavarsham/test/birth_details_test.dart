import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  group('published charts', () {
    test('17 Sep 1950, 11:00: Anuradha pada 2, Vrischika', () {
      // astrosage.com/celebrity-Horoscope/narendra-modi-birth-chart.asp:
      // Moon 8°48′22″ Scorpio, Anuradha pada 2.
      final b = BirthDetails.fromLocalTime(DateTime(1950, 9, 17, 11));
      expect(b.nakshatra, Nakshatra.anizham);
      expect(b.pada, 2);
      expect(b.rashi, Rashi.vrischika);
      expect(b.date.month, MalayalamMonth.kanni);
    });

    test('19 Nov 1917, 23:11: Uttara Ashadha pada 3, Makara', () {
      // astrosage.com/celebrity-Horoscope/indira-gandhi-birth-chart.asp gives
      // the time; aaps.space/kundli/indira-gandhi gives Moon 4°49′ Capricorn,
      // Uttara Ashadha pada 3.
      final b = BirthDetails.fromLocalTime(DateTime(1917, 11, 19, 23, 11));
      expect(b.nakshatra, Nakshatra.uthradam);
      expect(b.pada, 3);
      expect(b.rashi, Rashi.makara);
    });

    test('7 Nov 1912, a Deepavali day: Chithira star', () {
      // en.wikipedia.org/wiki/Chithira_Thirunal_Balarama_Varma: born on
      // Deepavali under the Chithira star. The time of birth isn't published,
      // so this reads the middle of the day.
      final b = BirthDetails.fromLocalTime(DateTime(1912, 11, 7, 12));
      expect(b.nakshatra, Nakshatra.chithira);
      expect(b.tithi.paksha, Paksha.krishna);
      expect(b.tithi.number, greaterThanOrEqualTo(28));
      expect(b.date.month, MalayalamMonth.thulam);
    });
  });

  group('fromInstant', () {
    test('Malayalam date is the civil day at the location', () {
      // 2025-09-04 19:00 UTC is 00:30 IST on 5 September, Chingam 20.
      final b = BirthDetails.fromInstant(DateTime.utc(2025, 9, 4, 19));
      expect(b.date.toGregorian(), DateTime(2025, 9, 5));
      expect(b.date.month, MalayalamMonth.chingam);
      expect(b.date.day, 20);
    });

    test('date follows the calendar location', () {
      final dubai = KollavarshamCalendar(
        location: const ObserverLocation(
          latitude: 25.2,
          longitude: 55.27,
          utcOffset: Duration(hours: 4),
        ),
      );
      final instant = DateTime.utc(2025, 9, 4, 19);
      final b = BirthDetails.fromInstant(instant, calendar: dubai);
      expect(b.date.toGregorian(), DateTime(2025, 9, 4));
      expect(b.nakshatra, BirthDetails.fromInstant(instant).nakshatra);
    });

    test('matches the calendar for the star and tithi', () {
      final cal = KollavarshamCalendar.standard;
      for (var i = 0; i < 400; i++) {
        final t = DateTime.utc(2026).add(Duration(hours: 7 * i));
        final b = BirthDetails.fromInstant(t);
        expect(b.nakshatra, cal.nakshatraAt(t), reason: '$t');
        expect(b.tithi, cal.tithiAt(t), reason: '$t');
        expect(b.pada, inInclusiveRange(1, 4));
      }
    });

    test('pada, nakshatra and rashi stay consistent through a span', () {
      final span = KollavarshamCalendar.standard
          .nakshatraSpanAt(DateTime.utc(2026, 3, 1));
      final length = span.end.difference(span.start);
      for (var pada = 1; pada <= 4; pada++) {
        final b = BirthDetails.fromInstant(
          span.start.add(length * ((pada - 0.5) / 4)),
        );
        expect(b.nakshatra, span.value);
        expect(b.pada, pada);
      }
    });

    test('a local DateTime is the same moment as its UTC value', () {
      final local = DateTime(2026, 5, 1, 12);
      expect(
        BirthDetails.fromInstant(local).instant,
        BirthDetails.fromInstant(local.toUtc()).instant,
      );
    });
  });

  group('Rashi', () {
    test('names come from the months', () {
      expect(Rashi.mesha.month, MalayalamMonth.medam);
      expect(Rashi.mesha.malayalam, 'മേടം');
      expect(Rashi.simha.english, 'Chingam');
      expect(Rashi.meena.sanskrit, 'Meena');
      expect(Rashi.dhanu.name(MalayalamScript.malayalam), 'ധനു');
    });
  });
}
