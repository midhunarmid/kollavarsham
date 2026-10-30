/// Malayalam calendar (Kollavarsham / Malayalam Era) for Dart.
///
/// Convert between Gregorian and Malayalam dates, get month and weekday
/// names in Malayalam script or transliteration, nakshatra and tithi,
/// festival dates, and format dates.
///
/// ```dart
/// import 'package:kollavarsham/kollavarsham.dart';
///
/// final today = MalayalamDate.today();
/// print(today.format('d MMMM y, EEEE'));
/// ```
library;

export 'src/birth_details.dart' show BirthDetails;
export 'src/calendar.dart'
    show KollavarshamCalendar, ObserverLocation, YearStart;
export 'src/festivals.dart' show KeralaFestival, KeralaFestivals;
export 'src/malayalam_date.dart' show MalayalamDate, DateTimeToMalayalam;
export 'src/names.dart' show MalayalamMonth, MalayalamWeekday, MalayalamScript;
export 'src/numerals.dart' show toMalayalamDigits, fromMalayalamDigits;
export 'src/panchanga.dart'
    show Kalam, Karana, Nakshatra, Paksha, PanchangaSpan, Rashi, Tithi, Yoga;
export 'src/recurrence.dart'
    show
        AbsentRule,
        DuplicateRule,
        GregorianYearly,
        MalayalamDateMonthly,
        MalayalamDateYearly,
        NakshatraInMonth,
        NakshatraMonthly,
        Recurrence,
        TithiEveryPaksha,
        TithiInMonth;
