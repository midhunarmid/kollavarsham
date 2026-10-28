import 'calendar.dart';
import 'format.dart' show eraNames;
import 'malayalam_date.dart';
import 'names.dart';
import 'numerals.dart';
import 'pattern.dart';

String _alternation(Iterable<String> names) {
  final sorted = names.toSet().toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  return sorted.map(RegExp.escape).join('|');
}

/// Implements [MalayalamDate.parse] and [MalayalamDate.tryParse]: returns
/// the date, or a [FormatException] describing why [input] did not match.
Object parseMalayalamDate(
  String input,
  String pattern,
  KollavarshamCalendar calendar,
) {
  final groups = <String>[];
  final regex = StringBuffer(r'^\s*');
  for (final token in tokenizePattern(pattern)) {
    if (token.isLiteral) {
      // Any run of whitespace in the pattern matches any run in the input.
      var inSpace = false;
      for (final ch in token.literal!.split('')) {
        final space = ch.trim().isEmpty;
        if (space && !inSpace) regex.write(r'\s+');
        if (!space) regex.write(RegExp.escape(ch));
        inSpace = space;
      }
      continue;
    }
    switch (token.letter) {
      case 'y':
        groups.add('y');
        regex.write(r'(\d{1,4})');
      case 'M' when token.count >= 3:
        groups.add('MMMM');
        regex.write('(${_alternation(MalayalamMonth.allNames)})');
      case 'M':
        groups.add('M');
        regex.write(r'(\d{1,2})');
      case 'd':
        groups.add('d');
        regex.write(r'(\d{1,2})');
      case 'E':
        regex.write('(?:${_alternation(MalayalamWeekday.allNames)})');
      case 'G':
        regex.write('(?:${_alternation(eraNames)})');
      default:
        return FormatException(
            "Pattern letter '${token.letter}' cannot be parsed", pattern);
    }
  }
  regex.write(r'\s*$');

  final normalized = normalizeMalayalam(fromMalayalamDigits(input));
  final match = RegExp(regex.toString(), caseSensitive: false, unicode: true)
      .firstMatch(normalized);
  if (match == null) {
    return FormatException('Does not match pattern "$pattern"', input);
  }

  int? year, day;
  MalayalamMonth? month;
  for (var i = 0; i < groups.length; i++) {
    final text = match.group(i + 1)!;
    switch (groups[i]) {
      case 'y':
        year = int.parse(text);
      case 'd':
        day = int.parse(text);
      case 'M':
        final n = int.parse(text);
        if (n < 1 || n > 12) {
          return FormatException('Month number out of range', input);
        }
        month = MalayalamMonth.fromNumber(n);
      case 'MMMM':
        month = MalayalamMonth.tryParseName(text);
    }
  }
  if (year == null || month == null || day == null) {
    return FormatException(
        'Pattern "$pattern" must contain a year, month and day', pattern);
  }
  try {
    return MalayalamDate(year, month, day, calendar: calendar);
  } on RangeError catch (e) {
    return FormatException(e.message?.toString() ?? 'Invalid date', input);
  }
}
