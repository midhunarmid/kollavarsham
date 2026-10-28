import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

Widget _app(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  // Chingam 1201: 2025-08-17 (Sunday) to 2025-09-16, 31 days.
  final chingam1 = MalayalamDate(1201, MalayalamMonth.chingam, 1);

  testWidgets('month view shows the month and its days', (tester) async {
    await tester.pumpWidget(_app(MalayalamMonthView(initialMonth: chingam1)));
    expect(find.text('Chingam 1201'), findsOneWidget);
    expect(find.text('Aug – Sep 2025'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('31'), findsWidgets); // Chingam 31 and Aug 31
    expect(find.text('32'), findsNothing);
  });

  testWidgets('uses Malayalam script for the ml locale', (tester) async {
    await tester.pumpWidget(_app(Builder(
      builder: (context) => Localizations.override(
        context: context,
        locale: const Locale('ml'),
        child:
            MalayalamMonthView(initialMonth: chingam1, malayalamDigits: true),
      ),
    )));
    expect(find.text('ചിങ്ങം ൧൨൦൧'), findsOneWidget);
    expect(find.text('ഞാ'), findsOneWidget);
  });

  testWidgets('tapping a day selects it; arrows navigate', (tester) async {
    MalayalamDate? picked;
    MalayalamDate? month;
    await tester.pumpWidget(_app(MalayalamMonthView(
      initialMonth: chingam1,
      showSecondaryDate: false,
      onDateSelected: (d) => picked = d,
      onMonthChanged: (m) => month = m,
    )));
    await tester.tap(find.text('10'));
    expect(picked, MalayalamDate(1201, MalayalamMonth.chingam, 10));

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('Kanni 1201'), findsOneWidget);
    expect(month, MalayalamDate(1201, MalayalamMonth.kanni, 1));

    await tester.tap(find.byTooltip('Previous month'));
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('Karkidakam 1200'), findsOneWidget);
  });

  testWidgets('dates outside the bounds are disabled', (tester) async {
    MalayalamDate? picked;
    await tester.pumpWidget(_app(MalayalamMonthView(
      initialMonth: chingam1,
      firstDate: chingam1.addDays(4),
      lastDate: chingam1.addDays(20),
      showSecondaryDate: false,
      onDateSelected: (d) => picked = d,
    )));
    await tester.tap(find.text('2'));
    expect(picked, isNull);
    await tester.tap(find.text('5'));
    expect(picked?.day, 5);
    final prev = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left));
    expect(prev.onPressed, isNull);
  });

  testWidgets('shows nakshatra when asked', (tester) async {
    final onamMonth = MalayalamDate(1201, MalayalamMonth.chingam, 20);
    await tester.pumpWidget(
        _app(MalayalamMonthView(initialMonth: onamMonth, showNakshatra: true)));
    expect(find.text('Thiruvonam'), findsWidgets);
  });

  testWidgets('date picker returns the chosen date', (tester) async {
    MalayalamDate? result;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showMalayalamDatePicker(
            context: context, initialDate: chingam1),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Njayar, 1 Chingam 1201'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^7 Chingam 1201')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, MalayalamDate(1201, MalayalamMonth.chingam, 7));
  });

  testWidgets('MalayalamDateText formats', (tester) async {
    await tester.pumpWidget(_app(MalayalamDateText(
      date: chingam1,
      pattern: 'd MMMM y',
      script: MalayalamScript.malayalam,
    )));
    expect(find.text('1 ചിങ്ങം 1201'), findsOneWidget);
  });
}
