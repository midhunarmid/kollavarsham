import 'package:shared_preferences/shared_preferences.dart';

/// Where the database document lives: a text value per key, read from
/// memory and written through.
abstract class DocumentStore {
  /// The text stored under [key], or null.
  String? read(String key);

  /// Stores [text] under [key].
  Future<void> write(String key, String text);
}

/// A [DocumentStore] in [SharedPreferences]: a file on Android, and
/// `localStorage` on the web when IndexedDB is unavailable.
class PrefsDocumentStore implements DocumentStore {
  /// Stores documents in [prefs].
  const PrefsDocumentStore(this.prefs);

  /// The preferences.
  final SharedPreferences prefs;

  @override
  String? read(String key) => prefs.getString(key);

  @override
  Future<void> write(String key, String text) => prefs.setString(key, text);
}

/// The store the database uses instead of preferences: on the web,
/// IndexedDB (set by `main` before the app starts); null elsewhere and in
/// tests, where the database stays in preferences.
DocumentStore? platformDocumentStore;
