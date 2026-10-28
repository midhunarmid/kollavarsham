import 'package:flutter/material.dart';
import 'package:kollavarsham/kollavarsham.dart';

import 'month_view.dart';
import 'script.dart';

/// Shows a dialog for picking a date on the Malayalam calendar.
///
/// Returns the chosen date, or `null` if the dialog was dismissed.
///
/// ```dart
/// final date = await showMalayalamDatePicker(context: context);
/// ```
Future<MalayalamDate?> showMalayalamDatePicker({
  required BuildContext context,
  MalayalamDate? initialDate,
  MalayalamDate? firstDate,
  MalayalamDate? lastDate,
  MalayalamScript? script,
  bool malayalamDigits = false,
  bool showNakshatra = false,
  KollavarshamCalendar? calendar,
  String? confirmText,
  String? cancelText,
}) =>
    showDialog<MalayalamDate>(
      context: context,
      builder: (context) => _MalayalamDatePickerDialog(
        initialDate: initialDate ??
            MalayalamDate.today(
                calendar: calendar ?? KollavarshamCalendar.standard),
        firstDate: firstDate,
        lastDate: lastDate,
        script: script,
        malayalamDigits: malayalamDigits,
        showNakshatra: showNakshatra,
        calendar: calendar,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );

class _MalayalamDatePickerDialog extends StatefulWidget {
  const _MalayalamDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.script,
    required this.malayalamDigits,
    required this.showNakshatra,
    required this.calendar,
    required this.confirmText,
    required this.cancelText,
  });

  final MalayalamDate initialDate;
  final MalayalamDate? firstDate;
  final MalayalamDate? lastDate;
  final MalayalamScript? script;
  final bool malayalamDigits;
  final bool showNakshatra;
  final KollavarshamCalendar? calendar;
  final String? confirmText;
  final String? cancelText;

  @override
  State<_MalayalamDatePickerDialog> createState() =>
      _MalayalamDatePickerDialogState();
}

class _MalayalamDatePickerDialogState
    extends State<_MalayalamDatePickerDialog> {
  late MalayalamDate _selected = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final script = resolveScript(context, widget.script);
    final ml = script == MalayalamScript.malayalam;
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _selected.format('EEEE, d MMMM y',
                      script: script, malayalamDigits: widget.malayalamDigits),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              MalayalamMonthView(
                initialMonth: widget.initialDate,
                selectedDate: _selected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                script: script,
                malayalamDigits: widget.malayalamDigits,
                showNakshatra: widget.showNakshatra,
                calendar: widget.calendar,
                onDateSelected: (d) => setState(() => _selected = d),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                        widget.cancelText ?? (ml ? 'റദ്ദാക്കുക' : 'Cancel')),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: Text(widget.confirmText ?? (ml ? 'ശരി' : 'OK')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
