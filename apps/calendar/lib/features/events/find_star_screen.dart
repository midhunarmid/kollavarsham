import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';

/// "Find my star": the birth star, pada and rashi from a birth date and
/// time at the chosen location. Pops with the [BirthDetails] when the user
/// takes the result.
class FindStarScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const FindStarScreen({super.key});

  @override
  ConsumerState<FindStarScreen> createState() => _FindStarScreenState();
}

class _FindStarScreenState extends ConsumerState<FindStarScreen> {
  DateTime _date = DateTime(1990, 1, 1);
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 0);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1800),
      lastDate: DateTime(2200),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final calendar = ref.watch(calendarProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final local = MaterialLocalizations.of(context);
    final details = BirthDetails.fromLocalTime(
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute),
      calendar: calendar,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.findMyStar)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.findStarIntro),
          const SizedBox(height: 8),
          ListTile(
            key: const Key('birth-date'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.birthDate),
            subtitle: Text(local.formatFullDate(_date)),
            onTap: _pickDate,
          ),
          ListTile(
            key: const Key('birth-time'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(l10n.birthTime),
            subtitle: Text(local.formatTimeOfDay(_time,
                alwaysUse24HourFormat:
                    MediaQuery.alwaysUse24HourFormatOf(context))),
            onTap: _pickTime,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.starResult(
                        details.nakshatra.name(script), details.pada),
                    key: const Key('star-result'),
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(l10n.rashiResult(details.rashi.name(script))),
                  MalayalamDateText(
                    date: details.date,
                    pattern: 'd MMMM y',
                    script: script,
                    malayalamDigits: settings.malayalamDigits,
                  ),
                  Text('${l10n.tithi}: ${details.tithi.name(script)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('use-star'),
            onPressed: () => context.pop(details),
            child: Text(l10n.useThisStar),
          ),
        ],
      ),
    );
  }
}
