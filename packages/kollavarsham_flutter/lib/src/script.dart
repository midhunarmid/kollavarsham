import 'package:flutter/widgets.dart';
import 'package:kollavarsham/kollavarsham.dart';

/// Picks the script for names: [explicit] if given, otherwise Malayalam
/// script when the ambient locale is Malayalam (`ml`), else English.
MalayalamScript resolveScript(BuildContext context, MalayalamScript? explicit) {
  if (explicit != null) return explicit;
  final locale = Localizations.maybeLocaleOf(context);
  return locale?.languageCode == 'ml'
      ? MalayalamScript.malayalam
      : MalayalamScript.english;
}

const _gregorianMonthsMl = [
  'ജനുവരി', 'ഫെബ്രുവരി', 'മാർച്ച്', 'ഏപ്രിൽ', 'മേയ്', 'ജൂൺ', //
  'ജൂലൈ', 'ഓഗസ്റ്റ്', 'സെപ്റ്റംബർ', 'ഒക്ടോബർ', 'നവംബർ', 'ഡിസംബർ',
];
const _gregorianMonthsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Short Gregorian month name (1-based [month]) in [script].
String gregorianMonthName(int month, MalayalamScript script) =>
    script == MalayalamScript.malayalam
        ? _gregorianMonthsMl[month - 1]
        : _gregorianMonthsEn[month - 1];

/// Formats an integer, optionally with Malayalam digits.
String formatNumber(int value, {required bool malayalamDigits}) =>
    malayalamDigits ? toMalayalamDigits(value) : value.toString();

/// The handful of interface strings used by the widgets, in both scripts.
class CalendarStrings {
  const CalendarStrings._(this.script);

  /// Strings for [script].
  factory CalendarStrings.of(MalayalamScript script) =>
      CalendarStrings._(script);

  /// The script the strings are in.
  final MalayalamScript script;

  bool get _ml => script == MalayalamScript.malayalam;

  /// Tooltip of the previous-month button.
  String get previousMonth => _ml ? 'മുൻ മാസം' : 'Previous month';

  /// Tooltip of the next-month button.
  String get nextMonth => _ml ? 'അടുത്ത മാസം' : 'Next month';

  /// Title of the month/year chooser.
  String get selectMonth => _ml ? 'മാസം തിരഞ്ഞെടുക്കുക' : 'Select month';

  /// Tooltip of the previous-year button.
  String get previousYear => _ml ? 'മുൻ വർഷം' : 'Previous year';

  /// Tooltip of the next-year button.
  String get nextYear => _ml ? 'അടുത്ത വർഷം' : 'Next year';

  /// Cancel button.
  String get cancel => _ml ? 'റദ്ദാക്കുക' : 'Cancel';

  /// Confirm button.
  String get ok => _ml ? 'ശരി' : 'OK';

  /// Accessibility label for a day with [count] events.
  String events(int count) => _ml
      ? '$count പരിപാടി${count == 1 ? '' : 'കൾ'}'
      : '$count event${count == 1 ? '' : 's'}';
}
