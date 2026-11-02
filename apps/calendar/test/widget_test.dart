import 'package:calendar/app/fonts.dart';
import 'package:calendar/app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

String _todayText(WidgetTester tester) => tester
    .widget<Text>(find.descendant(
      of: find.byKey(const Key('today-date')),
      matching: find.byType(Text),
    ))
    .data!;

void main() {
  testWidgets('Today tab shows today in English', (tester) async {
    await pumpApp(tester, settings: enSettings);
    expect(find.text('Malayalam Calendar'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      _todayText(tester),
      MalayalamDate.today()
          .format('EEEE, d MMMM y', script: MalayalamScript.english),
    );
  });

  testWidgets('Today tab is localized in Malayalam', (tester) async {
    await pumpApp(tester, settings: mlSettings);
    expect(find.text('മലയാളം കലണ്ടർ'), findsOneWidget);
    expect(find.text('കലണ്ടർ'), findsOneWidget);
    expect(
      _todayText(tester),
      MalayalamDate.today()
          .format('EEEE, d MMMM y', script: MalayalamScript.malayalam),
    );
  });

  testWidgets('dark theme is Material 3 with the bundled font', (tester) async {
    await pumpApp(tester,
        settings: const AppSettings(themeMode: ThemeMode.dark));
    final theme = Theme.of(tester.element(find.byType(NavigationBar)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.useMaterial3, isTrue);
    expect(theme.textTheme.bodyMedium!.fontFamily, appFontFamily);
  });

  testWidgets('bottom bar switches between the five tabs', (tester) async {
    await pumpApp(tester, settings: enSettings);
    await tapTab(tester, 'Calendar');
    expect(find.byType(MalayalamMonthView), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(AppBar), matching: find.byTooltip('Today')));
    await tester.pumpAndSettle();
    expect(find.byType(MalayalamMonthView), findsOneWidget);

    await tapTab(tester, 'People');
    expect(find.textContaining('pirannal'), findsOneWidget);
    await tapTab(tester, 'Tools');
    expect(find.textContaining('date converter'), findsOneWidget);
    await tapTab(tester, 'Settings');
    expect(find.byKey(const Key('settings-theme')), findsOneWidget);
    await tapTab(tester, 'Today');
    expect(find.byKey(const Key('today-date')), findsOneWidget);
  });

  testWidgets('name script and digits settings reach the Today tab',
      (tester) async {
    await pumpApp(tester,
        settings: enSettings.copyWith(
            nameScript: NameScript.malayalam, malayalamDigits: true));
    expect(
      _todayText(tester),
      MalayalamDate.today().format('EEEE, d MMMM y',
          script: MalayalamScript.malayalam, malayalamDigits: true),
    );
    // The interface stays English.
    expect(find.text('Malayalam Calendar'), findsOneWidget);
  });

  testWidgets('Calendar tab opens in the chosen mode', (tester) async {
    await pumpApp(tester,
        settings: enSettings.copyWith(calendarMode: CalendarMode.gregorian));
    await tapTab(tester, 'Calendar');
    final view =
        tester.widget<MalayalamMonthView>(find.byType(MalayalamMonthView));
    expect(view.mode, CalendarMode.gregorian);
  });
}
