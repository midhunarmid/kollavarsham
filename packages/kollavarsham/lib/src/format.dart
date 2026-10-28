import 'malayalam_date.dart';
import 'names.dart';
import 'numerals.dart';

const _patternLetters = {'y', 'M', 'd', 'E', 'N', 'T', 'P'};

/// Implements [MalayalamDate.format].
String formatMalayalamDate(
  MalayalamDate date,
  String pattern, {
  required MalayalamScript script,
  required bool malayalamDigits,
}) {
  final out = StringBuffer();
  String number(int value, int width) {
    final s = value.toString().padLeft(width, '0');
    return malayalamDigits ? toMalayalamDigits(s) : s;
  }

  var i = 0;
  while (i < pattern.length) {
    final ch = pattern[i];
    if (ch == "'") {
      // Quoted literal; '' inside or outside quotes is a single quote.
      if (i + 1 < pattern.length && pattern[i + 1] == "'") {
        out.write("'");
        i += 2;
        continue;
      }
      i++;
      while (i < pattern.length) {
        if (pattern[i] == "'") {
          if (i + 1 < pattern.length && pattern[i + 1] == "'") {
            out.write("'");
            i += 2;
            continue;
          }
          break;
        }
        out.write(pattern[i]);
        i++;
      }
      i++; // closing quote
      continue;
    }
    if (!_patternLetters.contains(ch)) {
      out.write(ch);
      i++;
      continue;
    }
    var run = 1;
    while (i + run < pattern.length && pattern[i + run] == ch) {
      run++;
    }
    i += run;
    switch (ch) {
      case 'y':
        out.write(number(date.year, run == 2 ? 2 : 1));
      case 'M':
        out.write(run >= 3
            ? date.month.name(script)
            : number(date.month.number, run));
      case 'd':
        out.write(number(date.day, run));
      case 'E':
        out.write(date.weekday.name(script));
      case 'N':
        out.write(date.nakshatra.name(script));
      case 'T':
        out.write(date.tithi.name(script));
      case 'P':
        out.write(date.tithi.paksha.name(script));
    }
  }
  return out.toString();
}
