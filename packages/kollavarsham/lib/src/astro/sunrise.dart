/// Sunrise and sunset by iterating on the Sun's local hour angle.
library;

import 'dart:math' as math;

import 'math.dart';
import 'sun.dart';
import 'time.dart';

/// Altitude of the Sun's centre at apparent rise/set: refraction plus
/// semi-diameter (upper limb on the horizon).
const double _riseAltitude = -0.8333;

/// Greenwich mean sidereal time (degrees) for a Julian Day (UT).
double greenwichSiderealTime(double jdUT) {
  final t = (jdUT - j2000) / 36525.0;
  return norm360(280.46061837 +
      360.98564736629 * (jdUT - j2000) +
      0.000387933 * t * t -
      t * t * t / 38710000.0);
}

/// Returns `(rightAscension, declination)` of the Sun in degrees.
(double, double) _sunEquatorial(double jdUT) {
  final t = julianCenturiesTT(jdUT);
  final lambda = sunApparentLongitude(jdUT);
  final eps = 23.4392911 - 0.0130042 * t;
  final ra = math.atan2(cosD(eps) * sinD(lambda), cosD(lambda)) / deg;
  final dec = math.asin(sinD(eps) * sinD(lambda)) / deg;
  return (norm360(ra), dec);
}

/// Instant (Julian Day, UT) of sunrise ([rising] true) or sunset on the
/// civil day starting at [jdLocalMidnight], for an observer at
/// [latitude]/[longitude] (degrees, east positive).
///
/// Returns `null` if the Sun does not rise or set that day.
double? sunEvent(
  double jdLocalMidnight, {
  required double latitude,
  required double longitude,
  required bool rising,
}) {
  // Start from an estimate of local apparent noon.
  var jd = jdLocalMidnight + 0.5;
  for (var i = 0; i < 6; i++) {
    final (ra, dec) = _sunEquatorial(jd);
    final cosH0 = (sinD(_riseAltitude) - sinD(latitude) * sinD(dec)) /
        (cosD(latitude) * cosD(dec));
    if (cosH0 < -1 || cosH0 > 1) return null;
    final h0 = math.acos(cosH0) / deg;
    final targetH = rising ? -h0 : h0;
    final h = norm180(greenwichSiderealTime(jd) + longitude - ra);
    final step = norm180(targetH - h) / 360.98564736;
    jd += step;
    if (step.abs() < 1e-6) break;
  }
  return jd;
}
