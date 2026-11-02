import 'dart:convert';

import 'package:calendar/app/app.dart';
import 'package:calendar/app/clock.dart';
import 'package:calendar/app/settings.dart';
import 'package:calendar/app/share.dart';
import 'package:calendar/backup/backup.dart';
import 'package:calendar/backup/ics.dart';
import 'package:calendar/data/database.dart';
import 'package:calendar/data/festival_days.dart';
import 'package:calendar/data/festival_index.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/features/settings/backup_screen.dart';
import 'package:calendar/l10n/app_localizations.dart';
import 'package:calendar/reminders/reminder_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

final _cal = KollavarshamCalendar.standard;

/// 2 November 2026, 09:00 in Kerala.
final _now = DateTime.utc(2026, 11, 2, 3, 30);

final _db = DbSnapshot(
  people: const [
    Person(id: 1, name: 'Midhun', relation: Relation.self, color: 0xFF3949AB),
  ],
  events: [
    CalendarEvent(
        id: 2,
        personId: 1,
        type: EventType.pirannal,
        recurrence: NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu),
        notes: 'Temple visit, then lunch; family',
        startYear: 1990),
    const CalendarEvent(
        id: 3,
        personId: 1,
        type: EventType.birthday,
        recurrence: GregorianYearly(12, 1)),
  ],
  reminders: const [Reminder(id: 4, eventId: 2, daysBefore: 1)],
  nextId: 5,
);

void main() {
  group('ics', () {
    test('escapes text and folds long lines at 75 octets', () {
      expect(icsEscape(r'a,b;c\d' '\nx'), r'a\,b\;c\\d\nx');
      final long = 'SUMMARY:${'പിറന്നാൾ ' * 20}';
      final folded = icsFold(long);
      for (final line in folded.split('\r\n')) {
        expect(utf8.encode(line).length, lessThanOrEqualTo(75));
      }
      expect(folded.replaceAll('\r\n ', ''), long);
    });

    test('writes all-day events with stable ids', () {
      final day = _cal.fromGregorian(DateTime(2026, 12, 31));
      final text = buildIcs([
        IcsEvent(uid: 'x@y', date: day, summary: 'A, B', description: 'l1\nl2'),
      ], now: _now);
      expect(text, startsWith('BEGIN:VCALENDAR\r\nVERSION:2.0\r\n'));
      expect(text, contains('DTSTART;VALUE=DATE:20261231\r\n'));
      expect(text, contains('DTEND;VALUE=DATE:20270101\r\n'));
      expect(text, contains('SUMMARY:A\\, B\r\n'));
      expect(text, contains('DESCRIPTION:l1\\nl2\r\n'));
      expect(text, contains('DTSTAMP:20261102T033000Z\r\n'));
      expect(text, endsWith('END:VCALENDAR\r\n'));
      expect('\n'.allMatches(text).length, '\r\n'.allMatches(text).length);
    });

    test('expands events into explicit dates for N years', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final today = _cal.fromGregorian(DateTime(2026, 11, 2));
      final events = icsEventsFor(_db.events, {1: _db.people.single}, today, 5,
          l10n, MalayalamScript.english);
      final pirannals =
          events.where((e) => e.summary == "Midhun's Pirannal").toList();
      final birthdays =
          events.where((e) => e.summary == "Midhun's Birthday").toList();
      expect(pirannals, hasLength(5));
      expect(birthdays, hasLength(5));
      for (final p in pirannals) {
        expect(p.date.month, MalayalamMonth.dhanu);
        expect(p.description, contains('Pooradam'));
        expect(p.description, contains('Temple visit'));
      }
      expect(birthdays.first.uid, 'event-3-2026-12-01@calendar.armid.in');
      expect(events.map((e) => e.uid).toSet(), hasLength(events.length));
    });
  });

  group('backup', () {
    Future<SharedPreferences> filled() async {
      final prefs = await testPrefs(enSettings.copyWith(
          malayalamDigits: true,
          location: ObserverLocation.kozhikode,
          categories: {FestivalCategory.hindu}));
      await AppDatabase(prefs).save(_db);
      await ReminderOptionsStore(prefs)
          .save(const ReminderOptions(monthStarts: true, dailyMinute: 330));
      return prefs;
    }

    test('round-trips the database, settings and reminder options', () async {
      final source = await filled();
      final text = createBackup(source, _now);
      final json = jsonDecode(text) as Map<String, dynamic>;
      expect(json['app'], backupApp);
      expect(json['backupVersion'], backupVersion);
      expect(json['createdAt'], '2026-11-02T03:30:00.000Z');

      final target = await testPrefs();
      final backup = Backup.parse(text, AppDatabase(target));
      expect(backup.createdAt, _now);
      await restoreBackup(target, backup);

      final db = AppDatabase(target).load();
      expect(db.people, _db.people);
      expect(db.events, _db.events);
      expect(db.reminders, _db.reminders);
      expect(db.nextId, 5);
      expect(SettingsStore(target).load(), SettingsStore(source).load());
      expect(ReminderOptionsStore(target).load(),
          ReminderOptionsStore(source).load());
      // A second backup of the restored data is the same file.
      expect(createBackup(target, _now), text);
    });

    test('refuses other files and newer versions', () async {
      final db = AppDatabase(await testPrefs());
      for (final bad in [
        'not json',
        '[]',
        '{"app": "other"}',
        jsonEncode({'app': backupApp, 'backupVersion': backupVersion + 1}),
        jsonEncode({
          'app': backupApp,
          'backupVersion': 1,
          'database': {'schema': 99},
        }),
      ]) {
        expect(() => Backup.parse(bad, db), throwsFormatException, reason: bad);
      }
    });

    test('migrates an older database schema in the backup', () async {
      final prefs = await testPrefs();
      final db = AppDatabase(prefs, migrations: [
        (json) => {...json, 'people': json['people'] ?? const []},
      ]);
      final text = jsonEncode({
        'app': backupApp,
        'backupVersion': 1,
        'database': {
          'schema': 1,
          'nextId': 2,
          'people': [
            {'id': 1, 'name': 'Amma'}
          ],
        },
      });
      expect(Backup.parse(text, db).db.people.single.name, 'Amma');
    });
  });

  testWidgets('the backup screen exports, saves and restores', (tester) async {
    final shared = <(List<String>?, String)>[];
    final prefs = await testPrefs(enSettings);
    await AppDatabase(prefs).save(_db);
    final backupText = createBackup(prefs, _now);
    // Start from an empty app and restore into it.
    await AppDatabase(prefs).save(const DbSnapshot());
    String? picked = backupText;

    await tester.binding.setSurfaceSize(const Size(480, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        holidaysProvider.overrideWithValue(bundledHolidays),
        clockProvider.overrideWithValue(() => _now),
        shareProvider
            .overrideWithValue(({text, files, fileNames, subject}) async {
          final data = files == null
              ? ''
              : utf8.decode(await files.single.readAsBytes());
          shared.add((fileNames, data));
        }),
        pickFileProvider.overrideWithValue(() async => picked),
      ],
      child: const CalendarApp(),
    ));
    await tester.pumpAndSettle();
    await tapTab(tester, 'Settings');
    await tester.tap(find.byKey(const Key('settings-backup')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('export-ics')), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('export-ics')))
            .onPressed,
        isNull);

    // A file that isn't a backup.
    picked = '{"app": "other"}';
    await tester.tap(find.byKey(const Key('restore-backup')));
    await tester.pumpAndSettle();
    expect(
        find.text('That file is not a backup from this app.'), findsOneWidget);

    // The real backup, after confirming.
    picked = backupText;
    await tester.tap(find.byKey(const Key('restore-backup')));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 people and 2 events'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-restore')));
    await tester.pumpAndSettle();
    expect(find.text('Backup restored.'), findsOneWidget);
    expect(AppDatabase(prefs).load().events, hasLength(2));
    expect(find.byKey(const Key('export-event-2')), findsOneWidget);

    // Export one event for one year.
    await tester.tap(find.byKey(const Key('export-event-3')));
    await tester.tap(find.text('1 year'));
    await tester.pumpAndSettle();
    expect(find.text('Export 1 date'), findsOneWidget);
    await tester.tap(find.byKey(const Key('export-ics')));
    await tester.pumpAndSettle();
    expect(shared.last.$1, ['malayalam-calendar.ics']);
    expect(shared.last.$2, contains("SUMMARY:Midhun's Pirannal"));

    await tester.tap(find.byKey(const Key('save-backup')));
    await tester.pumpAndSettle();
    expect(shared.last.$1, ['malayalam-calendar-backup-2026-11-02.json']);
    expect(Backup.parse(shared.last.$2, AppDatabase(prefs)).db.events,
        hasLength(2));
  });
}
