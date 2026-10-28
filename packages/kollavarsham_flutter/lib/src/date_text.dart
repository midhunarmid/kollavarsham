import 'package:flutter/widgets.dart';
import 'package:kollavarsham/kollavarsham.dart';

import 'script.dart';

/// Displays a Malayalam date formatted with [pattern]
/// (see [MalayalamDate.format]). Shows today's date if [date] is null.
///
/// ```dart
/// MalayalamDateText(pattern: 'd MMMM y, NNNN')
/// ```
class MalayalamDateText extends StatelessWidget {
  /// Creates a text widget showing [date] (today if null).
  const MalayalamDateText({
    super.key,
    this.date,
    this.pattern = 'd MMMM y',
    this.script,
    this.malayalamDigits = false,
    this.style,
    this.textAlign,
  });

  /// The date to show; today (in IST) if null.
  final MalayalamDate? date;

  /// Format pattern; see [MalayalamDate.format].
  final String pattern;

  /// Script for names. Defaults to the ambient locale.
  final MalayalamScript? script;

  /// Render numbers with Malayalam digits (൧൨൩).
  final bool malayalamDigits;

  /// Text style.
  final TextStyle? style;

  /// Text alignment.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
        (date ?? MalayalamDate.today()).format(pattern,
            script: resolveScript(context, script),
            malayalamDigits: malayalamDigits),
        style: style,
        textAlign: textAlign,
      );
}
