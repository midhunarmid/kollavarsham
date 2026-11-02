import 'package:calendar/app/app.dart';
import 'package:calendar/app/fonts.dart';
import 'package:calendar/app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

Future<void> _pumpApp(WidgetTester tester,
    {AppSettings settings = const AppSettings()}) async {
  await tester.binding.setSurfaceSize(const Size(480, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      settingsProvider.overrideWith(() => SettingsController(settings)),
    ],
    child: const CalendarApp(),
  ));
  await tester.pumpAndSettle();
}

String _todayText(WidgetTester tester) => tester
    .widget<Text>(find.descendant(
      of: find.byKey(const Key('today-date')),
      matching: find.byType(Text),
    ))
    .data!;

const _en = AppSettings(language: AppLanguage.english);
const _ml = AppSettings(language: AppLanguage.malayalam);

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
      of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Today tab shows today in English', (tester) async {
    await _pumpApp(tester, settings: _en);
    expect(find.text('Malayalam Calendar'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      _todayText(tester),
      MalayalamDate.today()
          .format('EEEE, d MMMM y', script: MalayalamScript.english),
    );
  });

  testWidgets('Today tab is localized in Malayalam', (tester) async {
    await _pumpApp(tester, settings: _ml);
    expect(find.text('മലയാളം കലണ്ടർ'), findsOneWidget);
    expect(find.text('കലണ്ടർ'), findsOneWidget);
    expect(
      _todayText(tester),
      MalayalamDate.today()
          .format('EEEE, d MMMM y', script: MalayalamScript.malayalam),
    );
  });

  testWidgets('dark theme is Material 3 with the bundled font', (tester) async {
    await _pumpApp(tester,
        settings: const AppSettings(themeMode: ThemeMode.dark));
    final theme = Theme.of(tester.element(find.byType(NavigationBar)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.useMaterial3, isTrue);
    expect(theme.textTheme.bodyMedium!.fontFamily, appFontFamily);
  });

  testWidgets('bottom bar switches between the five tabs', (tester) async {
    await _pumpApp(tester, settings: _en);
    await _tapTab(tester, 'Calendar');
    expect(find.byType(MalayalamMonthView), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(AppBar), matching: find.byTooltip('Today')));
    await tester.pumpAndSettle();
    expect(find.byType(MalayalamMonthView), findsOneWidget);

    await _tapTab(tester, 'People');
    expect(find.textContaining('pirannal'), findsOneWidget);
    await _tapTab(tester, 'Tools');
    expect(find.textContaining('date converter'), findsOneWidget);
    await _tapTab(tester, 'Settings');
    expect(find.byKey(const Key('settings-theme')), findsOneWidget);
    await _tapTab(tester, 'Today');
    expect(find.byKey(const Key('today-date')), findsOneWidget);
  });

  testWidgets('Settings change the theme and language', (tester) async {
    await _pumpApp(tester, settings: _en);
    await _tapTab(tester, 'Settings');
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.byType(NavigationBar))).brightness,
        Brightness.dark);

    await tester.tap(find.text('മലയാളം'));
    await tester.pumpAndSettle();
    expect(find.text('ക്രമീകരണങ്ങൾ'), findsWidgets);
  });
}
