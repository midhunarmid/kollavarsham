import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/locations.dart';
import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';

String _offset(Duration d) {
  final m = d.inMinutes.abs();
  final sign = d.isNegative ? '−' : '+';
  return 'UTC$sign${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
}

/// A short label for [location]: the city name, or the coordinates and UTC
/// offset for a manual location.
String locationLabel(ObserverLocation location, MalayalamScript script) {
  final city = keralaCityAt(location);
  if (city != null) return city.name(script);
  return '${location.latitude.toStringAsFixed(2)}, '
      '${location.longitude.toStringAsFixed(2)} '
      '(${_offset(location.utcOffset)})';
}

/// Lets the user choose a Kerala city or enter coordinates; returns the
/// chosen location, or null if cancelled.
Future<ObserverLocation?> showLocationPicker(
  BuildContext context, {
  required ObserverLocation current,
  required MalayalamScript script,
}) async {
  final l10n = AppLocalizations.of(context);
  const manual = Object();
  final choice = await showDialog<Object>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.settingsLocation),
      children: [
        for (final city in keralaCities)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, city.location),
            child: Row(
              children: [
                Expanded(child: Text(city.name(script))),
                if (city.location == current) const Icon(Icons.check),
              ],
            ),
          ),
        const Divider(),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, manual),
          child: Text(l10n.locationManual),
        ),
      ],
    ),
  );
  if (choice is ObserverLocation) return choice;
  if (choice != manual || !context.mounted) return null;
  return showDialog<ObserverLocation>(
    context: context,
    builder: (context) => _ManualLocationDialog(current: current),
  );
}

class _ManualLocationDialog extends StatefulWidget {
  const _ManualLocationDialog({required this.current});

  final ObserverLocation current;

  @override
  State<_ManualLocationDialog> createState() => _ManualLocationDialogState();
}

class _ManualLocationDialogState extends State<_ManualLocationDialog> {
  final _form = GlobalKey<FormState>();
  late final _lat =
      TextEditingController(text: widget.current.latitude.toString());
  late final _lng =
      TextEditingController(text: widget.current.longitude.toString());
  late final _offset = TextEditingController(
      text: (widget.current.utcOffset.inMinutes / 60).toString());

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    _offset.dispose();
    super.dispose();
  }

  String? _check(String? text, bool Function(double) ok, String message) {
    final v = double.tryParse(text?.trim() ?? '');
    return v != null && ok(v) ? null : message;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      ObserverLocation(
        latitude: double.parse(_lat.text.trim()),
        longitude: double.parse(_lng.text.trim()),
        utcOffset:
            Duration(minutes: (double.parse(_offset.text.trim()) * 60).round()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const keyboard =
        TextInputType.numberWithOptions(signed: true, decimal: true);
    return AlertDialog(
      title: Text(l10n.locationManual),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('manual-latitude'),
              controller: _lat,
              keyboardType: keyboard,
              decoration: InputDecoration(labelText: l10n.latitude),
              validator: (t) => _check(
                  t, (v) => isValidLocation(v, 0, 0), l10n.invalidLatitude),
            ),
            TextFormField(
              key: const Key('manual-longitude'),
              controller: _lng,
              keyboardType: keyboard,
              decoration: InputDecoration(labelText: l10n.longitude),
              validator: (t) => _check(
                  t, (v) => isValidLocation(0, v, 0), l10n.invalidLongitude),
            ),
            TextFormField(
              key: const Key('manual-offset'),
              controller: _offset,
              keyboardType: keyboard,
              decoration: InputDecoration(
                labelText: l10n.utcOffsetHours,
                helperText: l10n.utcOffsetHelp,
              ),
              validator: (t) => _check(
                  t,
                  (v) =>
                      (v * 60) == (v * 60).roundToDouble() &&
                      isValidLocation(0, 0, (v * 60).round()),
                  l10n.invalidUtcOffset),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
