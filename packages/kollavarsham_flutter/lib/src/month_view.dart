import 'package:flutter/material.dart';
import 'package:kollavarsham/kollavarsham.dart';

import 'script.dart';
import 'theme.dart';

/// Builds the content of one day cell in a [MalayalamMonthView].
typedef MalayalamDayBuilder = Widget Function(
  BuildContext context,
  MalayalamDate date,
  MalayalamDayState state,
);

/// Builds the event markers of a day cell from the [events] returned by
/// [MalayalamMonthView.eventLoader].
typedef MalayalamMarkerBuilder = Widget Function(
  BuildContext context,
  MalayalamDate date,
  List<Object> events,
);

/// Which calendar's months a [MalayalamMonthView] pages through.
enum CalendarMode {
  /// Malayalam months (Chingam, Kanni, …), with Gregorian dates as the
  /// secondary date in each cell.
  malayalam,

  /// Gregorian months, with Malayalam dates as the secondary date: the
  /// layout of a Kerala wall calendar.
  gregorian,
}

/// Visual state of a day cell, passed to a [MalayalamDayBuilder].
class MalayalamDayState {
  /// Creates the state of a day cell.
  const MalayalamDayState({
    required this.isToday,
    required this.isSelected,
    required this.isEnabled,
    this.events = const [],
  });

  /// Whether the cell is today.
  final bool isToday;

  /// Whether the cell is the selected date.
  final bool isSelected;

  /// Whether the cell is within the selectable range.
  final bool isEnabled;

  /// Events returned by [MalayalamMonthView.eventLoader] for this day.
  final List<Object> events;
}

/// Controls a [MalayalamMonthView]: reads and changes the displayed month.
class MalayalamMonthViewController extends ChangeNotifier {
  _MalayalamMonthViewState? _state;
  MalayalamDate? _displayed;

  /// First day of the displayed month (of the Gregorian month in
  /// [CalendarMode.gregorian]), or `null` before the view is built.
  MalayalamDate? get displayedMonth => _displayed;

  /// Shows the month containing [date].
  Future<void> jumpTo(MalayalamDate date, {bool animate = true}) async =>
      _state?._showOrdinal(_state!._ordinalOf(date), animate: animate);

  /// Shows the next month.
  Future<void> next() async => _state?._step(1);

  /// Shows the previous month.
  Future<void> previous() async => _state?._step(-1);

  void _update(MalayalamDate month) {
    if (_displayed != month) {
      _displayed = month;
      notifyListeners();
    }
  }
}

/// A month laid out as a week grid, paging through Malayalam or Gregorian
/// months.
///
/// Each cell shows the day prominently with the other calendar's date
/// underneath and, optionally, the day's nakshatra and event markers.
/// Swipe or use the header arrows to change month; tap the header to jump
/// to any month and year.
///
/// ```dart
/// MalayalamMonthView(
///   mode: CalendarMode.gregorian,
///   selectedDate: selected,
///   onDateSelected: (date) => setState(() => selected = date),
///   eventLoader: festivalEventLoader(),
/// )
/// ```
class MalayalamMonthView extends StatefulWidget {
  /// Creates a month view.
  const MalayalamMonthView({
    super.key,
    this.mode = CalendarMode.malayalam,
    this.controller,
    this.initialMonth,
    this.selectedDate,
    this.onDateSelected,
    this.onMonthChanged,
    this.firstDate,
    this.lastDate,
    this.script,
    this.malayalamDigits = false,
    this.showSecondaryDate = true,
    this.showNakshatra = false,
    this.eventLoader,
    this.markerBuilder,
    this.calendar,
    this.dayBuilder,
  });

  /// Whether to page through Malayalam or Gregorian months.
  final CalendarMode mode;

  /// Optional controller for reading and changing the displayed month.
  final MalayalamMonthViewController? controller;

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

  /// Show the other calendar's date under each day: the Gregorian day in
  /// [CalendarMode.malayalam], the Malayalam day in
  /// [CalendarMode.gregorian]. Where that calendar's month changes, its
  /// name is shown too.
  final bool showSecondaryDate;

  /// Show each day's nakshatra.
  final bool showNakshatra;

  /// Returns the events of a day; days with events show markers.
  /// See [festivalEventLoader].
  final List<Object> Function(MalayalamDate date)? eventLoader;

  /// Replaces the default markers (up to three dots).
  final MalayalamMarkerBuilder? markerBuilder;

  /// Calendar (location) to compute dates with. Defaults to
  /// [KollavarshamCalendar.standard].
  final KollavarshamCalendar? calendar;

  /// Replaces the default content of each day cell.
  final MalayalamDayBuilder? dayBuilder;

  @override
  State<MalayalamMonthView> createState() => _MalayalamMonthViewState();
}

/// An event loader for [MalayalamMonthView.eventLoader] that marks the
/// [KeralaFestival]s of each day.
List<Object> Function(MalayalamDate) festivalEventLoader(
        [KollavarshamCalendar? calendar]) =>
    (date) => (calendar ?? date.calendar).festivalsOn(date);

class _MalayalamMonthViewState extends State<MalayalamMonthView> {
  /// Months reachable either side of today when no bound is given.
  static const _defaultSpan = 1200;

  late int _minOrdinal;
  late int _maxOrdinal;
  late PageController _pages;
  late int _page;

  /// First day of the displayed month.
  late MalayalamDate _shown;

  /// Page being navigated to, which runs ahead of [_page] during an
  /// animation so that repeated taps accumulate.
  late int _targetPage;
  int _animations = 0;

  KollavarshamCalendar get _calendar =>
      widget.calendar ?? KollavarshamCalendar.standard;

  // Months are addressed by an ordinal: year * 12 + position in the year.

  int _ordinalOf(MalayalamDate date) {
    if (widget.mode == CalendarMode.gregorian) {
      final g = date.toGregorian();
      return g.year * 12 + g.month - 1;
    }
    return date.year * 12 +
        (date.month.index - _calendar.firstMonth.index) % 12;
  }

  MalayalamDate _monthStart(int ordinal) {
    final year = ordinal ~/ 12, position = ordinal % 12;
    if (widget.mode == CalendarMode.gregorian) {
      return _calendar.fromGregorian(DateTime(year, position + 1));
    }
    final month =
        MalayalamMonth.values[(_calendar.firstMonth.index + position) % 12];
    return MalayalamDate(year, month, 1, calendar: _calendar);
  }

  int _monthLength(int ordinal) => widget.mode == CalendarMode.gregorian
      ? DateUtils.getDaysInMonth(ordinal ~/ 12, ordinal % 12 + 1)
      : _monthStart(ordinal).monthLength;

  void _computeBounds() {
    final today = _ordinalOf(MalayalamDate.today(calendar: _calendar));
    _minOrdinal = widget.firstDate != null
        ? _ordinalOf(widget.firstDate!)
        : today - _defaultSpan;
    _maxOrdinal = widget.lastDate != null
        ? _ordinalOf(widget.lastDate!)
        : today + _defaultSpan;
  }

  @override
  void initState() {
    super.initState();
    _computeBounds();
    final initial = widget.initialMonth ??
        widget.selectedDate ??
        MalayalamDate.today(calendar: _calendar);
    _page =
        (_ordinalOf(initial) - _minOrdinal).clamp(0, _maxOrdinal - _minOrdinal);
    _shown = _monthStart(_minOrdinal + _page);
    _targetPage = _page;
    _pages = PageController(initialPage: _page);
    _attach(widget.controller);
  }

  void _attach(MalayalamMonthViewController? controller) {
    controller?._state = this;
    controller?._displayed = _shown;
  }

  @override
  void didUpdateWidget(MalayalamMonthView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      if (old.controller?._state == this) old.controller?._state = null;
      _attach(widget.controller);
    }
    if (old.mode != widget.mode ||
        old.calendar != widget.calendar ||
        old.firstDate != widget.firstDate ||
        old.lastDate != widget.lastDate) {
      // Keep showing the same days under the new addressing.
      _computeBounds();
      _page = (_ordinalOf(_shown) - _minOrdinal)
          .clamp(0, _maxOrdinal - _minOrdinal);
      _shown = _monthStart(_minOrdinal + _page);
      _targetPage = _page;
      _pages.dispose();
      _pages = PageController(initialPage: _page);
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    _pages.dispose();
    super.dispose();
  }

  Future<void> _showOrdinal(int ordinal, {required bool animate}) async {
    final page = (ordinal - _minOrdinal).clamp(0, _maxOrdinal - _minOrdinal);
    if (!_pages.hasClients || page == _targetPage) return;
    final distance = (page - _targetPage).abs();
    _targetPage = page;
    if (animate && distance == 1) {
      _animations++;
      try {
        await _pages.animateToPage(page,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      } finally {
        _animations--;
      }
    } else {
      _pages.jumpToPage(page);
    }
  }

  Future<void> _step(int delta) =>
      _showOrdinal(_minOrdinal + _targetPage + delta, animate: true);

  void _onPageChanged(int page) {
    final start = _monthStart(_minOrdinal + page);
    setState(() {
      _page = page;
      _shown = start;
    });
    // A swipe moves the target; during our own animations it is already set.
    if (_animations == 0) _targetPage = page;
    widget.controller?._update(start);
    widget.onMonthChanged?.call(start);
  }

  bool _isEnabled(MalayalamDate date) =>
      (widget.firstDate == null || !date.isBefore(widget.firstDate!)) &&
      (widget.lastDate == null || !date.isAfter(widget.lastDate!));

  String _num(int n) =>
      formatNumber(n, malayalamDigits: widget.malayalamDigits);

  String _title(int ordinal, MalayalamScript script) {
    final start = _monthStart(ordinal);
    if (widget.mode == CalendarMode.gregorian) {
      return '${_gregorianMonthTitle(ordinal % 12 + 1, script)} '
          '${_num(ordinal ~/ 12)}';
    }
    return '${start.month.name(script)} ${_num(start.year)}';
  }

  String _subtitle(int ordinal, MalayalamScript script) {
    final first = _monthStart(ordinal);
    final last = first.addDays(_monthLength(ordinal) - 1);
    if (widget.mode == CalendarMode.gregorian) {
      final a = '${first.month.name(script)} ${_num(first.year)}';
      final b = '${last.month.name(script)} ${_num(last.year)}';
      if (first.month == last.month) return a;
      return first.year == last.year
          ? '${first.month.name(script)} – ${last.month.name(script)} '
              '${_num(last.year)}'
          : '$a – $b';
    }
    final g1 = first.toGregorian(), g2 = last.toGregorian();
    if (g1.month == g2.month) {
      return '${gregorianMonthName(g1.month, script)} ${_num(g1.year)}';
    }
    return g1.year == g2.year
        ? '${gregorianMonthName(g1.month, script)} – '
            '${gregorianMonthName(g2.month, script)} ${_num(g2.year)}'
        : '${gregorianMonthName(g1.month, script)} ${_num(g1.year)} – '
            '${gregorianMonthName(g2.month, script)} ${_num(g2.year)}';
  }

  Future<void> _openChooser(MalayalamScript script) async {
    final chosen = await showDialog<int>(
      context: context,
      builder: (_) => _MonthChooserDialog(
        initialOrdinal: _minOrdinal + _page,
        minOrdinal: _minOrdinal,
        maxOrdinal: _maxOrdinal,
        script: script,
        malayalamDigits: widget.malayalamDigits,
        monthLabel: (position) => widget.mode == CalendarMode.gregorian
            ? gregorianMonthName(position + 1, script)
            : MalayalamMonth
                .values[(_calendar.firstMonth.index + position) % 12]
                .name(script),
      ),
    );
    if (chosen != null && mounted) {
      await _showOrdinal(chosen, animate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final script = resolveScript(context, widget.script);
    final strings = CalendarStrings.of(script);
    final theme = Theme.of(context);
    final calTheme = KollavarshamCalendarTheme.of(context);
    final ordinal = _minOrdinal + _page;

    final header = Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: strings.previousMonth,
          onPressed: _page > 0 ? () => _step(-1) : null,
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openChooser(script),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Text(_title(ordinal, script),
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center),
                  Text(_subtitle(ordinal, script),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: strings.nextMonth,
          onPressed: _page < _maxOrdinal - _minOrdinal ? () => _step(1) : null,
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
                      ? calTheme.holidayColor
                      : calTheme.secondaryTextColor,
                ),
              ),
            ),
          ),
      ],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final width =
          constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
      final rowHeight = width / 7 * (widget.showNakshatra ? 1.3 : 1.0);
      final today = MalayalamDate.today(calendar: _calendar);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const SizedBox(height: 4),
          weekdayRow,
          SizedBox(
            height: rowHeight * 6,
            child: PageView.builder(
              controller: _pages,
              itemCount: _maxOrdinal - _minOrdinal + 1,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, page) => _buildGrid(
                  context,
                  _minOrdinal + page,
                  rowHeight,
                  today,
                  script,
                  strings,
                  calTheme),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGrid(
    BuildContext context,
    int ordinal,
    double rowHeight,
    MalayalamDate today,
    MalayalamScript script,
    CalendarStrings strings,
    ResolvedKollavarshamCalendarTheme calTheme,
  ) {
    final first = _monthStart(ordinal);
    final length = _monthLength(ordinal);
    final leading = first.weekday.index;
    return Column(
      children: [
        for (var r = 0; r < 6; r++)
          SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: () {
                      final offset = r * 7 + c - leading;
                      if (offset < 0 || offset >= length) {
                        return const SizedBox.shrink();
                      }
                      return _buildCell(context, first.addDays(offset), today,
                          script, strings, calTheme);
                    }(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    MalayalamDate date,
    MalayalamDate today,
    MalayalamScript script,
    CalendarStrings strings,
    ResolvedKollavarshamCalendarTheme calTheme,
  ) {
    final events = widget.eventLoader?.call(date) ?? const <Object>[];
    final state = MalayalamDayState(
      isToday: date.isAtSameDayAs(today),
      isSelected: widget.selectedDate != null &&
          date.isAtSameDayAs(widget.selectedDate!),
      isEnabled: _isEnabled(date),
      events: events,
    );
    final theme = Theme.of(context);
    final g = date.toGregorian();
    final isSunday = date.weekday == MalayalamWeekday.njayar;
    final fg = !state.isEnabled
        ? calTheme.disabledColor
        : state.isSelected
            ? calTheme.onSelectedColor
            : isSunday
                ? calTheme.holidayColor
                : theme.colorScheme.onSurface;
    final secondary = state.isSelected || !state.isEnabled
        ? fg.withValues(alpha: 0.75)
        : calTheme.secondaryTextColor;

    final gregorianMode = widget.mode == CalendarMode.gregorian;
    final primary = _num(gregorianMode ? g.day : date.day);
    // The other calendar's date, labelled with its month where it changes.
    String? secondaryText;
    var monthChange = false;
    if (widget.showSecondaryDate) {
      if (gregorianMode) {
        monthChange = date.day == 1;
        secondaryText = monthChange
            ? '${date.month.name(script)} ${_num(1)}'
            : _num(date.day);
      } else {
        monthChange = g.day == 1;
        secondaryText = monthChange
            ? '${gregorianMonthName(g.month, script)} ${_num(1)}'
            : _num(g.day);
      }
    }

    final small = theme.textTheme.labelSmall;
    final content = widget.dayBuilder?.call(context, date, state) ??
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(primary,
                  style: theme.textTheme.titleSmall?.copyWith(color: fg)),
              if (secondaryText != null)
                Text(
                  secondaryText,
                  style: small?.copyWith(
                    color: monthChange && !state.isSelected
                        ? calTheme.monthChangeColor
                        : secondary,
                    fontWeight: monthChange ? FontWeight.w600 : null,
                  ),
                ),
              if (widget.showNakshatra)
                Text(
                  date.nakshatra.name(script),
                  style: small?.copyWith(color: secondary, fontSize: 9),
                ),
              if (events.isNotEmpty)
                widget.markerBuilder?.call(context, date, events) ??
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < events.length && i < 3; i++)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: state.isSelected
                                    ? calTheme.onSelectedColor
                                    : calTheme.markerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Semantics(
        label: [
          date.format('d MMMM y', script: script),
          '${g.year}-${g.month}-${g.day}',
          if (events.isNotEmpty) strings.events(events.length),
        ].join(', '),
        selected: state.isSelected,
        button: state.isEnabled,
        excludeSemantics: true,
        child: Material(
          color: state.isSelected ? calTheme.selectedColor : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: calTheme.cellBorderRadius,
            side: state.isToday && !state.isSelected
                ? BorderSide(color: calTheme.todayBorderColor)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: calTheme.cellBorderRadius,
            onTap: state.isEnabled && widget.onDateSelected != null
                ? () => widget.onDateSelected!(date)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}

const _gregorianMonthsEnFull = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _gregorianMonthTitle(int month, MalayalamScript script) =>
    script == MalayalamScript.malayalam
        ? gregorianMonthName(month, script)
        : _gregorianMonthsEnFull[month - 1];

/// Dialog for jumping to a month: a year stepper and a grid of months.
class _MonthChooserDialog extends StatefulWidget {
  const _MonthChooserDialog({
    required this.initialOrdinal,
    required this.minOrdinal,
    required this.maxOrdinal,
    required this.script,
    required this.malayalamDigits,
    required this.monthLabel,
  });

  final int initialOrdinal;
  final int minOrdinal;
  final int maxOrdinal;
  final MalayalamScript script;
  final bool malayalamDigits;
  final String Function(int position) monthLabel;

  @override
  State<_MonthChooserDialog> createState() => _MonthChooserDialogState();
}

class _MonthChooserDialogState extends State<_MonthChooserDialog> {
  late int _year = widget.initialOrdinal ~/ 12;

  @override
  Widget build(BuildContext context) {
    final strings = CalendarStrings.of(widget.script);
    final theme = Theme.of(context);
    final minYear = widget.minOrdinal ~/ 12, maxYear = widget.maxOrdinal ~/ 12;
    return AlertDialog(
      title: Text(strings.selectMonth),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: strings.previousYear,
                  onPressed:
                      _year > minYear ? () => setState(() => _year--) : null,
                ),
                Expanded(
                  child: Text(
                    formatNumber(_year,
                        malayalamDigits: widget.malayalamDigits),
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: strings.nextYear,
                  onPressed:
                      _year < maxYear ? () => setState(() => _year++) : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var p = 0; p < 12; p++)
                  () {
                    final ordinal = _year * 12 + p;
                    final enabled = ordinal >= widget.minOrdinal &&
                        ordinal <= widget.maxOrdinal;
                    final current = ordinal == widget.initialOrdinal;
                    const padding = EdgeInsets.symmetric(horizontal: 8);
                    return Padding(
                      padding: const EdgeInsets.all(2),
                      child: current
                          ? FilledButton.tonal(
                              style: FilledButton.styleFrom(padding: padding),
                              onPressed: () =>
                                  Navigator.of(context).pop(ordinal),
                              child:
                                  FittedBox(child: Text(widget.monthLabel(p))),
                            )
                          : TextButton(
                              style: TextButton.styleFrom(padding: padding),
                              onPressed: enabled
                                  ? () => Navigator.of(context).pop(ordinal)
                                  : null,
                              child:
                                  FittedBox(child: Text(widget.monthLabel(p))),
                            ),
                    );
                  }(),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
      ],
    );
  }
}
