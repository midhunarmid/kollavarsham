import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

void main() {
  final chingam1 = MalayalamDate(1201, MalayalamMonth.chingam, 1);
  final karkidakam3 = MalayalamDate(1200, MalayalamMonth.karkidakam, 3);

  group('format tokens', () {
    test('short month, short weekday and era', () {
      expect(chingam1.format('E, d MMM y G', script: MalayalamScript.english),
          'Sun, 1 Chi 1201 ME');
      expect(chingam1.format('E, d MMMM y G'), 'ഞാ, 1 ചിങ്ങം 1201 കൊ.വ.');
      expect(chingam1.format('GGGG y'), 'കൊല്ലവർഷം 1201');
      expect(chingam1.format('GGGG y', script: MalayalamScript.english),
          'Kollavarsham 1201');
    });
  });

  group('parse', () {
    test('default pattern in both scripts', () {
      expect(MalayalamDate.parse('1 ചിങ്ങം 1201'), chingam1);
      expect(MalayalamDate.parse('1 Chingam 1201'), chingam1);
      expect(MalayalamDate.parse('  1   chingam   1201 '), chingam1);
    });

    test('spelling variants, case and old-style chillu', () {
      expect(MalayalamDate.parse('3 KARKKIDAKAM 1200'), karkidakam3);
      expect(MalayalamDate.parse('3 കർക്കിടകം 1200'), karkidakam3);
      // ര + virama + ZWJ: the pre-Unicode-5.1 way of writing ർ.
      expect(MalayalamDate.parse('3 കര്‍ക്കടകം 1200'), karkidakam3);
      expect(MalayalamMonth.tryParseName('Vrishchikam'),
          MalayalamMonth.vrischikam);
      expect(MalayalamMonth.tryParseName('kar'), MalayalamMonth.karkidakam);
      expect(MalayalamMonth.tryParseName('July'), isNull);
    });

    test('Malayalam digits', () {
      expect(MalayalamDate.parse('൧ ചിങ്ങം ൧൨൦൧'), chingam1);
    });

    test('custom patterns with literals, weekday and era', () {
      expect(MalayalamDate.parse('Karkidakam 3, 1200', pattern: 'MMMM d, y'),
          karkidakam3);
      expect(MalayalamDate.parse('1201-01-01', pattern: 'y-MM-dd'), chingam1);
      expect(
          MalayalamDate.parse('ഞായർ, 1 ചിങ്ങം 1201 കൊല്ലവർഷം',
              pattern: 'EEEE, d MMMM y GGGG'),
          chingam1);
      expect(MalayalamDate.parse("1 Chingam ME 1201", pattern: "d MMMM 'ME' y"),
          chingam1);
    });

    test('round-trips format output', () {
      for (final pattern in ['d MMMM y', 'dd-MM-y', 'EEEE, d MMM y G']) {
        for (final script in MalayalamScript.values) {
          for (var i = 0; i < 400; i += 37) {
            final date = chingam1.addDays(i);
            final text = date.format(pattern, script: script);
            expect(MalayalamDate.parse(text, pattern: pattern), date,
                reason: '$pattern / $text');
          }
        }
      }
    });

    test('respects the calendar year convention', () {
      final north = KollavarshamCalendar(yearStart: YearStart.kanni);
      final d = MalayalamDate.parse('1 Chingam 1200', calendar: north);
      expect(d.toGregorian(), DateTime(2025, 8, 17));
    });

    test('errors', () {
      expect(() => MalayalamDate.parse('1 July 1201'), throwsFormatException);
      expect(
          () => MalayalamDate.parse('32 Chingam 1201'), throwsFormatException);
      expect(() => MalayalamDate.parse('1 Chingam'), throwsFormatException);
      expect(() => MalayalamDate.parse('13/1201', pattern: 'M/y'),
          throwsFormatException);
      expect(() => MalayalamDate.parse('1 Chingam 1201', pattern: 'd NNNN y'),
          throwsFormatException);
      expect(MalayalamDate.tryParse('nonsense'), isNull);
      expect(MalayalamDate.tryParse('1 Chingam 1201'), chingam1);
    });
  });
}
