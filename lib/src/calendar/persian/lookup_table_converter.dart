// Ported from io.github.persiancalendar.calendar.persian.LookupTableConverter
// (Kotlin)
//
// A simple and quick implementation just to be compatible with
// https://calendar.ut.ac.ir/Fa/News/Data/Doc/KabiseShamsi1206-1498-new.pdf
// For a correct implementation accurate for ~9k years, have a look at
// util/calendrical_calculations.dart (the astronomical converter), which
// also matches the numbers here for IRST longitude.
import '../date_triplet.dart';
import '../persian_date.dart';

class LookupTableConverter {
  LookupTableConverter._();

  static const int _startingYear = 1304;

  static final List<int> _yearsStartingJdn = _buildYearsStartingJdn();

  static List<int> _buildYearsStartingJdn() {
    final leapYears = [
      // 1210, 1214, 1218, 1222, 1226, 1230, 1234, 1238, 1243, 1247, 1251,
      // 1255, 1259, 1263, 1267, 1271, 1276, 1280, 1284, 1288, 1292, 1296,
      // 1300,
      1304, 1309, 1313, 1317, 1321, 1325, 1329, 1333, 1337, 1342, 1346, 1350,
      1354, 1358, 1362, 1366, 1370, 1375, 1379, 1383, 1387, 1391, 1395, 1399,
      1403, 1408, 1412, 1416, 1420, 1424, 1428, 1432, 1436, 1441, 1445, 1449,
      1453, 1457, 1461, 1465, 1469, 1474, 1478, 1482, 1486, 1490, 1494, 1498,
    ];
    final yearsStartingJdn = List<int>.filled(1498 - _startingYear, 0);
    yearsStartingJdn[0] = 2424231; // jdn of 1304
    var i = 0;
    var j = 0;
    while (i < yearsStartingJdn.length - 1) {
      final year = i + _startingYear;
      yearsStartingJdn[i + 1] =
          yearsStartingJdn[i] + (leapYears[j] == year ? 366 : 365);
      if (year >= leapYears[j] && j + 1 < leapYears.length) j++;
      i++;
    }
    return yearsStartingJdn;
  }

  static int toJdn(int year, int month, int day) {
    if (year < _startingYear ||
        year > _startingYear + _yearsStartingJdn.length - 1) {
      return -1;
    }
    return _yearsStartingJdn[year - _startingYear] +
        PersianDate.daysInPreviousMonths(month) +
        day -
        1;
  }

  static DateTriplet? fromJdn(int jdn) {
    if (jdn < _yearsStartingJdn[0] ||
        jdn > _yearsStartingJdn[_yearsStartingJdn.length - 1]) {
      return null;
    }
    var year = (jdn - _yearsStartingJdn[0]) ~/ 366;
    while (year < _yearsStartingJdn.length - 1) {
      if (jdn < _yearsStartingJdn[year + 1]) break;
      year++;
    }
    final startOfYearJdn = _yearsStartingJdn[year];
    year += _startingYear;
    final dayOfYear = (jdn - startOfYearJdn) + 1;
    final month = PersianDate.monthFromDaysCount(dayOfYear);
    final day = dayOfYear - PersianDate.daysInPreviousMonths(month);
    return DateTriplet(year: year, month: month, dayOfMonth: day);
  }
}
