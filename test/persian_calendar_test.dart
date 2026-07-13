import 'package:persian_calendar/persian_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('تست‌های تبدیلات پایه', () {
    test('تبدیل JDN به CivilDate و برعکس', () {
      final jdn = 2460000;
      final civil = CivilDate.fromJdn(jdn);
      expect(civil.toJdn(), equals(jdn));
    });

    test('تبدیل JDN به PersianDate و برعکس', () {
      final jdn = 2460000;
      final persian = PersianDate.fromJdn(jdn);
      expect(persian.toJdn(), equals(jdn));
    });

    test('تبدیل JDN به IslamicDate (Umm al-Qura)', () {
      IslamicDate.useUmmAlQura = true;
      final jdn = 2460000;
      final islamic = IslamicDate.fromJdn(jdn);
      expect(islamic.toJdn(), equals(jdn));
    });

    test('تبدیل JDN به IslamicDate (جدول ایرانی)', () {
      IslamicDate.useUmmAlQura = false;
      final jdn = 2460000;
      final islamic = IslamicDate.fromJdn(jdn);
      expect(islamic.toJdn(), equals(jdn));
    });

    test('تبدیل JDN به NepaliDate', () {
      final jdn = 2421697; // شروع بازه‌ی پشتیبانی نپال
      final nepali = NepaliDate.fromJdn(jdn);
      expect(nepali.toJdn(), equals(jdn));
    });
  });

  group('تست‌های عملیات فاصله و جابه‌جایی ماه', () {
    test('فاصله‌ی ماه‌ها بین دو تاریخ شمسی', () {
      final d1 = PersianDate(1400, 1, 1);
      final d2 = PersianDate(1400, 6, 1);
      expect(d1.monthsDistanceTo(d2), equals(5));
    });

    test('شروع ماه بعد از ۳ ماه فاصله', () {
      final d1 = PersianDate(1400, 1, 15);
      final result = d1.monthStartOfMonthsDistance(3);
      // باید برابر با 1400/4/1 باشد
      expect(result.year, equals(1400));
      expect(result.month, equals(4));
      expect(result.dayOfMonth, equals(1));
    });
  });

  group('تست دریافت JDN از تاریخ سیستم', () {
    test('گرفتن JDN لحظه‌ی حال از DateTime.now()', () {
      // ۱. دریافت تاریخ امروز از سیستم
      final now = DateTime.now();

      // ۲. ساخت شیء CivilDate (میلادی)
      final civilNow = CivilDate(now.year, now.month, now.day);

      // ۳. دریافت عدد ژولیانی (JDN)
      final jdnNow = civilNow.toJdn();

      // ۴. بررسی اینکه JDN یک عدد معتبر (بزرگتر از صفر) باشد
      expect(jdnNow, greaterThan(0));

      // ۵. (اختیاری) چاپ در کنسول هنگام اجرای تست
      print('JDN فعلی سیستم (از تست): $jdnNow');
      print('تاریخ میلادی فعلی: $civilNow');

      // ۶. تبدیل به شمسی برای اطمینان از صحت تبدیل
      final persianNow = PersianDate.fromJdn(jdnNow);
      print('تاریخ شمسی فعلی: $persianNow');

      // اطمینان از اینکه JDN برگشتی با JDN ورودی یکی است
      expect(persianNow.toJdn(), equals(jdnNow));
    });
  });
}
