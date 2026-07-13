// Ported from io.github.persiancalendar.calendar.DateTriplet (Kotlin)
//
// NOTE ON PORTING: the Kotlin original is a `@JvmInline value class` that packs
// year/month/day into a single 32-bit Int (16 bits + 8 bits + 8 bits) purely as
// a JVM allocation-avoidance trick. Dart has no equivalent inline value-class
// mechanism, so this is a plain immutable class instead. This does not change
// any calendar math -- it only changes how the three numbers are stored -- and
// it also removes the Kotlin version's implicit requirement that year fit in a
// signed 16-bit range and month/day fit in a signed 8-bit range.
class DateTriplet {
  final int year;
  final int month;
  final int dayOfMonth;

  const DateTriplet({
    required this.year,
    required this.month,
    required this.dayOfMonth,
  });

  @override
  String toString() => '(year=$year, month=$month, dayOfMonth=$dayOfMonth)';

  @override
  bool operator ==(Object other) =>
      other is DateTriplet &&
      year == other.year &&
      month == other.month &&
      dayOfMonth == other.dayOfMonth;

  @override
  int get hashCode => Object.hash(year, month, dayOfMonth);
}
