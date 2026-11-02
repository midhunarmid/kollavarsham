import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// The contents of the database: the `people`, `events` and `reminders`
/// tables, each in id order.
@immutable
class DbSnapshot {
  /// Creates a snapshot.
  const DbSnapshot({
    this.people = const [],
    this.events = const [],
    this.reminders = const [],
    this.nextId = 1,
  });

  /// People.
  final List<Person> people;

  /// Events, with or without a person.
  final List<CalendarEvent> events;

  /// Reminders of events.
  final List<Reminder> reminders;

  /// The next free id; ids are unique across all tables.
  final int nextId;

  /// A copy with the given tables replaced.
  DbSnapshot copyWith({
    List<Person>? people,
    List<CalendarEvent>? events,
    List<Reminder>? reminders,
    int? nextId,
  }) =>
      DbSnapshot(
        people: people ?? this.people,
        events: events ?? this.events,
        reminders: reminders ?? this.reminders,
        nextId: nextId ?? this.nextId,
      );
}

/// A database migration: upgrades the JSON of schema version `n` to `n + 1`.
typedef Migration = Map<String, Object?> Function(Map<String, Object?> json);

/// The local database: three tables kept as one versioned JSON document in
/// [SharedPreferences], which is a file on Android and `localStorage` on
/// the web.
///
/// The tables hold a few hundred rows at most, so the whole document is
/// rewritten on every change. Each schema change bumps [schemaVersion] and
/// adds a step to [migrations].
class AppDatabase {
  /// Opens the database in [prefs].
  AppDatabase(this.prefs, {List<Migration>? migrations})
      : migrations = migrations ?? defaultMigrations;

  /// Preferences holding the database.
  final SharedPreferences prefs;

  /// Steps from schema version `i + 1` to `i + 2`; version 1 is the first.
  final List<Migration> migrations;

  /// Preferences key of the database document.
  static const key = 'db';

  /// The current schema version.
  int get schemaVersion => migrations.length + 1;

  /// Migrations of the shipped schema versions (none yet).
  static const defaultMigrations = <Migration>[];

  /// Reads the database, migrating an older document to [schemaVersion].
  ///
  /// Throws a [FormatException] for a document newer than this app, so it
  /// is never overwritten by an older version.
  DbSnapshot load() {
    final text = prefs.getString(key);
    if (text == null) return const DbSnapshot();
    var json = (jsonDecode(text) as Map).cast<String, Object?>();
    var version = json['schema'] as int? ?? 1;
    if (version > schemaVersion) {
      throw FormatException('Database schema $version is newer than '
          'this app ($schemaVersion)');
    }
    while (version < schemaVersion) {
      json = migrations[version - 1](json);
      version++;
    }
    return fromJson(json);
  }

  /// Writes [db].
  Future<void> save(DbSnapshot db) =>
      prefs.setString(key, jsonEncode(toJson(db)));

  /// Reads the tables of a document at [schemaVersion].
  static DbSnapshot fromJson(Map<String, Object?> json) {
    List<T> table<T>(String name, T Function(Map<String, Object?>) read) => [
          for (final row in json[name] as List? ?? const [])
            read((row as Map).cast<String, Object?>()),
        ];
    return DbSnapshot(
      people: table('people', Person.fromJson),
      events: table('events', CalendarEvent.fromJson),
      reminders: table('reminders', Reminder.fromJson),
      nextId: json['nextId'] as int? ?? 1,
    );
  }

  /// The document of [db], at [schemaVersion].
  Map<String, Object?> toJson(DbSnapshot db) => {
        'schema': schemaVersion,
        'nextId': db.nextId,
        'people': [for (final p in db.people) p.toJson()],
        'events': [for (final e in db.events) e.toJson()],
        'reminders': [for (final r in db.reminders) r.toJson()],
      };
}
