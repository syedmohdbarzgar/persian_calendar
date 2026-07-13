import 'package:persian_calendar/persian_calendar.dart';

void main() {
  print('═══════════════════════════════════════════');
  print('  دریافت عدد ژولیانی (JDN) از سیستم');
  print('═══════════════════════════════════════════');

  // ۱. دریافت تاریخ فعلی از سیستم عامل
  final now = DateTime.now();
  final civilToday = CivilDate(now.year, now.month, now.day);
  final jdnToday = civilToday.toJdn();

  print('تاریخ میلادی امروز: $civilToday');
  print('➡️  عدد ژولیانی (JDN) امروز: $jdnToday');
  print('───────────────────────────────────────────');

  // ۲. تبدیل JDN به تقویم‌های دیگر
  final persianToday = PersianDate.fromJdn(jdnToday);
  final islamicToday = IslamicDate.fromJdn(jdnToday);
  final nepaliToday = NepaliDate.fromJdn(jdnToday);

  print('➡️  معادل شمسی (Jalali): $persianToday');
  print('➡️  معادل قمری (Islamic): $islamicToday');
  print('➡️  معادل نپالی (Bikram Sambat): $nepaliToday');
  print('───────────────────────────────────────────');

  // ۳. تغییر تنظیمات تقویم قمری و مشاهده‌ی تفاوت
  print('🔄 تغییر حالت تقویم قمری به Umm al-Qura...');
  IslamicDate.useUmmAlQura = true;
  final islamicUmmAlQura = IslamicDate.fromJdn(jdnToday);
  print('➡️  قمری (Umm al-Qura): $islamicUmmAlQura');

  print('───────────────────────────────────────────');

  // ۴. مثال از محاسبه‌ی فاصله‌ی ماه‌ها بین دو تاریخ شمسی
  print('═══════════════════════════════════════════');
  print('  محاسبه‌ی فاصله‌ی ماه‌ها و شروع ماه');
  print('═══════════════════════════════════════════');

  final startDate = PersianDate(1404, 1, 1); // ۱ فروردین ۱۴۰۴
  final endDate = PersianDate(1404, 12, 1); // ۱ اسفند ۱۴۰۴
  final monthsDiff = startDate.monthsDistanceTo(endDate);

  print('تاریخ شروع: $startDate');
  print('تاریخ پایان: $endDate');
  print('➡️  فاصله‌ی ماه‌ها: $monthsDiff ماه');

  // ۵. پیدا کردن شروع ماه بعد از چند ماه
  final futureMonthStart = startDate.monthStartOfMonthsDistance(6);
  print('➡️  شروع ماه ششم بعد از شروع: $futureMonthStart');

  print('───────────────────────────────────────────');
  print('✅ پایان اجرای نمونه.');
}
