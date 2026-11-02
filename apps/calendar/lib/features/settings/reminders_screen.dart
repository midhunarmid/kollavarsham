import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/festival_days.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_options.dart';
import '../../reminders/reminder_service.dart';
import '../people/labels.dart';

/// Settings → Reminders: what to be notified of, and when.
class RemindersScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool? _exact;

  @override
  void initState() {
    super.initState();
    _checkExact();
  }

  Future<void> _checkExact() async {
    final exact = await ref.read(notificationSinkProvider).canScheduleExact();
    if (mounted) setState(() => _exact = exact);
  }

  void _edit(ReminderOptions Function(ReminderOptions) change) {
    final c = ref.read(reminderOptionsProvider.notifier);
    c.update(change(ref.read(reminderOptionsProvider)));
  }

  Future<void> _pickTime(int minute, ReminderOptions Function(int) set) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
    if (picked != null) _edit((_) => set(picked.hour * 60 + picked.minute));
  }

  String _time(int minute) => MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final o = ref.watch(reminderOptionsProvider);
    final count = ref.watch(scheduledNotificationsProvider).length;
    final android = notificationsPlugin != null;

    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(text, style: theme.textTheme.titleSmall),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsReminders)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SwitchListTile(
            key: const Key('reminders-enabled'),
            title: Text(l10n.remindersEnabled),
            subtitle: Text(l10n.remindersScheduled(o.enabled ? count : 0)),
            value: o.enabled,
            onChanged: (v) => _edit((o) => o.copyWith(enabled: v)),
          ),
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.remindersWeb, style: theme.textTheme.bodySmall),
            ),
          if (android) ...[
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(l10n.remindersPermission),
              onTap: () =>
                  ref.read(notificationSinkProvider).requestPermission(),
            ),
            if (_exact != null)
              ListTile(
                leading: Icon(_exact! ? Icons.alarm_on : Icons.alarm_off),
                title: Text(l10n.remindersExact),
                subtitle: Text(
                    _exact! ? l10n.remindersExactOn : l10n.remindersExactOff),
                onTap: _exact!
                    ? null
                    : () async {
                        await ref
                            .read(notificationSinkProvider)
                            .requestExactAlarms();
                        await _checkExact();
                      },
              ),
          ],
          heading(l10n.remindersNotifyFor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final t in EventType.values)
                  FilterChip(
                    key: Key('remind-${t.name}'),
                    label: Text(eventTypeLabel(l10n, t)),
                    selected: o.eventTypes.contains(t),
                    onSelected: o.enabled
                        ? (on) => _edit((o) => o.copyWith(
                            eventTypes: on
                                ? {...o.eventTypes, t}
                                : ({...o.eventTypes}..remove(t))))
                        : null,
                  ),
              ],
            ),
          ),
          SwitchListTile(
            key: const Key('remind-year-start'),
            title: Text(l10n.remindersYearStart),
            value: o.yearStart,
            onChanged: o.enabled
                ? (v) => _edit((o) => o.copyWith(yearStart: v))
                : null,
          ),
          SwitchListTile(
            key: const Key('remind-month-starts'),
            title: Text(l10n.remindersMonthStarts),
            value: o.monthStarts,
            onChanged: o.enabled
                ? (v) => _edit((o) => o.copyWith(monthStarts: v))
                : null,
          ),
          heading(l10n.remindersFestivals),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final (c, label) in [
                  (FestivalCategory.hindu, l10n.categoryHindu),
                  (FestivalCategory.christian, l10n.categoryChristian),
                  (FestivalCategory.muslim, l10n.categoryMuslim),
                ])
                  FilterChip(
                    key: Key('remind-festival-${c.name}'),
                    label: Text(label),
                    selected: o.festivals.contains(c),
                    onSelected: o.enabled
                        ? (on) => _edit((o) => o.copyWith(
                            festivals: on
                                ? {...o.festivals, c}
                                : ({...o.festivals}..remove(c))))
                        : null,
                  ),
              ],
            ),
          ),
          if (o.festivals.contains(FestivalCategory.muslim))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child:
                  Text(l10n.muslimTentative, style: theme.textTheme.bodySmall),
            ),
          ListTile(
            key: const Key('remind-evening-time'),
            title: Text(l10n.remindersEveningTime),
            trailing: Text(_time(o.minuteOfDay)),
            enabled: o.enabled,
            onTap: () =>
                _pickTime(o.minuteOfDay, (m) => o.copyWith(minuteOfDay: m)),
          ),
          const Divider(),
          SwitchListTile(
            key: const Key('remind-daily'),
            title: Text(l10n.remindersDaily),
            value: o.dailyPanchangam,
            onChanged: o.enabled
                ? (v) => _edit((o) => o.copyWith(dailyPanchangam: v))
                : null,
          ),
          ListTile(
            key: const Key('remind-daily-time'),
            title: Text(l10n.remindersDailyTime),
            trailing: Text(_time(o.dailyMinute)),
            enabled: o.enabled && o.dailyPanchangam,
            onTap: () =>
                _pickTime(o.dailyMinute, (m) => o.copyWith(dailyMinute: m)),
          ),
        ],
      ),
    );
  }
}
