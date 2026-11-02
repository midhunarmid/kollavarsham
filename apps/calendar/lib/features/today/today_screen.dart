import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';

/// Today tab: today's Malayalam and Gregorian dates, star and festivals.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final calendar = ref.watch(calendarProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final today = MalayalamDate.today(calendar: calendar);
    final festivals = calendar.festivalsOn(today);

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
                      Text(
                        today.nakshatra.name(script),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.todaysFestivals, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              if (festivals.isEmpty)
                Text(l10n.noFestivalToday)
              else
                for (final f in festivals) Text(f.name(script)),
            ],
          ),
        ),
      ),
    );
  }
}
