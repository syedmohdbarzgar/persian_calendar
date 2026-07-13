# Persian Calendar for Dart

A powerful Dart library for working with multiple calendar systems, including Persian (Jalali), Gregorian, Islamic (Hijri), and Nepali (Bikram Sambat) calendars.

This library provides accurate date conversion and calendar calculations using Julian Day Number (JDN) as the common conversion layer between calendar systems.

---

## Features

* ✅ Persian (Jalali / Solar Hijri) calendar support
* ✅ Gregorian calendar support
* ✅ Islamic (Hijri) calendar support

  * Umm al-Qura calculation method
  * Iranian tabular calculation method
* ✅ Nepali (Bikram Sambat) calendar support
* ✅ Conversion between different calendar systems
* ✅ Julian Day Number (JDN) based calculations
* ✅ Date comparison and distance calculations
* ✅ Month-based date operations
* ✅ Pure Dart implementation
* ✅ Tested conversion algorithms

---

## Supported Calendars

| Calendar      | Description                             |
| ------------- | --------------------------------------- |
| `PersianDate` | Persian / Jalali / Solar Hijri calendar |
| `CivilDate`   | Gregorian calendar                      |
| `IslamicDate` | Islamic / Hijri calendar                |
| `NepaliDate`  | Nepali Bikram Sambat calendar           |

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  persian_calendar:
    git:
      url: https://github.com/syedmohdbarzgar/persian_calendar.git
```

Then run:

```bash
dart pub get
```

---

## Quick Start

### Import the library

```dart
import 'package:persian_calendar/persian_calendar.dart';
```

---

## Working with Gregorian Dates

```dart
void main() {
  final today = DateTime.now();

  final civilDate = CivilDate(
    today.year,
    today.month,
    today.day,
  );

  print(civilDate);
}
```

---

## Convert Gregorian Date to Julian Day Number

```dart
final civilDate = CivilDate(2025, 3, 21);

final jdn = civilDate.toJdn();

print(jdn);
```

---

## Convert JDN to Different Calendars

```dart
final persian = PersianDate.fromJdn(jdn);
final islamic = IslamicDate.fromJdn(jdn);
final nepali = NepaliDate.fromJdn(jdn);

print(persian);
print(islamic);
print(nepali);
```

---

## Convert Between Calendars

### Persian to Gregorian

```dart
final persianDate = PersianDate(1404, 1, 1);

final gregorianDate = CivilDate.fromDate(
  persianDate,
);

print(gregorianDate);
```

### Gregorian to Persian

```dart
final civilDate = CivilDate(2025, 3, 21);

final persianDate = PersianDate.fromDate(
  civilDate,
);

print(persianDate);
```

---

## Date Calculations

### Calculate Month Distance

```dart
final start = PersianDate(1404, 1, 1);
final end = PersianDate(1405, 1, 1);

final difference = start.monthsDistanceTo(end);

print(difference);
```

Output:

```
12
```

---

### Find Date After Several Months

```dart
final date = PersianDate(1404, 1, 15);

final result = date.monthStartOfMonthsDistance(3);

print(result);
```

---

# Islamic Calendar Configuration

The Islamic calendar supports two calculation modes.

## Umm al-Qura Mode (Default)

```dart
IslamicDate.useUmmAlQura = true;

final date = IslamicDate.fromJdn(jdn);
```

## Iranian Tabular Mode

```dart
IslamicDate.useUmmAlQura = false;

final date = IslamicDate.fromJdn(jdn);
```

---

# Architecture

The library uses a common abstract date model where each calendar implementation converts through Julian Day Number.

```
AbstractDate
     |
     ├── CivilDate
     |
     ├── PersianDate
     |
     ├── IslamicDate
     |
     └── NepaliDate
```

This design allows calendar conversions without directly coupling calendar implementations.

---

# API Overview

| Class           | Description                          |
| --------------- | ------------------------------------ |
| `AbstractDate`  | Base abstraction for calendar dates  |
| `CivilDate`     | Gregorian date implementation        |
| `PersianDate`   | Persian/Jalali date implementation   |
| `IslamicDate`   | Islamic/Hijri date implementation    |
| `NepaliDate`    | Nepali calendar implementation       |
| `YearMonthDate` | Interface for month-based operations |

---

# Project Structure

```
lib/
├── persian_calendar.dart
│
└── src/
    ├── calendar/
    │   ├── abstract_date.dart
    │   ├── civil_date.dart
    │   ├── persian_date.dart
    │   ├── islamic_date.dart
    │   ├── nepali_date.dart
    │   └── year_month_date.dart
    │
    └── util/
        └── calendar conversion utilities

test/
└── calendar_test.dart

example/
└── usage_example.dart
```

---

# Testing

The project includes tests to verify calendar calculations and conversions.

Run tests with:

```bash
dart test
```

---

# Supported Date Range

* Persian and Gregorian calendars support a wide range of dates.
* Nepali calendar support covers years from 1975 to 2199 Gregorian.

---

# References

This project is based on the original Kotlin implementation:

* Persian Calendar Kotlin Library
  https://github.com/persian-calendar/calendar

The conversion approach is based on Julian Day Number calculations, a standard method used for astronomical and calendar computations.

---

# Contributing

Contributions are welcome.

You can help by:

* Reporting bugs
* Suggesting improvements
* Opening issues
* Creating pull requests

Please ensure that changes include appropriate tests.

---

# License

This project is released under the:

**MIT license**

See the `LICENSE` file for more information.

---

# Acknowledgements

Special thanks to the original Kotlin implementation:

https://github.com/persian-calendar/calendar

for providing the foundation and algorithms used in this Dart port.
