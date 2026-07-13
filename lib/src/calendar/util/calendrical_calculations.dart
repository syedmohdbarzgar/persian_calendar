// Ported from io.github.persiancalendar.calendar.util.CalendricalCalculations.kt
// which itself was ported from
// https://github.com/roozbehp/persiancalendar/blob/daf8fb2b46466a324cee98833c19c36aa5d97f39/persiancalendar.py
// (released under the Apache 2.0 license)
//
// NOTE ON PORTING (operator semantics): Kotlin's `/` on integers truncates
// towards zero and its `%` keeps the sign of the dividend (like Java/C).
// Dart's `~/` also truncates towards zero (a direct match for `/`), but
// Dart's `%` is a *floored* modulo (always non-negative for a positive
// divisor) -- so every plain Kotlin `%` below is translated with Dart's
// `.remainder()` (which truncates like Kotlin's `%`), and every explicit
// Kotlin `.mod()` call (which is already floored) is translated with Dart's
// native `%`. Kotlin's `.floorDiv()` is translated with the `floorDiv()`
// helper in math_utils.dart. This preserves the exact numeric behaviour,
// including for negative years/dates.
import 'dart:math' as math;

import '../date_triplet.dart';
import 'math_utils.dart';

/// The value of x shifted into the range [a..b). Returns x if a=b.
double _mod3(double x, int a, int b) {
  if (a == b) return x;
  // Truncating remainder of (x - a) by (b - a), computed via `~/` (which is
  // guaranteed to truncate towards zero and return an int) instead of
  // `.remainder()`, to avoid relying on num vs. double static-type nuances.
  final dividend = x - a;
  final divisor = b - a;
  final truncatingRemainder = dividend - (dividend ~/ divisor) * divisor;
  return a + truncatingRemainder;
}

/// Sum powers of x with coefficients (from order 0 up) in list a.
double _poly(double indeterminate, List<double> coefficients) {
  var sum = coefficients[0];
  var indeterminateRaised = 1.0;
  for (var i = 1; i < coefficients.length; i++) {
    indeterminateRaised *= indeterminate;
    sum += coefficients[i] * indeterminateRaised;
  }
  return sum;
}

/// Identity function for fixed dates/moments. If internal timekeeping is
/// shifted, change epoch to be RD date of origin of internal count. epoch
/// should be an integer.
int _rd(int tee) {
  const epoch = 0;
  return tee - epoch;
}

// Fixed date of start of the (proleptic) Gregorian calendar.
final int _gregorianEpoch = _rd(1);

/// True if gYear is a leap year on the Gregorian calendar.
bool _gregorianLeapYear(int gYear) {
  if (gYear.remainder(4) != 0) return false;
  final r = gYear.remainder(400);
  if (r == 100 || r == 200 || r == 300) return false;
  return true;
}

/// Fixed date equivalent to the Gregorian date g_date.
int fixedFromGregorian(int year, int month, int day) {
  return (_gregorianEpoch -
      1 // Days before start of calendar
      +
      365 *
          (year - 1) // Ordinary days since epoch
          +
      floorDiv(year - 1, 4) // Julian leap days since epoch...
      -
      floorDiv(year - 1, 100) // ...minus century years since epoch...
      +
      floorDiv(year - 1, 400) // plus years since epoch divisible by 400.
      // Days in prior months this year assuming 30-day Feb
      +
      (367 * month - 362) ~/ 12
      // Correct for 28- or 29-day Feb
      +
      (month <= 2 ? 0 : (_gregorianLeapYear(year) ? -1 : -2)) +
      day); // Days so far this month.
}

/// Gregorian year corresponding to the fixed date.
int _gregorianYearFromFixed(int date) {
  final d0 = date - _gregorianEpoch; // Prior days.
  final n400 = d0 ~/ 146097; // Completed 400-year cycles.
  final d1 = d0.remainder(146097); // Prior days not in n400.
  final n100 = d1 ~/ 36524; // 100-year cycles not in n400.
  final d2 = d1.remainder(36524); // Prior days not in n400 or n100.
  final n4 = d2 ~/ 1461; // 4-year cycles not in n400 or n100.
  final d3 = d2.remainder(1461); // Prior days not in n400, n100, or n4.
  final n1 = d3 ~/ 365; // Years not in n400, n100, or n4.
  final year = 400 * n400 + 100 * n100 + 4 * n4 + n1;
  return (n100 == 4 || n1 == 4)
      ? year // Date is day 366 in a leap year.
      : year + 1; // Date is ordinal day (d % 365 + 1) in (year + 1).
}

/// Fixed date of January 1 in gYear.
int _gregorianNewYear(int gYear) => fixedFromGregorian(gYear, 1, 1);

/// Gregorian (year, month, day) corresponding to fixed date.
DateTriplet gregorianFromFixed(int date) {
  final year = _gregorianYearFromFixed(date);
  final priorDays = date - _gregorianNewYear(year); // This year
  // To simulate a 30-day Feb
  final int correction;
  if (date < fixedFromGregorian(year, 3, 1)) {
    correction = 0;
  } else if (_gregorianLeapYear(year)) {
    correction = 1;
  } else {
    correction = 2;
  }
  final month =
      (12 * (priorDays + correction) + 373) ~/ 367; // Assuming a 30-day Feb
  // Calculate the day by subtraction.
  final day = date - fixedFromGregorian(year, month, 1) + 1;
  return DateTriplet(year: year, month: month, dayOfMonth: day);
}

/// Number of days from Gregorian date g_date1 until g_date2.
int _gregorianDateDifference(
  int year1,
  int month1,
  int day1,
  int year2,
  int month2,
  int day2,
) =>
    fixedFromGregorian(year2, month2, day2) -
    fixedFromGregorian(year1, month1, day1);

// Fixed date of start of the Julian calendar.
final int _julianEpoch = fixedFromGregorian(0, 12, 30);

/// True if jYear is a leap year on the Julian calendar.
bool _julianLeapYear(int jYear) => jYear.remainder(4) == (jYear > 0 ? 0 : 3);

/// Fixed date equivalent to the Julian date.
int fixedFromJulian(int year, int month, int day) {
  final y = year < 0 ? year + 1 : year; // No year zero
  return (_julianEpoch -
      1 // Days before start of calendar
      +
      365 *
          (y - 1) // Ordinary days since epoch.
          +
      floorDiv(y - 1, 4) // Leap days since epoch...
      // Days in prior months this year...
      +
      ((367 * month - 362) ~/ 12) // ...assuming 30-day Feb
      // Correct for 28- or 29-day Feb
      +
      (month <= 2 ? 0 : (_julianLeapYear(year) ? -1 : -2)) +
      day); // Days so far this month.
}

/// True if jYear is a leap year on the Julian calendar.
bool _isJulianLeapYear(int jYear) => jYear.remainder(4) == (jYear > 0 ? 0 : 3);

/// Julian (year month day) corresponding to fixed date.
DateTriplet julianFromFixed(int date) {
  // Nominal year.
  final approx = ((4 * (date - _julianEpoch) + 1464) / 1461.0).floor();
  final year = approx <= 0 ? approx - 1 : approx; // No year 0.

  // This year
  final priorDays = date - fixedFromJulian(year, 1, 1);

  // To simulate a 30-day Feb
  final correction = date < fixedFromJulian(year, 3, 1)
      ? 0
      : (_isJulianLeapYear(year) ? 1 : 2);

  // Assuming a 30-day Feb
  final month = ((12 * (priorDays + correction) + 373) / 367.0).floor();

  // Calculate the day by subtraction.
  final day = 1 + (date - fixedFromJulian(year, month, 1));

  return DateTriplet(year: year, month: month, dayOfMonth: day);
}

/// x hours.
double _hr(int x) => x / 24.0;

/// d degrees, m arcminutes, s arcseconds.
double _angle(int d, int m, double s) => d + (m + s / 60) / 60.0;

/// Convert angle theta from degrees to radians.
double _radiansFromDegrees(double theta) {
  // Truncating remainder of theta by 360 (see _mod3 comment above for why
  // this avoids `.remainder()`).
  final truncatingRemainder = theta - (theta ~/ 360) * 360;
  return truncatingRemainder * math.pi / 180;
}

/// Sine of theta (given in degrees).
double _sinDegrees(double theta) => math.sin(_radiansFromDegrees(theta));

/// Cosine of theta (given in degrees).
double _cosDegrees(double theta) => math.cos(_radiansFromDegrees(theta));

/// Tangent of theta (given in degrees).
double _tanDegrees(double theta) => math.tan(_radiansFromDegrees(theta));

/// Difference between UT and local mean time at longitude phi as a fraction
/// of a day.
double _zoneFromLongitude(double phi) => phi / 360;

/// Universal time from local teeEll at location.
double _universalFromLocal(double teeEll, double longitude) =>
    teeEll - _zoneFromLongitude(longitude);

/// Local time from sundial time tee at location.
double _localFromApparent(double tee, double longitude) =>
    tee - _equationOfTime(_universalFromLocal(tee, longitude));

/// Universal time from sundial time tee at location.
double _universalFromApparent(double tee, double longitude) =>
    _universalFromLocal(_localFromApparent(tee, longitude), longitude);

/// Universal time on fixed date of midday at location.
double _midday(int date, double longitude) =>
    _universalFromApparent(date + _hr(12), longitude);

/// Julian centuries since 2000 at moment tee.
double _julianCenturies(double tee) =>
    (_dynamicalFromUniversal(tee) - _j2000) / 36525;

final List<double> _obliquityCoefficients = [
  0.0,
  _angle(0, 0, -46.8150),
  _angle(0, 0, -0.00059),
  _angle(0, 0, 0.001813),
];

/// Obliquity of ecliptic at moment tee.
double _obliquity(double tee) {
  final c = _julianCenturies(tee);
  return _angle(23, 26, 21.448) + _poly(c, _obliquityCoefficients);
}

/// Dynamical time at Universal moment teeRomU.
double _dynamicalFromUniversal(double teeRomU) =>
    teeRomU + _ephemerisCorrection(teeRomU);

// Noon at start of Gregorian year 2000.
final double _j2000 = _hr(12) + _gregorianNewYear(2000);

const double _meanTropicalYear = 365.242189;

final List<double> _c2006Coefficients = [62.92, 0.32217, 0.005589];
final List<double> _c1987Coefficients = [
  63.86, 0.3345, -0.060374, //
  0.0017275, //
  0.000651814, 0.00002373599,
];
final List<double> _c1900Coefficients = [
  -0.00002, 0.000297, 0.025184, //
  -0.181133, 0.553040, -0.861938, //
  0.677066, -0.212591,
];
final List<double> _c1800Coefficients = [
  -0.000009, 0.003844, 0.083563, //
  0.865736, //
  4.867575, 15.845535, 31.332267, //
  38.291999, 28.316289, 11.636204, //
  2.043794,
];
final List<double> _c1700Coefficients = [
  8.118780842, -0.005092142, //
  0.003336121, -0.0000266484,
];
final List<double> _c1600Coefficients = [
  120.0, -0.9808, -0.01532, //
  0.000140272128,
];
final List<double> _c500Coefficients = [
  1574.2, -556.01, 71.23472, 0.319781, //
  -0.8503463, -0.005050998, //
  0.0083572073,
];
final List<double> _c0Coefficients = [
  10583.6, -1014.41, 33.78311, //
  -5.952053, -0.1798452, 0.022174192, //
  0.0090316521,
];
final List<double> _otherCoefficients = [-20.0, 0.0, 32.0];

/// Dynamical Time minus Universal Time (in days) for moment tee.
///
/// Adapted from "Astronomical Algorithms" by Jean Meeus, Willmann-Bell
/// (1991) for years 1600-1986 and from polynomials on the NASA Eclipse web
/// site for other years.
double _ephemerisCorrection(double tee) {
  final year = _gregorianYearFromFixed(tee.floor());
  if (year >= 2051 && year <= 2150) {
    final x = (year - 1820) / 100.0;
    return (-20 + 32 * (x * x) + 0.5628 * (2150 - year)) / 86400;
  }
  if (year >= 2006 && year <= 2050) {
    final y2000 = year - 2000;
    return _poly(y2000.toDouble(), _c2006Coefficients) / 86400;
  }
  if (year >= 1987 && year <= 2005) {
    final y2000 = year - 2000;
    return _poly(y2000.toDouble(), _c1987Coefficients) / 86400;
  }
  if (year >= 1900 && year <= 1986) {
    final c = _gregorianDateDifference(1900, 1, 1, year, 7, 1) / 36525.0;
    return _poly(c, _c1900Coefficients);
  }
  if (year >= 1800 && year <= 1899) {
    final c = _gregorianDateDifference(1900, 1, 1, year, 7, 1) / 36525.0;
    return _poly(c, _c1800Coefficients);
  }
  if (year >= 1700 && year <= 1799) {
    final y1700 = year - 1700;
    return _poly(y1700.toDouble(), _c1700Coefficients) / 86400;
  }
  if (year >= 1600 && year <= 1699) {
    final y1600 = year - 1600;
    return _poly(y1600.toDouble(), _c1600Coefficients) / 86400;
  }
  if (year >= 500 && year <= 1599) {
    final y1000 = (year - 1000) / 100.0;
    return _poly(y1000, _c500Coefficients) / 86400;
  }
  if (year > -500 && year < 500) {
    final y0 = year / 100.0;
    return _poly(y0, _c0Coefficients) / 86400;
  }
  final y1820 = (year - 1820) / 100.0;
  return _poly(y1820, _otherCoefficients) / 86400;
}

final List<double> _lamdaCoefficient = [280.46645, 36000.76983, 0.0003032];
final List<double> _anamolyCoefficients = [
  357.52910,
  35999.05030,
  -0.0001559,
  -0.00000048,
];
final List<double> _eccentricityCoefficients = [
  0.016708617,
  -0.000042037,
  -0.0000001236,
];

/// Equation of time (as fraction of day) for moment tee.
///
/// Adapted from "Astronomical Algorithms" by Jean Meeus, Willmann-Bell, 2nd
/// edn., 1998, p. 185.
double _equationOfTime(double tee) {
  final c = _julianCenturies(tee);
  final lamda = _poly(c, _lamdaCoefficient);
  final anomaly = _poly(c, _anamolyCoefficients);
  final eccentricity = _poly(c, _eccentricityCoefficients);
  final varepsilon = _obliquity(tee);
  final tanHalfEps = _tanDegrees(varepsilon / 2);
  final y = tanHalfEps * tanHalfEps;
  final equation =
      (1.0 / 2 / math.pi) *
      (y * _sinDegrees(2 * lamda) -
          2 * eccentricity * _sinDegrees(anomaly) +
          4 * eccentricity * y * _sinDegrees(anomaly) * _cosDegrees(2 * lamda) -
          0.5 * y * y * _sinDegrees(4 * lamda) -
          1.25 * eccentricity * eccentricity * _sinDegrees(2 * anomaly));
  return equation.sign * math.min(equation.abs(), _hr(12));
}

final List<int> _solarLongitudeCoefficients = [
  403406, 195207, 119433, 112392, 3891, 2819, 1721, //
  660, 350, 334, 314, 268, 242, 234, 158, 132, 129, 114, //
  99, 93, 86, 78, 72, 68, 64, 46, 38, 37, 32, 29, 28, 27, 27, //
  25, 24, 21, 21, 20, 18, 17, 14, 13, 13, 13, 12, 10, 10, 10, //
  10,
];
final List<double> _solarLongitudeMultipliers = [
  0.9287892, 35999.1376958, 35999.4089666, //
  35998.7287385, 71998.20261, 71998.4403, //
  36000.35726, 71997.4812, 32964.4678, //
  -19.4410, 445267.1117, 45036.8840, 3.1008, //
  22518.4434, -19.9739, 65928.9345, //
  9038.0293, 3034.7684, 33718.148, 3034.448, //
  -2280.773, 29929.992, 31556.493, 149.588, //
  9037.750, 107997.405, -4444.176, 151.771, //
  67555.316, 31556.080, -4561.540, //
  107996.706, 1221.655, 62894.167, //
  31437.369, 14578.298, -31931.757, //
  34777.243, 1221.999, 62894.511, //
  -4442.039, 107997.909, 119.066, 16859.071, //
  -4.578, 26895.292, -39.127, 12297.536, //
  90073.778,
];
final List<double> _solarLongitudeAddends = [
  270.54861, 340.19128, 63.91854, 331.26220, //
  317.843, 86.631, 240.052, 310.26, 247.23, //
  260.87, 297.82, 343.14, 166.79, 81.53, //
  3.50, 132.75, 182.95, 162.03, 29.8, //
  266.4, 249.2, 157.6, 257.8, 185.1, 69.9, //
  8.0, 197.1, 250.4, 65.3, 162.7, 341.5, //
  291.6, 98.5, 146.7, 110.0, 5.2, 342.6, //
  230.9, 256.1, 45.3, 242.9, 115.2, 151.8, //
  285.3, 53.3, 126.6, 205.7, 85.9, //
  146.1,
];

/// Longitude of sun at moment tee.
///
/// Adapted from "Planetary Programs and Tables from -4000 to +2800" by
/// Pierre Bretagnon and Jean-Louis Simon, Willmann-Bell, 1986.
double _solarLongitude(double tee) {
  final c = _julianCenturies(tee); // moment in Julian centuries
  var sum = 0.0;
  for (var i = 0; i < _solarLongitudeCoefficients.length; i++) {
    sum +=
        _solarLongitudeCoefficients[i] *
        _sinDegrees(
          _solarLongitudeAddends[i] + _solarLongitudeMultipliers[i] * c,
        );
  }
  final lamda =
      282.7771834 + 36000.76953744 * c + 0.000005729577951308232 * sum;
  return (lamda + _aberration(tee) + _nutation(tee)) % 360.0;
}

final List<double> _nutationCoefficientA = [124.90, -1934.134, 0.002063];
final List<double> _nutationCoefficientB = [201.11, 72001.5377, 0.00057];

/// Longitudinal nutation at moment tee.
double _nutation(double tee) {
  final c = _julianCenturies(tee); // moment in Julian centuries
  final capA = _poly(c, _nutationCoefficientA);
  final capB = _poly(c, _nutationCoefficientB);
  return -0.004778 * _sinDegrees(capA) - 0.0003667 * _sinDegrees(capB);
}

/// Aberration at moment tee.
double _aberration(double tee) {
  final c = _julianCenturies(tee); // moment in Julian centuries
  return 0.0000974 * _cosDegrees(177.63 + 35999.01848 * c) - 0.005575;
}

// Longitude of sun at vernal equinox.
const double _spring = 0.0;

/// Approximate moment at or before tee when solar longitude just exceeded
/// lamda degrees.
double _estimatePriorSolarLongitude(double lamda, double tee) {
  final rate = _meanTropicalYear / 360; // Mean change of one degree.
  // First approximation.
  final tau = tee - rate * ((_solarLongitude(tee) - lamda) % 360.0);
  final capDelta = _mod3(_solarLongitude(tau) - lamda, -180, 180);
  return math.min(tee, tau - rate * capDelta);
}

// Fixed date of start of the Persian calendar.
final int _persianEpoch = fixedFromJulian(622, 3, 19);

// Location of Tehran, Iran.
// Specifically location of "Dar ul-Funun", https://w.wiki/DjPM
final List<double> _tehran = [35.683789, 51.421864, 1100.0, 3.5];

// Middle of Iran.
final List<double> _iran = [35.5, 52.5, 0.0, 3.5];

/// Fixed date of Astronomical Persian New Year on or before fixed date.
int _persianNewYearOnOrBefore(int date, double longitude) {
  // Approximate time of equinox.
  final approx = _estimatePriorSolarLongitude(
    _spring,
    _midday(date, longitude),
  );
  var day = approx.floor() - 1;
  while (_solarLongitude(_midday(day, longitude)) > _spring + 2) {
    day += 1;
  }
  return day;
}

/// Fixed date of Borji Persian new month on or before fixed date.
int _persianBorjiNewMonthOnOrBefore(int date, int month, double longitude) {
  // Approximate time of equinox.
  final targetLong = (month - 1) * 30.0;
  final approx = _estimatePriorSolarLongitude(
    targetLong,
    _midday(date, longitude),
  );
  var day = approx.floor() - 1;
  while (true) {
    final solarLong = _solarLongitude(_midday(day, longitude));
    if (targetLong + 2 > solarLong && solarLong >= targetLong) break;
    day += 1;
  }
  return day;
}

/// Fixed date of Astronomical Persian date pDate.
int _fixedFromPersian(int year, int month, int day, double longitude) {
  final newYear = _persianNewYearOnOrBefore(
    _persianEpoch +
        180 // Fall after epoch.
        +
        (_meanTropicalYear * (0 < year ? year - 1 : year)).floor(),
    longitude,
  ); // No year zero.
  return (newYear -
      1 // Days in prior years.
      // Days in prior months this year.
      +
      (month <= 7 ? 31 * (month - 1) : 30 * (month - 1) + 6) +
      day); // Days so far this month.
}

/// Fixed date of Borji Persian date pDate.
int _fixedFromPersianBorji(int year, int month, int day, double longitude) {
  final newMonth = _persianBorjiNewMonthOnOrBefore(
    _persianEpoch +
        180 +
        (_meanTropicalYear *
                ((0 < year ? year - 1 : year) + (month - 1) / 12.0))
            .floor(),
    month,
    longitude,
  );
  return (newMonth -
      1 // Days in prior months.
      +
      day); // Days so far this month.
}

/// Astronomical Persian date corresponding to fixed date.
DateTriplet _persianFromFixed(int date, double longitude) {
  final newYear = _persianNewYearOnOrBefore(date, longitude);
  final y = roundHalfToEven((newYear - _persianEpoch) / _meanTropicalYear) + 1;
  final year = 0 < y ? y : y - 1; // No year zero
  final dayOfYear = date - _fixedFromPersian(year, 1, 1, longitude) + 1;
  final month = dayOfYear <= 186
      ? (dayOfYear / 31.0).ceil()
      : ((dayOfYear - 6) / 30.0).ceil();
  // Calculate the day by subtraction
  final day = date - _fixedFromPersian(year, month, 1, longitude) + 1;
  return DateTriplet(year: year, month: month, dayOfMonth: day);
}

/// Borji Persian date corresponding to fixed date.
DateTriplet _persianBorjiFromFixed(int date, double longitude) {
  final newYear = _persianNewYearOnOrBefore(date, longitude);
  final y = roundHalfToEven((newYear - _persianEpoch) / _meanTropicalYear) + 1;
  final year = 0 < y ? y : y - 1; // No year zero
  var month = 1;
  while (month < 12 &&
      date >= _fixedFromPersianBorji(year, month + 1, 1, longitude)) {
    month += 1;
  }
  // Calculate the day by subtraction
  final day = date - _fixedFromPersianBorji(year, month, 1, longitude) + 1;
  return DateTriplet(year: year, month: month, dayOfMonth: day);
}

const int _offsetJdn = 1721425;
const int _startOfModernEraJdn = 2424231; // PersianDate(1304, 1, 1).toJdn()
const int _startOfModernEraYear = 1304;

DateTriplet persianFromJdn(int jdn, {bool alwaysBorji = false}) {
  final isModernEra = jdn >= _startOfModernEraJdn;
  final fixed = jdn - _offsetJdn;
  final longitude = (isModernEra ? _iran : _tehran)[1];
  return (isModernEra && !alwaysBorji)
      ? _persianFromFixed(fixed, longitude)
      : _persianBorjiFromFixed(fixed, longitude);
}

int jdnFromPersian(int year, int month, int dayOfMonth) {
  final isModernEra = year >= _startOfModernEraYear;
  final longitude = (isModernEra ? _iran : _tehran)[1];
  final fixed = isModernEra
      ? _fixedFromPersian(year, month, dayOfMonth, longitude)
      : _fixedFromPersianBorji(year, month, dayOfMonth, longitude);
  return fixed + _offsetJdn;
}

// Expose this so the app can display Julian date for now
// but it's unstable and maybe we would decide to expose it differently
DateTriplet julianFromJdn(int jdn) => julianFromFixed(jdn - _offsetJdn);

int jdnFromCivil(int year, int month, int dayOfMonth) {
  return _offsetJdn +
      (((year > 1582) ||
              ((year == 1582) && (month > 10)) ||
              ((year == 1582) && (month == 10) && (dayOfMonth > 14)))
          ? fixedFromGregorian(year, month, dayOfMonth)
          : fixedFromJulian(year, month, dayOfMonth));
}

DateTriplet civilFromJdn(int jdn) =>
    jdn > 2299160 ? gregorianFromFixed(jdn - _offsetJdn) : julianFromJdn(jdn);
