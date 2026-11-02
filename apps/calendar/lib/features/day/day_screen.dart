import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/router.dart';
import '../../app/settings.dart';
import '../../data/festival_index.dart';
import '../../data/occurrences.dart';
import '../../l10n/app_localizations.dart';
import '../people/labels.dart';
import 'day_info.dart';
import 'festival_tile.dart';
import 'panchangam_view.dart';

/// Day detail: the full panchangam and festivals of one Gregorian [date].
class DayScreen extends ConsumerWidget {
  /// Creates the Day screen for [date] (only its year, month and day count).
  const DayScreen({super.key, required this.date});

  /// The day shown.
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final calendar = ref.watch(calendarProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final day = calendar.fromGregorian(date);
    final info = DayInfo.of(day);
    final festivals = ref.watch(festivalIndexProvider).on(day);
    final events = ref.watch(eventIndexProvider).on(day);
    final gregorian = day.toGregorian();

    void goTo(int days) => context.pushReplacement(
        AppRoutes.dayPath(gregorian.add(Duration(days: days))));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dayDetails),
        actions: [
          IconButton(
            tooltip: l10n.previousDay,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => goTo(-1),
          ),
          IconButton(
            tooltip: l10n.nextDay,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => goTo(1),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                MaterialLocalizations.of(context).formatFullDate(gregorian),
                style: theme.textTheme.titleMedium,
              ),
              MalayalamDateText(
                key: const Key('day-date'),
                date: day,
                pattern: 'd MMMM y',
                script: script,
                malayalamDigits: settings.malayalamDigits,
                style: theme.textTheme.headlineSmall,
              ),
              Text(info.nakshatras.first.value.name(script),
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.panchangam, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      PanchangamTable(info: info, script: script, full: true),
                      if (info.monthStartIsClose) ...[
                        const SizedBox(height: 8),
                        Text(l10n.monthStartClose,
                            key: const Key('month-start-close'),
                            style: theme.textTheme.bodySmall),
                      ],
                      const SizedBox(height: 8),
                      Text(l10n.timesForLocation,
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.festivals, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              if (festivals.isEmpty)
                Text(l10n.noFestivals)
              else
                for (final f in festivals) FestivalTile(day: f, script: script),
              if (events.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.yourEvents, style: theme.textTheme.titleSmall),
                for (final o in events)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.event_repeat,
                        color: o.color == null ? null : Color(o.color!)),
                    title: Text(eventTitle(l10n, o.event, o.person)),
                    onTap: () =>
                        context.push(AppRoutes.editEventPath(o.event.id)),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
