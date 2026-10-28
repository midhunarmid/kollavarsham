const int _malayalamZero = 0x0D66;
const int _asciiZero = 0x30;

/// Replaces ASCII digits in [input] with Malayalam digits (൦–൯).
///
/// ```dart
/// toMalayalamDigits(1202); // '൧൨൦൨'
/// ```
String toMalayalamDigits(Object input) => String.fromCharCodes(
      input.toString().codeUnits.map((c) =>
          c >= _asciiZero && c <= _asciiZero + 9
              ? c - _asciiZero + _malayalamZero
              : c),
    );

/// Replaces Malayalam digits (൦–൯) in [input] with ASCII digits.
String fromMalayalamDigits(String input) => String.fromCharCodes(
      input.codeUnits.map((c) => c >= _malayalamZero && c <= _malayalamZero + 9
          ? c - _malayalamZero + _asciiZero
          : c),
    );
