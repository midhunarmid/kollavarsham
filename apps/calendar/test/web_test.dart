import 'package:calendar/app/settings.dart';
import 'package:calendar/app/share.dart';
import 'package:calendar/backup/backup_status.dart';
import 'package:calendar/data/database.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/data/repository.dart';
import 'package:calendar/web/browser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

/// A browser whose answers the test sets.
class FakeBrowser extends NoBrowser {
  bool? persisted = false;
  int persistRequests = 0;
  bool installable = false;
  bool installed = false;
  bool ios = false;
  int installs = 0;
  bool update = false;
  int reloads = 0;
  final _changes = ChangeNotifier();

  void changed() =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _changes.notifyListeners();

  @override
  bool get isWeb => true;
  @override
  Future<bool?> storagePersisted() async => persisted;
  @override
  Future<bool?> requestPersistentStorage() async {
    persistRequests++;
    return persisted = true;
  }

  @override
  bool get canInstall => installable;
  @override
  bool get isInstalled => installed;
  @override
  bool get isIos => ios;
  @override
  Future<bool> install() async {
    installs++;
    installable = false;
    changed();
    return true;
  }

  @override
  bool get updateReady => update;
  @override
  void reload() => reloads++;
  @override
  Listenable get changes => _changes;
}

/// An in-memory document store.
class MemoryStore implements DocumentStore {
  final docs = <String, String>{};
  @override
  String? read(String key) => docs[key];
  @override
  Future<void> write(String key, String text) async => docs[key] = text;
}

final _now = DateTime.utc(2026, 11, 23, 6);

const _db = DbSnapshot(
  people: [Person(id: 1, name: 'Midhun')],
  events: [
    CalendarEvent(
        id: 2,
        personId: 1,
        type: EventType.birthday,
        recurrence: GregorianYearly(12, 1)),
  ],
  nextId: 3,
);

void main() {
  test('the database reads and writes through its document store', () async {
    final prefs = await testPrefs();
    final store = MemoryStore();
    await AppDatabase(prefs, store: store).save(_db);
    expect(prefs.getString(AppDatabase.key), isNull);
    expect(store.docs[AppDatabase.key], contains('Midhun'));
    expect(
        AppDatabase(prefs, store: store).load().people.single.name, 'Midhun');
  });

  test('a backup is due with events and none in 30 days, unless snoozed', () {
    final now = DateTime.utc(2026, 11, 23);
    expect(const BackupStatus().shouldNudge(now, 0), isFalse);
    expect(const BackupStatus().shouldNudge(now, 1), isTrue);
    expect(
        BackupStatus(lastBackup: now.subtract(const Duration(days: 10)))
            .shouldNudge(now, 1),
        isFalse);
    expect(
        BackupStatus(lastBackup: now.subtract(const Duration(days: 31)))
            .shouldNudge(now, 1),
        isTrue);
    expect(
        BackupStatus(nudgeSnoozedUntil: now.add(const Duration(days: 1)))
            .shouldNudge(now, 1),
        isFalse);
  });

  testWidgets('Android shows no web suggestions', (tester) async {
    final prefs = await testPrefs(enSettings);
    await AppDatabase(prefs).save(_db);
    await pumpApp(tester, settings: null, prefs: prefs, now: _now);
    expect(find.byKey(const Key('backup-nudge')), findsNothing);
    expect(find.byKey(const Key('install-card')), findsNothing);
  });

  testWidgets('the web reminds to back up; saving or "Not now" hides it',
      (tester) async {
    final prefs = await testPrefs(enSettings);
    await AppDatabase(prefs).save(_db);
    final browser = FakeBrowser();
    await pumpApp(tester, settings: null, prefs: prefs, now: _now, overrides: [
      browserProvider.overrideWithValue(browser),
      shareProvider
          .overrideWithValue(({text, files, fileNames, subject}) async {}),
    ]);
    expect(find.text('Your data lives only in this browser'), findsOneWidget);

    await tester.tap(find.byKey(const Key('backup-nudge-save')));
    await tester.pumpAndSettle();
    expect(find.text('No backup saved yet.'), findsOneWidget);
    expect(find.textContaining('may clear it'), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-backup')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Last backup: '), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('backup-nudge')), findsNothing);

    // Thirty-one days later it comes back; "Not now" hides it for a week.
    final later = _now.add(const Duration(days: 31));
    await pumpApp(tester, settings: null, prefs: prefs, now: later, overrides: [
      browserProvider.overrideWithValue(browser),
      shareProvider
          .overrideWithValue(({text, files, fileNames, subject}) async {}),
    ]);
    expect(find.byKey(const Key('backup-nudge')), findsOneWidget);
    await tester.tap(find.byKey(const Key('backup-nudge-later')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('backup-nudge')), findsNothing);
  });

  testWidgets('install card: the prompt, the iOS steps, and dismissing',
      (tester) async {
    final browser = FakeBrowser()..installable = true;
    final prefs = await pumpApp(tester,
        settings: enSettings,
        now: _now,
        overrides: [browserProvider.overrideWithValue(browser)]);
    expect(find.text('Install the app'), findsOneWidget);
    await tester.tap(find.byKey(const Key('install-now')));
    await tester.pumpAndSettle();
    expect(browser.installs, 1);
    expect(find.byKey(const Key('install-card')), findsNothing);

    final iphone = FakeBrowser()..ios = true;
    await pumpApp(tester, settings: null, prefs: prefs, now: _now, overrides: [
      browserProvider.overrideWithValue(iphone),
    ]);
    expect(find.textContaining('Add to Home Screen'), findsOneWidget);
    expect(find.byKey(const Key('install-now')), findsNothing);
    await tester.tap(find.byKey(const Key('install-later')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('install-card')), findsNothing);

    // Dismissed for good, and never shown when already installed.
    await pumpApp(tester, settings: null, prefs: prefs, now: _now, overrides: [
      browserProvider.overrideWithValue(FakeBrowser()..installable = true),
    ]);
    expect(find.byKey(const Key('install-card')), findsNothing);
  });

  testWidgets('a new version shows a reload snackbar', (tester) async {
    final browser = FakeBrowser();
    await pumpApp(tester,
        settings: enSettings,
        now: _now,
        overrides: [browserProvider.overrideWithValue(browser)]);
    expect(find.text('A new version is ready.'), findsNothing);
    browser
      ..update = true
      ..changed();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('A new version is ready.'), findsOneWidget);
    await tester.tap(find.text('Reload'));
    expect(browser.reloads, 1);
  });

  test('the first person asks the browser to keep its storage', () async {
    final prefs = await testPrefs(enSettings);
    final browser = FakeBrowser();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      browserProvider.overrideWithValue(browser),
    ]);
    addTearDown(container.dispose);
    final repo = container.read(repositoryProvider.notifier);
    await repo.savePerson(const Person(id: 0, name: 'Midhun'));
    await repo.savePerson(const Person(id: 0, name: 'Anu'));
    await Future<void>.delayed(Duration.zero);
    expect(browser.persistRequests, 1);
  });
}
