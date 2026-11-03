import 'dart:io';

import 'package:calendar/app/app.dart';
import 'package:calendar/app/clock.dart';
import 'package:calendar/app/fonts.dart';
import 'package:calendar/app/settings.dart';
import 'package:calendar/data/festival_days.dart';
import 'package:calendar/data/festival_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings of a user who has finished onboarding.
const doneSettings = AppSettings(onboardingDone: true);

/// English interface settings, past onboarding.
const enSettings =
    AppSettings(language: AppLanguage.english, onboardingDone: true);

/// Malayalam interface settings, past onboarding.
const mlSettings =
    AppSettings(language: AppLanguage.malayalam, onboardingDone: true);

/// Fresh in-memory preferences holding [settings], if given.
Future<SharedPreferences> testPrefs([AppSettings? settings]) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  if (settings != null) await SettingsStore(prefs).save(settings);
  return prefs;
}

/// Pumps the whole app on a tall phone-sized surface; returns its
/// preferences. With [now], the app's clock is fixed at that instant;
/// with [prefs], those preferences are used instead of fresh ones.
Future<SharedPreferences> pumpApp(WidgetTester tester,
    {AppSettings? settings = doneSettings,
    DateTime? now,
    SharedPreferences? prefs,
    Size size = const Size(480, 1400)}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  prefs ??= await testPrefs(settings);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      holidaysProvider.overrideWithValue(bundledHolidays),
      if (now != null) clockProvider.overrideWithValue(() => now),
    ],
    child: const CalendarApp(),
  ));
  await tester.pumpAndSettle();
  return prefs;
}

/// Taps the bottom-bar tab labelled [label].
Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
      of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

/// Opens [location] over the current tab, as a push from the app would.
Future<void> pushRoute(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(NavigationBar))).push(location);
  await tester.pumpAndSettle();
}

/// The app's bundled holiday lists, read from disk as `main` would load
/// them from the asset bundle.
final bundledHolidays = HolidayData.parse([
  for (final f in Directory('assets/holidays').listSync().whereType<File>())
    if (f.path.endsWith('.json')) f.readAsStringSync(),
]);

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader
        .addFont(Future.value(ByteData.sublistView(File(p).readAsBytesSync())));
  }
  await loader.load();
}

/// Loads the real fonts, since tests otherwise draw every glyph as a box.
///
/// Noto Sans Malayalam has no Latin letters; on devices the system font
/// supplies them, so Roboto from the Flutter SDK stands in here.
Future<void> loadRealFonts() async {
  final sdk = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final material = '$sdk/bin/cache/artifacts/material_fonts';
  await _loadFont(appFontFamily, [
    'assets/fonts/NotoSansMalayalam-Regular.ttf',
    'assets/fonts/NotoSansMalayalam-Bold.ttf',
  ]);
  await _loadFont('Roboto', [
    '$material/roboto-regular.ttf',
    '$material/roboto-medium.ttf',
    '$material/roboto-bold.ttf',
  ]);
  await _loadFont('MaterialIcons', ['$material/materialicons-regular.otf']);
}
