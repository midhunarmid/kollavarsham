import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/store.dart';
import 'browser_stub.dart' if (dart.library.js_interop) 'browser_web.dart'
    as platform;

/// What the web app needs from the browser: lasting storage, installing,
/// and new versions. On Android (and in tests) [NoBrowser] stands in.
abstract class BrowserApi {
  /// Whether the app runs in a browser.
  bool get isWeb;

  /// Whether the browser keeps this site's storage from automatic
  /// clearing; null if unknown.
  Future<bool?> storagePersisted();

  /// Asks the browser to keep this site's storage; returns the result, or
  /// null if the browser can't say.
  Future<bool?> requestPersistentStorage();

  /// Whether the browser offers to install the app now.
  bool get canInstall;

  /// Whether the app runs installed (standalone).
  bool get isInstalled;

  /// Whether this is iOS or iPadOS, where installing is manual (Share →
  /// Add to Home Screen).
  bool get isIos;

  /// Shows the browser's install prompt; true if the user accepted.
  Future<bool> install();

  /// Whether a newer version has been downloaded and a reload shows it.
  bool get updateReady;

  /// Reloads the app.
  void reload();

  /// Notifies when [canInstall] or [updateReady] change.
  Listenable get changes;
}

/// The [BrowserApi] outside a browser: nothing to persist, install or
/// update.
class NoBrowser implements BrowserApi {
  /// Creates it.
  NoBrowser();

  @override
  bool get isWeb => false;

  @override
  Future<bool?> storagePersisted() async => null;

  @override
  Future<bool?> requestPersistentStorage() async => null;

  @override
  bool get canInstall => false;

  @override
  bool get isInstalled => false;

  @override
  bool get isIos => false;

  @override
  Future<bool> install() async => false;

  @override
  bool get updateReady => false;

  @override
  void reload() {}

  @override
  final Listenable changes = ChangeNotifier();
}

/// The browser, or [NoBrowser] on Android; tests override it.
final browserProvider = Provider<BrowserApi>((ref) => platform.browser());

/// Opens the web app's IndexedDB document store, moving a database left in
/// `localStorage` (by versions before IndexedDB) into it. Null outside a
/// browser, or when IndexedDB can't be opened (the database then stays in
/// preferences, as before).
Future<DocumentStore?> openBrowserStore(SharedPreferences prefs) =>
    platform.openStore(prefs);
