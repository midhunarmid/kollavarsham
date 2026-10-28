/// Malayalam calendar (Kollavarsham / Malayalam Era) for Dart.
///
/// Convert between Gregorian and Malayalam dates, get month and weekday
/// names in Malayalam script or transliteration, and format dates.
///
/// ```dart
/// import 'package:kollavarsham/kollavarsham.dart';
///
/// final today = MalayalamDate.today();
/// print(today.format('d MMMM y, EEEE'));
/// ```
library;

export 'src/calendar.dart' show KollavarshamCalendar, ObserverLocation;
export 'src/malayalam_date.dart' show MalayalamDate, DateTimeToMalayalam;
export 'src/names.dart' show MalayalamMonth, MalayalamWeekday, MalayalamScript;
export 'src/numerals.dart' show toMalayalamDigits, fromMalayalamDigits;
