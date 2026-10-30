/// Lunar longitude from the ELP-2000/82 abridgement in Meeus,
/// *Astronomical Algorithms*, ch. 47 (accurate to ~10″).
library;

import 'math.dart';
import 'sun.dart';
import 'time.dart';

// Periodic terms for longitude: [D, M, M′, F, Σl coefficient (1e-6 deg)].
const List<List<int>> _terms = [
  [0, 0, 1, 0, 6288774],
  [2, 0, -1, 0, 1274027],
  [2, 0, 0, 0, 658314],
  [0, 0, 2, 0, 213618],
  [0, 1, 0, 0, -185116],
  [0, 0, 0, 2, -114332],
  [2, 0, -2, 0, 58793],
  [2, -1, -1, 0, 57066],
  [2, 0, 1, 0, 53322],
  [2, -1, 0, 0, 45758],
  [0, 1, -1, 0, -40923],
  [1, 0, 0, 0, -34720],
  [0, 1, 1, 0, -30383],
  [2, 0, 0, -2, 15327],
  [0, 0, 1, 2, -12528],
  [0, 0, 1, -2, 10980],
  [4, 0, -1, 0, 10675],
  [0, 0, 3, 0, 10034],
  [4, 0, -2, 0, 8548],
  [2, 1, -1, 0, -7888],
  [2, 1, 0, 0, -6766],
  [1, 0, -1, 0, -5163],
  [1, 1, 0, 0, 4987],
  [2, -1, 1, 0, 4036],
  [2, 0, 2, 0, 3994],
  [4, 0, 0, 0, 3861],
  [2, 0, -3, 0, 3665],
  [0, 1, -2, 0, -2689],
  [2, 0, -1, 2, -2602],
  [2, -1, -2, 0, 2390],
  [1, 0, 1, 0, -2348],
  [2, -2, 0, 0, 2236],
  [0, 1, 2, 0, -2120],
  [0, 2, 0, 0, -2069],
  [2, -2, -1, 0, 2048],
  [2, 0, 1, -2, -1773],
  [2, 0, 0, 2, -1595],
  [4, -1, -1, 0, 1215],
  [0, 0, 2, 2, -1110],
  [3, 0, -1, 0, -892],
  [2, 1, 1, 0, -810],
  [4, -1, -2, 0, 759],
  [0, 2, -1, 0, -713],
  [2, 2, -1, 0, -700],
  [2, 1, -2, 0, 691],
  [2, -1, 0, -2, 596],
  [4, 0, 1, 0, 549],
  [0, 0, 4, 0, 537],
  [4, -1, 0, 0, 520],
  [1, 0, -2, 0, -487],
  [2, 1, 0, -2, -399],
  [0, 0, 2, -2, -381],
  [1, 1, 1, 0, 351],
  [3, 0, -2, 0, -340],
  [4, 0, -3, 0, 330],
  [2, -1, 2, 0, 327],
  [0, 2, 1, 0, -323],
  [1, 1, -1, 0, 299],
  [2, 0, 3, 0, 294],
];

// Periodic terms for latitude: [D, M, M′, F, Σb coefficient (1e-6 deg)]. Only
// the largest of Meeus's 60; enough for moonrise, not for occultations.
const List<List<int>> _latitudeTerms = [
  [0, 0, 0, 1, 5128122],
  [0, 0, 1, 1, 280602],
  [0, 0, 1, -1, 277693],
  [2, 0, 0, -1, 173237],
  [2, 0, -1, 1, 55413],
  [2, 0, -1, -1, 46271],
  [2, 0, 0, 1, 32573],
  [0, 0, 2, 1, 17198],
  [2, 0, 1, -1, 9266],
  [0, 0, 2, -1, 8822],
  [2, -1, 0, -1, 8216],
  [2, 0, -2, -1, 4324],
  [2, 0, 1, 1, 4200],
  [2, 1, 0, -1, -3359],
  [2, -1, -1, 1, 2463],
  [2, -1, 0, 1, 2211],
  [2, -1, -1, -1, 2065],
  [0, 1, -1, -1, -1870],
  [4, 0, -1, -1, 1828],
  [0, 1, 0, 1, -1794],
  [0, 0, 0, 3, -1749],
  [0, 1, -1, 1, -1565],
  [1, 0, 0, 1, -1491],
  [0, 1, 1, 1, -1475],
  [0, 1, 1, -1, -1410],
  [0, 1, 0, -1, -1344],
  [1, 0, 0, -1, -1335],
];

// Periodic terms for distance: [D, M, M′, F, Σr coefficient (1e-3 km)], again
// the largest of Meeus's 60.
const List<List<int>> _distanceTerms = [
  [0, 0, 1, 0, -20905355],
  [2, 0, -1, 0, -3699111],
  [2, 0, 0, 0, -2955968],
  [0, 0, 2, 0, -569925],
  [0, 1, 0, 0, 48888],
  [2, 0, -2, 0, 246158],
  [2, -1, -1, 0, -152138],
  [2, 0, 1, 0, -170733],
  [2, -1, 0, 0, -204586],
  [0, 1, -1, 0, -129620],
  [1, 0, 0, 0, 108743],
  [0, 1, 1, 0, 104755],
  [2, 0, 0, -2, 10321],
  [0, 0, 1, -2, 79661],
  [4, 0, -1, 0, -34782],
  [0, 0, 3, 0, -23210],
  [4, 0, -2, 0, -21636],
  [2, 1, -1, 0, 24208],
  [2, 1, 0, 0, 30824],
  [1, 0, -1, 0, -8379],
  [1, 1, 0, 0, -16675],
  [2, -1, 1, 0, -12831],
  [2, 0, 2, 0, -10445],
  [4, 0, 0, 0, -11650],
  [2, 0, -3, 0, 14403],
  [0, 1, -2, 0, -7003],
  [2, -1, -2, 0, 10056],
  [1, 0, 1, 0, 6322],
  [2, -2, 0, 0, -9884],
  [0, 1, 2, 0, 5751],
];

/// The Moon's fundamental arguments (degrees) at [t], and the eccentricity
/// factor `e` of the Earth's orbit.
({double lp, double d, double m, double mp, double f, double e}) _arguments(
    double t) {
  final t2 = t * t, t3 = t2 * t, t4 = t3 * t;
  return (
    lp: 218.3164477 +
        481267.88123421 * t -
        0.0015786 * t2 +
        t3 / 538841 -
        t4 / 65194000,
    d: 297.8501921 +
        445267.1114034 * t -
        0.0018819 * t2 +
        t3 / 545868 -
        t4 / 113065000,
    m: 357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000,
    mp: 134.9633964 +
        477198.8675055 * t +
        0.0087414 * t2 +
        t3 / 69699 -
        t4 / 14712000,
    f: 93.2720950 +
        483202.0175233 * t -
        0.0036539 * t2 -
        t3 / 3526000 +
        t4 / 863310000,
    e: 1 - 0.002516 * t - 0.0000074 * t2,
  );
}

/// Sums [terms], applying the trigonometric function [trig] to each angle.
double _series(
  List<List<int>> terms,
  ({double lp, double d, double m, double mp, double f, double e}) a,
  double Function(double) trig,
) {
  var sum = 0.0;
  for (final term in terms) {
    var coeff = term[4].toDouble();
    final mCount = term[1].abs();
    if (mCount == 1) {
      coeff *= a.e;
    } else if (mCount == 2) {
      coeff *= a.e * a.e;
    }
    sum += coeff *
        trig(term[0] * a.d + term[1] * a.m + term[2] * a.mp + term[3] * a.f);
  }
  return sum;
}

/// Geocentric ecliptic longitude of the Moon (degrees, mean equinox of
/// date, without nutation) at Julian centuries [t] of TT since J2000.0.
double moonGeometricLongitude(double t) {
  final a = _arguments(t);
  final a1 = 119.75 + 131.849 * t;
  final a2 = 53.09 + 479264.290 * t;
  final sum = _series(_terms, a, sinD) +
      3958 * sinD(a1) +
      1962 * sinD(a.lp - a.f) +
      318 * sinD(a2);
  return norm360(a.lp + sum / 1e6);
}

/// Geocentric ecliptic latitude of the Moon (degrees) at Julian centuries
/// [t] of TT since J2000.0.
double moonLatitude(double t) {
  final a = _arguments(t);
  final a1 = 119.75 + 131.849 * t;
  final a3 = 313.45 + 481266.484 * t;
  final sum = _series(_latitudeTerms, a, sinD) -
      2235 * sinD(a.lp) +
      382 * sinD(a3) +
      175 * sinD(a1 - a.f) +
      175 * sinD(a1 + a.f) +
      127 * sinD(a.lp - a.mp) -
      115 * sinD(a.lp + a.mp);
  return sum / 1e6;
}

/// Distance between the centres of the Earth and Moon (km) at Julian
/// centuries [t] of TT since J2000.0.
double moonDistance(double t) =>
    385000.56 + _series(_distanceTerms, _arguments(t), cosD) / 1000;

/// Apparent tropical longitude of the Moon (degrees) for a Julian Day (UT).
double moonApparentLongitude(double jdUT) {
  final t = julianCenturiesTT(jdUT);
  return norm360(moonGeometricLongitude(t) + nutationInLongitude(t));
}

/// Sidereal (nirayana, Lahiri) longitude of the Moon for a Julian Day (UT).
double moonSiderealLongitude(double jdUT) {
  final t = julianCenturiesTT(jdUT);
  return norm360(
      moonGeometricLongitude(t) + nutationInLongitude(t) - lahiriAyanamsa(t));
}

/// Elongation of the Moon from the Sun, 0–360°, for a Julian Day (UT).
/// Each 12° is one tithi.
double lunarElongation(double jdUT) =>
    norm360(moonApparentLongitude(jdUT) - sunApparentLongitude(jdUT));

/// Sum of the Sun's and Moon's sidereal longitudes, 0–360°, for a Julian Day
/// (UT). Each 13°20′ is one yoga.
double yogaLongitude(double jdUT) =>
    norm360(moonSiderealLongitude(jdUT) + sunSiderealLongitude(jdUT));

/// Finds the instant (JD, UT) near [guessJd] at which [f] (an angle in
/// degrees that increases roughly linearly) equals [target].
double solveAngle(
  double Function(double jd) f,
  double target,
  double guessJd, {
  required double degreesPerDay,
}) {
  var jd = guessJd;
  for (var i = 0; i < 40; i++) {
    final diff = norm180(f(jd) - target);
    if (diff.abs() < 1e-6) break;
    // Refine the rate with a numerical derivative for faster convergence.
    final rate = norm180(f(jd + 0.01) - f(jd)) / 0.01;
    jd -= diff / (rate.abs() > 1e-3 ? rate : degreesPerDay);
  }
  return jd;
}
