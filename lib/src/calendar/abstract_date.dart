// Ported from io.github.persiancalendar.calendar.AbstractDate (Kotlin)
//
// NOTE ON PORTING: the Kotlin original has a `constructor(jdn: Long)` that
// calls the (still-abstract-at-that-point) `fromJdn` method on `this` to fill
// in year/month/day. Dart does not support overloaded/unnamed constructors
// the way Kotlin does, and giving a named constructor the same name as an
// instance method is not legal in Dart, so each subclass below instead
// exposes a `factory ClassName.fromJdn(int jdn)` constructor that calls a
// free conversion function directly. The resulting values, field names, and
// public API (`toJdn()`, equality, `toString()`) are unchanged; only the
// Kotlin-specific "protected abstract fromJdn" indirection is gone.

/// Abstract class representing a date.
abstract class AbstractDate {
  // Concrete things
  final int year;
  final int month;
  final int dayOfMonth;

  const AbstractDate(this.year, this.month, this.dayOfMonth);

  /* What JDN (Julian Day Number) means?
   *
   * From https://en.wikipedia.org/wiki/Julian_day:
   * Julian day is the continuous count of days since the beginning of the
   * Julian Period and is used primarily by astronomers, and in software for
   * easily calculating elapsed days between two events (e.g. food production
   * date and sell by date).
   */

  // Things needed to be implemented by subclasses
  int toJdn();

  @override
  bool operator ==(Object other) {
    if (other is! AbstractDate || other.runtimeType != runtimeType) {
      return false;
    }
    return year == other.year &&
        month == other.month &&
        dayOfMonth == other.dayOfMonth;
  }

  @override
  int get hashCode {
    var result = year;
    result = 31 * result + month;
    result = 31 * result + dayOfMonth;
    return result;
  }
}
