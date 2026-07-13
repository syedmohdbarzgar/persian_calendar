// Ported from io.github.persiancalendar.calendar.util.TwelveMonthsYear (Kotlin)
import '../abstract_date.dart';

class TwelveMonthsYear {
  static T monthStartOfMonthsDistance<T extends AbstractDate>(
    T baseDate,
    int monthsDistance,
    T Function(int year, int month, int dayOfMonth) createDate,
  ) {
    // make it zero based for easier calculations
    final month0 = monthsDistance + baseDate.month - 1;
    final monthDiv12 = month0 ~/ 12;
    var year = baseDate.year + monthDiv12;
    // Kotlin's `%` truncates toward zero (same sign as dividend), which is
    // why the manual sign-correction below is needed. We reconstruct that
    // truncating remainder from `~/` (rather than using `.remainder()`,
    // which is inherited from `num` and would statically type as `num`,
    // not `int`) to keep everything cleanly typed as `int`.
    var month = month0 - monthDiv12 * 12;
    if (month < 0) {
      year -= 1;
      month += 12;
    }
    return createDate(year, month + 1, 1);
  }

  static int monthsDistanceTo<T extends AbstractDate>(T baseDate, T toDate) =>
      ((toDate.year - baseDate.year) * 12) + toDate.month - baseDate.month;
}
