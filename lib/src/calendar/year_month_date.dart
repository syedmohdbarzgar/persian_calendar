// Ported from io.github.persiancalendar.calendar.YearMonthDate (Kotlin)
import 'abstract_date.dart';

abstract class YearMonthDate<T extends AbstractDate> {
  // Ideally year/month/dayOfMonth also should be moved to this interface
  T monthStartOfMonthsDistance(int monthsDistance);
  int monthsDistanceTo(T date);
}
