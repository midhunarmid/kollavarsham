import 'package:kollavarsham/kollavarsham.dart';

void main() {
  // Today's Malayalam date (in IST).
  final today = MalayalamDate.today();
  print(today.format('d MMMM y, EEEE')); // e.g. 11 തുലാം 1202, ബുധൻ
  print(today.format('d MMMM y', script: MalayalamScript.english));

  // Gregorian → Malayalam.
  final date = DateTime(2025, 8, 17).toMalayalamDate();
  print(date); // 1201 Chingam 1

  // Malayalam → Gregorian.
  final vishu = MalayalamDate(1201, MalayalamMonth.medam, 1).toGregorian();
  print('Vishu 1201: $vishu');

  // Month details.
  final cal = KollavarshamCalendar.standard;
  for (final month in MalayalamMonth.values) {
    print('${month.malayalam.padRight(10)} '
        '${cal.monthStart(1201, month).toIso8601String().split('T').first} '
        '${cal.monthLength(1201, month)} days');
  }

  // Malayalam numerals.
  print(today.format('d MMMM y', malayalamDigits: true));
}
