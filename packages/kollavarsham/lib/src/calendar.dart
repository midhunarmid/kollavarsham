import 'astro/moon.dart';
import 'astro/sun.dart';
import 'astro/sunrise.dart';
import 'astro/time.dart';
import 'malayalam_date.dart';
import 'month_table.dart';
import 'names.dart';
import 'panchanga.dart';

/// Where (and in which time zone) the calendar is reckoned.
///
/// The day on which a Malayalam month begins depends on local sunrise and
/// sunset, so the result can differ by a day between distant places. Kerala
/// almanacs use a Kerala location and Indian Standard Time.
class ObserverLocation {
  const ObserverLocation({
    required this.latitude,
    required this.longitude,
    required this.utcOffset,
    this.name,
  });

  /// Thiruvananthapuram, Kerala, in Indian Standard Time — the default.
  static const thiruvananthapuram = ObserverLocation(
    latitude: 8.5241,
    longitude: 76.9366,
    utcOffset: Duration(hours: 5, minutes: 30),
    name: 'Thiruvananthapuram',
  );

  /// Kochi, Kerala, in Indian Standard Time.
  static const kochi = ObserverLocation(
    latitude: 9.9312,
    longitude: 76.2673,
    utcOffset: Duration(hours: 5, minutes: 30),
    name: 'Kochi',
  );

  /// Kozhikode, Kerala, in Indian Standard Time.
  static const kozhikode = ObserverLocation(
    latitude: 11.2588,
    longitude: 75.7804,
    utcOffset: Duration(hours: 5, minutes: 30),
    name: 'Kozhikode',
  );

  /// Latitude in degrees, north positive.
  final double latitude;

  /// Longitude in degrees, east positive.
  final double longitude;

  /// Offset of local civil time from UTC.
  final Duration utcOffset;

  /// Optional display name.
  final String? name;

  @override
  String toString() => name ?? '($latitude, $longitude, UTC$utcOffset)';
}

/// Computes Kollavarsham (Malayalam Era) dates for an [ObserverLocation].
///
/// Most code can use [KollavarshamCalendar.standard] (Thiruvananthapuram,
/// IST) through [MalayalamDate]. Results are cached per instance, so reuse
/// instances rather than creating one per conversion.
///
/// ## How months are reckoned
///
/// A month begins at the *sankranti* — the moment the Sun's sidereal
/// longitude (Lahiri ayanamsa) crosses a multiple of 30°. Following the
/// Kerala rule, if the sankranti falls within the first three-fifths of the
/// daytime (sunrise to sunset), that day is day 1 of the new month;
/// otherwise the month starts on the next day.
///
/// When the sankranti falls within a few minutes of that cut-off, almanacs
/// can disagree with each other and with this computation. Such months are
/// listed in [verifiedMonthStarts] with the date observed in Kerala, and
/// [monthStartMargin] reports how close any month came to the cut-off.
class KollavarshamCalendar {
  /// Creates a calendar for [location].
  ///
  /// [monthStartOverrides] maps a `(year, month)` to the Gregorian date of
  /// its first day, taking precedence over both the computation and
  /// [verifiedMonthStarts]. An override must keep months 29–32 days long.
  ///
  /// For the default location, month starts from 1899 to 2101 come from a
  /// table precomputed with this same engine, which makes conversions fast.
  /// Set [usePrecomputedTable] to false to always compute them.
  KollavarshamCalendar({
    this.location = ObserverLocation.thiruvananthapuram,
    Map<(int, MalayalamMonth), DateTime> monthStartOverrides = const {},
    bool usePrecomputedTable = true,
  })  : _overrides = {
          for (final e
              in {...verifiedMonthStarts, ...monthStartOverrides}.entries)
            _cacheKey(e.key.$1, e.key.$2): _dayNumberOf(e.value),
        },
        _table = usePrecomputedTable && _isDefaultLocation(location)
            ? MonthStartTable.instance
            : null;

  static bool _isDefaultLocation(ObserverLocation l) {
    const d = ObserverLocation.thiruvananthapuram;
    return l.latitude == d.latitude &&
        l.longitude == d.longitude &&
        l.utcOffset == d.utcOffset;
  }

  /// Month starts observed in Kerala almanacs that differ from the
  /// astronomical computation because the sankranti fell within minutes of
  /// the cut-off.
  ///
  /// Each entry cites its source in `test/fixtures/borderline_months.csv`.
  static final Map<(int, MalayalamMonth), DateTime> verifiedMonthStarts = {
    // Vrischika sankranti 2021-11-16 ~13:18 IST, cut-off ~13:17 IST.
    // Mandala Pooja (41st day) was held on 2021-12-26.
    (1197, MalayalamMonth.vrischikam): DateTime(2021, 11, 16),
    // Simha sankranti 2023-08-17 ~13:44 IST, cut-off ~13:41 IST.
    // Kerala New Year (Chingam 1) was observed on 2023-08-17.
    (1199, MalayalamMonth.chingam): DateTime(2023, 8, 17),
  };

  /// Earliest Kollavarsham year supported (825–826 CE).
  ///
  /// Dates are most accurate from 1900 to 2100, where they are checked
  /// against an independent ephemeris; further out they are computed with
  /// growing uncertainty in ΔT (Earth's rotation).
  static const int minYear = 1;

  /// Latest Kollavarsham year supported (2824–2825 CE). See [minYear].
  static const int maxYear = 2000;

  /// Shared calendar for Thiruvananthapuram in IST.
  static final KollavarshamCalendar standard = KollavarshamCalendar();

  /// The observer location used for sunrise/sunset.
  final ObserverLocation location;

  /// Fraction of daytime after sunrise by which the sankranti must occur
  /// for the month to begin that same day.
  static const double _keralaCutoff = 0.6;

  final Map<int, int> _overrides;
  final MonthStartTable? _table;
  final Map<int, double> _cutoffCache = {};
  final Map<int, int> _monthStartCache = {};

  /// Entries kept per cache before it is cleared, bounding memory use.
  static const int _maxCacheEntries = 4096;

  static V _cached<V>(Map<int, V> cache, int key, V Function() compute) {
    final hit = cache[key];
    if (hit != null) return hit;
    if (cache.length >= _maxCacheEntries) cache.clear();
    return cache[key] = compute();
  }

  double get _offsetDays => location.utcOffset.inSeconds / 86400.0;

  // ---------------------------------------------------------------------------
  // Civil day numbers: days since 1970-01-01 in local civil time.

  static int _dayNumberOf(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  static DateTime _dateOfDayNumber(int n) {
    final u = DateTime.fromMillisecondsSinceEpoch(
        n * Duration.millisecondsPerDay,
        isUtc: true);
    return DateTime(u.year, u.month, u.day);
  }

  double _jdLocalMidnight(int n) => unixEpochJd + n - _offsetDays;

  int _localDayOfJd(double jd) => (jd - unixEpochJd + _offsetDays).floor();

  double? _sunEventJd(int n, {required bool rising}) => sunEvent(
        _jdLocalMidnight(n),
        latitude: location.latitude,
        longitude: location.longitude,
        rising: rising,
      );

  /// The Kerala cut-off instant on day [n]: sunrise + 3/5 of daytime.
  double _cutoffJd(int n) => _cached(_cutoffCache, n, () {
        final rise = _sunEventJd(n, rising: true);
        final set = _sunEventJd(n, rising: false);
        if (rise == null || set == null) {
          // Polar day/night: fall back to local 13:12, the cut-off for a
          // 12-hour day starting at 06:00.
          return _jdLocalMidnight(n) + 13.2 / 24;
        }
        return rise + _keralaCutoff * (set - rise);
      });

  /// First civil day whose cut-off is at or after the sankranti [jd].
  int _monthStartForSankranti(double jd) {
    final day = _localDayOfJd(jd);
    return _cutoffJd(day) >= jd ? day : day + 1;
  }

  static int _cacheKey(int year, MalayalamMonth month) =>
      year * 12 + month.index;

  /// Gregorian year in which [month] of Kollavarsham [year] begins.
  static int _gregorianYearOfMonthStart(int year, MalayalamMonth month) =>
      month.index <= MalayalamMonth.dhanu.index ? year + 824 : year + 825;

  // ---------------------------------------------------------------------------
  // Public API.

  /// The sankranti instant (UTC) that begins [month] of Kollavarsham [year].
  DateTime sankranti(int year, MalayalamMonth month) =>
      dateTimeFromJulianDay(_sankrantiJd(year, month));

  double _sankrantiJd(int year, MalayalamMonth month) {
    final gy = _gregorianYearOfMonthStart(year, month);
    final gm = (month.index + 7) % 12 + 1;
    final guess = _jdLocalMidnight(_dayNumberOf(DateTime.utc(gy, gm, 15)));
    return findSunSiderealLongitude(month.signIndex * 30.0, guess);
  }

  int _monthStartDayNumber(int year, MalayalamMonth month) {
    // One year of slack lets neighbouring months be consulted at the edges.
    if (year < minYear - 1 || year > maxYear + 1) {
      throw RangeError.range(year, minYear, maxYear, 'year',
          'Kollavarsham year out of supported range');
    }
    final key = _cacheKey(year, month);
    return _overrides[key] ??
        _table?.startOf(year, month.index) ??
        _cached(_monthStartCache, key,
            () => _monthStartForSankranti(_sankrantiJd(year, month)));
  }

  /// How far the sankranti that begins [month] of [year] fell from the
  /// Kerala cut-off of its day: positive if before the cut-off (the month
  /// starts that day), negative if after (it starts the next day).
  ///
  /// A margin of only a few minutes means almanacs may disagree about the
  /// first day of the month.
  Duration monthStartMargin(int year, MalayalamMonth month) {
    final jd = _sankrantiJd(year, month);
    final cutoff = _cutoffJd(_localDayOfJd(jd));
    return Duration(microseconds: ((cutoff - jd) * 86400e6).round());
  }

  /// Gregorian date of day 1 of [month] in Kollavarsham [year].
  DateTime monthStart(int year, MalayalamMonth month) =>
      _dateOfDayNumber(_monthStartDayNumber(year, month));

  /// Number of days (29–32) in [month] of Kollavarsham [year].
  int monthLength(int year, MalayalamMonth month) {
    final nextYear = month == MalayalamMonth.karkidakam ? year + 1 : year;
    return _monthStartDayNumber(nextYear, month.next) -
        _monthStartDayNumber(year, month);
  }

  /// Number of days (365 or 366) in Kollavarsham [year].
  int yearLength(int year) =>
      _monthStartDayNumber(year + 1, MalayalamMonth.chingam) -
      _monthStartDayNumber(year, MalayalamMonth.chingam);

  /// Converts a Gregorian calendar date (its year, month and day; the time
  /// of day and time zone are ignored) to a [MalayalamDate].
  ///
  /// Throws a [RangeError] for dates outside [minYear]–[maxYear].
  MalayalamDate fromGregorian(DateTime date) {
    if (date.year < minYear + 824 || date.year > maxYear + 825) {
      throw RangeError.range(date.year, minYear + 824, maxYear + 825,
          'date.year', 'Gregorian year out of supported range');
    }
    final n = _dayNumberOf(date);
    var (year, month) = _approximateMonth(n, date);

    // Apply the start-day rule (and any overrides) exactly.
    var start = _monthStartDayNumber(year, month);
    if (n < start) {
      if (month == MalayalamMonth.chingam) year--;
      month = month.previous;
      start = _monthStartDayNumber(year, month);
    } else {
      final nextYear = month == MalayalamMonth.karkidakam ? year + 1 : year;
      final nextStart = _monthStartDayNumber(nextYear, month.next);
      if (n >= nextStart) {
        month = month.next;
        year = nextYear;
        start = nextStart;
      }
    }
    return MalayalamDate.internal(year, month, n - start + 1, n, this);
  }

  /// A month that contains day [n] or is adjacent to it; [fromGregorian]
  /// then settles the exact month with the start-day rule and overrides.
  (int, MalayalamMonth) _approximateMonth(int n, DateTime date) {
    final located = _table?.locate(n);
    if (located != null) {
      return (located.$1, MalayalamMonth.values[located.$2]);
    }
    // The month whose sign the Sun occupies at the day's cut-off.
    final sign = sunSiderealLongitude(_cutoffJd(n)) ~/ 30;
    final month = MalayalamMonth.fromSignIndex(sign);
    // Kollavarsham year of that month, from the Gregorian year of the date.
    var year = month.index <= MalayalamMonth.dhanu.index
        ? date.year - 824
        : date.year - 825;
    // Dhanu straddles the new Gregorian year: early-January days of Dhanu
    // belong to the month that began the previous December.
    if (month == MalayalamMonth.dhanu && date.month == 1) year--;
    // Makaram never begins before January, so a Makaram date in December
    // (possible only via an override) belongs to the coming year's month.
    if (month == MalayalamMonth.makaram && date.month == 12) year++;
    return (year, month);
  }

  /// Converts a Malayalam date to its Gregorian calendar date.
  ///
  /// Throws a [RangeError] if [day] is outside the month.
  DateTime toGregorian(int year, MalayalamMonth month, int day) =>
      _dateOfDayNumber(dayNumberOf(year, month, day));

  /// Civil day number (days since 1970-01-01) of a Malayalam date.
  ///
  /// Throws a [RangeError] if [day] is outside the month or [year] is
  /// outside [minYear]–[maxYear].
  int dayNumberOf(int year, MalayalamMonth month, int day) {
    RangeError.checkValueInInterval(year, minYear, maxYear, 'year');
    RangeError.checkValueInInterval(
        day, 1, monthLength(year, month), 'day', 'Day of ${month.english}');
    return _monthStartDayNumber(year, month) + day - 1;
  }

  /// The [MalayalamDate] for civil day number [n] (days since 1970-01-01).
  MalayalamDate fromDayNumber(int n) => fromGregorian(_dateOfDayNumber(n));

  /// Gregorian date for civil day number [n].
  DateTime dateOfDayNumber(int n) => _dateOfDayNumber(n);

  /// Civil day number of a Gregorian date.
  int dayNumberOfGregorian(DateTime date) => _dayNumberOf(date);

  /// Today's date at [location], according to the device clock.
  MalayalamDate today() {
    final local = DateTime.now().toUtc().add(location.utcOffset);
    return fromGregorian(local);
  }

  /// Sunrise (UTC) at [location] on a Gregorian [date], or `null` if the
  /// Sun does not rise.
  DateTime? sunrise(DateTime date) {
    final jd = _sunEventJd(_dayNumberOf(date), rising: true);
    return jd == null ? null : dateTimeFromJulianDay(jd);
  }

  /// Sunset (UTC) at [location] on a Gregorian [date], or `null` if the
  /// Sun does not set.
  DateTime? sunset(DateTime date) {
    final jd = _sunEventJd(_dayNumberOf(date), rising: false);
    return jd == null ? null : dateTimeFromJulianDay(jd);
  }

  // ---------------------------------------------------------------------------
  // Panchanga: nakshatra and tithi.

  /// Sunrise on day [n], or 06:00 local time if the Sun does not rise.
  double _sunriseJd(int n) =>
      _sunEventJd(n, rising: true) ?? _jdLocalMidnight(n) + 0.25;

  /// The nakshatra (Moon's sidereal mansion) at [instant].
  Nakshatra nakshatraAt(DateTime instant) => Nakshatra.fromSiderealLongitude(
      moonSiderealLongitude(julianDayFromDateTime(instant)));

  /// The nakshatra of a Gregorian [date]: the one prevailing at sunrise,
  /// as in Kerala almanacs.
  Nakshatra nakshatraOn(DateTime date) => Nakshatra.fromSiderealLongitude(
      moonSiderealLongitude(_sunriseJd(_dayNumberOf(date))));

  /// The tithi at [instant].
  Tithi tithiAt(DateTime instant) =>
      Tithi.fromElongation(lunarElongation(julianDayFromDateTime(instant)));

  /// The tithi of a Gregorian [date]: the one prevailing at sunrise.
  Tithi tithiOn(DateTime date) =>
      Tithi.fromElongation(lunarElongation(_sunriseJd(_dayNumberOf(date))));

  /// When the nakshatra prevailing at [instant] began and ends.
  PanchangaSpan<Nakshatra> nakshatraSpanAt(DateTime instant) {
    final jd = julianDayFromDateTime(instant);
    final lon = moonSiderealLongitude(jd);
    final i = (lon / Nakshatra.span).floor() % 27;
    final start = solveAngle(moonSiderealLongitude, i * Nakshatra.span,
        jd - (lon - i * Nakshatra.span) / 13.176,
        degreesPerDay: 13.176);
    final end = solveAngle(moonSiderealLongitude, (i + 1) * Nakshatra.span,
        jd + ((i + 1) * Nakshatra.span - lon) / 13.176,
        degreesPerDay: 13.176);
    return PanchangaSpan(Nakshatra.values[i], dateTimeFromJulianDay(start),
        dateTimeFromJulianDay(end));
  }

  /// When the tithi prevailing at [instant] began and ends.
  PanchangaSpan<Tithi> tithiSpanAt(DateTime instant) {
    final jd = julianDayFromDateTime(instant);
    final e = lunarElongation(jd);
    final i = (e / 12).floor() % 30;
    final start = solveAngle(
        lunarElongation, i * 12.0, jd - (e - i * 12) / 12.19,
        degreesPerDay: 12.19);
    final end = solveAngle(
        lunarElongation, (i + 1) * 12.0, jd + ((i + 1) * 12 - e) / 12.19,
        degreesPerDay: 12.19);
    return PanchangaSpan(
        Tithi(i + 1), dateTimeFromJulianDay(start), dateTimeFromJulianDay(end));
  }

  /// Days of [month] in Kollavarsham [year] whose nakshatra (at sunrise) is
  /// [nakshatra] — e.g. to find a Malayalam birthday (pirannal). Usually
  /// one day; occasionally none or two.
  List<MalayalamDate> daysWithNakshatra(
      int year, MalayalamMonth month, Nakshatra nakshatra) {
    final start = _monthStartDayNumber(year, month);
    final length = monthLength(year, month);
    return [
      for (var d = 0; d < length; d++)
        if (Nakshatra.fromSiderealLongitude(
                moonSiderealLongitude(_sunriseJd(start + d))) ==
            nakshatra)
          MalayalamDate.internal(year, month, d + 1, start + d, this),
    ];
  }
}
