// Ported from io.github.persiancalendar.calendar.islamic.FallbackIslamicConverter
// (Kotlin), which is itself adapted from a well-known public-domain C/JS
// lunar-visibility algorithm (conjunction-based Hijri calendar estimation).
//
// NOTE ON PORTING: the Kotlin original marks TIMZ/MINAGE/SUNSET as `Float`,
// but every place they're used they get promoted to `Double` by Kotlin's own
// mixed-arithmetic rules, and their values (3, 13.5, 19.5) are exactly
// representable in both precisions -- so this port just uses Dart's `double`
// throughout with zero behavioural difference. Likewise `day / 365f` becomes
// `day / 365.0`; the tiny extra precision from computing in 64-bit instead of
// 32-bit cannot change which day the surrounding coarse iterative search
// lands on.
import 'dart:math' as math;

import '../civil_date.dart';
import '../date_triplet.dart';
import '../util/math_utils.dart';

class FallbackIslamicConverter {
  static const int _nMonths = (1405 * 12) + 1;

  /// toJdn/fromJdn below use int throughout (Dart has no separate Long type).
  static int toJdn(int year, int month, int day) {
    // NMONTH is the number of months between julian day number 1 and
    // the year 1405 A.H. which started immediately after lunar
    // conjunction number 1048 which occurred on September 1984 25d
    // 3h 10m UT.
    var y = year;
    if (y < 0) y++;
    final k = month + y * 12 - _nMonths; // number of months since 1/1/1405
    return (_visibility(k + 1048) + day + .5).floor();
  }

  static double _tmoonphase(int n, int nph) {
    final k = n + nph / 4.0;
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    final jd =
        2415020.75933 +
        29.53058868 * k -
        .0001178 * t2 -
        .000000155 * t3 +
        .00033 * sinOfDegree(166.56 + 132.87 * t - .009173 * t2);

    // Sun's mean anomaly
    final sa = (359.2242 + 29.10535608 * k - .0000333 * t2 - .00000347 * t3)
        .toRadians();

    // Moon's mean anomaly
    final ma = (306.0253 + 385.81691806 * k + .0107306 * t2 + .00001236 * t3)
        .toRadians();

    // Moon's argument of latitude
    final tf =
        (2 * (21.2964 + 390.67050646 * k - .0016528 * t2 - .00000239 * t3))
            .toRadians();

    final double xtra;
    switch (nph) {
      case 0:
      case 2:
        xtra =
            ((.1734 - .000393 * t) * math.sin(sa)) +
            (.0021 * math.sin(sa * 2)) -
            (.4068 * math.sin(ma)) +
            (.0161 * math.sin(2 * ma)) -
            (.0004 * math.sin(3 * ma)) +
            (.0104 * math.sin(tf)) -
            (.0051 * math.sin(sa + ma)) -
            (.0074 * math.sin(sa - ma)) +
            (.0004 * math.sin(tf + sa)) -
            (.0004 * math.sin(tf - sa)) -
            (.0006 * math.sin(tf + ma)) +
            (.001 * math.sin(tf - ma)) +
            (.0005 * math.sin(sa + 2 * ma));
        break;
      case 1:
      case 3:
        xtra =
            ((.1721 - .0004 * t) * math.sin(sa)) +
            (.0021 * math.sin(sa * 2)) -
            (.628 * math.sin(ma)) +
            (.0089 * math.sin(2 * ma)) -
            (.0004 * math.sin(3 * ma)) +
            (.0079 * math.sin(tf)) -
            (.0119 * math.sin(sa + ma)) -
            (.0047 * math.sin(sa - ma)) +
            (.0003 * math.sin(tf + sa)) -
            (.0004 * math.sin(tf - sa)) -
            (.0006 * math.sin(tf + ma)) +
            (.0021 * math.sin(tf - ma)) +
            (.0003 * math.sin(sa + 2 * ma)) +
            (.0004 * math.sin(sa - 2 * ma)) -
            (.0003 * math.sin(2 * sa + ma)) +
            (nph == 1
                ? .0028 - (.0004 * math.cos(sa)) + (.0003 * math.cos(ma))
                : -.0028 + (.0004 * math.cos(sa)) - (.0003 * math.cos(ma)));
        break;
      default:
        return 0.0;
    }
    // convert from Ephemeris Time (ET) to (approximate) Universal Time (UT)
    return jd + xtra - (.41 + (1.2053 * t) + (.4992 * t2)) / 1440;
  }

  static double _visibility(int n) {
    // parameters for Makkah: for a new moon to be visible after sunset on
    // the same day in which it started, it has to have started before
    // (SUNSET-MINAGE)-TIMZ=3 A.M. local time.
    const timz = 3.0;
    const minAge = 13.5;
    const sunset = 19.5;
    // approximate
    const timDif = sunset - minAge;
    final jd = _tmoonphase(n, 0);
    final d = jd.floor();
    var tf = jd - d;
    if (tf <= .5) {
      // new moon starts in the afternoon
      return jd + 1.0;
    } else {
      // new moon starts before noon
      tf = (tf - .5) * 24 + timz; // local time
      if (tf > timDif) {
        return jd + 1.0; // age at sunset < min for visibility
      } else {
        return jd;
      }
    }
  }

  static DateTriplet fromJdn(int jd) {
    final civil = CivilDate.fromJdn(jd);
    var year = civil.year;
    var month = civil.month;
    var day = civil.dayOfMonth;
    var k =
        (.6 +
                (year +
                        (month.remainder(2) == 0 ? month : month - 1) / 12.0 +
                        day / 365.0 -
                        1900) *
                    12.3685)
            .floor();
    double mjd;
    do {
      mjd = _visibility(k);
      k -= 1;
    } while (mjd > jd - .5);
    k += 1;
    final hm = k - 1048;
    year = 1405 + hm ~/ 12;
    // hm.remainder(12) would statically type as `num` (remainder is
    // inherited from `num`, not overridden by `int`), so it's reconstructed
    // via `~/` instead to stay cleanly typed as `int`.
    month = (hm - (hm ~/ 12) * 12) + 1;
    if (hm != 0 && month <= 0) {
      month += 12;
      year -= 1;
    }
    if (year <= 0) year -= 1;
    day = (jd - mjd + .5).floor();
    return DateTriplet(year: year, month: month, dayOfMonth: day);
  }
}
