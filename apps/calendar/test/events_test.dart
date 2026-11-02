import 'package:calendar/data/database.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/data/occurrences.dart';
import 'package:calendar/features/events/event_draft.dart';
import 'package:calendar/features/people/person_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

/// 2 November 2026, 09:00 in Kerala.
final _now = DateTime.utc(2026, 11, 2, 3, 30);

final _cal = KollavarshamCalendar.standard;

/// The star read for a day: at sunrise + 6 nazhika (rule R3).
Nakshatra _starOf(MalayalamDate d) => _cal.nakshatraAt(
    _cal.sunrise(d.toGregorian())!.add(const Duration(minutes: 144)));

Future<void> _select<T>(WidgetTester tester, T value) async {
  final dropdown = find.byType(DropdownButton<T>);
  tester.widget<DropdownButton<T>>(dropdown).onChanged!(value);
  await tester.pumpAndSettle();
}

void main() {
  group('EventDraft', () {
    test('builds the rule of each type and reads it back', () {
      final drafts = [
        EventDraft()
          ..nakshatra = Nakshatra.pooradam
          ..month = MalayalamMonth.dhanu,
        EventDraft()
          ..setType(EventType.nakshatram)
          ..nakshatra = Nakshatra.atham,
        EventDraft()
          ..setType(EventType.shraddham)
          ..tithi = 23
          ..month = MalayalamMonth.karkidakam,
        EventDraft()
          ..setType(EventType.shraddham)
          ..setShraddhamByStar(true)
          ..nakshatra = Nakshatra.bharani
          ..month = MalayalamMonth.medam,
        EventDraft()
          ..setType(EventType.birthday)
          ..gregorianMonth = 3
          ..gregorianDay = 14,
        for (final kind in CustomKind.values)
          EventDraft()
            ..setType(EventType.custom)
            ..title = 'Custom'
            ..customKind = kind
            ..month = MalayalamMonth.medam
            ..malayalamDay = 5
            ..gregorianMonth = 6
            ..gregorianDay = 1
            ..tithi = 11
            ..paksha = Paksha.shukla,
      ];
      for (final d in drafts) {
        final event = d.toEvent();
        final back = EventDraft.fromEvent(event).toEvent();
        expect(back.recurrence.toJson(), event.recurrence.toJson(),
            reason: '${d.type} ${d.customKind}');
      }
      expect(drafts[0].recurrence,
          NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu));
      expect(drafts[2].recurrence, isA<TithiInMonth>());
      expect(drafts[7].recurrence, const GregorianYearly(6, 1));
    });

    test('shraddham by star defaults to the first day, others the second', () {
      final d = EventDraft()..setType(EventType.shraddham);
      expect(d.duplicateRule, DuplicateRule.second);
      d.setShraddhamByStar(true);
      expect(d.duplicateRule, DuplicateRule.first);
      d.setType(EventType.pirannal);
      expect(d.duplicateRule, DuplicateRule.second);
    });

    test('birth details fill a pirannal', () {
      final details = BirthDetails.fromLocalTime(DateTime(1990, 1, 1, 6));
      final d = EventDraft()..applyBirthDetails(details);
      expect(d.nakshatra, details.nakshatra);
      expect(d.month, details.date.month);
      expect(d.startYear, 1990);
    });
  });

  testWidgets('Midhun: Pooradam in Dhanu, yearly and monthly', (tester) async {
    final prefs = await pumpApp(tester, settings: enSettings, now: _now);
    await tapTab(tester, 'People');
    await tester.tap(find.byKey(const Key('add-person')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('person-name')), 'Midhun');
    await tester.tap(find.byKey(const Key('relation-self')));
    await tester.tap(find.byKey(const Key('save-person')));
    await tester.pumpAndSettle();

    // A first event defaults to a pirannal.
    await tester.tap(find.byKey(const Key('add-event')));
    await tester.pumpAndSettle();
    expect(find.text('New event'), findsOneWidget);
    expect(find.text('Pirannal'), findsOneWidget);
    expect(find.text('Second day'), findsOneWidget);
    await _select(tester, Nakshatra.pooradam);
    // Pick the month through the menu.
    await tester.tap(find.byKey(const Key('event-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dhanu').last);
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: find.byKey(const Key('event-previews')),
            matching: find.byType(Text)),
        findsNWidgets(3));
    await tester.tap(find.byKey(const Key('save-event')));
    await tester.pumpAndSettle();

    // Then the monthly nakshatram.
    await tester.tap(find.byKey(const Key('add-event')));
    await tester.pumpAndSettle();
    await _select(tester, EventType.nakshatram);
    expect(find.text('Second day'), findsNothing);
    await _select(tester, Nakshatra.pooradam);
    await tester.tap(find.byKey(const Key('save-event')));
    await tester.pumpAndSettle();

    final db = AppDatabase(prefs).load();
    final midhun = db.people.single;
    final pirannal = db.events.firstWhere((e) => e.type == EventType.pirannal);
    final monthly = db.events.firstWhere((e) => e.type == EventType.nakshatram);
    expect(pirannal.personId, midhun.id);
    expect(pirannal.recurrence,
        NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu));
    expect(monthly.recurrence, const NakshatraMonthly(Nakshatra.pooradam));
    // Each new event gets a same-day reminder at 07:00.
    expect(db.reminders.map((r) => (r.daysBefore, r.minuteOfDay)),
        [(0, 420), (0, 420)]);

    // The next 5 pirannals: one in each Dhanu, on a Pooradam day.
    final today = _cal.fromGregorian(DateTime(2026, 11, 2));
    final years = nextOccurrences(pirannal.recurrence, today, 5);
    expect(years, hasLength(5));
    for (final (i, d) in years.indexed) {
      expect(d.month, MalayalamMonth.dhanu);
      expect(d.year, 1202 + i);
      expect(_starOf(d), Nakshatra.pooradam);
    }
    // Dhanu 1202 runs from mid-December 2026 to mid-January 2027.
    expect(years.first.toGregorian().isAfter(DateTime(2026, 12, 15)), isTrue);

    // The next 12 nakshatram days, each a Pooradam day. The star can be
    // read on two days running (it is wider than a day's motion of the
    // Moon); otherwise the days are a lunar month apart.
    final months = nextOccurrences(monthly.recurrence, today, 12);
    expect(months, hasLength(12));
    var cycles = 1;
    for (var i = 0; i < months.length; i++) {
      expect(_starOf(months[i]), Nakshatra.pooradam);
      if (i > 0) {
        final gap = months[i - 1].daysUntil(months[i]);
        if (gap != 1) {
          expect(gap, inInclusiveRange(24, 29));
          cycles++;
        }
      }
    }
    expect(cycles, greaterThanOrEqualTo(8));
    expect(months, contains(years.first));

    // The detail lists both, soonest first, with countdowns.
    expect(find.byType(PersonScreen), findsOneWidget);
    final tiles = tester
        .widgetList<ListTile>(find.byWidgetPredicate(
            (w) => w is ListTile && '${w.key}'.contains('event-')))
        .toList();
    expect(tiles, hasLength(2));
    expect((tiles.first.title! as Text).data, 'Nakshatram');
    expect((tiles.first.subtitle! as Text).data,
        contains('in ${today.daysUntil(months.first)} days'));

    // Today lists the coming days in the next 30.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapTab(tester, 'Today');
    expect(find.text("Midhun's Nakshatram"), findsWidgets);
  });

  testWidgets('Find my star fills the pirannal', (tester) async {
    await pumpApp(tester, settings: enSettings, now: _now);
    await pushRoute(tester, '/event/new');
    await tester.tap(find.byKey(const Key('find-my-star')));
    await tester.pumpAndSettle();
    final expected = BirthDetails.fromLocalTime(DateTime(1990, 1, 1, 6));
    expect(find.text('${expected.nakshatra.english}, pada ${expected.pada}'),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('use-star')));
    await tester.pumpAndSettle();
    final star = tester.widget<DropdownButton<Nakshatra>>(
        find.byType(DropdownButton<Nakshatra>));
    final month = tester.widget<DropdownButton<MalayalamMonth>>(
        find.byType(DropdownButton<MalayalamMonth>));
    expect(star.value, expected.nakshatra);
    expect(month.value, expected.date.month);
    expect(find.widgetWithText(TextFormField, '1990'), findsOneWidget);
  });

  testWidgets('an event can be edited and deleted', (tester) async {
    final prefs = await testPrefs(enSettings);
    await AppDatabase(prefs).save(DbSnapshot(
      people: const [Person(id: 1, name: 'Amma', relation: Relation.family)],
      events: [
        CalendarEvent(
            id: 2,
            personId: 1,
            type: EventType.shraddham,
            recurrence: TithiInMonth(Tithi(23), MalayalamMonth.karkidakam)),
      ],
      reminders: const [Reminder(id: 3, eventId: 2)],
      nextId: 4,
    ));
    await pumpApp(tester, settings: null, prefs: prefs, now: _now);
    await pushRoute(tester, '/person/1');
    await tester.tap(find.byKey(const Key('event-2')));
    await tester.pumpAndSettle();
    expect(find.text('Edit event'), findsOneWidget);
    expect(find.text('By tithi'), findsOneWidget);

    await tester.tap(find.text('By star'));
    await tester.pumpAndSettle();
    expect(find.text('First day'), findsOneWidget);
    await _select(tester, Nakshatra.bharani);
    await tester.tap(find.byKey(const Key('save-event')));
    await tester.pumpAndSettle();
    var db = AppDatabase(prefs).load();
    expect(
        db.events.single.recurrence,
        NakshatraInMonth(Nakshatra.bharani, MalayalamMonth.karkidakam,
            duplicateRule: DuplicateRule.first));
    // Editing adds no reminder.
    expect(db.reminders, hasLength(1));

    await tester.tap(find.byKey(const Key('event-2')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('delete-event')));
    await tester.tap(find.byKey(const Key('delete-event')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();
    db = AppDatabase(prefs).load();
    expect(db.events, isEmpty);
    expect(db.reminders, isEmpty);
    expect(find.text('No events yet.'), findsOneWidget);
  });
}
