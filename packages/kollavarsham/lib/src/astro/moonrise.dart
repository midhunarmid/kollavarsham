/// Moonrise and moonset by scanning the Moon's altitude through the day.
library;

import 'dart:math' as math;

import 'math.dart';
import 'moon.dart';
import 'sunrise.dart';
import 'time.dart';

/// Sampling step of the altitude scan, in days (20 minutes).
const double _step = 1 / 72;

/// Equatorial radius of the Earth, km.
const double _earthRadius = 6378.14;

/// Height (degrees) of the Moon's centre above the rise/set altitude at
/// Julian Day [jd] (UT). As in published panchangams, the Moon rises when its
/// centre reaches the observer's true horizon, without refraction: a
/// geocentric altitude equal to its parallax. (The upper limb with
/// refraction, as for the Sun, would widen the times by about 3.7 minutes.)
double _heightAboveHorizon(
  double jd, {
  required double latitude,
  required double longitude,
}) {
  final t = julianCenturiesTT(jd);
  final lambda = moonApparentLongitude(jd);
  final beta = moonLatitude(t);
  final eps = 23.4392911 - 0.0130042 * t;
  final ra = math.atan2(
          sinD(lambda) * cosD(eps) - sinD(beta) / cosD(beta) * sinD(eps),
          cosD(lambda)) /
      deg;
  final dec = math.asin(
          sinD(beta) * cosD(eps) + cosD(beta) * sinD(eps) * sinD(lambda)) /
      deg;
  final hourAngle = greenwichSiderealTime(jd) + longitude - ra;
  final altitude = math.asin(sinD(latitude) * sinD(dec) +
          cosD(latitude) * cosD(dec) * cosD(hourAngle)) /
      deg;
  final parallax = math.asin(_earthRadius / moonDistance(t)) / deg;
  return altitude - parallax;
}

/// Instant (Julian Day, UT) of moonrise ([rising] true) or moonset on the
/// civil day starting at [jdLocalMidnight], for an observer at
/// [latitude]/[longitude] (degrees, east positive).
///
/// Returns `null` if the event does not happen that day.
double? moonEvent(
  double jdLocalMidnight, {
  required double latitude,
  required double longitude,
  required bool rising,
}) {
  double height(double jd) =>
      _heightAboveHorizon(jd, latitude: latitude, longitude: longitude);

  final end = jdLocalMidnight + 1;
  var a = jdLocalMidnight;
  var heightA = height(a);
  while (a < end) {
    final b = math.min(a + _step, end);
    final heightB = height(b);
    if (rising ? heightA < 0 && heightB >= 0 : heightA >= 0 && heightB < 0) {
      var low = a, high = b;
      // Halving 20 minutes 12 times leaves about 0.3 seconds.
      for (var i = 0; i < 12; i++) {
        final mid = (low + high) / 2;
        final below = height(mid) < 0;
        if (below == rising) {
          low = mid;
        } else {
          high = mid;
        }
      }
      return (low + high) / 2;
    }
    a = b;
    heightA = heightB;
  }
  return null;
}
