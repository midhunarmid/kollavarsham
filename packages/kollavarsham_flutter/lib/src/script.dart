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
