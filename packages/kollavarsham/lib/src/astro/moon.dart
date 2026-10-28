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

/// Geocentric ecliptic longitude of the Moon (degrees, mean equinox of
/// date, without nutation) at Julian centuries [t] of TT since J2000.0.
double moonGeometricLongitude(double t) {
  final t2 = t * t, t3 = t2 * t, t4 = t3 * t;
  final lp = 218.3164477 +
      481267.88123421 * t -
      0.0015786 * t2 +
      t3 / 538841 -
      t4 / 65194000;
  final d = 297.8501921 +
      445267.1114034 * t -
      0.0018819 * t2 +
      t3 / 545868 -
      t4 / 113065000;
  final m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000;
  final mp = 134.9633964 +
      477198.8675055 * t +
      0.0087414 * t2 +
      t3 / 69699 -
      t4 / 14712000;
  final f = 93.2720950 +
      483202.0175233 * t -
      0.0036539 * t2 -
      t3 / 3526000 +
      t4 / 863310000;
  final a1 = 119.75 + 131.849 * t;
  final a2 = 53.09 + 479264.290 * t;
  final e = 1 - 0.002516 * t - 0.0000074 * t2;

  var sum = 0.0;
  for (final term in _terms) {
    var coeff = term[4].toDouble();
    final mCount = term[1].abs();
    if (mCount == 1) {
      coeff *= e;
    } else if (mCount == 2) {
      coeff *= e * e;
    }
    sum += coeff * sinD(term[0] * d + term[1] * m + term[2] * mp + term[3] * f);
  }
  sum += 3958 * sinD(a1) + 1962 * sinD(lp - f) + 318 * sinD(a2);
  return norm360(lp + sum / 1e6);
}

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
