import 'dart:io';

import 'package:calendar/data/database.dart';
import 'package:calendar/data/festival_days.dart';
import 'package:calendar/data/festival_index.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

final _cal = KollavarshamCalendar.standard;

MalayalamDate _d(int y, int m, int d) => _cal.fromGregorian(DateTime(y, m, d));

/// 2 November 2026, 09:00 in Kerala.
final _now = DateTime.utc(2026, 11, 2, 3, 30);

Future<HolidayData> _bundled() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  return loadHolidays(rootBundle);
}

void main() {
  test('the bundled lists are copies of data/holidays', () {
    final source = Directory('../../data/holidays')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    expect(source, isNotEmpty);
    for (final f in source) {
      final name = f.uri.pathSegments.last;
      final copy = File('assets/holidays/$name');
      expect(copy.existsSync(), isTrue,
          reason: 'Run dart run tool/sync_holidays.dart');
      expect(copy.readAsStringSync(), f.readAsStringSync(),
          reason: '$name differs; run dart run tool/sync_holidays.dart');
    }
  });

  test('loads every year and every entry', () async {
    final data = await _bundled();
    expect(data.byYear.keys, containsAll([2026, 2027]));
    expect(data.inYear(2026), hasLength(32));
    expect(data.inYear(2030), isEmpty);
    final mannam = data.inYear(2026).first;
    expect(mannam.name, 'Mannam Jayanthi');
    expect(mannam.category, FestivalCategory.government);
    expect(mannam.kind, HolidayKind.public);
    expect(mannam.source, startsWith('https://'));
  });

  test('a malformed file or entry is skipped', () {
    final data = HolidayData.parse([
      '{"year": 2030, "holidays": [{"date": "2030-01-01", "name": "X", '
          '"category": "nope", "kind": "public", "source": "https://x"}]}',
      'not json',
      '{"year": 2031, "holidays": []}',
    ]);
    expect(data.byYear.keys, [2031]);
  });

  group('merging', () {
    late HolidayData data;
    setUpAll(() async => data = await _bundled());

    List<FestivalDay> on(MalayalamDate d,
            [Set<FestivalCategory> c = const {...FestivalCategory.values}]) =>
        festivalDaysBetween(_cal, d, d, categories: c, holidays: data);

    test('a listed computed festival becomes a holiday, not a duplicate', () {
      final onam = on(_d(2026, 8, 26));
      expect(onam.map((f) => f.english), ['Thiruvonam']);
      expect(onam.single.holiday, HolidayKind.public);
      expect(onam.single.malayalam, 'തിരുവോണം');
      expect(onam.single.source, startsWith('https://'));
      final deepavali = on(_d(2026, 11, 8));
      expect(deepavali.single.english, 'Deepavali');
      expect(deepavali.single.holiday, HolidayKind.public);
      final christmas = on(_d(2026, 12, 25));
      expect(christmas.single.english, 'Christmas');
      expect(christmas.single.holiday, HolidayKind.public);
    });

    test('other entries stand on their own', () {
      final first = on(_d(2026, 8, 25));
      expect(first.map((f) => f.english),
          containsAll(['First Onam', 'Milad-i-Sherif']));
      final aug28 = on(_d(2026, 8, 28)).map((f) => f.english).toList();
      expect(aug28, containsAll(['Fourth Onam', 'Ayyankali Jayanthi']));
      final avittom =
          on(_d(2026, 8, 28)).firstWhere((f) => f.english == 'Avani Avittom');
      expect(avittom.holiday, HolidayKind.restricted);
      final bank = on(_d(2026, 4, 1)).single;
      expect(bank.category, FestivalCategory.bank);
      expect(bank.holiday, HolidayKind.bank);
    });

    test('an announced Muslim date replaces the computed one', () {
      // Data: Id-ul Fitr on 20 March 2026; the tabular date differs.
      final announced = DateTime(2026, 3, 20);
      final computed = hijriFestivalsIn(2026)
          .firstWhere((e) => e.$1 == HijriFestival.eidUlFitr)
          .$2;
      final range = festivalDaysBetween(_cal, _d(2026, 3, 10), _d(2026, 3, 30),
          categories: {FestivalCategory.muslim}, holidays: data);
      final eid = range.where((f) => f.english == 'Eid ul-Fitr').toList();
      expect(eid, hasLength(1));
      expect(eid.single.date.toGregorian(), announced);
      expect(eid.single.tentative, isTrue);
      expect(eid.single.holiday, HolidayKind.public);
      // No second item under the data's own name.
      expect(range.where((f) => f.english.contains('Id-ul')), isEmpty);
      if (computed != announced) {
        expect(on(_cal.fromGregorian(computed), {FestivalCategory.muslim}),
            isEmpty);
      }
    });

    test('categories filter both sources', () {
      final national = festivalDaysBetween(
          _cal, _d(2026, 1, 1), _d(2026, 12, 31),
          categories: {FestivalCategory.national}, holidays: data);
      expect(national.map((f) => f.english), contains('Independence Day'));
      expect(national.every((f) => f.category == FestivalCategory.national),
          isTrue);
      // Without data, a year without a file still has computed festivals.
      final computed = festivalDaysBetween(
          _cal, _d(2030, 1, 1), _d(2030, 12, 31),
          categories: {FestivalCategory.hindu, FestivalCategory.christian});
      expect(
          computed.map((f) => f.english), containsAll(['Vishu', 'Christmas']));
    });
  });

  test('the category filter is saved', () async {
    final prefs = await testPrefs(enSettings
        .copyWith(categories: {FestivalCategory.hindu, FestivalCategory.bank}));
    expect(SettingsStore(prefs).load().categories,
        {FestivalCategory.hindu, FestivalCategory.bank});
  });

  testWidgets('the agenda lists, filters and searches', (tester) async {
    final prefs = await testPrefs(enSettings);
    await AppDatabase(prefs).save(DbSnapshot(
      people: const [Person(id: 1, name: 'Midhun')],
      events: [
        const CalendarEvent(
            id: 2,
            personId: 1,
            type: EventType.birthday,
            recurrence: GregorianYearly(12, 1)),
      ],
      nextId: 3,
    ));
    await pumpApp(tester, settings: null, prefs: prefs, now: _now);
    await tapTab(tester, 'Calendar');
    await tester.tap(find.byKey(const Key('open-agenda')));
    await tester.pumpAndSettle();
    expect(find.text('Deepavali'), findsWidgets);
    expect(find.text("Midhun's Birthday"), findsOneWidget);

    await tester.enterText(find.byKey(const Key('agenda-search')), 'midhun');
    await tester.pumpAndSettle();
    expect(find.text("Midhun's Birthday"), findsOneWidget);
    expect(find.text('Deepavali'), findsNothing);

    await tester.enterText(find.byKey(const Key('agenda-search')), 'christ');
    await tester.pumpAndSettle();
    expect(find.text('Christmas'), findsOneWidget);
    await tester.tap(find.byKey(const Key('filter-christian')));
    await tester.pumpAndSettle();
    expect(find.text('Christmas'), findsNothing);
    expect(find.text('Nothing found in the next year.'), findsOneWidget);
    expect(SettingsStore(prefs).load().categories,
        isNot(contains(FestivalCategory.christian)));

    await tester.enterText(find.byKey(const Key('agenda-search')), 'ദീപാവലി');
    await tester.pumpAndSettle();
    expect(find.text('Deepavali'), findsNWidgets(2));
  });
}
