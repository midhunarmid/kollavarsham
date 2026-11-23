import 'package:shared_preferences/shared_preferences.dart';

import '../data/store.dart';
import 'browser.dart';

/// Outside a browser: [NoBrowser].
BrowserApi browser() => NoBrowser();

/// Outside a browser there is no IndexedDB.
Future<DocumentStore?> openStore(SharedPreferences prefs) async => null;
