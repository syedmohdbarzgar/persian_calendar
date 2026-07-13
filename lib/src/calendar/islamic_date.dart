// Ported from io.github.persiancalendar.calendar.IslamicDate (Kotlin)
import 'abstract_date.dart';
import 'islamic/fallback_islamic_converter.dart';
import 'islamic/iranian_islamic_date_converter.dart';
import 'islamic/umm_al_qura_converter.dart';
import 'util/twelve_months_year.dart';
import 'year_month_date.dart';

class IslamicDate extends AbstractDate implements YearMonthDate<IslamicDate> {
  IslamicDate(super.year, super.month, super.dayOfMonth);

  factory IslamicDate.fromDate(AbstractDate date) =>
      IslamicDate.fromJdn(date.toJdn());

  factory IslamicDate.fromJdn(int jdn) {
    final adjustedJdn = jdn + islamicOffset;
    final t =
        (useUmmAlQura
            ? UmmAlQuraConverter.fromJdn(adjustedJdn)
            : IranianIslamicDateConverter.fromJdn(adjustedJdn)) ??
        FallbackIslamicConverter.fromJdn(adjustedJdn);
    return IslamicDate(t.year, t.month, t.dayOfMonth);
  }

  @override
  int toJdn() {
    final tableResult = useUmmAlQura
        ? UmmAlQuraConverter.toJdn(year, month, dayOfMonth)
        : IranianIslamicDateConverter.toJdn(year, month, dayOfMonth);
    return tableResult != -1
        ? tableResult - islamicOffset
        : FallbackIslamicConverter.toJdn(year, month, dayOfMonth) -
              islamicOffset;
  }

  @override
  IslamicDate monthStartOfMonthsDistance(int monthsDistance) =>
      TwelveMonthsYear.monthStartOfMonthsDistance<IslamicDate>(
        this,
        monthsDistance,
        (y, m, d) => IslamicDate(y, m, d),
      );

  @override
  int monthsDistanceTo(IslamicDate date) =>
      TwelveMonthsYear.monthsDistanceTo(this, date);

  @override
  String toString() => 'IslamicDate($year, $month, $dayOfMonth)';

  // Converters
  static bool useUmmAlQura = false;
  static int islamicOffset = 0;
}
