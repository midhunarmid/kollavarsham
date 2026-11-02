import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../l10n/app_localizations.dart';

/// Today tab: today's Malayalam and Gregorian dates, star and festivals.
class TodayScreen extends StatelessWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final script = resolveScript(context, null);
    final today = MalayalamDate.today();
    final festivals = KollavarshamCalendar.standard.festivalsOn(today);

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
