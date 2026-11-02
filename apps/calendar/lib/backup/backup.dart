import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';

/// Identifies a backup file of this app.
const backupApp = 'in.armid.calendar';

/// Current backup format; bump it and teach [Backup.parse] the old one
/// when the format changes.
const backupVersion = 1;

/// A backup: the database, the settings and the reminder options.
class Backup {
  /// Creates a backup of [db], [settings] and [reminders].
  const Backup(this.db, this.settings, this.reminders, this.createdAt);

  /// Reads a backup of the current or an older version.
  ///
  /// Throws a [FormatException] for anything else, including a backup from
  /// a newer app.
  factory Backup.parse(String text, AppDatabase database) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException('Not a backup file');
    }
    if (decoded is! Map || decoded['app'] != backupApp) {
      throw const FormatException('Not a backup file');
    }
    final version = decoded['backupVersion'];
    if (version is! int || version > backupVersion) {
      throw FormatException('Backup version $version is not supported');
    }
    final dbJson = (decoded['database'] as Map).cast<String, Object?>();
    final schema = dbJson['schema'] as int? ?? 1;
    if (schema > database.schemaVersion) {
      throw FormatException('Database schema $schema is newer than this app');
    }
    var migrated = dbJson;
    for (var v = schema; v < database.schemaVersion; v++) {
      migrated = database.migrations[v - 1](migrated);
    }
    return Backup(
      AppDatabase.fromJson(migrated),
      ((decoded['settings'] as Map?) ?? const {}).cast<String, Object?>(),
      ((decoded['reminders'] as Map?) ?? const {}).cast<String, Object?>(),
      DateTime.tryParse(decoded['createdAt'] as String? ?? ''),
    );
  }

  /// The database contents.
  final DbSnapshot db;

  /// Stored settings, as preference key–value pairs.
  final Map<String, Object?> settings;

  /// Stored reminder options, as preference key–value pairs.
  final Map<String, Object?> reminders;

  /// When the backup was made.
  final DateTime? createdAt;
}

Map<String, Object?> _prefsWithPrefix(SharedPreferences prefs, String prefix) =>
    {
      for (final k in prefs.getKeys())
        if (k.startsWith(prefix)) k: prefs.get(k),
    };

/// The backup file of everything in [prefs], stamped [now].
String createBackup(SharedPreferences prefs, DateTime now) {
  final database = AppDatabase(prefs);
  return const JsonEncoder.withIndent('  ').convert({
    'app': backupApp,
    'backupVersion': backupVersion,
    'createdAt': now.toUtc().toIso8601String(),
    'database': database.toJson(database.load()),
    'settings': _prefsWithPrefix(prefs, 'settings.'),
    'reminders': _prefsWithPrefix(prefs, 'reminders.'),
  });
}

Future<void> _restorePrefs(
    SharedPreferences prefs, String prefix, Map<String, Object?> values) async {
  for (final MapEntry(:key, :value) in values.entries) {
    if (!key.startsWith(prefix)) continue;
    switch (value) {
      case bool v:
        await prefs.setBool(key, v);
      case int v:
        await prefs.setInt(key, v);
      case double v:
        await prefs.setDouble(key, v);
      case String v:
        await prefs.setString(key, v);
      case List v:
        await prefs.setStringList(key, [for (final s in v) '$s']);
    }
  }
}

/// Replaces the database, settings and reminder options in [prefs] with
/// [backup]'s. Settings that the backup lacks keep their values.
Future<void> restoreBackup(SharedPreferences prefs, Backup backup) async {
  await AppDatabase(prefs).save(backup.db);
  await _restorePrefs(prefs, 'settings.', backup.settings);
  await _restorePrefs(prefs, 'reminders.', backup.reminders);
  // Whatever was restored, the user has been through onboarding here.
  await prefs.setBool('settings.onboardingDone', true);
}
