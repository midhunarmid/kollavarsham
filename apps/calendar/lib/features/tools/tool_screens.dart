import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';
import 'date_math.dart';

/// Shared bits of the tool screens.
mixin _ToolHelpers<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  MalayalamScript get script =>
      resolveScript(context, ref.read(settingsProvider).nameScript.script);

  bool get digits => ref.read(settingsProvider).malayalamDigits;

  String gregorianText(DateTime d) =>
      MaterialLocalizations.of(context).formatFullDate(d);

  String malayalamText(MalayalamDate d, [String pattern = 'EEEE, d MMMM y']) =>
      d.format(pattern, script: script, malayalamDigits: digits);

  Future<DateTime?> pickGregorian(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1800),
        lastDate: DateTime(2200),
      );

  Future<MalayalamDate?> pickMalayalam(MalayalamDate initial) =>
      showMalayalamDatePicker(
        context: context,
        initialDate: initial,
        calendar: initial.calendar,
        script: script,
        malayalamDigits: digits,
        showNakshatra: true,
      );

  Widget page(String title, List<Widget> children) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child:
                ListView(padding: const EdgeInsets.all(16), children: children),
          ),
        ),
      );
}

/// Date converter: one day shown as both dates, pickable either way.
class ConverterScreen extends ConsumerStatefulWidget {
  /// Creates the converter.
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen>
    with _ToolHelpers {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final calendar = ref.watch(calendarProvider);
    final date = _date ?? ref.watch(todayProvider).toGregorian();
    final ml = calendar.fromGregorian(date);
    return page(l10n.toolConverter, [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.englishDate, style: theme.textTheme.labelLarge),
              Text(gregorianText(date),
                  key: const Key('converter-gregorian'),
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(l10n.malayalamDate, style: theme.textTheme.labelLarge),
              Text(malayalamText(ml),
                  key: const Key('converter-malayalam'),
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('${l10n.nakshatra}: ${ml.nakshatra.name(script)} · '
                  '${l10n.tithi}: ${ml.tithi.name(script)}'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            key: const Key('pick-gregorian'),
            icon: const Icon(Icons.event),
            label: Text(l10n.pickEnglishDate),
            onPressed: () async {
              final d = await pickGregorian(date);
              if (d != null) setState(() => _date = d);
            },
          ),
          OutlinedButton.icon(
            key: const Key('pick-malayalam'),
            icon: const Icon(Icons.calendar_month),
            label: Text(l10n.pickMalayalamDate),
            onPressed: () async {
              final d = await pickMalayalam(ml);
              if (d != null) setState(() => _date = d.toGregorian());
            },
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.dayPath(date)),
            child: Text(l10n.dayDetails),
          ),
        ],
      ),
    ]);
  }
}

/// Age calculator.
class AgeScreen extends ConsumerStatefulWidget {
  /// Creates the age calculator.
  const AgeScreen({super.key});

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> with _ToolHelpers {
  DateTime _birth = DateTime(1990, 1, 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider).toGregorian();
    final valid = !_birth.isAfter(today);
    final age = valid ? ymdBetween(_birth, today) : null;
    final next = nextAnniversary(_birth, today);
    return page(l10n.toolAge, [
      ListTile(
        key: const Key('age-birth'),
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.cake_outlined),
        title: Text(l10n.birthDate),
        subtitle: Text(gregorianText(_birth)),
        onTap: () async {
          final d = await pickGregorian(_birth);
          if (d != null) setState(() => _birth = d);
        },
      ),
      if (age != null) ...[
        Text(l10n.ageResult(age.years, age.months, age.days),
            key: const Key('age-result'), style: theme.textTheme.titleLarge),
        Text(l10n.totalDays(daysBetween(_birth, today))),
        const SizedBox(height: 8),
        Text(l10n.nextBirthday(
          gregorianText(DateTime(next.year, next.month, next.day)),
          l10n.inDays(daysBetween(today, next)),
        )),
      ],
    ]);
  }
}

/// Days between two dates.
class BetweenScreen extends ConsumerStatefulWidget {
  /// Creates the calculator.
  const BetweenScreen({super.key});

  @override
  ConsumerState<BetweenScreen> createState() => _BetweenScreenState();
}

class _BetweenScreenState extends ConsumerState<BetweenScreen>
    with _ToolHelpers {
  DateTime? _from;
  DateTime? _to;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final calendar = ref.watch(calendarProvider);
    final today = ref.watch(todayProvider).toGregorian();
    final from = _from ?? today;
    final to = _to ?? today.add(const Duration(days: 100));
    final days = daysBetween(from, to);
    Widget dateTile(String key, String label, DateTime d,
            void Function(DateTime) set) =>
        ListTile(
          key: Key(key),
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: Text('${gregorianText(d)}\n'
              '${malayalamText(calendar.fromGregorian(d), 'd MMMM y')}'),
          isThreeLine: true,
          trailing: const Icon(Icons.edit_calendar_outlined),
          onTap: () async {
            final picked = await pickGregorian(d);
            if (picked != null) setState(() => set(picked));
          },
        );
    return page(l10n.toolBetween, [
      dateTile('between-from', l10n.fromDate, from, (d) => _from = d),
      dateTile('between-to', l10n.toDate, to, (d) => _to = d),
      const SizedBox(height: 8),
      Text(l10n.daysResult(days.abs()),
          key: const Key('between-result'), style: theme.textTheme.titleLarge),
      Text(l10n.weeksResult(days.abs() ~/ 7, days.abs() % 7)),
    ]);
  }
}

/// The months of a Kollavarsham year.
class YearInfoScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const YearInfoScreen({super.key});

  @override
  ConsumerState<YearInfoScreen> createState() => _YearInfoScreenState();
}

class _YearInfoScreenState extends ConsumerState<YearInfoScreen>
    with _ToolHelpers {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final calendar = ref.watch(calendarProvider);
    final year = ref.watch(todayProvider).year + _offset;
    final local = MaterialLocalizations.of(context);
    final first =
        MalayalamDate(year, calendar.firstMonth, 1, calendar: calendar);
    final last = first.addDays(first.yearLength - 1);
    final months = <MalayalamDate>[];
    for (var m = first; months.length < 12; m = m.lastDayOfMonth.addDays(1)) {
      months.add(m);
    }
    final locale = Localizations.localeOf(context).toString();
    String date(DateTime d) => DateFormat.yMMMd(locale).format(d);
    String time(DateTime utc) {
      final t = utc.toUtc().add(calendar.location.utcOffset);
      return '${DateFormat.MMMd(locale).format(t)} ${local.formatTimeOfDay(TimeOfDay.fromDateTime(t), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${l10n.toolYearInfo} ${first.format('y', script: script, malayalamDigits: digits)}',
            key: const Key('year-info-title')),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.yearLength(
                    first.yearLength,
                    local.formatMediumDate(first.toGregorian()),
                    local.formatMediumDate(last.toGregorian())),
                key: const Key('year-info-length'),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              for (final m in months)
                ListTile(
                  key:
                      Key('year-info-${m.month.name(MalayalamScript.english)}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.month.name(script)),
                  subtitle: Text(l10n.monthInfo(
                    date(m.toGregorian()),
                    m.monthLength,
                    time(calendar.sankranti(m.year, m.month)),
                  )),
                  onTap: () => context.push(AppRoutes.dayPath(m.toGregorian())),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
