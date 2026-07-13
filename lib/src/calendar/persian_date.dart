// Ported from io.github.persiancalendar.calendar.PersianDate (Kotlin)
import 'abstract_date.dart';
import 'date_triplet.dart';
import 'persian/lookup_table_converter.dart';
import 'persian/old_era_converter.dart';
import 'util/calendrical_calculations.dart';
import 'util/twelve_months_year.dart';
import 'year_month_date.dart';

class PersianDate extends AbstractDate implements YearMonthDate<PersianDate> {
  PersianDate(super.year, super.month, super.dayOfMonth);

  factory PersianDate.fromDate(AbstractDate date) =>
      PersianDate.fromJdn(date.toJdn());

  factory PersianDate.fromJdn(int jdn) {
    final t =
        LookupTableConverter.fromJdn(jdn) ??
        OldEraConverter.fromJdn(jdn) ??
        persianFromJdn(jdn);
    return PersianDate(t.year, t.month, t.dayOfMonth);
  }

  // Converters
  @override
  int toJdn() {
    var result = LookupTableConverter.toJdn(year, month, dayOfMonth);
    if (result == -1) result = OldEraConverter.toJdn(year, month, dayOfMonth);
    if (result == -1) result = jdnFromPersian(year, month, dayOfMonth);
    return result;
  }

  @override
  PersianDate monthStartOfMonthsDistance(int monthsDistance) =>
      TwelveMonthsYear.monthStartOfMonthsDistance<PersianDate>(
        this,
        monthsDistance,
        (y, m, d) => PersianDate(y, m, d),
      );

  @override
  int monthsDistanceTo(PersianDate date) =>
      TwelveMonthsYear.monthsDistanceTo(this, date);

  @override
  String toString() => 'PersianDate($year, $month, $dayOfMonth)';

  // This is always Borji (old era) and never new era's fixed months days
  static DateTriplet borjiFromJdn(int jdn) =>
      OldEraConverter.fromJdn(jdn) ?? persianFromJdn(jdn, alwaysBorji: true);

  // First six months have length of 31, next 5 months are 30 and the last
  // month is 29 and in leap years are 30.
  //
  // NOTE ON PORTING: Kotlin's `internal` visibility (visible package-wide,
  // hidden outside the module) has no exact Dart equivalent -- Dart privacy
  // is per-file, not per-package -- so these are plain public members here
  // (needed since persian/lookup_table_converter.dart and
  // persian/old_era_converter.dart both call them). They are simply not
  // re-exported from the package's main library file.
  static const List<int> daysToMonth = [
    0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336, 366, //
  ];

  static int monthFromDaysCount(int days) =>
      daysToMonth.indexWhere((v) => v >= days);

  static int daysInPreviousMonths(int month) => daysToMonth[month - 1];
}
