import 'calendar.dart';
import 'malayalam_date.dart';
import 'names.dart';
import 'panchanga.dart';

/// Kerala festivals and seasons known to [KeralaFestivals].
enum KeralaFestival {
  /// The first day of the Kollavarsham year (Chingam 1, or Kanni 1 with
  /// [YearStart.kanni]).
  newYear('പുതുവർഷം', 'Malayalam New Year'),

  /// Ashtami Rohini (Sree Krishna Jayanthi), in Chingam.
  ashtamiRohini('അഷ്ടമി രോഹിണി', 'Ashtami Rohini'),

  /// Vinayaka Chathurthi: the fourth day of the lunar month that holds
  /// Kanni's sankranti.
  vinayakaChathurthi('വിനായക ചതുർത്ഥി', 'Vinayaka Chathurthi'),

  /// Atham, the first of the ten days of Onam.
  atham('അത്തം', 'Atham'),

  /// Thiruvonam, the main day of Onam.
  onam('തിരുവോണം', 'Thiruvonam'),

  /// Durgashtami, the eighth day of Navaratri.
  durgashtami('ദുർഗാഷ്ടമി', 'Durgashtami'),

  /// Mahanavami, the ninth day of Navaratri.
  mahanavami('മഹാനവമി', 'Mahanavami'),

  /// Vijayadasami, the tenth day of Navaratri.
  vijayadasami('വിജയദശമി', 'Vijayadasami'),

  /// Deepavali, on Naraka Chaturdashi.
  deepavali('ദീപാവലി', 'Deepavali'),

  /// Vrischikam 1, the start of the 41-day Mandala season.
  mandalaKalamStart('മണ്ഡലകാലാരംഭം', 'Mandala Kalam begins'),

  /// Guruvayur Ekadashi: the waxing Ekadashi of Vrischikam.
  guruvayurEkadashi('ഗുരുവായൂർ ഏകാദശി', 'Guruvayur Ekadashi'),

  /// The 41st day of the Mandala season.
  mandalaPooja('മണ്ഡലപൂജ', 'Mandala Pooja'),

  /// Makaram 1.
  makaravilakku('മകരവിളക്ക്', 'Makaravilakku'),

  /// Thaipooyam: Pooyam nakshatra at the full moon of Makaram.
  thaipooyam('തൈപ്പൂയം', 'Thaipooyam'),

  /// Sivaratri: the night of the waning Chathurdashi of the lunar month that
  /// holds Kumbham's sankranti.
  sivaratri('ശിവരാത്രി', 'Sivaratri'),

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
/// they are observed; each rule is checked against at least five years of
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
      (KeralaFestival.ashtamiRohini, ashtamiRohini(year)),
      (KeralaFestival.vinayakaChathurthi, vinayakaChathurthi(year)),
      (KeralaFestival.durgashtami, durgashtami(year)),
      (KeralaFestival.mahanavami, mahanavami(year)),
      (KeralaFestival.vijayadasami, vijayadasami(year)),
      (KeralaFestival.deepavali, deepavali(year)),
      (KeralaFestival.guruvayurEkadashi, guruvayurEkadashi(year)),
      (KeralaFestival.thaipooyam, thaipooyam(year)),
      (KeralaFestival.sivaratri, sivaratri(year)),
    ]..sort((a, b) => a.$2.compareTo(b.$2)));
  }

  /// The festivals falling on [date].
  ///
  /// A festival can fall just before the year it is listed under, as Atham
  /// can, so the next year is searched too.
  List<KeralaFestival> festivalsOn(MalayalamDate date) => [
        for (final year in [date.year, date.year + 1])
          for (final (festival, day) in festivalsIn(year))
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
  /// later occurrence (e.g. 1189 → 2013-09-16, 1200 → 2024-09-15). If the
  /// star falls between two sunrises, the day with it at sunset is used.
  MalayalamDate onam(int year) {
    final days =
        daysWithNakshatra(year, MalayalamMonth.chingam, Nakshatra.thiruvonam);
    if (days.isNotEmpty) return days.last;
    return _lastOccurrence(
      year,
      MalayalamMonth.chingam,
      (d) => nakshatraAt(_sunset(d)) == Nakshatra.thiruvonam,
    );
  }

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
  /// occurrence (near the full moon) is used. If it falls between two
  /// sunsets, the day with the star at sunrise is used.
  ///
  /// Kumbham of year 1200 falls in February–March 2025.
  MalayalamDate attukalPongala(int year) => _lastOccurrence(
        year,
        MalayalamMonth.kumbham,
        (d) => nakshatraAt(_sunset(d)) == Nakshatra.pooram,
        orElse: (d) => nakshatraAt(_sunrise(d)) == Nakshatra.pooram,
      );

  /// Thrissur Pooram of Kollavarsham [year]: the day in Medam whose night
  /// (at midnight) falls in the Pooram nakshatra; the later occurrence if
  /// the star recurs within Medam. If it falls between two midnights, the
  /// day with the star at sunrise is used.
  ///
  /// Medam of year 1200 falls in April–May 2025.
  MalayalamDate thrissurPooram(int year) => _lastOccurrence(
        year,
        MalayalamMonth.medam,
        (d) => nakshatraAt(_endOfDay(d)) == Nakshatra.pooram,
        orElse: (d) => nakshatraAt(_sunrise(d)) == Nakshatra.pooram,
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

  /// Sivaratri of Kollavarsham [year]: the first night (at midnight) of the
  /// waning Chathurdashi in the lunar month that holds Kumbham's sankranti.
  ///
  /// It usually falls in Kumbham, but in Makaram if the new moon comes just
  /// after the sankranti (2029-02-11).
  MalayalamDate sivaratri(int year) =>
      _lunarDay(year, MalayalamMonth.kumbham, 29, _endOfDay);

  /// Ashtami Rohini of Kollavarsham [year]: the night (at midnight) of the
  /// waning Ashtami in Chingam. If several nights qualify, the first with
  /// the Rohini nakshatra at midnight is used, otherwise the first; if no
  /// night does, the first night with Rohini.
  ///
  /// Kerala's holiday list gives 2021-08-30 here, although the Ashtami began
  /// late on the 29th, and 2022-08-18, when Rohini was two days away.
  MalayalamDate ashtamiRohini(int year) {
    final start =
        MalayalamDate(year, MalayalamMonth.chingam, 1, calendar: this);
    final days = [for (var i = 0; i < start.monthLength; i++) start.addDays(i)];
    bool rohini(MalayalamDate d) =>
        nakshatraAt(_endOfDay(d)) == Nakshatra.rohini;
    final ashtami = [
      for (final d in days)
        if (tithiAt(_endOfDay(d)).number == 23) d,
    ];
    if (ashtami.isEmpty) return days.firstWhere(rohini);
    return ashtami.firstWhere(rohini, orElse: () => ashtami.first);
  }

  /// Vinayaka Chathurthi of Kollavarsham [year]: the waxing Chathurthi at
  /// the middle of the day, in the lunar month that holds Kanni's sankranti.
  MalayalamDate vinayakaChathurthi(int year) =>
      _lunarDay(year, MalayalamMonth.kanni, 4, (d) => _dayFraction(d, 0.5));

  /// Vijayadasami of Kollavarsham [year]: the waxing Dashami at sunrise, in
  /// the lunar month that holds Thulam's sankranti.
  MalayalamDate vijayadasami(int year) =>
      _lunarDay(year, MalayalamMonth.thulam, 10, _sunrise);

  /// Mahanavami of Kollavarsham [year]: the day before [vijayadasami].
  MalayalamDate mahanavami(int year) => vijayadasami(year).addDays(-1);

  /// Durgashtami of Kollavarsham [year]: two days before [vijayadasami].
  MalayalamDate durgashtami(int year) => vijayadasami(year).addDays(-2);

  /// Deepavali of Kollavarsham [year]: Naraka Chaturdashi, the waning
  /// Chathurdashi at dawn (arunodaya, 96 minutes before sunrise), in the
  /// lunar month that holds Thulam's sankranti.
  MalayalamDate deepavali(int year) => _lunarDay(
        year,
        MalayalamMonth.thulam,
        29,
        (d) => _sunrise(d).subtract(const Duration(minutes: 96)),
      );

  /// Guruvayur Ekadashi of Kollavarsham [year]: the first waxing Ekadashi at
  /// sunrise from Vrischikam 1. An Ekadashi that falls wholly between two
  /// sunrises counts on the earlier day.
  MalayalamDate guruvayurEkadashi(int year) {
    var d = mandalaKalamStart(year);
    while (true) {
      final tithi = d.tithi.number;
      final next = d.addDays(1);
      if (tithi == 11 || (tithi == 10 && next.tithi.number == 12)) return d;
      d = next;
    }
  }

  /// Thaipooyam of Kollavarsham [year]: the day nearest the first full moon
  /// after Makaram's sankranti with the Pooyam nakshatra at sunrise or
  /// sunset; the earlier day if two are equally near.
  MalayalamDate thaipooyam(int year) {
    var span = tithiSpanAt(sankranti(year, MalayalamMonth.makaram));
    while (!span.value.isPournami) {
      span = tithiSpanAt(span.end.add(const Duration(seconds: 1)));
    }
    final fullMoon = _dayOf(span.end);
    bool pooyam(MalayalamDate d) =>
        nakshatraAt(_sunrise(d)) == Nakshatra.pooyam ||
        nakshatraAt(_sunset(d)) == Nakshatra.pooyam;
    return [0, -1, 1, -2, 2].map(fullMoon.addDays).firstWhere(pooyam);
  }

  DateTime _sunrise(MalayalamDate d) => sunrise(d.toGregorian())!;

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

  /// The Malayalam date at [location] of [instant].
  MalayalamDate _dayOf(DateTime instant) {
    final local = instant.toUtc().add(location.utcOffset);
    return fromGregorian(DateTime(local.year, local.month, local.day));
  }

  /// The first day, in the lunar month (new moon to new moon) that holds
  /// [month]'s sankranti in [year], whose tithi at the instant given by [at]
  /// has reached [tithi]. Reaching rather than equalling it means a tithi
  /// that falls wholly between two readings counts on the later day.
  MalayalamDate _lunarDay(
    int year,
    MalayalamMonth month,
    int tithi,
    DateTime Function(MalayalamDate) at,
  ) {
    var span = tithiSpanAt(sankranti(year, month));
    while (span.value.number != 1) {
      span = tithiSpanAt(span.start.subtract(const Duration(seconds: 1)));
    }
    var d = _dayOf(span.start).addDays(1);
    while (tithiAt(at(d)).number < tithi) {
      d = d.addDays(1);
    }
    return d;
  }

  /// The first day of the last run of consecutive days in [month] of
  /// [year] that satisfy [test], or else [orElse].
  MalayalamDate _lastOccurrence(
    int year,
    MalayalamMonth month,
    bool Function(MalayalamDate) test, {
    bool Function(MalayalamDate)? orElse,
  }) {
    final start = MalayalamDate(year, month, 1, calendar: this);
    MalayalamDate? found;
    var previousMatched = false;
    for (var i = 0; i < start.monthLength; i++) {
      final d = start.addDays(i);
      final matched = test(d);
      if (matched && !previousMatched) found = d;
      previousMatched = matched;
    }
    if (found != null) return found;
    if (orElse != null) return _lastOccurrence(year, month, orElse);
    throw StateError('No matching day in ${month.english} $year');
  }
}
