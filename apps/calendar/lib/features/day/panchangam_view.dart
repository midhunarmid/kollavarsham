import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../l10n/app_localizations.dart';
import 'day_info.dart';

/// Formats [instant] as a time at the location of [info]'s calendar, noting
/// when it falls after the day.
String formatDayTime(BuildContext context, DayInfo info, DateTime? instant) {
  final l10n = AppLocalizations.of(context);
  if (instant == null) return l10n.noTime;
  final local = localTime(instant, info.date.calendar);
  final text = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));
  final day = info.date.toGregorian();
  final sameDay = local.year == day.year &&
      local.month == day.month &&
      local.day == day.day;
  return sameDay ? text : l10n.timeNextDay(text);
}

/// The panchangam of a day as label–value rows.
///
/// [full] adds yoga, karana and moonrise/moonset, and lists every star and
/// tithi up to the next sunrise instead of only the first.
class PanchangamTable extends StatelessWidget {
  /// Creates the table for [info].
  const PanchangamTable({
    super.key,
    required this.info,
    required this.script,
    this.full = false,
  });

  /// The day.
  final DayInfo info;

  /// Script for star, tithi and kalam names.
  final MalayalamScript script;

  /// Whether to show every row and span.
  final bool full;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String time(DateTime? t) => formatDayTime(context, info, t);
    List<String> spans<T>(
            List<PanchangaSpan<T>> list, String Function(T) name) =>
        [
          for (final s in full ? list : list.take(1))
            l10n.untilTime(name(s.value), time(s.end)),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(l10n.nakshatra, spans(info.nakshatras, (n) => n.name(script)),
            key: const Key('row-nakshatra')),
        _Row(l10n.tithi, spans(info.tithis, (t) => t.name(script)),
            key: const Key('row-tithi')),
        _Row(l10n.paksha, [info.paksha.name(script)]),
        if (full) ...[
          _Row(l10n.yoga, spans(info.yogas, (y) => y.name(script))),
          _Row(l10n.karana, spans(info.karanas, (k) => k.name(script))),
        ],
        _Row(l10n.sunrise, [time(info.sunrise)], key: const Key('row-sunrise')),
        _Row(l10n.sunset, [time(info.sunset)]),
        if (full) ...[
          _Row(l10n.moonrise, [time(info.moonrise)]),
          _Row(l10n.moonset, [time(info.moonset)]),
        ],
        for (final k in info.kalams)
          _Row(k.value.name(script), [
            l10n.timeRange(time(k.start), time(k.end)),
          ]),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.values, {super.key});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(label,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final v in values)
                  Text(v, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
