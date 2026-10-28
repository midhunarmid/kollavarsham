import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

Widget _app(Widget child, {ThemeData? theme, double textScale = 1}) =>
    MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  // Chingam 1201: 2025-08-17 to 2025-09-16.
  final chingam1 = MalayalamDate(1201, MalayalamMonth.chingam, 1);

  group('Gregorian mode', () {
    testWidgets('pages through Gregorian months with Malayalam dates',
        (tester) async {
      await tester.pumpWidget(_app(MalayalamMonthView(
        mode: CalendarMode.gregorian,
        initialMonth: chingam1,
      )));
      expect(find.text('August 2025'), findsOneWidget);
      expect(find.text('Karkidakam – Chingam 1201'), findsNothing);
      expect(find.text('Karkidakam 1200 – Chingam 1201'), findsOneWidget);
      // Chingam 1 is labelled where the Malayalam month changes.
      expect(find.text('Chingam 1'), findsOneWidget);
    });

    testWidgets('onMonthChanged reports the first of the Gregorian month',
        (tester) async {
      MalayalamDate? month;
      await tester.pumpWidget(_app(MalayalamMonthView(
        mode: CalendarMode.gregorian,
        initialMonth: chingam1,
        onMonthChanged: (m) => month = m,
      )));
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('September 2025'), findsOneWidget);
      expect(month?.toGregorian(), DateTime(2025, 9, 1));
    });
  });

  group('navigation', () {
    testWidgets('swiping changes month', (tester) async {
      await tester.pumpWidget(_app(MalayalamMonthView(initialMonth: chingam1)));
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Kanni 1201'), findsOneWidget);
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Chingam 1201'), findsOneWidget);
    });

    testWidgets('header opens a month/year chooser', (tester) async {
      await tester.pumpWidget(_app(MalayalamMonthView(initialMonth: chingam1)));
      await tester.tap(find.text('Chingam 1201'));
      await tester.pumpAndSettle();
      expect(find.text('Select month'), findsOneWidget);
      await tester.tap(find.byTooltip('Next year'));
      await tester.pump();
      expect(find.text('1202'), findsOneWidget);
      await tester.tap(find.text('Medam'));
      await tester.pumpAndSettle();
      expect(find.text('Medam 1202'), findsOneWidget);
    });

    testWidgets('chooser disables months outside the bounds', (tester) async {
      await tester.pumpWidget(_app(MalayalamMonthView(
        initialMonth: chingam1,
        firstDate: chingam1,
        lastDate: MalayalamDate(1201, MalayalamMonth.thulam, 10),
      )));
      await tester.tap(find.text('Chingam 1201'));
      await tester.pumpAndSettle();
      final medam = tester.widget<TextButton>(find.ancestor(
          of: find.text('Medam'), matching: find.byType(TextButton)));
      expect(medam.onPressed, isNull);
      final nextYear = tester.widget<IconButton>(find.ancestor(
          of: find.byTooltip('Next year'), matching: find.byType(IconButton)));
      expect(nextYear.onPressed, isNull);
    });

    testWidgets('controller jumps and reports the displayed month',
        (tester) async {
      final controller = MalayalamMonthViewController();
      await tester.pumpWidget(_app(
          MalayalamMonthView(initialMonth: chingam1, controller: controller)));
      expect(controller.displayedMonth, chingam1);
      controller.jumpTo(MalayalamDate(1201, MalayalamMonth.medam, 14));
      await tester.pumpAndSettle();
      expect(find.text('Medam 1201'), findsOneWidget);
      expect(controller.displayedMonth?.month, MalayalamMonth.medam);
      controller.previous();
      await tester.pumpAndSettle();
      expect(find.text('Meenam 1201'), findsOneWidget);
    });
  });

  group('markers and theme', () {
    testWidgets('festival markers appear with semantics', (tester) async {
      final handle = tester.ensureSemantics();
      final onam = KollavarshamCalendar.standard.onam(1201);
      await tester.pumpWidget(_app(MalayalamMonthView(
        initialMonth: onam,
        eventLoader: festivalEventLoader(),
      )));
      expect(find.bySemanticsLabel(RegExp('^20 Chingam 1201.*1 event\$')),
          findsOneWidget);
      handle.dispose();
    });

    testWidgets('custom marker builder receives the events', (tester) async {
      await tester.pumpWidget(_app(MalayalamMonthView(
        initialMonth: chingam1,
        eventLoader: (d) => d.day == 5 ? ['a', 'b'] : const [],
        markerBuilder: (context, date, events) =>
            Text('×${events.length}', key: ValueKey('m${date.day}')),
      )));
      expect(find.byKey(const ValueKey('m5')), findsOneWidget);
      expect(find.text('×2'), findsOneWidget);
    });

    testWidgets('theme extension overrides colours', (tester) async {
      const red = Color(0xFFFF0000);
      await tester.pumpWidget(_app(
        MalayalamMonthView(initialMonth: chingam1, selectedDate: chingam1),
        theme: ThemeData(extensions: const [
          KollavarshamCalendarTheme(selectedColor: red),
        ]),
      ));
      final materials = tester.widgetList<Material>(find.descendant(
          of: find.byType(MalayalamMonthView),
          matching: find.byType(Material)));
      expect(materials.any((m) => m.color == red), isTrue);
    });
  });

  group('robustness', () {
    for (final scale in [1.0, 2.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('no overflow at text scale $scale, $brightness',
            (tester) async {
          await tester.pumpWidget(_app(
            MalayalamMonthView(
              initialMonth: chingam1,
              showNakshatra: true,
              eventLoader: festivalEventLoader(),
            ),
            theme: ThemeData(brightness: brightness),
            textScale: scale,
          ));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(_app(
            MalayalamMonthView(
              mode: CalendarMode.gregorian,
              initialMonth: chingam1,
              script: MalayalamScript.malayalam,
              showNakshatra: true,
            ),
            theme: ThemeData(brightness: brightness),
            textScale: scale,
          ));
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('Malayalam strings for tooltips', (tester) async {
      await tester.pumpWidget(_app(MalayalamMonthView(
          initialMonth: chingam1, script: MalayalamScript.malayalam)));
      expect(find.byTooltip('അടുത്ത മാസം'), findsOneWidget);
      expect(find.byTooltip('മുൻ മാസം'), findsOneWidget);
    });
  });
}
