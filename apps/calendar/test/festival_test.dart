import 'package:calendar/app/share.dart';
import 'package:calendar/app/clock.dart';
import 'package:calendar/app/app.dart';
import 'package:calendar/app/settings.dart';
import 'package:calendar/data/festival_days.dart';
import 'package:calendar/data/festival_index.dart';
import 'package:calendar/data/festival_info.dart';
import 'package:calendar/features/festival/festival_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

final _cal = KollavarshamCalendar.standard;

/// 25 August 2026, 10:00 in Kerala: the day before Thiruvonam.
final _now = DateTime.utc(2026, 8, 25, 4, 30);

Future<List<String>> _pumpWithShare(WidgetTester tester,
    {AppSettings settings = enSettings}) async {
  final shared = <String>[];
  final prefs = await testPrefs(settings);
  await tester.binding.setSurfaceSize(const Size(480, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      holidaysProvider.overrideWithValue(bundledHolidays),
      clockProvider.overrideWithValue(() => _now),
      shareProvider.overrideWithValue(
          ({text, files, subject}) async => shared.add(text ?? '')),
    ],
    child: const CalendarApp(),
  ));
  await tester.pumpAndSettle();
  return shared;
}

void main() {
  test('every festival has a description and a rule in both languages', () {
    final ids = {
      for (final f in KeralaFestival.values) 'hindu.${EnumName(f).name}',
      for (final f in ChristianFeast.values) 'christian.${EnumName(f).name}',
      for (final f in HijriFestival.values) 'muslim.${EnumName(f).name}',
    };
    for (final id in ids) {
      final info = festivalInfo(id);
      for (final text in [
        info.aboutMl,
        info.aboutEn,
        info.ruleMl,
        info.ruleEn
      ]) {
        expect(text.trim(), isNotEmpty, reason: id);
      }
    }
    // Every id has a festival, so no description is orphaned.
    for (final id
        in festivalInfos.keys.where((k) => !k.startsWith('holiday.'))) {
      expect(ids, contains(id));
    }
  });

  test('every holiday entry has a Malayalam name and a description', () {
    for (final entries in bundledHolidays.byYear.values) {
      for (final e in entries) {
        expect(e.nameMl, isNotNull, reason: e.name);
        expect(festivalInfo(e.id).aboutEn, isNotEmpty, reason: e.id);
      }
    }
    // Spelling variants across years share an id.
    final ids2026 = {for (final e in bundledHolidays.inYear(2026)) e.id};
    final ids2027 = {for (final e in bundledHolidays.inYear(2027)) e.id};
    expect(
        ids2026.intersection(ids2027),
        containsAll(
            ['holiday.ayyankalijayanthi', 'holiday.sreenarayanagurujayanthi']));
  });

  test('next five Thiruvonam dates, each in Chingam', () {
    final after = _cal.fromGregorian(DateTime(2026, 8, 25));
    final dates = festivalDates('hindu.onam', after, bundledHolidays);
    expect(dates, hasLength(5));
    for (final (i, f) in dates.indexed) {
      expect(f.date.month, MalayalamMonth.chingam);
      expect(f.date.year, 1202 + i);
    }
    expect(dates.first.date.toGregorian(), DateTime(2026, 8, 26));
    expect(dates.first.holiday, HolidayKind.public);
    // A list-only holiday has dates only in the years with data.
    final gandhi =
        festivalDates('holiday.gandhijayanthi', after, bundledHolidays);
    expect(gandhi.map((f) => f.date.toGregorian()),
        [DateTime(2026, 10, 2), DateTime(2027, 10, 2)]);
  });

  testWidgets('festival detail from the Day screen, and sharing',
      (tester) async {
    final shared = await _pumpWithShare(tester);
    await pushRoute(tester, '/day/2026-08-26');
    await tester.tap(find.widgetWithText(ListTile, 'Thiruvonam'));
    await tester.pumpAndSettle();
    expect(find.byType(FestivalScreen), findsOneWidget);
    expect(find.byKey(const Key('festival-about')), findsOneWidget);
    expect(find.textContaining('Thiruvonam star at sunrise'), findsOneWidget);
    expect(find.textContaining('Source: https://'), findsOneWidget);
    expect(
        find.byKey(Key(
            'festival-date-${_cal.fromGregorian(DateTime(2026, 8, 26)).dayNumber}')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('share-festival')));
    await tester.pumpAndSettle();
    expect(shared.single, startsWith('Thiruvonam: Wednesday, August 26, 2026'));
    expect(shared.single, contains('calendar.armid.in'));
  });

  testWidgets('festival detail in Malayalam', (tester) async {
    await _pumpWithShare(tester, settings: mlSettings);
    await pushRoute(tester, '/festival/hindu.vishu');
    expect(find.text('വിഷു'), findsWidgets);
    expect(find.textContaining('വിഷുക്കണി'), findsOneWidget);
  });

  testWidgets('an unknown festival id shows a note', (tester) async {
    await _pumpWithShare(tester);
    await pushRoute(tester, '/festival/hindu.nothing');
    expect(find.text('This festival is not in the calendar.'), findsOneWidget);
  });

  testWidgets('year view opens a month in the calendar', (tester) async {
    await _pumpWithShare(tester);
    await tapTab(tester, 'Calendar');
    await tester.tap(find.byKey(const Key('open-year')));
    await tester.pumpAndSettle();
    expect(find.text('Year 1202'), findsOneWidget);
    expect(find.text('Chingam'), findsOneWidget);

    await tester.tap(find.byTooltip('Next year'));
    await tester.pumpAndSettle();
    expect(find.text('Year 1203'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous year'));
    await tester.pumpAndSettle();

    // Kanni, the second month of 1202.
    await tester.tap(find.byKey(const Key('mini-month-1')));
    await tester.pumpAndSettle();
    final view =
        tester.widget<MalayalamMonthView>(find.byType(MalayalamMonthView));
    expect(view.controller!.displayedMonth!.month, MalayalamMonth.kanni);
    expect(view.controller!.displayedMonth!.year, 1202);
  });

  testWidgets('year view in Gregorian mode', (tester) async {
    await _pumpWithShare(tester,
        settings: enSettings.copyWith(calendarMode: CalendarMode.gregorian));
    await tapTab(tester, 'Calendar');
    await tester.tap(find.byKey(const Key('open-year')));
    await tester.pumpAndSettle();
    expect(find.text('Year 2026'), findsOneWidget);
    expect(find.text('January'), findsOneWidget);
  });
}
