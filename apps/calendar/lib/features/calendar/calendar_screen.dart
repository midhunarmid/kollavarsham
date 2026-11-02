import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';

/// Calendar tab: a month view with festival markers and the selected day's
/// festivals; tapping a day opens its Day detail.
class CalendarScreen extends ConsumerStatefulWidget {
  /// Creates the Calendar screen.
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final _controller = MalayalamMonthViewController();
  MalayalamDate? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToToday(MalayalamDate today) {
    setState(() => _selected = today);
    _controller.jumpTo(today);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final calendar = ref.watch(calendarProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final today = ref.watch(todayProvider);
    // Re-read the selection in the current calendar, which changes with
    // the location and year-start settings.
    final selected = MalayalamDate.fromGregorian(
        (_selected ?? today).toGregorian(),
        calendar: calendar);
    final festivals = calendar.festivalsOn(selected);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCalendar),
        actions: [
          IconButton(
            tooltip: l10n.today,
            icon: const Icon(Icons.today),
            onPressed: () => _goToToday(today),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MalayalamMonthView(
                // A new calendar or mode needs a fresh month page.
                key: ValueKey((calendar, settings.calendarMode)),
                controller: _controller,
                calendar: calendar,
                mode: settings.calendarMode,
                script: script,
                malayalamDigits: settings.malayalamDigits,
                initialMonth: selected,
                selectedDate: selected,
                showNakshatra: true,
                eventLoader: festivalEventLoader(calendar),
                onDateSelected: (d) {
                  setState(() => _selected = d);
                  context.push(AppRoutes.dayPath(d.toGregorian()));
                },
              ),
              const Divider(height: 32),
              MalayalamDateText(
                date: selected,
                pattern: 'EEEE, d MMMM y',
                script: script,
                malayalamDigits: settings.malayalamDigits,
                style: theme.textTheme.titleMedium,
              ),
              TextButton(
                key: const Key('calendar-details'),
                onPressed: () =>
                    context.push(AppRoutes.dayPath(selected.toGregorian())),
                child: Text(l10n.dayDetails),
              ),
              Text(l10n.festivals, style: theme.textTheme.labelLarge),
              if (festivals.isEmpty)
                Text(l10n.noFestivals)
              else
                for (final f in festivals) Text(f.name(script)),
            ],
          ),
        ),
      ),
    );
  }
}
