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
  const MalayalamDateText({
    super.key,
    this.date,
    this.pattern = 'd MMMM y',
    this.script,
    this.malayalamDigits = false,
    this.style,
    this.textAlign,
  });

  final MalayalamDate? date;
  final String pattern;
  final MalayalamScript? script;
  final bool malayalamDigits;
  final TextStyle? style;
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
