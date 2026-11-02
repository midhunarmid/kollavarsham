import 'package:calendar/app/clock.dart';
import 'package:calendar/app/app.dart';
import 'package:calendar/app/settings.dart';
import 'package:calendar/data/database.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/features/day/day_screen.dart';
import 'package:calendar/l10n/app_localizations.dart';
import 'package:calendar/reminders/notifications.dart';
import 'package:calendar/reminders/reminder_options.dart';
import 'package:calendar/reminders/reminder_service.dart';
import 'package:calendar/reminders/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// Records what would be scheduled.
class FakeSink implements NotificationSink {
  final syncs = <List<ScheduledNotification>>[];
  int permissionRequests = 0;

  @override
  Future<void> sync(
      List<ScheduledNotification> list, AppLocalizations l10n) async {
    syncs.add(list);
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<bool?> canScheduleExact() async => false;

  @override
  Future<void> requestExactAlarms() async {}
}

/// 2 November 2026, 09:00 in Kerala.
final _now = DateTime.utc(2026, 11, 2, 3, 30);

final _db = DbSnapshot(
  people: const [Person(id: 1, name: 'Midhun')],
  events: const [
    CalendarEvent(
        id: 2,
        personId: 1,
        type: EventType.birthday,
        recurrence: GregorianYearly(12, 1)),
  ],
  reminders: const [Reminder(id: 3, eventId: 2)],
  nextId: 4,
);

Future<(FakeSink, SharedPreferences)> _pump(WidgetTester tester,
    {DbSnapshot? db}) async {
  final prefs = await testPrefs(enSettings);
  if (db != null) await AppDatabase(prefs).save(db);
  final sink = FakeSink();
  await tester.binding.setSurfaceSize(const Size(480, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      clockProvider.overrideWithValue(() => _now),
      notificationSinkProvider.overrideWithValue(sink),
    ],
    child: const CalendarApp(),
  ));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  return (sink, prefs);
}

void main() {
  test('payloads round-trip; junk decodes to null', () {
    const p = NotificationPayload('/day/2026-12-01', 'T', 'B', 'events');
    final back = NotificationPayload.decode(p.encode())!;
    expect((back.route, back.title, back.body, back.channel),
        ('/day/2026-12-01', 'T', 'B', 'events'));
    expect(NotificationPayload.decode('nope'), isNull);
    expect(NotificationPayload.decode(null), isNull);
  });

  test('each kind has a channel', () {
    expect(channelOf(NotificationKind.event), 'events');
    expect(channelOf(NotificationKind.festival), 'calendar');
    expect(channelOf(NotificationKind.daily), 'daily');
  });

  test('notification language follows the app, else the device', () {
    var (l10n, script) = notificationLanguage(enSettings, const Locale('ml'));
    expect((l10n.localeName, script), ('en', MalayalamScript.english));
    (l10n, script) = notificationLanguage(
        const AppSettings(onboardingDone: true), const Locale('ml', 'IN'));
    expect((l10n.localeName, script), ('ml', MalayalamScript.malayalam));
    (l10n, script) = notificationLanguage(
        enSettings.copyWith(nameScript: NameScript.malayalam),
        const Locale('en'));
    expect(script, MalayalamScript.malayalam);
  });

  test('the background job schedules from stored data', () async {
    final prefs = await testPrefs(enSettings);
    await AppDatabase(prefs).save(_db);
    final sink = FakeSink();
    await rescheduleFromPrefs(prefs, sink, _now);
    final birthday = sink.syncs.single.where((n) => n.eventId == 2).single;
    expect(birthday.title, "Midhun's birthday");
    expect(birthday.time, DateTime.utc(2026, 12, 1, 1, 30));
  });

  testWidgets('the app schedules on start and after changes', (tester) async {
    final (sink, _) = await _pump(tester, db: _db);
    expect(sink.syncs, isNotEmpty);
    expect(sink.syncs.last.where((n) => n.eventId == 2), hasLength(1));

    await tapTab(tester, 'Settings');
    await tester.tap(find.byKey(const Key('settings-reminders')));
    await tester.pumpAndSettle();
    expect(find.text('1 reminder in the next 60 days'), findsOneWidget);

    // Turning birthdays off reschedules without it.
    await tester.tap(find.byKey(const Key('remind-birthday')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(sink.syncs.last.where((n) => n.eventId == 2), isEmpty);
    expect(find.text('No reminders in the next 60 days'), findsOneWidget);
  });

  testWidgets('reminder settings are saved', (tester) async {
    final (_, prefs) = await _pump(tester);
    await pushRoute(tester, '/settings/reminders');
    await tester.tap(find.byKey(const Key('remind-month-starts')));
    await tester.tap(find.byKey(const Key('remind-festival-christian')));
    await tester.tap(find.byKey(const Key('remind-daily')));
    await tester.pumpAndSettle();
    final o = ReminderOptionsStore(prefs).load();
    expect(o.monthStarts, isTrue);
    expect(o.festivals.map((f) => f.name), ['christian']);
    expect(o.dailyPanchangam, isTrue);

    // The master switch disables the rest.
    await tester.tap(find.byKey(const Key('reminders-enabled')));
    await tester.pumpAndSettle();
    expect(ReminderOptionsStore(prefs).load().enabled, isFalse);
    expect(find.text('No reminders in the next 60 days'), findsOneWidget);
    expect(
        tester
            .widget<SwitchListTile>(find.byKey(const Key('remind-daily')))
            .onChanged,
        isNull);
  });

  testWidgets('a new event asks for the notification permission',
      (tester) async {
    final (sink, _) = await _pump(tester, db: _db);
    await pushRoute(tester, '/event/new?person=1');
    await tester.tap(find.byKey(const Key('save-event')));
    await tester.pumpAndSettle();
    expect(sink.permissionRequests, 1);
  });

  testWidgets('a tapped notification opens its day', (tester) async {
    await _pump(tester);
    notificationRoute.value = '/day/2026-12-01';
    await tester.pumpAndSettle();
    expect(tester.widget<DayScreen>(find.byType(DayScreen)).date,
        DateTime(2026, 12, 1));
    expect(notificationRoute.value, isNull);
  });
}
