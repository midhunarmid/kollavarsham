import 'dart:io';

import 'package:calendar/app/app.dart';
import 'package:calendar/app/clock.dart';
import 'package:calendar/app/report.dart';
import 'package:calendar/app/settings.dart';
import 'package:calendar/app/version.dart';
import 'package:calendar/data/database.dart';
import 'package:calendar/data/festival_days.dart';
import 'package:calendar/data/festival_index.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/data/occurrences.dart';
import 'package:calendar/l10n/app_localizations.dart';
import 'package:calendar/reminders/home_widgets.dart';
import 'package:calendar/reminders/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

final _cal = KollavarshamCalendar.standard;
final _en = lookupAppLocalizations(const Locale('en'));

/// 2 November 2026, 09:00 in Kerala.
final _now = DateTime.utc(2026, 11, 2, 3, 30);

void main() {
  test('the app version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
        RegExp(r'^version: (\S+?)\+', multiLine: true).firstMatch(pubspec)![1],
        appVersion);
  });

  group('home-screen widget data', () {
    final today = _cal.fromGregorian(DateTime(2026, 11, 2));
    final events = EventIndex(
      const [
        CalendarEvent(
            id: 2,
            personId: 1,
            type: EventType.birthday,
            recurrence: GregorianYearly(11, 5)),
      ],
      const [Person(id: 1, name: 'Midhun')],
      _cal,
    );
    final data = homeWidgetData(
      today: today,
      festivals:
          FestivalIndex(_cal, bundledHolidays, {...FestivalCategory.values}),
      events: events,
      l10n: _en,
      script: MalayalamScript.english,
    );

    test('a week of text ahead, keyed by date', () {
      for (var i = 0; i < widgetDays; i++) {
        final g = DateTime(2026, 11, 2 + i);
        final key = '${g.year}-${g.month.toString().padLeft(2, '0')}-'
            '${g.day.toString().padLeft(2, '0')}';
        final day = _cal.fromGregorian(g);
        expect(data['today.$key.date'],
            day.format('d MMMM y', script: MalayalamScript.english));
        expect(data['today.$key.star'], contains(day.nakshatra.english));
        expect(data['next.$key.title'], "Midhun's Birthday");
      }
      expect(data['next.2026-11-02.when'], endsWith('in 3 days'));
      expect(data['next.2026-11-05.when'], endsWith('today'));
      // After it, the next one is a year away.
      expect(data['next.2026-11-06.when'], endsWith('in 364 days'));
      // Deepavali on 8 November.
      expect(data['today.2026-11-08.festival'], contains('Deepavali'));
      expect(data['today.2026-11-02.festival'], '');
    });

    test("last week's keys are deleted", () {
      expect(data.containsKey('today.2026-11-01.date'), isTrue);
      expect(data['today.2026-11-01.date'], isNull);
      expect(data['next.2026-10-26.title'], isNull);
      expect(data.containsKey('today.2026-10-25.date'), isFalse);
    });
  });

  group('wrong-date report', () {
    final day = _cal.fromGregorian(DateTime(2026, 11, 8));

    test('opens a pre-filled issue', () {
      final uri = wrongDateReport(
          day,
          FestivalIndex(_cal, bundledHolidays, {...FestivalCategory.values})
              .on(day),
          appVersion: '0.1.0');
      expect(uri.toString(), startsWith(issuesUrl));
      final q = uri.queryParameters;
      expect(q['title'], 'Wrong date: 2026-11-08');
      expect(q['labels'], 'wrong-date');
      expect(q['body'], contains('Thulam'));
      expect(q['body'], contains('Deepavali'));
      expect(q['body'], contains('Thiruvananthapuram'));
      expect(q['body'], contains('app 0.1.0'));
    });

    test('leaves out manual coordinates', () {
      final manual = KollavarshamCalendar(
          location: const ObserverLocation(
              latitude: 12.3456,
              longitude: 76.5432,
              utcOffset: Duration(hours: 4)));
      final uri = wrongDateReport(
          manual.fromGregorian(DateTime(2026, 11, 8)), const [],
          appVersion: '0.1.0');
      final body = uri.queryParameters['body']!;
      expect(body, contains('manual location (UTC+04:00)'));
      expect(body, isNot(contains('12.3')));
      expect(body, isNot(contains('76.5')));
    });
  });

  testWidgets('the Day screen opens the report', (tester) async {
    final opened = <Uri>[];
    final prefs = await testPrefs(enSettings);
    await tester.binding.setSurfaceSize(const Size(480, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        holidaysProvider.overrideWithValue(bundledHolidays),
        clockProvider.overrideWithValue(() => _now),
        openUrlProvider.overrideWithValue((uri) async {
          opened.add(uri);
          return true;
        }),
      ],
      child: const CalendarApp(),
    ));
    await tester.pumpAndSettle();
    await pushRoute(tester, '/day/2026-11-08');
    await tester.tap(find.byKey(const Key('day-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report a wrong date'));
    await tester.pumpAndSettle();
    expect(opened.single.queryParameters['title'], 'Wrong date: 2026-11-08');
  });

  group('North Malabar year (Kanni 1)', () {
    final kanni = KollavarshamCalendar(yearStart: YearStart.kanni);

    test('the year-start reminder is for Kanni 1', () {
      final list = ReminderScheduler(
        calendar: kanni,
        l10n: _en,
        script: MalayalamScript.english,
        options: const ReminderOptions(),
      ).schedule(const DbSnapshot(), DateTime.utc(2027, 9, 1));
      expect(list.single.title,
          startsWith('Kanni 1 tomorrow: Malayalam New Year'));
      expect(list.single.date.month, MalayalamMonth.kanni);
    });

    testWidgets('year info and the year view start at Kanni', (tester) async {
      await pumpApp(tester,
          settings: enSettings.copyWith(yearStart: YearStart.kanni), now: _now);
      await pushRoute(tester, '/tools/year');
      final rows = tester
          .widgetList<ListTile>(find.byWidgetPredicate(
              (w) => w is ListTile && '${w.key}'.contains('year-info-')))
          .map((t) => (t.title! as Text).data)
          .toList();
      expect(rows.first, 'Kanni');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapTab(tester, 'Calendar');
      await tester.tap(find.byKey(const Key('open-year')));
      await tester.pumpAndSettle();
      final first = tester.widget<Text>(find
          .descendant(
              of: find.byKey(const Key('mini-month-0')),
              matching: find.byType(Text))
          .first);
      expect(first.data, 'Kanni');
    });
  });
}
