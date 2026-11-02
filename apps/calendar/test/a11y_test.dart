import 'package:calendar/data/database.dart';
import 'package:calendar/data/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

/// 25 August 2026, 10:00 in Kerala: the day before Thiruvonam.
final _now = DateTime.utc(2026, 8, 25, 4, 30);

final _db = DbSnapshot(
  people: const [Person(id: 1, name: 'Midhun', relation: Relation.self)],
  events: [
    CalendarEvent(
        id: 2,
        personId: 1,
        type: EventType.pirannal,
        recurrence: NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu)),
  ],
  nextId: 3,
);

/// Screens to check, as routes.
const _routes = [
  '/today',
  '/calendar',
  '/calendar/agenda',
  '/calendar/year',
  '/day/2026-08-26',
  '/festival/hindu.onam',
  '/people',
  '/person/1',
  '/event/2/edit',
  '/tools',
  '/tools/converter',
  '/tools/year',
  '/settings',
  '/settings/reminders',
  '/settings/backup',
];

Future<void> _open(WidgetTester tester, String route) async {
  if (route.split('/').length == 2) {
    // A tab: switch to it.
    GoRouter.of(tester.element(find.byType(NavigationBar))).go(route);
    await tester.pumpAndSettle();
  } else {
    await pushRoute(tester, route);
  }
}

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final route in _routes) {
      testWidgets('$route meets the guidelines (${theme.name})',
          (tester) async {
        final handle = tester.ensureSemantics();
        final prefs = await testPrefs(enSettings.copyWith(themeMode: theme));
        await AppDatabase(prefs).save(_db);
        await pumpApp(tester, settings: null, prefs: prefs, now: _now);
        await _open(tester, route);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  }

  for (final (name, settings) in [
    ('English', enSettings),
    ('Malayalam', mlSettings),
  ]) {
    testWidgets('large text (200%) lays out without overflow in $name',
        (tester) async {
      final prefs = await testPrefs(settings);
      await AppDatabase(prefs).save(_db);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester,
          settings: null, prefs: prefs, now: _now, size: const Size(360, 780));
      for (final route in _routes) {
        await _open(tester, route);
        expect(tester.takeException(), isNull, reason: route);
        if (route.split('/').length > 2) {
          // Some screens close rather than go back; pop either way.
          GoRouter.of(tester.element(find.byType(Scaffold).last)).pop();
          await tester.pumpAndSettle();
        }
      }
    });
  }
}
