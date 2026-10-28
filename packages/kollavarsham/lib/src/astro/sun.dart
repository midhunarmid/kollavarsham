/// Solar position from the truncated VSOP87 theory (Meeus, *Astronomical
/// Algorithms*, ch. 25 & 32), accurate to about one arc-second.
library;

import 'dart:math' as math;

import 'math.dart';
import 'time.dart';

// Earth heliocentric longitude series L0..L5: [A, B, C] → A·cos(B + C·τ),
// with A in 1e-8 radians and τ in Julian millennia of TT from J2000.0.
const List<List<double>> _l0 = [
  [175347046, 0, 0],
  [3341656, 4.6692568, 6283.0758500],
  [34894, 4.62610, 12566.15170],
  [3497, 2.7441, 5753.3849],
  [3418, 2.8289, 3.5231],
  [3136, 3.6277, 77713.7715],
  [2676, 4.4181, 7860.4194],
  [2343, 6.1352, 3930.2097],
  [1324, 0.7425, 11506.7698],
  [1273, 2.0371, 529.6910],
  [1199, 1.1096, 1577.3435],
  [990, 5.233, 5884.927],
  [902, 2.045, 26.298],
  [857, 3.508, 398.149],
  [780, 1.179, 5223.694],
  [753, 2.533, 5507.553],
  [505, 4.583, 18849.228],
  [492, 4.205, 775.523],
  [357, 2.920, 0.067],
  [317, 5.849, 11790.629],
  [284, 1.899, 796.298],
  [271, 0.315, 10977.079],
  [243, 0.345, 5486.778],
  [206, 4.806, 2544.314],
  [205, 1.869, 5573.143],
  [202, 2.458, 6069.777],
  [156, 0.833, 213.299],
  [132, 3.411, 2942.463],
  [126, 1.083, 20.775],
  [115, 0.645, 0.980],
  [103, 0.636, 4694.003],
  [102, 0.976, 15720.839],
  [102, 4.267, 7.114],
  [99, 6.21, 2146.17],
  [98, 0.68, 155.42],
  [86, 5.98, 161000.69],
  [85, 1.30, 6275.96],
  [85, 3.67, 71430.70],
  [80, 1.81, 17260.15],
  [79, 3.04, 12036.46],
  [75, 1.76, 5088.63],
  [74, 3.50, 3154.69],
  [74, 4.68, 801.82],
  [70, 0.83, 9437.76],
  [62, 3.98, 8827.39],
  [61, 1.82, 7084.90],
  [57, 2.78, 6286.60],
  [56, 4.39, 14143.50],
  [56, 3.47, 6279.55],
  [52, 0.19, 12139.55],
  [52, 1.33, 1748.02],
  [51, 0.28, 5856.48],
  [49, 0.49, 1194.45],
  [41, 5.37, 8429.24],
  [41, 2.40, 19651.05],
  [39, 6.17, 10447.39],
  [37, 6.04, 10213.29],
  [37, 2.57, 1059.38],
  [36, 1.71, 2352.87],
  [36, 1.78, 6812.77],
  [33, 0.59, 17789.85],
  [30, 0.44, 83996.85],
  [30, 2.74, 1349.87],
  [25, 3.16, 4690.48],
];

const List<List<double>> _l1 = [
  [628331966747, 0, 0],
  [206059, 2.678235, 6283.07585],
  [4303, 2.6351, 12566.1517],
  [425, 1.590, 3.523],
  [119, 5.796, 26.298],
  [109, 2.966, 1577.344],
  [93, 2.59, 18849.23],
  [72, 1.14, 529.69],
  [68, 1.87, 398.15],
  [67, 4.41, 5507.55],
  [59, 2.89, 5223.69],
  [56, 2.17, 155.42],
  [45, 0.40, 796.30],
  [36, 0.47, 775.52],
  [29, 2.65, 7.11],
  [21, 5.34, 0.98],
  [19, 1.85, 5486.78],
  [19, 4.97, 213.30],
  [17, 2.99, 6275.96],
  [16, 0.03, 2544.31],
  [16, 1.43, 2146.17],
  [15, 1.21, 10977.08],
  [12, 2.83, 1748.02],
  [12, 3.26, 5088.63],
  [12, 5.27, 1194.45],
  [12, 2.08, 4694.00],
  [11, 0.77, 553.57],
  [10, 1.30, 6286.60],
  [10, 4.24, 1349.87],
  [9, 2.70, 242.73],
  [9, 5.64, 951.72],
  [8, 5.30, 2352.87],
  [6, 2.65, 9437.76],
  [6, 4.67, 4690.48],
];

const List<List<double>> _l2 = [
  [52919, 0, 0],
  [8720, 1.0721, 6283.0758],
  [309, 0.867, 12566.152],
  [27, 0.05, 3.52],
  [16, 5.19, 26.30],
  [16, 3.68, 155.42],
  [10, 0.76, 18849.23],
  [9, 2.06, 77713.77],
  [7, 0.83, 775.52],
  [5, 4.66, 1577.34],
  [4, 1.03, 7.11],
  [4, 3.44, 5573.14],
  [3, 5.14, 796.30],
  [3, 6.05, 5507.55],
  [3, 1.19, 242.73],
  [3, 6.12, 529.69],
  [3, 0.31, 398.15],
  [3, 2.28, 553.57],
  [2, 4.38, 5223.69],
  [2, 3.75, 0.98],
];

const List<List<double>> _l3 = [
  [289, 5.844, 6283.076],
  [35, 0, 0],
  [17, 5.49, 12566.15],
  [3, 5.20, 155.42],
  [1, 4.72, 3.52],
  [1, 5.30, 18849.23],
  [1, 5.97, 242.73],
];

const List<List<double>> _l4 = [
  [114, 3.142, 0],
  [8, 4.13, 6283.08],
  [1, 3.84, 12566.15],
];

const List<List<double>> _l5 = [
  [1, 3.14, 0],
];

double _series(List<List<double>> terms, double tau) {
  var sum = 0.0;
  for (final t in terms) {
    sum += t[0] * math.cos(t[1] + t[2] * tau);
  }
  return sum;
}

/// Geometric geocentric ecliptic longitude of the Sun (degrees, FK5,
/// mean equinox of date) at Julian centuries [t] of TT since J2000.0.
double sunGeometricLongitude(double t) {
  final tau = t / 10.0;
  final l = (_series(_l0, tau) +
          tau *
              (_series(_l1, tau) +
                  tau *
                      (_series(_l2, tau) +
                          tau *
                              (_series(_l3, tau) +
                                  tau *
                                      (_series(_l4, tau) +
                                          tau * _series(_l5, tau)))))) /
      1e8;
  // Heliocentric Earth → geocentric Sun, plus the FK5 correction.
  return norm360(l / deg + 180.0 - 0.09033 / 3600.0);
}

/// Nutation in longitude Δψ, in degrees (Meeus ch. 22, low precision).
double nutationInLongitude(double t) {
  final omega = 125.04452 - 1934.136261 * t;
  final lSun = 280.4665 + 36000.7698 * t;
  final lMoon = 218.3165 + 481267.8813 * t;
  return (-17.20 * sinD(omega) -
          1.32 * sinD(2 * lSun) -
          0.23 * sinD(2 * lMoon) +
          0.21 * sinD(2 * omega)) /
      3600.0;
}

/// Annual aberration for the Sun, in degrees.
const double _aberration = -20.4898 / 3600.0;

/// Apparent tropical longitude of the Sun (degrees) for a Julian Day in UT.
double sunApparentLongitude(double jdUT) {
  final t = julianCenturiesTT(jdUT);
  return norm360(
      sunGeometricLongitude(t) + nutationInLongitude(t) + _aberration);
}

/// Lahiri (Chitrapaksha) ayanamsa in degrees, for Julian centuries [t] of TT
/// since J2000.0.
///
/// Advanced with the IAU general precession from 23.863092° on J2000.0.
/// That anchor is calibrated so that, together with [sunSiderealLongitude],
/// it reproduces the sankranti moments of published Kerala panchangams
/// (checked against 2024–2025) to within one minute.
double lahiriAyanamsa(double t) => 23.863092 + 1.396971 * t + 0.0003086 * t * t;

/// Sidereal (nirayana) longitude of the Sun in degrees for a Julian Day in UT.
///
/// The Lahiri ayanamsa is subtracted from the Sun's apparent longitude
/// (geometric plus nutation and aberration).
double sunSiderealLongitude(double jdUT) {
  final t = julianCenturiesTT(jdUT);
  return norm360(sunGeometricLongitude(t) +
      nutationInLongitude(t) +
      _aberration -
      lahiriAyanamsa(t));
}

/// Finds the instant (Julian Day, UT) nearest [guessJd] at which the Sun's
/// sidereal longitude equals [targetDeg]. This is a *sankranti* when
/// [targetDeg] is a multiple of 30.
double findSunSiderealLongitude(double targetDeg, double guessJd) {
  var jd = guessJd;
  for (var i = 0; i < 30; i++) {
    final diff = norm180(sunSiderealLongitude(jd) - targetDeg);
    if (diff.abs() < 1e-7) break;
    jd -= diff / 0.98564736;
  }
  return jd;
}
