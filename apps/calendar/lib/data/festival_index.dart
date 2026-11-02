import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../app/settings.dart';
import 'festival_days.dart';

/// Asset folder of the bundled holiday lists.
const holidayAssets = 'assets/holidays/';

/// Loads every bundled `assets/holidays/YYYY.json` from [bundle].
Future<HolidayData> loadHolidays([AssetBundle? bundle]) async {
  final b = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(b);
  final files = [
    for (final path in manifest.listAssets())
      if (path.startsWith(holidayAssets) && path.endsWith('.json'))
        await b.loadString(path),
  ];
  return HolidayData.parse(files);
}

/// The bundled holiday lists; `main` loads them before the first frame
/// and overrides this.
final holidaysProvider = Provider<HolidayData>((ref) => HolidayData.empty);

/// Festivals and holidays, computed a Gregorian year at a time on first use
/// and kept.
class FestivalIndex {
  /// Indexes the festivals of [categories] in [calendar] with [holidays].
  FestivalIndex(this.calendar, this.holidays, this.categories);

  /// The calendar dates are computed in.
  final KollavarshamCalendar calendar;

  /// The holiday lists.
  final HolidayData holidays;

  /// The categories shown.
  final Set<FestivalCategory> categories;

  final Map<int, Map<int, List<FestivalDay>>> _years = {};

  Map<int, List<FestivalDay>> _year(int year) => _years[year] ??= () {
        final days = <int, List<FestivalDay>>{};
        for (final f in festivalDaysBetween(
            calendar,
            calendar.fromGregorian(DateTime(year)),
            calendar.fromGregorian(DateTime(year, 12, 31)),
            categories: categories,
            holidays: holidays)) {
          (days[f.date.dayNumber] ??= []).add(f);
        }
        return days;
      }();

  /// The festivals and holidays on [date].
  List<FestivalDay> on(MalayalamDate date) =>
      _year(date.toGregorian().year)[date.dayNumber] ?? const [];

  /// The festivals and holidays from [from] for [days] days, by date.
  List<FestivalDay> upcoming(MalayalamDate from, int days) {
    final last = from.addDays(days - 1);
    return [
      for (var y = from.toGregorian().year; y <= last.toGregorian().year; y++)
        for (final MapEntry(:key, :value)
            in (_year(y).entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key))))
          if (key >= from.dayNumber && key <= last.dayNumber) ...value,
    ];
  }

  /// The first festival day after [date], within a year and a half.
  FestivalDay? next(MalayalamDate date) {
    for (final f in upcoming(date.addDays(1), 550)) {
      return f;
    }
    return null;
  }
}

/// The festival index for the current calendar, holiday data and category
/// filter.
final festivalIndexProvider = Provider<FestivalIndex>((ref) => FestivalIndex(
      ref.watch(calendarProvider),
      ref.watch(holidaysProvider),
      ref.watch(settingsProvider.select((s) => s.categories)),
    ));

/// The next [count] days of the festival with [id] after [after]
/// (exclusive), looking up to [years] years ahead.
List<FestivalDay> festivalDates(
  String id,
  MalayalamDate after,
  HolidayData holidays, {
  int count = 5,
  int years = 12,
}) {
  final calendar = after.calendar;
  final result = <FestivalDay>[];
  var from = after.addDays(1);
  for (var i = 0; i < years && result.length < count; i++) {
    final to = from.addDays(365);
    for (final f
        in festivalDaysBetween(calendar, from, to, holidays: holidays)) {
      if (f.id == id && result.length < count) result.add(f);
    }
    from = to.addDays(1);
  }
  return result;
}
