// Ported from io.github.persiancalendar.calendar.util.Math.kt
import 'dart:math' as math;

extension DegreeMath on double {
  double toRadians() => this * math.pi / 180.0;
}

double sinOfDegree(double degree) => math.sin(degree.toRadians());

double cosOfDegree(double degree) => math.cos(degree.toRadians());

double tanOfDegree(double degree) => math.tan(degree.toRadians());

/// Integer floor division matching Kotlin's `Int.floorDiv`/`Long.floorDiv`
/// (rounds towards negative infinity), as opposed to Dart's built-in `~/`
/// which truncates towards zero like Kotlin's plain `/` operator.
int floorDiv(int a, int b) {
  final q = a ~/ b;
  final r = a - q * b;
  if (r != 0 && (r < 0) != (b < 0)) return q - 1;
  return q;
}

/// Rounds to the nearest integer, with ties rounded to the nearest *even*
/// integer, matching Kotlin's `kotlin.math.round(Double)` (aka Java's
/// `Math.rint`). This is different from Dart's built-in `double.round()`,
/// which always rounds ties away from zero.
int roundHalfToEven(double x) {
  final lower = x.floor();
  final diff = x - lower;
  if (diff < 0.5) return lower;
  if (diff > 0.5) return lower + 1;
  return (lower % 2 == 0) ? lower : lower + 1;
}
