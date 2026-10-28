import 'package:flutter/material.dart';
import 'package:kollavarsham/kollavarsham.dart';

import 'script.dart';

/// Builds the content of one day cell in a [MalayalamMonthView].
typedef MalayalamDayBuilder = Widget Function(
  BuildContext context,
  MalayalamDate date,
  MalayalamDayState state,
);

/// Visual state of a day cell, passed to a [MalayalamDayBuilder].
class MalayalamDayState {
  const MalayalamDayState({
    required this.isToday,
    required this.isSelected,
    required this.isEnabled,
  });

  final bool isToday;
  final bool isSelected;
  final bool isEnabled;
}

/// A month of the Malayalam calendar laid out as a week grid.
///
/// Each cell shows the Malayalam day prominently with the Gregorian day
/// underneath and, optionally, the day's nakshatra. Arrows in the header
/// move between months.
///
/// ```dart
/// MalayalamMonthView(
///   selectedDate: selected,
///   onDateSelected: (date) => setState(() => selected = date),
///   showNakshatra: true,
/// )
/// ```
class MalayalamMonthView extends StatefulWidget {
  const MalayalamMonthView({
    super.key,
    this.initialMonth,
    this.selectedDate,
    this.onDateSelected,
    this.onMonthChanged,
    this.firstDate,
    this.lastDate,
    this.script,
    this.malayalamDigits = false,
    this.showGregorian = true,
    this.showNakshatra = false,
    this.calendar,
    this.dayBuilder,
  });

  /// Any date in the month to show first. Defaults to [selectedDate], then
  /// today.
  final MalayalamDate? initialMonth;

  /// The highlighted date.
  final MalayalamDate? selectedDate;

  /// Called when an enabled day is tapped.
  final ValueChanged<MalayalamDate>? onDateSelected;

  /// Called with the first day of the month after navigating.
  final ValueChanged<MalayalamDate>? onMonthChanged;

  /// Earliest selectable date; earlier months cannot be navigated to.
  final MalayalamDate? firstDate;

  /// Latest selectable date; later months cannot be navigated to.
  final MalayalamDate? lastDate;

  /// Script for names. Defaults to the ambient locale (see [resolveScript]).
  final MalayalamScript? script;

  /// Render numbers with Malayalam digits (൧൨൩).
  final bool malayalamDigits;

  /// Show the Gregorian day under each Malayalam day.
  final bool showGregorian;

  /// Show each day's nakshatra.
  final bool showNakshatra;

  /// Calendar (location) to compute dates with. Defaults to
  /// [KollavarshamCalendar.standard].
  final KollavarshamCalendar? calendar;

  /// Replaces the default content of each day cell.
  final MalayalamDayBuilder? dayBuilder;

  @override
  State<MalayalamMonthView> createState() => _MalayalamMonthViewState();
}

class _MalayalamMonthViewState extends State<MalayalamMonthView> {
  late MalayalamDate _month;

  KollavarshamCalendar get _calendar =>
      widget.calendar ?? KollavarshamCalendar.standard;

  @override
  void initState() {
    super.initState();
    _month = (widget.initialMonth ??
            widget.selectedDate ??
            MalayalamDate.today(calendar: _calendar))
        .firstDayOfMonth;
  }

  bool _isEnabled(MalayalamDate date) =>
      (widget.firstDate == null || !date.isBefore(widget.firstDate!)) &&
      (widget.lastDate == null || !date.isAfter(widget.lastDate!));

  bool get _canGoBack =>
      widget.firstDate == null || _month.isAfter(widget.firstDate!);

  bool get _canGoForward =>
      widget.lastDate == null ||
      _month.lastDayOfMonth.isBefore(widget.lastDate!);

  void _changeMonth(int delta) {
    setState(() => _month = _month.addMonths(delta).firstDayOfMonth);
    widget.onMonthChanged?.call(_month);
  }

  @override
  Widget build(BuildContext context) {
    final script = resolveScript(context, widget.script);
    final theme = Theme.of(context);
    final today = MalayalamDate.today(calendar: _calendar);
    final first = _month;
    final last = _month.lastDayOfMonth;
    final gFirst = first.toGregorian();
    final gLast = last.toGregorian();
    String num(int n) =>
        formatNumber(n, malayalamDigits: widget.malayalamDigits);

    final gregorianRange = gFirst.month == gLast.month
        ? '${gregorianMonthName(gFirst.month, script)} ${num(gFirst.year)}'
        : gFirst.year == gLast.year
            ? '${gregorianMonthName(gFirst.month, script)} – '
                '${gregorianMonthName(gLast.month, script)} ${num(gLast.year)}'
            : '${gregorianMonthName(gFirst.month, script)} ${num(gFirst.year)} – '
                '${gregorianMonthName(gLast.month, script)} ${num(gLast.year)}';

    final header = Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
          onPressed: _canGoBack ? () => _changeMonth(-1) : null,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${_month.month.name(script)} ${num(_month.year)}',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                gregorianRange,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
          onPressed: _canGoForward ? () => _changeMonth(1) : null,
        ),
      ],
    );

    final weekdayRow = Row(
      children: [
        for (final w in MalayalamWeekday.values)
          Expanded(
            child: Center(
              child: Text(
                w.shortName(script),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: w == MalayalamWeekday.njayar
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );

    final leading = first.weekday.index;
    final cellCount = ((leading + first.monthLength) / 7).ceil() * 7;
    final rows = <Widget>[];
    for (var r = 0; r < cellCount ~/ 7; r++) {
      rows.add(Row(
        children: [
          for (var c = 0; c < 7; c++)
            Expanded(
              child: AspectRatio(
                aspectRatio: widget.showNakshatra ? 0.8 : 1,
                child: _buildCell(
                    context, r * 7 + c - leading, today, script, num),
              ),
            ),
        ],
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [header, const SizedBox(height: 4), weekdayRow, ...rows],
    );
  }

  Widget _buildCell(
    BuildContext context,
    int offset,
    MalayalamDate today,
    MalayalamScript script,
    String Function(int) num,
  ) {
    if (offset < 0 || offset >= _month.monthLength) {
      return const SizedBox.shrink();
    }
    final date = _month.addDays(offset);
    final state = MalayalamDayState(
      isToday: date.isAtSameDayAs(today),
      isSelected: widget.selectedDate != null &&
          date.isAtSameDayAs(widget.selectedDate!),
      isEnabled: _isEnabled(date),
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = !state.isEnabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : state.isSelected
            ? scheme.onPrimary
            : date.weekday == MalayalamWeekday.njayar
                ? scheme.error
                : scheme.onSurface;

    final content = widget.dayBuilder?.call(context, date, state) ??
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(num(date.day),
                style: theme.textTheme.titleSmall?.copyWith(color: fg)),
            if (widget.showGregorian)
              Text(
                num(date.toGregorian().day),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: fg.withValues(alpha: 0.7)),
              ),
            if (widget.showNakshatra)
              Text(
                date.nakshatra.name(script),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: fg.withValues(alpha: 0.7), fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        );

    final g = date.toGregorian();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        label: '${date.format('d MMMM y', script: script)}, '
            '${g.year}-${g.month}-${g.day}',
        selected: state.isSelected,
        button: state.isEnabled,
        child: Material(
          color: state.isSelected ? scheme.primary : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: state.isToday && !state.isSelected
                ? BorderSide(color: scheme.primary)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: state.isEnabled && widget.onDateSelected != null
                ? () => widget.onDateSelected!(date)
                : null,
            child: content,
          ),
        ),
      ),
    );
  }
}
