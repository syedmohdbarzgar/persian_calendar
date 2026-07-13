// Ported from io.github.persiancalendar.calendar.persian.AfghanSolarCalendar
// (Kotlin). Not currently referenced by any other file in the library (same
// as in the Kotlin original) -- kept for structural fidelity with the source
// repository.
// https://iranicaonline.org/uploads/files/Calendars/v4f6a073_t20_300.jpg
const List<List<int>> months = [
  // Lunar 1322 -> 1283
  // [31, 30, 32, 31, 31, 32, 30, 30, 29, 30, 29, 30],
  // 1312
  [31, 31, 31, 31, 32, 31, 30, 30, 29, 30, 29, 30],
  // 1313
  [31, 31, 31, 32, 31, 31, 31, 30, 29, 29, 30, 30],
  // 1314
  [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  // 1315
  [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 29, 30],
  // 1316
  [31, 31, 31, 32, 31, 31, 30, 30, 29, 29, 30, 30],
  // 1317
  [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
  // from this point just use the modern variant of months, 1336
  // [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29],
];
