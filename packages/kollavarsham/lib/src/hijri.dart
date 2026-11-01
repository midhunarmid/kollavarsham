import 'names.dart';

/// Muslim festivals observed in Kerala, by their Hijri date.
///
/// Dates from [hijriFestivalsIn] are tentative: the real dates follow the
/// sighting of the moon, so they can differ by a day or two.
enum HijriFestival {
  /// Muharram (Ashura), 10 Muharram.
  muharram('മുഹറം', 'Muharram', 1, 10),

  /// Milad-i-Sherif, 12 Rabi al-Awwal.
  miladISherif('മിലാദ് ഇ ഷെരീഫ്', 'Milad-i-Sherif', 3, 12),

  /// The first day of the fast, 1 Ramadan.
  ramadanStart('റമദാൻ ആരംഭം', 'Ramadan begins', 9, 1),

  /// Eid ul-Fitr (Ramzan), 1 Shawwal.
  eidUlFitr('ഈദുൽ ഫിത്ർ', 'Eid ul-Fitr', 10, 1),

  /// Bakrid (Eid ul-Adha), 10 Dhu al-Hijjah.
  bakrid('ബക്രീദ്', 'Bakrid', 12, 10);

  const HijriFestival(this.malayalam, this.english, this.month, this.day);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in English.
  final String english;

  /// The Hijri month, from 1 (Muharram) to 12 (Dhu al-Hijjah).
  final int month;

  /// The day of the Hijri month.
  final int day;

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}

/// The Gregorian date of a day in the tabular Hijri calendar: the civil
/// epoch (Friday, Julian day number 1948440) with leap years 2, 5, 7, 10,
/// 13, 16, 18, 21, 24, 26 and 29 of each 30-year cycle.
///
/// This is an arithmetic calendar, not the observed one.
DateTime tabularHijriToGregorian(int year, int month, int day) {
  final julianDay = day +
      (295 * (month - 1) + 9) ~/ 10 +
      (year - 1) * 354 +
      (3 + 11 * year) ~/ 30 +
      1948439;
  return DateTime(1970, 1, 1 + julianDay - 2440588);
}

/// Every [HijriFestival] falling in Gregorian [year], in date order, from
/// the tabular calendar. A festival can occur twice in a year, or not at all.
///
/// These dates are tentative; announced dates from holiday data replace
/// them.
List<(HijriFestival, DateTime)> hijriFestivalsIn(int year) {
  final firstHijriYear = (year - 622) * 33 ~/ 32 - 1;
  return [
    for (var hijri = firstHijriYear; hijri <= firstHijriYear + 3; hijri++)
      for (final festival in HijriFestival.values)
        if (tabularHijriToGregorian(hijri, festival.month, festival.day)
            case final date when date.year == year)
          (festival, date),
  ]..sort((a, b) => a.$2.compareTo(b.$2));
}
