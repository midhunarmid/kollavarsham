import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../data/festival_index.dart';
import '../data/occurrences.dart';
import '../features/people/labels.dart';
import '../l10n/app_localizations.dart';

/// Days of widget text written ahead, so the widgets stay right after
/// midnight even before the app or the daily job runs again.
const widgetDays = 7;

/// Android class names of the home-screen widgets.
const todayWidget = 'in.armid.calendar.TodayWidgetProvider';

/// See [todayWidget].
const nextEventWidget = 'in.armid.calendar.NextEventWidgetProvider';

const _fields = [
  'today.*.date',
  'today.*.weekday',
  'today.*.star',
  'today.*.festival',
  'today.*.gregorian',
  'next.*.title',
  'next.*.when',
];

String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// The text of both widgets for [widgetDays] days from [today], keyed
/// `today.<yyyy-mm-dd>.<field>` and `next.<yyyy-mm-dd>.<field>`; the
/// Android side reads the keys of the device's date. The past week's keys
/// map to null, which deletes them.
Map<String, String?> homeWidgetData({
  required MalayalamDate today,
  required FestivalIndex festivals,
  required EventIndex events,
  required AppLocalizations l10n,
  required MalayalamScript script,
  bool malayalamDigits = false,
}) {
  final data = <String, String?>{};
  for (var i = 1; i <= widgetDays; i++) {
    final key = _iso(today.addDays(-i).toGregorian());
    for (final f in _fields) {
      data[f.replaceFirst('*', key)] = null;
    }
  }
  // A pirannal can be most of a year away.
  final upcoming = events.upcoming(today, widgetDays + 366);
  for (var i = 0; i < widgetDays; i++) {
    final day = today.addDays(i);
    final key = _iso(day.toGregorian());
    final g = day.toGregorian();
    data['today.$key.date'] = day.format('d MMMM y',
        script: script, malayalamDigits: malayalamDigits);
    data['today.$key.weekday'] =
        day.format('EEEE', script: script, malayalamDigits: malayalamDigits);
    data['today.$key.star'] = '${l10n.nakshatra}: ${day.nakshatra.name(script)}'
        ' · ${l10n.tithi}: ${day.tithi.name(script)}';
    final fs = festivals.on(day);
    data['today.$key.festival'] = fs.map((f) => f.name(script)).join(' · ');
    data['today.$key.gregorian'] = '${g.day}/${g.month}/${g.year}';

    final next = upcoming.where((o) => !o.date.isBefore(day)).firstOrNull;
    data['next.$key.title'] = next == null
        ? l10n.noEvents
        : eventTitle(l10n, next.event, next.person);
    data['next.$key.when'] = next == null
        ? ''
        : '${next.date.format('d MMMM', script: script, malayalamDigits: malayalamDigits)}'
            ' · ${l10n.inDays(day.daysUntil(next.date))}';
  }
  return data;
}

/// Writes widget text and asks the widgets to redraw; a no-op off Android.
class HomeWidgetSink {
  /// Creates the sink; [enabled] is false except in the Android app.
  const HomeWidgetSink({this.enabled = false});

  /// Whether to write anything.
  final bool enabled;

  /// Saves [data] (null deletes a key) and refreshes both widgets.
  Future<void> update(Map<String, String?> data) async {
    if (!enabled) return;
    try {
      for (final MapEntry(:key, :value) in data.entries) {
        await HomeWidget.saveWidgetData<String?>(key, value);
      }
      await HomeWidget.updateWidget(qualifiedAndroidName: todayWidget);
      await HomeWidget.updateWidget(qualifiedAndroidName: nextEventWidget);
    } on Object catch (e) {
      debugPrint('Updating home-screen widgets failed: $e');
    }
  }
}
