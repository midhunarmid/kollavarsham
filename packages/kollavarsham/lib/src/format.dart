import 'malayalam_date.dart';
import 'names.dart';
import 'numerals.dart';
import 'pattern.dart';

/// Era names: `G` (short) and `GGGG` (long).
const _eraShort = {
  MalayalamScript.malayalam: 'കൊ.വ.',
  MalayalamScript.english: 'ME',
};
const _eraLong = {
  MalayalamScript.malayalam: 'കൊല്ലവർഷം',
  MalayalamScript.english: 'Kollavarsham',
};

/// Short (`G`) and long (`GGGG`) era names in every script, for parsing.
Iterable<String> get eraNames => [..._eraShort.values, ..._eraLong.values];

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

  for (final token in tokenizePattern(pattern)) {
    if (token.isLiteral) {
      out.write(token.literal);
      continue;
    }
    final run = token.count;
    switch (token.letter) {
      case 'y':
        out.write(number(date.year, run == 2 ? 2 : 1));
      case 'M':
        out.write(switch (run) {
          >= 4 => date.month.name(script),
          3 => date.month.shortName(script),
          _ => number(date.month.number, run),
        });
      case 'd':
        out.write(number(date.day, run));
      case 'E':
        out.write(run >= 4
            ? date.weekday.name(script)
            : date.weekday.shortName(script));
      case 'N':
        out.write(date.nakshatra.name(script));
      case 'T':
        out.write(date.tithi.name(script));
      case 'P':
        out.write(date.tithi.paksha.name(script));
      case 'G':
        out.write((run >= 4 ? _eraLong : _eraShort)[script]);
    }
  }
  return out.toString();
}
