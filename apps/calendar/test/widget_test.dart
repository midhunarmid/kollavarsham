import 'package:calendar/app/app.dart';
import 'package:calendar/app/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

Future<void> _pumpApp(WidgetTester tester,
    {Locale? locale, ThemeMode? themeMode}) async {
  await tester.binding.setSurfaceSize(const Size(480, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    child: CalendarApp(locale: locale, themeMode: themeMode),
  ));
  await tester.pumpAndSettle();
}

String _todayText(WidgetTester tester) => tester
    .widget<Text>(find.descendant(
      of: find.byKey(const Key('today-date')),
      matching: find.byType(Text),
    ))
    .data!;

void main() {
  testWidgets('home shows today and a month view in English', (tester) async {
    await _pumpApp(tester, locale: const Locale('en'));
    expect(find.text('Malayalam Calendar'), findsOneWidget);
    expect(find.byType(MalayalamMonthView), findsOneWidget);
    expect(
      _todayText(tester),
      MalayalamDate.today()
          .format('EEEE, d MMMM y', script: MalayalamScript.english),
    );
  });

  testWidgets('home is localized in Malayalam', (tester) async {
    await _pumpApp(tester, locale: const Locale('ml'));
    expect(find.text('മലയാളം കലണ്ടർ'), findsOneWidget);
    expect(
      _todayText(tester),
      MalayalamDate.today()
          .format('EEEE, d MMMM y', script: MalayalamScript.malayalam),
    );
  });

  testWidgets('dark theme is Material 3 with the bundled font', (tester) async {
    await _pumpApp(tester, themeMode: ThemeMode.dark);
    final theme = Theme.of(tester.element(find.byType(MalayalamMonthView)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.useMaterial3, isTrue);
    expect(theme.textTheme.bodyMedium!.fontFamily, appFontFamily);
  });

  testWidgets('Today button keeps the month view', (tester) async {
    await _pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.byTooltip('Today'));
    await tester.pumpAndSettle();
    expect(find.byType(MalayalamMonthView), findsOneWidget);
  });
}
