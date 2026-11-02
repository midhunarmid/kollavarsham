import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../data/festival_index.dart';
import '../../data/occurrences.dart';
import '../people/labels.dart';
import '../../l10n/app_localizations.dart';
import '../day/day_info.dart';
import '../day/festival_tile.dart';
import '../day/panchangam_view.dart';
import '../share/share_card.dart';

/// Today tab: today's Malayalam and Gregorian dates, the panchangam
/// summary, today's festivals and the next festival.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final today = ref.watch(todayProvider);
    final info = DayInfo.of(today);
    final festivals = ref.watch(festivalIndexProvider);
    final todays = festivals.on(today);
    final next = festivals.next(today);
    final upcoming = ref.watch(eventIndexProvider).upcoming(today, 30);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            key: const Key('share-today'),
            tooltip: l10n.shareCard,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => showShareCardDialog(
              context,
              ref,
              card: PanchangamCard(
                info: info,
                script: script,
                malayalamDigits: settings.malayalamDigits,
                festivals: [for (final f in todays) f.name(script)],
              ),
              fileName:
                  'panchangam-${today.toGregorian().toIso8601String().substring(0, 10)}.png',
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.todayHeading,
                          style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      MalayalamDateText(
                        key: const Key('today-date'),
                        date: today,
                        pattern: 'EEEE, d MMMM y',
                        script: script,
                        malayalamDigits: settings.malayalamDigits,
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        MaterialLocalizations.of(context)
                            .formatFullDate(today.toGregorian()),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.panchangam, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      PanchangamTable(info: info, script: script),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          key: const Key('today-details'),
                          onPressed: () => context
                              .push(AppRoutes.dayPath(today.toGregorian())),
                          child: Text(l10n.dayDetails),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.todaysFestivals, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              if (todays.isEmpty)
                Text(l10n.noFestivalToday)
              else
                for (final f in todays) FestivalTile(day: f, script: script),
              const SizedBox(height: 16),
              Text(l10n.pirannalAndEvents, style: theme.textTheme.titleSmall),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(l10n.noUpcoming),
                )
              else
                for (final o in upcoming)
                  ListTile(
                    key: Key('upcoming-${o.event.id}-${o.date.dayNumber}'),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 6,
                      height: 36,
                      decoration: BoxDecoration(
                        color: o.color == null
                            ? theme.colorScheme.primary
                            : Color(o.color!),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    title: Text(eventTitle(l10n, o.event, o.person)),
                    subtitle: Text(
                      '${o.date.format('d MMMM', script: script, malayalamDigits: settings.malayalamDigits)}'
                      ' · ${l10n.inDays(today.daysUntil(o.date))}',
                    ),
                    onTap: o.person == null
                        ? () =>
                            context.push(AppRoutes.editEventPath(o.event.id))
                        : () =>
                            context.push(AppRoutes.personPath(o.person!.id)),
                  ),
              if (next != null) ...[
                const SizedBox(height: 16),
                Text(l10n.nextFestival, style: theme.textTheme.titleSmall),
                FestivalTile(
                  key: const Key('next-festival'),
                  day: next,
                  script: script,
                  subtitlePrefix:
                      '${next.date.format('d MMMM', script: script, malayalamDigits: settings.malayalamDigits)}'
                      ' · ${l10n.inDays(today.daysUntil(next.date))}',
                  onTap: () =>
                      context.push(AppRoutes.dayPath(next.date.toGregorian())),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
