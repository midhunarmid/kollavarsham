import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/settings.dart';
import '../../data/festival_days.dart';
import '../../data/festival_index.dart';
import '../../l10n/app_localizations.dart';

/// One month of the year view: its title and its days.
typedef _Month = (String title, List<MalayalamDate> days);

/// Year view: twelve small months with festival dots, in the Calendar
/// tab's mode (the Kollavarsham year, or January to December). Tapping a
/// month pops with its first day, for the month view to open.
class YearScreen extends ConsumerStatefulWidget {
  /// Creates the year view around [initial], or today.
  const YearScreen({super.key, this.initial});

  /// A day in the year to show first.
  final MalayalamDate? initial;

  @override
  ConsumerState<YearScreen> createState() => _YearScreenState();
}

class _YearScreenState extends ConsumerState<YearScreen> {
  int _offset = 0;

  List<_Month> _months(
      MalayalamDate around, CalendarMode mode, MalayalamScript script) {
    final cal = around.calendar;
    if (mode == CalendarMode.gregorian) {
      final year = around.toGregorian().year + _offset;
      return [
        for (var m = 1; m <= 12; m++)
          (
            _gregorianMonthName(context, year, m),
            [
              for (var d = 1; d <= DateUtils.getDaysInMonth(year, m); d++)
                cal.fromGregorian(DateTime(year, m, d)),
            ],
          ),
      ];
    }
    final year = around.year + _offset;
    final start = MalayalamDate(year, cal.firstMonth, 1, calendar: cal);
    final months = <_Month>[];
    var first = start;
    for (var i = 0; i < 12; i++) {
      months.add((
        first.month.name(script),
        [for (var d = 0; d < first.monthLength; d++) first.addDays(d)],
      ));
      first = first.lastDayOfMonth.addDays(1);
    }
    return months;
  }

  static String _gregorianMonthName(BuildContext context, int year, int m) =>
      MaterialLocalizations.of(context)
          .formatMonthYear(DateTime(year, m))
          .replaceAll(RegExp(r'\s*\d{4}\s*'), ' ')
          .trim();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final today = ref.watch(todayProvider);
    final around = widget.initial ?? today;
    final festivals = ref.watch(festivalIndexProvider);
    final mode = settings.calendarMode;
    final months = _months(around, mode, script);
    final title = mode == CalendarMode.gregorian
        ? '${around.toGregorian().year + _offset}'
        : MalayalamDate(around.year + _offset, around.calendar.firstMonth, 1,
                calendar: around.calendar)
            .format('y',
                script: script, malayalamDigits: settings.malayalamDigits);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.yearView} $title', key: const Key('year-title')),
        actions: [
          IconButton(
            tooltip: l10n.previousYear,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _offset--),
          ),
          IconButton(
            tooltip: l10n.nextYear,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _offset++),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 560
                  ? 3
                  : 2;
          return GridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              for (final (i, (name, days)) in months.indexed)
                _MiniMonth(
                  key: Key('mini-month-$i'),
                  title: name,
                  days: days,
                  gregorian: mode == CalendarMode.gregorian,
                  today: today,
                  festivals: festivals,
                  digits: settings.malayalamDigits &&
                      mode == CalendarMode.malayalam,
                  onTap: () => context.pop(days.first),
                  titleStyle: theme.textTheme.titleSmall,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniMonth extends StatelessWidget {
  const _MiniMonth({
    super.key,
    required this.title,
    required this.days,
    required this.gregorian,
    required this.today,
    required this.festivals,
    required this.digits,
    required this.onTap,
    required this.titleStyle,
  });

  final String title;
  final List<MalayalamDate> days;
  final bool gregorian;
  final MalayalamDate today;
  final FestivalIndex festivals;
  final bool digits;
  final VoidCallback onTap;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calTheme = KollavarshamCalendarTheme.of(context);
    // Sunday-first rows, as in the month view.
    final lead = days.first.toGregorian().weekday % 7;
    final small = theme.textTheme.labelSmall!.copyWith(fontSize: 9);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < lead; i++) const SizedBox.shrink(),
                  for (final d in days)
                    _cell(d, festivals.on(d), small, theme, calTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(MalayalamDate d, List<FestivalDay> fs, TextStyle small,
      ThemeData theme, ResolvedKollavarshamCalendarTheme calTheme) {
    final isToday = d.isAtSameDayAs(today);
    final number = gregorian ? d.toGregorian().day : d.day;
    final holiday = fs.any((f) => f.holiday == HolidayKind.public);
    final sunday = d.toGregorian().weekday == DateTime.sunday;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: isToday
              ? BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4))
              : null,
          child: Text(
            digits ? toMalayalamDigits('$number') : '$number',
            style: small.copyWith(
              color: isToday
                  ? theme.colorScheme.onPrimary
                  : holiday || sunday
                      ? calTheme.holidayColor
                      : null,
            ),
          ),
        ),
        Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fs.isEmpty
                ? Colors.transparent
                : holiday
                    ? calTheme.holidayColor
                    : calTheme.markerColor,
          ),
        ),
      ],
    );
  }
}
