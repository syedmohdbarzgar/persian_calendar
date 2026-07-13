// Ported from io.github.persiancalendar.calendar.CivilDate (Kotlin)
import 'abstract_date.dart';
import 'util/calendrical_calculations.dart';
import 'util/twelve_months_year.dart';
import 'year_month_date.dart';

class CivilDate extends AbstractDate implements YearMonthDate<CivilDate> {
  CivilDate(super.year, super.month, super.dayOfMonth);

  factory CivilDate.fromDate(AbstractDate date) =>
      CivilDate.fromJdn(date.toJdn());

  factory CivilDate.fromJdn(int jdn) {
    final t = civilFromJdn(jdn);
    return CivilDate(t.year, t.month, t.dayOfMonth);
  }

  @override
  int toJdn() => jdnFromCivil(year, month, dayOfMonth);

  @override
  CivilDate monthStartOfMonthsDistance(int monthsDistance) =>
      TwelveMonthsYear.monthStartOfMonthsDistance<CivilDate>(
        this,
        monthsDistance,
        (y, m, d) => CivilDate(y, m, d),
      );

  @override
  int monthsDistanceTo(CivilDate date) =>
      TwelveMonthsYear.monthsDistanceTo(this, date);

  @override
  String toString() => 'CivilDate($year, $month, $dayOfMonth)';
}
