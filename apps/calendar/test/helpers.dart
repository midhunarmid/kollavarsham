import 'package:calendar/app/app.dart';
import 'package:calendar/app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
/// preferences.
Future<SharedPreferences> pumpApp(WidgetTester tester,
    {AppSettings? settings = doneSettings}) async {
  await tester.binding.setSurfaceSize(const Size(480, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final prefs = await testPrefs(settings);
  await tester.pumpWidget(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
