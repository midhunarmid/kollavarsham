import 'package:calendar/app/app.dart';
import 'package:calendar/app/clock.dart';
import 'package:calendar/app/settings.dart';
import 'package:calendar/app/share.dart';
import 'package:calendar/data/database.dart';
import 'package:calendar/data/festival_index.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/features/tools/date_math.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'helpers.dart';

final _cal = KollavarshamCalendar.standard;

/// 2 November 2026, 09:00 in Kerala.
final _now = DateTime.utc(2026, 11, 2, 3, 30);

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

typedef _Shared = ({String? text, List<XFile>? files, List<String>? names});

Future<List<_Shared>> _pump(WidgetTester tester, {DbSnapshot? db}) async {
  final shared = <_Shared>[];
  final prefs = await testPrefs(enSettings);
  if (db != null) await AppDatabase(prefs).save(db);
  await tester.binding.setSurfaceSize(const Size(480, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      holidaysProvider.overrideWithValue(bundledHolidays),
      clockProvider.overrideWithValue(() => _now),
      shareProvider.overrideWithValue((
              {text, files, fileNames, subject}) async =>
          shared.add((text: text, files: files, names: fileNames))),
    ],
    child: const CalendarApp(),
  ));
  await tester.pumpAndSettle();
  return shared;
}

void main() {
  group('date math', () {
    test('days between ignores the time of day', () {
      expect(daysBetween(DateTime(2026, 1, 1, 23), DateTime(2026, 1, 2, 1)), 1);
      expect(daysBetween(DateTime(2026, 3, 1), DateTime(2026, 2, 1)), -28);
      expect(daysBetween(DateTime(2024, 1, 1), DateTime(2025, 1, 1)), 366);
    });

    test('years, months and days', () {
      expect(ymdBetween(DateTime(1990, 1, 15), DateTime(2026, 11, 2)),
          (years: 36, months: 9, days: 18));
      expect(ymdBetween(DateTime(2026, 1, 31), DateTime(2026, 2, 28)),
          (years: 0, months: 1, days: 0));
      expect(ymdBetween(DateTime(2026, 5, 5), DateTime(2026, 5, 5)),
          (years: 0, months: 0, days: 0));
      expect(() => ymdBetween(DateTime(2027), DateTime(2026)),
          throwsArgumentError);
    });

    test('next anniversary, including 29 February', () {
      expect(nextAnniversary(DateTime(1990, 12, 1), DateTime(2026, 11, 2)),
          DateTime.utc(2026, 12, 1));
      expect(nextAnniversary(DateTime(1990, 3, 1), DateTime(2026, 11, 2)),
          DateTime.utc(2027, 3, 1));
      expect(nextAnniversary(DateTime(1990, 11, 2), DateTime(2026, 11, 2)),
          DateTime.utc(2026, 11, 2));
      expect(nextAnniversary(DateTime(2000, 2, 29), DateTime(2026, 11, 2)),
          DateTime.utc(2027, 2, 28));
    });
  });

  testWidgets('the Tools tab lists the tools; the converter shows both dates',
      (tester) async {
    await _pump(tester);
    await tapTab(tester, 'Tools');
    for (final key in [
      'tool-converter',
      'tool-find-star',
      'tool-age',
      'tool-between',
      'tool-year',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('tool-converter')));
    await tester.pumpAndSettle();
    final today = _cal.fromGregorian(DateTime(2026, 11, 2));
    expect(find.text('Monday, November 2, 2026'), findsOneWidget);
    expect(
        find.text(
            today.format('EEEE, d MMMM y', script: MalayalamScript.english)),
        findsOneWidget);

    // Malayalam → English through the Malayalam date picker.
    await tester.tap(find.byKey(const Key('pick-malayalam')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('age and days between', (tester) async {
    await _pump(tester);
    await pushRoute(tester, '/tools/age');
    // Default birth date 1 January 1990, today 2 November 2026.
    expect(find.text('36 years, 10 months, 1 days'), findsOneWidget);
    expect(find.textContaining('Next birthday: Friday, January 1, 2027'),
        findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await pushRoute(tester, '/tools/between');
    expect(find.text('100 days'), findsOneWidget);
    expect(find.text('14 weeks and 2 days'), findsOneWidget);
  });

  testWidgets('Kollavarsham year info', (tester) async {
    await _pump(tester);
    await pushRoute(tester, '/tools/year');
    expect(find.text('Kollavarsham year 1202'), findsOneWidget);
    final chingam = MalayalamDate(1202, MalayalamMonth.chingam, 1);
    final length = chingam.yearLength;
    expect(find.textContaining('$length days, from'), findsOneWidget);
    final row =
        tester.widget<ListTile>(find.byKey(const Key('year-info-Thulam')));
    final thulam = _cal.monthStart(1202, MalayalamMonth.thulam);
    expect(
        (row.subtitle! as Text).data,
        startsWith(
            '${_months[thulam.month - 1]} ${thulam.day}, ${thulam.year} · '
            '${_cal.monthLength(1202, MalayalamMonth.thulam)} days · sankranti '));
    await tester.tap(find.byTooltip('Next year'));
    await tester.pumpAndSettle();
    expect(find.text('Kollavarsham year 1203'), findsOneWidget);
  });

  testWidgets("today's panchangam shares as an image", (tester) async {
    final shared = await _pump(tester);
    await tester.tap(find.byKey(const Key('share-today')));
    await tester.pumpAndSettle();
    expect(find.textContaining('calendar.armid.in'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share-card')));
      // Let the image capture finish outside the fake clock.
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(shared, hasLength(1));
    final file = shared.single.files!.single;
    expect(shared.single.names, ['panchangam-2026-11-02.png']);
    expect(file.mimeType, 'image/png');
    final bytes = await tester.runAsync(file.readAsBytes);
    // PNG signature.
    expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });

  testWidgets('a pirannal greeting card', (tester) async {
    await _pump(tester,
        db: DbSnapshot(
          people: const [Person(id: 1, name: 'Midhun')],
          events: [
            CalendarEvent(
                id: 2,
                personId: 1,
                type: EventType.pirannal,
                recurrence:
                    NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu)),
          ],
          nextId: 3,
        ));
    await pushRoute(tester, '/person/1');
    await tester.tap(find.byKey(const Key('greeting-2')));
    await tester.pumpAndSettle();
    expect(find.text('Happy pirannal, Midhun!'), findsOneWidget);
    expect(find.text('Pooradam'), findsOneWidget);
  });
}
