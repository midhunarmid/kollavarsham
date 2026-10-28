import 'calendar.dart';
import 'malayalam_date.dart';
import 'names.dart';
import 'panchanga.dart';

/// Kerala festivals and seasons known to [KeralaFestivals].
enum KeralaFestival {
  /// The first day of the Kollavarsham year (Chingam 1, or Kanni 1 with
  /// [YearStart.kanni]).
  newYear('പുതുവർഷം', 'Malayalam New Year'),

  /// Atham, the first of the ten days of Onam.
  atham('അത്തം', 'Atham'),

  /// Thiruvonam, the main day of Onam.
  onam('തിരുവോണം', 'Thiruvonam'),

  /// Vrischikam 1, the start of the 41-day Mandala season.
  mandalaKalamStart('മണ്ഡലകാലാരംഭം', 'Mandala Kalam begins'),

  /// The 41st day of the Mandala season.
  mandalaPooja('മണ്ഡലപൂജ', 'Mandala Pooja'),

  /// Makaram 1.
  makaravilakku('മകരവിളക്ക്', 'Makaravilakku'),

  /// Attukal Pongala: Pooram nakshatra in Kumbham.
  attukalPongala('ആറ്റുകാൽ പൊങ്കാല', 'Attukal Pongala'),

  /// Vishu: Medam 1.
  vishu('വിഷു', 'Vishu'),

  /// Thrissur Pooram: Pooram nakshatra in Medam.
  thrissurPooram('തൃശ്ശൂർ പൂരം', 'Thrissur Pooram'),

  /// Karkidakam 1, the start of the Ramayana month.
  karkidakamStart('രാമായണ മാസാരംഭം', 'Ramayana Masam begins'),

  /// Karkidaka Vavu: the new moon of Karkidakam, for ancestral rites.
  karkidakaVavu('കർക്കടക വാവ്', 'Karkidaka Vavu');

  const KeralaFestival(this.malayalam, this.english);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in English.
  final String english;

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}

final _festivalCache = Expando<Map<int, List<(KeralaFestival, MalayalamDate)>>>(
    'kollavarsham festivals');

/// Dates of major Kerala festivals and seasons, by Kollavarsham year.
///
/// Festivals tied to a nakshatra or tithi follow the time of day at which
/// they are observed; each rule is checked against at least eight years of
/// published dates.
extension KeralaFestivals on KollavarshamCalendar {
  /// Every festival in Kollavarsham [year], in date order.
  ///
  /// Results are cached per calendar and year, so this is cheap to call
  /// repeatedly (e.g. for calendar markers).
  List<(KeralaFestival, MalayalamDate)> festivalsIn(int year) {
    final cache = _festivalCache[this] ??= {};
    return cache[year] ??= List.unmodifiable([
      (
        KeralaFestival.newYear,
        MalayalamDate(year, firstMonth, 1, calendar: this)
      ),
      (KeralaFestival.atham, atham(year)),
      (KeralaFestival.onam, onam(year)),
      (KeralaFestival.mandalaKalamStart, mandalaKalamStart(year)),
      (KeralaFestival.mandalaPooja, mandalaPooja(year)),
      (KeralaFestival.makaravilakku, makaravilakku(year)),
      (KeralaFestival.attukalPongala, attukalPongala(year)),
      (KeralaFestival.vishu, vishu(year)),
      (KeralaFestival.thrissurPooram, thrissurPooram(year)),
      (KeralaFestival.karkidakamStart, karkidakamStart(year)),
      (KeralaFestival.karkidakaVavu, karkidakaVavu(year)),
    ]..sort((a, b) => a.$2.compareTo(b.$2)));
  }

  /// The festivals falling on [date].
  List<KeralaFestival> festivalsOn(MalayalamDate date) => [
        for (final (festival, day) in festivalsIn(date.year))
          if (day.isAtSameDayAs(date)) festival,
      ];

  /// Vishu: Medam 1, the astronomical new year, of Kollavarsham [year].
  ///
  /// Medam of year 1200 falls in April 2025.
  MalayalamDate vishu(int year) =>
      MalayalamDate(year, MalayalamMonth.medam, 1, calendar: this);

  /// Thiruvonam (Onam) of Kollavarsham [year]: the day in Chingam with the
  /// Thiruvonam nakshatra at sunrise.
  ///
  /// Chingam is long enough (31 days) for the star to occur twice, once in
  /// its first days and again at its end; Onam is then celebrated on the
  /// later occurrence (e.g. 1189 → 2013-09-16, 1200 → 2024-09-15).
  MalayalamDate onam(int year) =>
      daysWithNakshatra(year, MalayalamMonth.chingam, Nakshatra.thiruvonam)
          .last;

  /// Atham, the first of the ten days of Onam, nine days before
  /// Thiruvonam. It may fall in Karkidakam.
  MalayalamDate atham(int year) => onam(year).addDays(-9);

  /// Start of the 41-day Mandala season: Vrischikam 1 of [year].
  MalayalamDate mandalaKalamStart(int year) =>
      MalayalamDate(year, MalayalamMonth.vrischikam, 1, calendar: this);

  /// Mandala Pooja, the 41st day of the Mandala season of [year].
  MalayalamDate mandalaPooja(int year) => mandalaKalamStart(year).addDays(40);

  /// Makaravilakku: Makaram 1 of Kollavarsham [year].
  ///
  /// Makaram of year 1200 falls in January 2025.
  MalayalamDate makaravilakku(int year) =>
      MalayalamDate(year, MalayalamMonth.makaram, 1, calendar: this);

  /// Start of the Karkidakam month (Ramayana month) of [year].
  MalayalamDate karkidakamStart(int year) =>
      MalayalamDate(year, MalayalamMonth.karkidakam, 1, calendar: this);

  /// Attukal Pongala of Kollavarsham [year]: the day in Kumbham on whose
  /// evening (at sunset) the Pooram nakshatra prevails, the offering being
  /// made in the afternoon. If the star recurs within Kumbham, the later
  /// occurrence (near the full moon) is used.
  ///
  /// Kumbham of year 1200 falls in February–March 2025.
  MalayalamDate attukalPongala(int year) => _lastOccurrence(
        year,
        MalayalamMonth.kumbham,
        (d) => nakshatraAt(_sunset(d)) == Nakshatra.pooram,
      );

  /// Thrissur Pooram of Kollavarsham [year]: the day in Medam whose night
  /// (at midnight) falls in the Pooram nakshatra; the later occurrence if
  /// the star recurs within Medam.
  ///
  /// Medam of year 1200 falls in April–May 2025.
  MalayalamDate thrissurPooram(int year) => _lastOccurrence(
        year,
        MalayalamMonth.medam,
        (d) => nakshatraAt(_endOfDay(d)) == Nakshatra.pooram,
      );

  /// Karkidaka Vavu of Kollavarsham [year]: the new moon (amavasya) of
  /// Karkidakam, observed on the day the amavasya prevails at the end of
  /// the afternoon (aparahna, four-fifths of the daytime); if no day
  /// qualifies, on the day it prevails at sunrise. If Karkidakam has two
  /// new moons, the first is used.
  MalayalamDate karkidakaVavu(int year) {
    final start = karkidakamStart(year);
    final days = [for (var i = 0; i < start.monthLength; i++) start.addDays(i)];
    return days.firstWhere(
      (d) => tithiAt(_dayFraction(d, 0.8)).isAmavasya,
      orElse: () => days.firstWhere((d) => d.tithi.isAmavasya),
    );
  }

  DateTime _sunset(MalayalamDate d) => sunset(d.toGregorian())!;

  DateTime _dayFraction(MalayalamDate d, double fraction) {
    final rise = sunrise(d.toGregorian())!;
    return rise.add(_sunset(d).difference(rise) * fraction);
  }

  /// The last instant of [d]'s civil day at [location].
  DateTime _endOfDay(MalayalamDate d) {
    final g = d.toGregorian();
    return DateTime.utc(g.year, g.month, g.day + 1)
        .subtract(location.utcOffset)
        .subtract(const Duration(seconds: 1));
  }

  /// The first day of the last run of consecutive days in [month] of
  /// [year] that satisfy [test].
  MalayalamDate _lastOccurrence(
    int year,
    MalayalamMonth month,
    bool Function(MalayalamDate) test,
  ) {
    final start = MalayalamDate(year, month, 1, calendar: this);
    MalayalamDate? found;
    var previousMatched = false;
    for (var i = 0; i < start.monthLength; i++) {
      final d = start.addDays(i);
      final matched = test(d);
      if (matched && !previousMatched) found = d;
      previousMatched = matched;
    }
    if (found == null) {
      throw StateError('No matching day in ${month.english} $year');
    }
    return found;
  }
}
