import 'dart:convert';

import 'package:calendar/app/settings.dart';
import 'package:calendar/data/database.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/data/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

final _pirannal = NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu);

Future<ProviderContainer> _container() async {
  final prefs = await testPrefs();
  final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('models round-trip through JSON', () {
    const person = Person(
        id: 3, name: 'Midhun', relation: Relation.self, color: 0xFF3949AB);
    expect(Person.fromJson(person.toJson()), person);
    final event = CalendarEvent(
        id: 4,
        personId: 3,
        type: EventType.pirannal,
        recurrence: _pirannal,
        startYear: 1990);
    final back = CalendarEvent.fromJson(
        (jsonDecode(jsonEncode(event.toJson())) as Map)
            .cast<String, Object?>());
    expect(back, event);
    expect(back.recurrence, isA<NakshatraInMonth>());
    const reminder =
        Reminder(id: 5, eventId: 4, daysBefore: 1, minuteOfDay: 1200);
    expect(Reminder.fromJson(reminder.toJson()), reminder);
  });

  test('unknown enum names fall back instead of failing', () {
    final p = Person.fromJson({'id': 1, 'name': 'A', 'relation': 'cousin'});
    expect(p.relation, Relation.other);
    expect(p.color, personColors.first);
  });

  test('an empty database loads as empty tables', () async {
    final db = AppDatabase(await testPrefs());
    final s = db.load();
    expect(s.people, isEmpty);
    expect(s.nextId, 1);
    expect(db.schemaVersion, 1);
  });

  test('save and load keep every table', () async {
    final prefs = await testPrefs();
    final db = AppDatabase(prefs);
    await db.save(DbSnapshot(
      people: const [Person(id: 1, name: 'Amma')],
      events: [
        CalendarEvent(
            id: 2, personId: 1, type: EventType.pirannal, recurrence: _pirannal)
      ],
      reminders: const [Reminder(id: 3, eventId: 2)],
      nextId: 4,
    ));
    final s = AppDatabase(prefs).load();
    expect(s.people.single.name, 'Amma');
    expect(s.events.single.recurrence, isA<NakshatraInMonth>());
    expect(s.reminders.single.eventId, 2);
    expect(s.nextId, 4);
  });

  test('migrations upgrade older documents step by step', () async {
    final prefs = await testPrefs();
    await prefs.setString(
        AppDatabase.key,
        jsonEncode({
          'schema': 1,
          'nextId': 2,
          'people': [
            {'id': 1, 'fullName': 'Ajay'}
          ],
        }));
    // A made-up v2 renames `fullName` to `name`; v3 adds a default relation.
    final db = AppDatabase(prefs, migrations: [
      (json) => {
            ...json,
            'people': [
              for (final p in json['people']! as List)
                {'id': (p as Map)['id'], 'name': p['fullName']},
            ],
          },
      (json) => {
            ...json,
            'people': [
              for (final p in json['people']! as List)
                {...(p as Map), 'relation': 'friend'},
            ],
          },
    ]);
    expect(db.schemaVersion, 3);
    final person = db.load().people.single;
    expect(person.name, 'Ajay');
    expect(person.relation, Relation.friend);

    await db.save(db.load());
    expect(jsonDecode(prefs.getString(AppDatabase.key)!)['schema'], 3);
  });

  test('a newer schema is refused, not overwritten', () async {
    final prefs = await testPrefs();
    await prefs.setString(AppDatabase.key, jsonEncode({'schema': 9}));
    expect(() => AppDatabase(prefs).load(), throwsFormatException);
  });

  group('Repository', () {
    test('inserts assign unique ids and updates replace rows', () async {
      final c = await _container();
      final repo = c.read(repositoryProvider.notifier);
      final a = await repo.savePerson(const Person(id: 0, name: 'Ajay'));
      final m = await repo.savePerson(
          const Person(id: 0, name: 'Midhun', relation: Relation.self));
      expect(a.id, isNot(m.id));
      await repo.savePerson(a.copyWith(name: 'Ajay K'));
      expect(c.read(peopleProvider).map((p) => p.name), ['Midhun', 'Ajay K']);
      expect(c.read(personProvider(a.id))!.name, 'Ajay K');
      expect(c.read(personProvider(999)), isNull);
    });

    test('changes persist to a fresh container', () async {
      final prefs = await testPrefs();
      final c1 = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
      await c1
          .read(repositoryProvider.notifier)
          .savePerson(const Person(id: 0, name: 'Amma'));
      c1.dispose();
      final c2 = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
      addTearDown(c2.dispose);
      expect(c2.read(peopleProvider).single.name, 'Amma');
    });

    test('deleting a person deletes their events and reminders', () async {
      final c = await _container();
      final repo = c.read(repositoryProvider.notifier);
      final p = await repo.savePerson(const Person(id: 0, name: 'Midhun'));
      final other = await repo.savePerson(const Person(id: 0, name: 'Ajay'));
      final e = await repo.saveEvent(CalendarEvent(
          id: 0,
          personId: p.id,
          type: EventType.pirannal,
          recurrence: _pirannal));
      final kept = await repo.saveEvent(CalendarEvent(
          id: 0,
          personId: other.id,
          type: EventType.nakshatram,
          recurrence: NakshatraMonthly(Nakshatra.atham)));
      await repo.saveReminder(Reminder(id: 0, eventId: e.id));
      final keptReminder =
          await repo.saveReminder(Reminder(id: 0, eventId: kept.id));
      expect(c.read(personEventsProvider(p.id)), hasLength(1));
      expect(c.read(eventRemindersProvider(e.id)), hasLength(1));

      await repo.deletePerson(p.id);
      final s = c.read(repositoryProvider);
      expect(s.people.map((x) => x.id), [other.id]);
      expect(s.events.map((x) => x.id), [kept.id]);
      expect(s.reminders.map((x) => x.id), [keptReminder.id]);
    });

    test('deleting an event deletes its reminders', () async {
      final c = await _container();
      final repo = c.read(repositoryProvider.notifier);
      final e = await repo.saveEvent(CalendarEvent(
          id: 0,
          type: EventType.custom,
          title: 'Temple visit',
          recurrence: MalayalamDateYearly(MalayalamMonth.medam, 1)));
      final r = await repo.saveReminder(Reminder(id: 0, eventId: e.id));
      await repo.saveReminder(r.copyWith(daysBefore: 2));
      expect(c.read(eventRemindersProvider(e.id)).single.daysBefore, 2);
      await repo.deleteEvent(e.id);
      expect(c.read(repositoryProvider).reminders, isEmpty);
      expect(c.read(repositoryProvider).events, isEmpty);
    });
  });
}
