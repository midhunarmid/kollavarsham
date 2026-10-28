import 'dart:math' as math;

/// Radians per degree.
const double deg = math.pi / 180.0;

/// Normalises an angle in degrees to `[0, 360)`.
double norm360(double x) {
  final r = x % 360.0;
  return r < 0 ? r + 360.0 : r;
}

/// Normalises an angle in degrees to `(-180, 180]`.
double norm180(double x) {
  final r = norm360(x);
  return r > 180.0 ? r - 360.0 : r;
}

/// Sine of an angle in degrees.
double sinD(double x) => math.sin(x * deg);

/// Cosine of an angle in degrees.
double cosD(double x) => math.cos(x * deg);
