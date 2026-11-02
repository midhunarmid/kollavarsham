import 'package:calendar/app/locations.dart';
import 'package:calendar/app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

const _dubai = ObserverLocation(
    latitude: 25.2, longitude: 55.27, utcOffset: Duration(hours: 4));

void main() {
  group('SettingsStore', () {
    test('defaults when nothing is stored', () async {
      final prefs = await testPrefs();
      expect(SettingsStore(prefs).load(), const AppSettings());
    });

    test('round-trips every field', () async {
      final prefs = await testPrefs();
      final s = AppSettings(
        language: AppLanguage.malayalam,
        nameScript: NameScript.english,
        malayalamDigits: true,
        location: keralaCityById('kannur')!.location,
        yearStart: YearStart.kanni,
        calendarMode: CalendarMode.gregorian,
        themeMode: ThemeMode.dark,
        onboardingDone: true,
      );
      await SettingsStore(prefs).save(s);
      expect(SettingsStore(prefs).load(), s);
    });

    test('round-trips a manual location', () async {
      final prefs = await testPrefs();
      const s = AppSettings(location: _dubai);
      await SettingsStore(prefs).save(s);
      expect(prefs.getString('settings.location'), 'manual');
      expect(SettingsStore(prefs).load().location, _dubai);
    });

    test('ignores unknown and invalid values', () async {
      SharedPreferences.setMockInitialValues({
        'settings.language': 'tamil',
        'settings.themeMode': 'sepia',
        'settings.location': 'manual',
        'settings.latitude': 95.0,
        'settings.longitude': 10.0,
        'settings.utcOffsetMinutes': 0,
      });
      final prefs = await SharedPreferences.getInstance();
      expect(SettingsStore(prefs).load(), const AppSettings());
    });
  });

  test('isValidLocation', () {
    expect(isValidLocation(8.5, 76.9, 330), isTrue);
    expect(isValidLocation(-33.9, 151.2, 600), isTrue);
    expect(isValidLocation(70, 0, 0), isFalse);
    expect(isValidLocation(0, 181, 0), isFalse);
    expect(isValidLocation(0, 0, 340), isFalse);
    expect(isValidLocation(0, 0, 15 * 60), isFalse);
  });

  test('Kerala cities have unique ids and Kerala coordinates', () {
    expect(keralaCities.map((c) => c.id).toSet(), hasLength(14));
    for (final c in keralaCities) {
      expect(c.location.latitude, inInclusiveRange(8.2, 12.8), reason: c.id);
      expect(c.location.longitude, inInclusiveRange(74.8, 77.5), reason: c.id);
      expect(c.location.utcOffset, const Duration(hours: 5, minutes: 30));
      expect(keralaCityAt(c.location), same(c));
    }
  });

  test('calendarProvider follows location and year start', () async {
    final prefs = await testPrefs();
    final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);
    expect(
        container.read(calendarProvider), same(KollavarshamCalendar.standard));

    await container.read(settingsProvider.notifier).update(
        const AppSettings(location: _dubai, yearStart: YearStart.kanni));
    final cal = container.read(calendarProvider);
    expect(cal.location, _dubai);
    expect(cal.yearStart, YearStart.kanni);
    // Saved for the next start.
    expect(SettingsStore(prefs).load().location, _dubai);
  });

  testWidgets('Settings screen changes and saves the theme and language',
      (tester) async {
    final prefs = await pumpApp(tester, settings: enSettings);
    await tapTab(tester, 'Settings');
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(NavigationBar))).brightness,
        Brightness.dark);
    expect(SettingsStore(prefs).load().themeMode, ThemeMode.dark);

    await tester.tap(find.text('മലയാളം').first);
    await tester.pumpAndSettle();
    expect(find.text('ക്രമീകരണങ്ങൾ'), findsWidgets);
    expect(SettingsStore(prefs).load().language, AppLanguage.malayalam);
  });

  testWidgets('Settings screen picks a city and a manual location',
      (tester) async {
    final prefs = await pumpApp(tester, settings: enSettings);
    await tapTab(tester, 'Settings');

    await tester.tap(find.byKey(const Key('settings-location')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kannur'));
    await tester.pumpAndSettle();
    expect(SettingsStore(prefs).load().location,
        keralaCityById('kannur')!.location);
    expect(find.textContaining('Kannur'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-location')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter coordinates'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('manual-latitude')), '25.2');
    await tester.enterText(find.byKey(const Key('manual-longitude')), '55.27');
    await tester.enterText(find.byKey(const Key('manual-offset')), '20');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter hours from −12 to 14, in quarter hours'),
        findsOneWidget);
    await tester.enterText(find.byKey(const Key('manual-offset')), '4');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(SettingsStore(prefs).load().location, _dubai);
    expect(find.textContaining('25.20, 55.27 (UTC+4:00)'), findsOneWidget);
  });

  testWidgets('Settings screen sets year start, mode, script and digits',
      (tester) async {
    final prefs = await pumpApp(tester, settings: enSettings);
    await tapTab(tester, 'Settings');
    await tester.tap(find.text('Kanni'));
    await tester.tap(find.text('English months'));
    await tester.tap(find.text('Latin'));
    await tester.tap(find.byKey(const Key('settings-digits')));
    await tester.pumpAndSettle();
    final s = SettingsStore(prefs).load();
    expect(s.yearStart, YearStart.kanni);
    expect(s.calendarMode, CalendarMode.gregorian);
    expect(s.nameScript, NameScript.english);
    expect(s.malayalamDigits, isTrue);
  });
}
