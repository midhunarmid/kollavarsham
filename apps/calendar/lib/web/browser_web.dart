import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/store.dart';
import 'browser.dart';

/// `window.calendarBrowser`, defined by web/browser.js.
@JS('calendarBrowser')
external _Shim? get _shim;

extension type _Shim._(JSObject _) implements JSObject {
  external JSPromise<JSString?> get(String key);
  external JSPromise<JSAny?> set(String key, String value);
  external JSPromise<JSBoolean?> persisted();
  external JSPromise<JSBoolean?> persist();
  external bool canInstall();
  external bool standalone();
  external bool ios();
  external JSPromise<JSBoolean> install();
  external bool updateReady();
  external void reload();
  external void listen(JSFunction callback);
}

class _WebBrowser implements BrowserApi {
  _WebBrowser(this._js) {
    _js.listen((() => _changes.notify()).toJS);
  }

  final _Shim _js;
  final _changes = _Notifier();

  @override
  bool get isWeb => true;

  @override
  Future<bool?> storagePersisted() async =>
      (await _js.persisted().toDart)?.toDart;

  @override
  Future<bool?> requestPersistentStorage() async =>
      (await _js.persist().toDart)?.toDart;

  @override
  bool get canInstall => _js.canInstall();

  @override
  bool get isInstalled => _js.standalone();

  @override
  bool get isIos => _js.ios();

  @override
  Future<bool> install() async => (await _js.install().toDart).toDart;

  @override
  bool get updateReady => _js.updateReady();

  @override
  void reload() => _js.reload();

  @override
  Listenable get changes => _changes;
}

class _Notifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Without web/browser.js (e.g. `flutter run -d chrome` before it loads),
/// the app still runs, as a browser without those features.
class _BareBrowser extends NoBrowser {
  @override
  bool get isWeb => true;
}

/// The browser, through web/browser.js.
BrowserApi browser() {
  final js = _shim;
  return js == null ? _BareBrowser() : _WebBrowser(js);
}

/// The database document in IndexedDB, cached in memory so reads stay
/// synchronous; writes go through to IndexedDB.
class _IndexedDbStore implements DocumentStore {
  _IndexedDbStore(this._js, this._cache);

  final _Shim _js;
  final Map<String, String> _cache;

  @override
  String? read(String key) => _cache[key];

  @override
  Future<void> write(String key, String text) async {
    _cache[key] = text;
    await _js.set(key, text).toDart;
  }
}

/// Keys of documents kept in IndexedDB rather than preferences.
const _documentKeys = ['db'];

/// Opens the IndexedDB store, moving documents still in `localStorage`
/// into it.
Future<DocumentStore?> openStore(SharedPreferences prefs) async {
  final js = _shim;
  if (js == null) return null;
  try {
    final cache = <String, String>{};
    for (final key in _documentKeys) {
      final stored = (await js.get(key).toDart)?.toDart;
      if (stored != null) {
        cache[key] = stored;
        continue;
      }
      final old = prefs.getString(key);
      if (old == null) continue;
      await js.set(key, old).toDart;
      cache[key] = old;
      await prefs.remove(key);
    }
    return _IndexedDbStore(js, cache);
  } catch (e) {
    debugPrint('IndexedDB unavailable, keeping localStorage: $e');
    return null;
  }
}
