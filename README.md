[![pub version](https://img.shields.io/pub/v/persian_calendar.svg)](https://pub.dev/packages/persian_calendar)

# 📅 کتابخانه‌ی تقویم فارسی (Dart)

یک کتابخانه‌ی کامل و دقیق برای تبدیل و محاسبه‌ی تقویم‌های مختلف در زبان Dart. این کتابخانه از روی نسخه‌ی [persian-calendar/calendar](https://github.com/persian-calendar/calendar) که به زبان کاتلین نوشته شده، به دارت منتقل شده است.

---

## ✨ چه تقویم‌هایی را پشتیبانی می‌کند؟

- **تقویم شمسی (جلالی / خورشیدی)** – همان تقویم رسمی ایران و افغانستان
- **تقویم میلادی (گریگوری)** – تقویم رسمی بیشتر کشورهای جهان
- **تقویم قمری (هجری)** – با دو روش محاسبه: جدول ایرانی و ام‌القرا
- **تقویم نپالی (بیکرام سامبت)** – تقویم رسمی نپال

همه‌ی این تقویم‌ها با استفاده از **عدد ژولیانی (JDN)** به هم تبدیل می‌شوند. عدد ژولیانی یعنی تعداد روزهایی که از یک نقطه‌ی مشخص در گذشته گذشته است.

---

## 📦 نصب

فایل `pubspec.yaml` را باز کنید و این خط را به قسمت `dependencies` اضافه کنید:

```yaml
dependencies:
  persian_calendar:
    git:
      url: https://github.com/your-username/persian_calendar.git
```

بعد دستور زیر را اجرا کنید:

```bash
dart pub get
```

---

## 🚀 شروع سریع

### ۱. گرفتن تاریخ امروز از سیستم و تبدیل به عدد ژولیانی

```dart
import 'package:persian_calendar/persian_calendar.dart';

void main() {
  // گرفتن تاریخ امروز از سیستم
  final now = DateTime.now();
  final civilToday = CivilDate(now.year, now.month, now.day);
  
  // تبدیل به عدد ژولیانی
  final jdnToday = civilToday.toJdn();
  print('عدد ژولیانی امروز: $jdnToday');
}
```

### ۲. تبدیل عدد ژولیانی به تقویم‌های مختلف

```dart
// تبدیل به شمسی
final persian = PersianDate.fromJdn(jdnToday);
print('تاریخ شمسی امروز: $persian');

// تبدیل به قمری
final islamic = IslamicDate.fromJdn(jdnToday);
print('تاریخ قمری امروز: $islamic');

// تبدیل به نپالی
final nepali = NepaliDate.fromJdn(jdnToday);
print('تاریخ نپالی امروز: $nepali');
```

### ۳. تبدیل مستقیم بین تقویم‌ها

```dart
// از شمسی به میلادی
final persianNow = PersianDate(1404, 1, 1);
final civilEquivalent = CivilDate.fromDate(persianNow);
print('معادل میلادی: $civilEquivalent');

// از میلادی به شمسی
final civilNow = CivilDate(2025, 3, 21);
final persianEquivalent = PersianDate.fromDate(civilNow);
print('معادل شمسی: $persianEquivalent');
```

### ۴. محاسبه‌ی فاصله‌ی ماه‌ها بین دو تاریخ

```dart
final start = PersianDate(1404, 1, 1);  // اول فروردین ۱۴۰۴
final end = PersianDate(1405, 1, 1);    // اول فروردین ۱۴۰۵
final monthsDiff = start.monthsDistanceTo(end);
print('فاصله: $monthsDiff ماه');  // خروجی: ۱۲
```

### ۵. پیدا کردن شروع ماه بعد از چند ماه

```dart
final start = PersianDate(1404, 1, 15);
final monthStart = start.monthStartOfMonthsDistance(3);
print('شروع ماه سوم بعد: $monthStart');  // ۱۴۰۴/۴/۱
```

---

## 🔧 تنظیمات تقویم قمری

تقویم قمری دو حالت دارد که می‌توانید انتخاب کنید:

```dart
// حالت ام‌القرا (پیش‌فرض)
IslamicDate.useUmmAlQura = true;
final islamic1 = IslamicDate.fromJdn(jdnToday);

// حالت جدول ایرانی
IslamicDate.useUmmAlQura = false;
final islamic2 = IslamicDate.fromJdn(jdnToday);
```

---

## 🧪 اجرای تست‌ها

برای اطمینان از درست کار کردن کتابخانه، تست‌هایی نوشته شده است. برای اجرای آنها:

```bash
dart test
```

---

## 📂 ساختار پروژه

```
lib/
├── persian_calendar.dart          # فایل اصلی (همه‌ی کلاس‌ها از اینجا در دسترس است)
├── src/
│   ├── calendar/
│   │   ├── abstract_date.dart     # کلاس پایه
│   │   ├── civil_date.dart        # تاریخ میلادی
│   │   ├── persian_date.dart      # تاریخ شمسی
│   │   ├── islamic_date.dart      # تاریخ قمری
│   │   ├── nepali_date.dart       # تاریخ نپالی
│   │   └── year_month_date.dart   # رابط (interface) برای عملیات ماه
│   └── util/                      # فرمول‌های اصلی تبدیل
test/
└── calendar_test.dart              # تست‌ها
example/
└── usage_example.dart              # مثال کامل
```

---

## ❓ سوالات متداول

**۱. آیا این کتابخانه با نسخه‌ی کاتلین فرق دارد؟**  
از نظر محاسبات و نتیجه‌ی نهایی هیچ فرقی ندارد. فقط کد به گونه‌ای بازنویسی شده که با قوانین زبان دارت هماهنگ باشد.

**۲. عدد ژولیانی دقیقاً چیست؟**  
یک عدد است که تعداد روزهای گذشته از یک مبدأ مشخص را نشان می‌دهد. دانشمندان و برنامه‌نویسان از آن برای تبدیل دقیق تاریخ‌ها استفاده می‌کنند.

**۳. محدوده‌ی سال‌های پشتیبانی شده چقدر است؟**  
- تقویم شمسی و میلادی محدودیت خاصی ندارند  
- تقویم نپالی از سال ۱۹۷۵ تا ۲۱۹۹ میلادی را پشتیبانی می‌کند  

---

## 📄 مجوز

این کتابخانه تحت مجوز **GPL-2.0-only** منتشر شده است.

---

## 🤝 مشارکت

اگر مشکل یا پیشنهادی دارید، خوشحال می‌شویم که Issue یا Pull Request شما را ببینیم.

---

## 🌐 منبع اصلی

نسخه‌ی اصلی این کتابخانه به زبان کاتلین در این آدرس قرار دارد:  
[https://github.com/persian-calendar/calendar](https://github.com/persian-calendar/calendar)

---

**اگر از این کتابخانه استفاده می‌کنید، خوشحال می‌شویم که به ما ⭐ دهید!**