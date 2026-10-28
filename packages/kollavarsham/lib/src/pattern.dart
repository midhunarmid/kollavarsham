/// A piece of a date pattern: either a run of one pattern letter
/// ([letter] repeated [count] times) or literal text.
class PatternToken {
  /// A run of [count] copies of the pattern [letter].
  const PatternToken.field(this.letter, this.count) : literal = null;

  /// Literal text.
  const PatternToken.literal(String this.literal)
      : letter = '',
        count = 0;

  /// The pattern letter, or '' for literal text.
  final String letter;

  /// How many times [letter] is repeated.
  final int count;

  /// The literal text, or `null` for a field.
  final String? literal;

  /// Whether this token is literal text.
  bool get isLiteral => literal != null;
}

/// Letters with a meaning in date patterns.
const patternLetters = {'y', 'M', 'd', 'E', 'N', 'T', 'P', 'G'};

/// Splits [pattern] into fields and literals. Text in single quotes is
/// literal, and `''` is a single quote.
List<PatternToken> tokenizePattern(String pattern) {
  final tokens = <PatternToken>[];
  final literal = StringBuffer();
  void flush() {
    if (literal.isNotEmpty) {
      tokens.add(PatternToken.literal(literal.toString()));
      literal.clear();
    }
  }

  var i = 0;
  while (i < pattern.length) {
    final ch = pattern[i];
    if (ch == "'") {
      if (i + 1 < pattern.length && pattern[i + 1] == "'") {
        literal.write("'");
        i += 2;
        continue;
      }
      i++;
      while (i < pattern.length) {
        if (pattern[i] == "'") {
          if (i + 1 < pattern.length && pattern[i + 1] == "'") {
            literal.write("'");
            i += 2;
            continue;
          }
          break;
        }
        literal.write(pattern[i]);
        i++;
      }
      i++; // closing quote
      continue;
    }
    if (!patternLetters.contains(ch)) {
      literal.write(ch);
      i++;
      continue;
    }
    var run = 1;
    while (i + run < pattern.length && pattern[i + run] == ch) {
      run++;
    }
    flush();
    tokens.add(PatternToken.field(ch, run));
    i += run;
  }
  flush();
  return tokens;
}
