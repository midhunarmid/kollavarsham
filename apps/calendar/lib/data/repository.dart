import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/settings.dart';
import 'database.dart';
import 'models.dart';

/// The database, opened on the app's preferences.
final databaseProvider = Provider<AppDatabase>(
    (ref) => AppDatabase(ref.watch(sharedPreferencesProvider)));

/// Holds the database contents and writes every change through.
///
/// Inserts take an id of 0 and return the row with its new id. Deleting a
/// person deletes their events, and deleting an event its reminders.
class Repository extends Notifier<DbSnapshot> {
  @override
  DbSnapshot build() => ref.watch(databaseProvider).load();

  Future<void> _commit(DbSnapshot next) {
    state = next;
    return ref.read(databaseProvider).save(next);
  }

  (int, int) _allocate(int id) =>
      id == 0 ? (state.nextId, state.nextId + 1) : (id, state.nextId);

  static List<T> _upsert<T>(List<T> rows, T row, bool Function(T) same) {
    final i = rows.indexWhere(same);
    return i < 0 ? [...rows, row] : ([...rows]..[i] = row);
  }

  /// Inserts or updates [person]; returns it as saved.
  Future<Person> savePerson(Person person) async {
    final (id, nextId) = _allocate(person.id);
    final saved = person.copyWith(id: id);
    await _commit(state.copyWith(
      people: _upsert(state.people, saved, (p) => p.id == id),
      nextId: nextId,
    ));
    return saved;
  }

  /// Deletes the person with [id], their events and those events' reminders.
  Future<void> deletePerson(int id) {
    final events = {
      for (final e in state.events)
        if (e.personId == id) e.id,
    };
    return _commit(state.copyWith(
      people: [...state.people.where((p) => p.id != id)],
      events: [...state.events.where((e) => !events.contains(e.id))],
      reminders: [...state.reminders.where((r) => !events.contains(r.eventId))],
    ));
  }

  /// Inserts or updates [event]; returns it as saved.
  Future<CalendarEvent> saveEvent(CalendarEvent event) async {
    final (id, nextId) = _allocate(event.id);
    final saved = event.copyWith(id: id);
    await _commit(state.copyWith(
      events: _upsert(state.events, saved, (e) => e.id == id),
      nextId: nextId,
    ));
    return saved;
  }

  /// Deletes the event with [id] and its reminders.
  Future<void> deleteEvent(int id) => _commit(state.copyWith(
        events: [...state.events.where((e) => e.id != id)],
        reminders: [...state.reminders.where((r) => r.eventId != id)],
      ));

  /// Inserts or updates [reminder]; returns it as saved.
  Future<Reminder> saveReminder(Reminder reminder) async {
    final (id, nextId) = _allocate(reminder.id);
    final saved = reminder.copyWith(id: id);
    await _commit(state.copyWith(
      reminders: _upsert(state.reminders, saved, (r) => r.id == id),
      nextId: nextId,
    ));
    return saved;
  }

  /// Deletes the reminder with [id].
  Future<void> deleteReminder(int id) => _commit(state.copyWith(
        reminders: [...state.reminders.where((r) => r.id != id)],
      ));
}

/// The database contents and the operations on them.
final repositoryProvider =
    NotifierProvider<Repository, DbSnapshot>(Repository.new);

/// People, the user first, then by name.
final peopleProvider = Provider<List<Person>>((ref) {
  final people = [...ref.watch(repositoryProvider).people];
  return people
    ..sort((a, b) {
      final self = (b.relation == Relation.self ? 1 : 0) -
          (a.relation == Relation.self ? 1 : 0);
      if (self != 0) return self;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
});

/// The person with an id, or null if there is none.
final personProvider = Provider.family<Person?, int>((ref, id) {
  for (final p in ref.watch(repositoryProvider).people) {
    if (p.id == id) return p;
  }
  return null;
});

/// The events of the person with an id.
final personEventsProvider =
    Provider.family<List<CalendarEvent>, int>((ref, id) => [
          for (final e in ref.watch(repositoryProvider).events)
            if (e.personId == id) e,
        ]);

/// The reminders of the event with an id.
final eventRemindersProvider =
    Provider.family<List<Reminder>, int>((ref, id) => [
          for (final r in ref.watch(repositoryProvider).reminders)
            if (r.eventId == id) r,
        ]);
