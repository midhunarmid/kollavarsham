import 'package:calendar/app/router.dart';
import 'package:calendar/features/day/day_info.dart';
import 'package:calendar/features/day/day_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

/// 25 August 2026, 10:00 in Kerala: the day before Thiruvonam.
final _now = DateTime.utc(2026, 8, 25, 4, 30);

final _cal = KollavarshamCalendar.standard;

void main() {
  group('DayInfo', () {
    final day = _cal.fromGregorian(DateTime(2026, 8, 25));
    final info = DayInfo.of(day);

    test('spans run from sunrise past the next sunrise', () {
      final sunrise = _cal.sunrise(DateTime(2026, 8, 25))!;
      final nextSunrise = _cal.sunrise(DateTime(2026, 8, 26))!;
      for (final spans in [info.nakshatras, info.tithis, info.yogas]) {
        expect(spans.first.contains(sunrise), isTrue);
        expect(spans.last.end.isAfter(nextSunrise), isTrue);
        for (var i = 1; i < spans.length; i++) {
          expect(spans[i].start.difference(spans[i - 1].end).inSeconds.abs(),
              lessThan(5));
        }
      }
      expect(
          info.nakshatras.first.value, _cal.nakshatraOn(DateTime(2026, 8, 25)));
      expect(info.tithis.first.value, _cal.tithiOn(DateTime(2026, 8, 25)));
      expect(info.paksha, info.tithis.first.value.paksha);
    });

    test('has the three kalams in order and no month-start note', () {
      expect(info.kalams.map((k) => k.value), shownKalams);
      expect(info.monthStartMargin, isNull);
      expect(info.monthStartIsClose, isFalse);
    });

    test('a month start carries its margin', () {
      final first = MalayalamDate(1202, MalayalamMonth.chingam, 1);
      final margin = DayInfo.of(first).monthStartMargin;
      expect(margin, _cal.monthStartMargin(1202, MalayalamMonth.chingam));
    });

    test('next festival is Onam, the day after', () {
      final (festival, date) = nextFestival(day)!;
      expect(festival, KeralaFestival.onam);
      expect(day.daysUntil(date), 1);
    });

    test('local time adds the location offset', () {
      expect(localTime(DateTime.utc(2026, 1, 1, 0, 30), _cal),
          DateTime.utc(2026, 1, 1, 6));
    });
  });

  group('day paths', () {
    test('round-trip', () {
      final d = DateTime(2026, 3, 5);
      expect(AppRoutes.dayPath(d), '/day/2026-03-05');
      expect(AppRoutes.parseDay('2026-03-05'), d);
    });

    test('reject malformed and rolled-over dates', () {
      expect(AppRoutes.parseDay('2026-02-30'), isNull);
      expect(AppRoutes.parseDay('2026-3-5'), isNull);
      expect(AppRoutes.parseDay(null), isNull);
    });
  });

  testWidgets('Today shows the panchangam and the next festival',
      (tester) async {
    await pumpApp(tester, settings: enSettings, now: _now);
    final info = DayInfo.of(_cal.fromGregorian(DateTime(2026, 8, 25)));
    final star = info.nakshatras.first.value.name(MalayalamScript.english);
    expect(
        find.descendant(
            of: find.byKey(const Key('row-nakshatra')),
            matching: find.textContaining(star)),
        findsOneWidget);
    expect(find.text('Rahu Kalam'), findsOneWidget);
    expect(find.text('No festival today'), findsOneWidget);
    expect(find.text('Thiruvonam'), findsOneWidget);
    expect(find.textContaining('tomorrow'), findsOneWidget);

    await tester.tap(find.byKey(const Key('next-festival')));
    await tester.pumpAndSettle();
    final screen = tester.widget<DayScreen>(find.byType(DayScreen));
    expect(screen.date, DateTime(2026, 8, 26));
    expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
  });

  testWidgets('Today is in Malayalam with a Malayalam interface',
      (tester) async {
    await pumpApp(tester, settings: mlSettings, now: _now);
    expect(find.text('പഞ്ചാംഗം'), findsOneWidget);
    expect(find.text('തിരുവോണം'), findsOneWidget);
    expect(find.textContaining('നാളെ'), findsOneWidget);
  });

  testWidgets('Day detail pages to the previous and next day', (tester) async {
    await pumpApp(tester, settings: enSettings, now: _now);
    await tester.tap(find.byKey(const Key('today-details')));
    await tester.pumpAndSettle();
    expect(tester.widget<DayScreen>(find.byType(DayScreen)).date,
        DateTime(2026, 8, 25));
    expect(find.text('Moonrise'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);

    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();
    expect(tester.widget<DayScreen>(find.byType(DayScreen)).date,
        DateTime(2026, 8, 26));
    expect(find.widgetWithText(ListTile, 'Thiruvonam'), findsOneWidget);

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Previous day'));
      await tester.pumpAndSettle();
    }
    expect(tester.widget<DayScreen>(find.byType(DayScreen)).date,
        DateTime(2026, 8, 24));

    // Back returns to the Today tab.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-date')), findsOneWidget);
  });

  testWidgets('tapping a day in the Calendar tab opens it', (tester) async {
    await pumpApp(tester, settings: enSettings, now: _now);
    await tapTab(tester, 'Calendar');
    final view =
        tester.widget<MalayalamMonthView>(find.byType(MalayalamMonthView));
    view.onDateSelected!(_cal.fromGregorian(DateTime(2026, 8, 20)));
    await tester.pumpAndSettle();
    expect(tester.widget<DayScreen>(find.byType(DayScreen)).date,
        DateTime(2026, 8, 20));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MalayalamMonthView), findsOneWidget);
  });
}
