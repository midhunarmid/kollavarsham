import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../data/festival_days.dart';
import '../../data/festival_index.dart';
import '../../data/occurrences.dart';
import '../day/festival_tile.dart';
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
    final festivalIndex = ref.watch(festivalIndexProvider);
    final festivals = festivalIndex.on(selected);
    final index = ref.watch(eventIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCalendar),
        actions: [
          IconButton(
            key: const Key('open-agenda'),
            tooltip: l10n.agenda,
            icon: const Icon(Icons.view_agenda_outlined),
            onPressed: () => context.push(AppRoutes.agenda),
          ),
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
                key: ValueKey(
                    (calendar, settings.calendarMode, index, festivalIndex)),
                controller: _controller,
                calendar: calendar,
                mode: settings.calendarMode,
                script: script,
                malayalamDigits: settings.malayalamDigits,
                initialMonth: selected,
                selectedDate: selected,
                showNakshatra: true,
                eventLoader: (d) => [
                  ...festivalIndex.on(d),
                  ...index.on(d),
                ],
                markerBuilder: (context, date, events) =>
                    _Markers(events: events),
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
                for (final f in festivals) FestivalTile(day: f, script: script),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to three dots under a day: public holidays in the holiday colour,
/// other festivals in the marker colour, personal events in their
/// person's colour.
class _Markers extends StatelessWidget {
  const _Markers({required this.events});

  final List<Object> events;

  @override
  Widget build(BuildContext context) {
    final calTheme = KollavarshamCalendarTheme.of(context);
    final fallback = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in events.take(3))
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: e is Occurrence
                    ? (e.color == null ? fallback : Color(e.color!))
                    : e is FestivalDay && e.holiday == HolidayKind.public
                        ? calTheme.holidayColor
                        : calTheme.markerColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
