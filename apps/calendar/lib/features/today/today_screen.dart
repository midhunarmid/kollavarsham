import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';
import '../day/day_info.dart';
import '../day/panchangam_view.dart';

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
    final next = nextFestival(today);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
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
              if (info.festivals.isEmpty)
                Text(l10n.noFestivalToday)
              else
                for (final f in info.festivals)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.celebration_outlined),
                    title: Text(f.name(script)),
                  ),
              if (next case (final festival, final date)) ...[
                const SizedBox(height: 16),
                Text(l10n.nextFestival, style: theme.textTheme.titleSmall),
                ListTile(
                  key: const Key('next-festival'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(festival.name(script)),
                  subtitle: Text(
                    '${date.format('d MMMM', script: script, malayalamDigits: settings.malayalamDigits)}'
                    ' · ${l10n.inDays(today.daysUntil(date))}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(AppRoutes.dayPath(date.toGregorian())),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
