/// Time-scale helpers: Julian Day numbers and ΔT (TT − UT).
library;

/// Julian Day of the Unix epoch (1970-01-01T00:00:00Z).
const double unixEpochJd = 2440587.5;

/// Julian Day of the J2000.0 epoch.
const double j2000 = 2451545.0;

/// Converts a UTC instant to a Julian Day (UT).
double julianDayFromDateTime(DateTime instant) =>
    unixEpochJd + instant.toUtc().microsecondsSinceEpoch / 86400e6;

/// Converts a Julian Day (UT) to a UTC [DateTime].
DateTime dateTimeFromJulianDay(double jd) =>
    DateTime.fromMicrosecondsSinceEpoch(
      ((jd - unixEpochJd) * 86400e6).round(),
      isUtc: true,
    );

/// Julian centuries of TT since J2000.0 for a Julian Day in UT.
double julianCenturiesTT(double jdUT) =>
    (jdUT + deltaTSeconds(jdUT) / 86400.0 - j2000) / 36525.0;

/// Approximate ΔT = TT − UT in seconds, using the Espenak–Meeus polynomials.
///
/// Accurate to a few seconds for 1900–2050, which is far below the precision
/// that matters for calendar work (the Sun moves ~1° per day).
double deltaTSeconds(double jdUT) {
  final y = 2000.0 + (jdUT - j2000) / 365.25;
  double t;
  if (y < 1900) {
    final u = (y - 1820) / 100;
    return -20 + 32 * u * u;
  } else if (y < 1920) {
    t = y - 1900;
    return -2.79 +
        1.494119 * t -
        0.0598939 * t * t +
        0.0061966 * t * t * t -
        0.000197 * t * t * t * t;
  } else if (y < 1941) {
    t = y - 1920;
    return 21.20 + 0.84493 * t - 0.076100 * t * t + 0.0020936 * t * t * t;
  } else if (y < 1961) {
    t = y - 1950;
    return 29.07 + 0.407 * t - t * t / 233 + t * t * t / 2547;
  } else if (y < 1986) {
    t = y - 1975;
    return 45.45 + 1.067 * t - t * t / 260 - t * t * t / 718;
  } else if (y < 2005) {
    t = y - 2000;
    return 63.86 +
        0.3345 * t -
        0.060374 * t * t +
        0.0017275 * t * t * t +
        0.000651814 * t * t * t * t +
        0.00002373599 * t * t * t * t * t;
  } else if (y < 2050) {
    t = y - 2000;
    return 62.92 + 0.32217 * t + 0.005589 * t * t;
  } else if (y < 2150) {
    final u = (y - 1820) / 100;
    return -20 + 32 * u * u - 0.5628 * (2150 - y);
  }
  final u = (y - 1820) / 100;
  return -20 + 32 * u * u;
}
