// Ported from
// io.github.persiancalendar.calendar.islamic.IranianIslamicDateConverter
// (Kotlin).
//
// NOTE ON PORTING: `hijriMonths` stores one 12-bit value per Hijri year
// (years 1264..1449); bit `11 - (monthIndexInYear)` tells whether that month
// has 30 days (bit set) or 29 days (bit clear). Dart has no `0b...` binary
// integer literal syntax (unlike Kotlin), so each 12-bit binary literal from
// the Kotlin source was mechanically converted to its equivalent decimal
// value (e.g. Kotlin's `0b1_0_1_0_1_1_1_0_1_0_1_0` -> `2794`) with a Python
// script reading the original source directly, rather than by hand -- this
// keeps every single bit pattern exact. The bit-shifting logic below then
// operates on these decimal integers exactly as the original operated on the
// binary literals, since they represent identical bit patterns.
import '../date_triplet.dart';

class IranianIslamicDateConverter {
  IranianIslamicDateConverter._();

  static const int latestSupportedYearOfIran = 1405;
  static const int _supportedStartJdn = 2396005;
  // one year is just added to make the rest fit
  static const int _supportedStartYear = 1265 - 1;

  // One 12-bit entry per Hijri year from 1264 to 1449; bit (11 - m) set
  // means month m (0-based) has 30 days, clear means 29 days.
  static const List<int> _hijriMonths = [
    2711,
    2730,
    2773,
    1428,
    2986,
    1461,
    1206,
    2647,
    1323,
    1699,
    1745,
    2793,
    1386,
    2669,
    1325,
    3221,
    3658,
    3749,
    1716,
    2490,
    1339,
    603,
    1323,
    2645,
    2730,
    2905,
    1396,
    2426,
    1210,
    2650,
    3380,
    3761,
    1752,
    2796,
    1372,
    2670,
    1334,
    2726,
    2898,
    2985,
    948,
    2522,
    1370,
    2730,
    3402,
    3749,
    1874,
    2921,
    1460,
    2733,
    1622,
    3366,
    3730,
    3913,
    1876,
    2906,
    2459,
    1179,
    2379,
    2853,
    3410,
    3434,
    1389,
    694,
    2615,
    1179,
    1613,
    1706,
    2901,
    860,
    2414,
    1199,
    599,
    811,
    1429,
    938,
    1497,
    730,
    2397,
    683,
    1365,
    1737,
    1764,
    2922,
    1461,
    694,
    2454,
    3402,
    3525,
    1874,
    1957,
    874,
    2477,
    1357,
    2709,
    3401,
    3493,
    1458,
    2773,
    1366,
    2647,
    1323,
    1685,
    2890,
    2917,
    1387,
    685,
    1358,
    3223,
    1355,
    1701,
    1746,
    2777,
    1245,
    599,
    2349,
    2709,
    2898,
    2921,
    884,
    2422,
    1207,
    599,
    1355,
    1701,
    1746,
    2794,
    1261,
    621,
    2357,
    3365,
    3409,
    2985,
    1492,
    2741,
    1334,
    2711,
    1610,
    3749,
    1874,
    2985,
    1461,
    693,
    2646,
    3366,
    3667,
    1705,
    3412,
    3414,
    2647,
    1191,
    3143,
    3366,
    3668,
    3494,
    1383,
    694,
    2359,
    1175,
    1621,
    2730,
    2917,
    748,
    2421,
    1134,
    2614,
    3238,
    3410,
    3538,
    1493,
    730,
    1373,
    1195,
    1683,
    1865,
    1956,
    2994,
    1461,
    694,
    1626,
    3370,
    3732,
    3793,
    1768,
    2794,
    2396,
  ];

  static final int _supportedYears = _hijriMonths.length;

  // Cumulative day offset (from _supportedStartJdn) of the 1st of each
  // (year, month) pair, flattened to a single list of length
  // hijriMonths.length * 12; plus the total day count once all months are
  // accounted for (used to compute _jdSupportEnd).
  static final (List<int>, int) _monthsData = _buildMonths();
  static List<int> get _months => _monthsData.$1;
  static final int _jdSupportEnd = _monthsData.$2 + _supportedStartJdn;

  static (List<int>, int) _buildMonths() {
    final months = List<int>.filled(_hijriMonths.length * 12, 0);
    var jd = 0;
    for (var m = 0; m < months.length; m++) {
      months[m] = jd;
      jd += ((_hijriMonths[m ~/ 12] >> (11 - m % 12)) & 1) == 1 ? 30 : 29;
    }
    return (months, jd);
  }

  static int toJdn(int year, int month, int day) {
    final yearIndex = year - _supportedStartYear;
    if (yearIndex < 0 || yearIndex >= _supportedYears) return -1;
    return _months[yearIndex * 12 + month - 1] + day + _supportedStartJdn - 1;
  }

  static DateTriplet? fromJdn(int jd) {
    if (jd < _supportedStartJdn || jd >= _jdSupportEnd) return null;
    final days = jd - _supportedStartJdn;
    var index = days ~/ 30;
    while (index + 1 < _months.length && _months[index + 1] <= days) {
      index++;
    }
    final yearIndex = index ~/ 12;
    final month = index % 12;
    final day = days - _months[index];
    return DateTriplet(
      year: yearIndex + _supportedStartYear,
      month: month + 1,
      dayOfMonth: day + 1,
    );
  }
}
