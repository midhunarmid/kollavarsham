import 'package:calendar/data/database.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/l10n/app_localizations.dart';
import 'package:calendar/data/festival_days.dart';
import 'package:calendar/reminders/reminder_options.dart';
import 'package:calendar/reminders/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'helpers.dart';

final _cal = KollavarshamCalendar.standard;
final _en = lookupAppLocalizations(const Locale('en'));
final _ml = lookupAppLocalizations(const Locale('ml'));

ReminderScheduler _scheduler({
  AppLocalizations? l10n,
  MalayalamScript script = MalayalamScript.english,
  ReminderOptions options = const ReminderOptions(yearStart: false),
}) =>
    ReminderScheduler(
      calendar: _cal,
      l10n: l10n ?? _en,
      script: script,
      options: options,
    );

/// Midhun (self) with a pirannal, monthly nakshatram and birthday.
final _db = DbSnapshot(
  people: const [Person(id: 1, name: 'Midhun', relation: Relation.self)],
  events: [
    CalendarEvent(
        id: 2,
        personId: 1,
        type: EventType.pirannal,
        recurrence: NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu)),
    const CalendarEvent(
        id: 3,
        personId: 1,
        type: EventType.nakshatram,
        recurrence: NakshatraMonthly(Nakshatra.pooradam)),
    const CalendarEvent(
        id: 4,
        personId: 1,
        type: EventType.birthday,
        recurrence: GregorianYearly(12, 1),
        startYear: 1990),
  ],
  reminders: const [
    Reminder(id: 5, eventId: 2),
    Reminder(id: 6, eventId: 2, daysBefore: 1, minuteOfDay: 20 * 60),
    Reminder(id: 7, eventId: 3),
    Reminder(id: 8, eventId: 4),
    Reminder(id: 9, eventId: 4, daysBefore: 3, enabled: false),
  ],
  nextId: 10,
);

/// 2 November 2026 at 09:00 in Kerala.
final _now = DateTime.utc(2026, 11, 2, 3, 30);

void main() {
  test('stable ids are 31-bit and repeatable', () {
    final a = stableNotificationId('event|2|20000|0');
    expect(a, stableNotificationId('event|2|20000|0'));
    expect(a, isNot(stableNotificationId('event|2|20000|1')));
    expect(a, inInclusiveRange(0, 0x7fffffff));
  });

  test('schedules every enabled reminder in the next 60 days', () {
    final list = _scheduler().schedule(_db, _now);
    final end = _now.add(const Duration(days: 61));
    expect(list, isNotEmpty);
    for (final n in list) {
      expect(n.time.isAfter(_now), isTrue);
      expect(n.time.isBefore(end), isTrue);
    }
    // Sorted, with unique ids.
    for (var i = 1; i < list.length; i++) {
      expect(list[i].time.isBefore(list[i - 1].time), isFalse);
    }
    expect(list.map((n) => n.id).toSet(), hasLength(list.length));

    // The birthday on 1 December 2026 at 07:00 IST; the disabled reminder
    // three days before is left out.
    final birthday = list.where((n) => n.eventId == 4).toList();
    expect(birthday, hasLength(1));
    expect(birthday.single.time, DateTime.utc(2026, 12, 1, 1, 30));
    expect(birthday.single.title, "Midhun's birthday");
    expect(birthday.single.body, contains('Today'));
    expect(birthday.single.body, contains('turns 36'));

    // A nakshatram reminder at 07:00 IST on each Pooradam day.
    final monthly = list.where((n) => n.eventId == 3).toList();
    expect(monthly.length, inInclusiveRange(2, 5));
    for (final n in monthly) {
      expect(n.title, "Midhun's nakshatram (Pooradam)");
      expect(n.time.toUtc().add(const Duration(hours: 5, minutes: 30)).hour, 7);
    }
  });

  test('ids stay the same when rescheduled later', () {
    final first = _scheduler().schedule(_db, _now);
    final later =
        _scheduler().schedule(_db, _now.add(const Duration(days: 10)));
    final firstIds = {for (final n in first) n.id: n.time};
    for (final n in later) {
      if (firstIds.containsKey(n.id)) expect(firstIds[n.id], n.time);
    }
    // Something early has dropped out and something new has come in.
    expect(
        later.first.time.isAfter(_now.add(const Duration(days: 10))), isTrue);
  });

  test('a pirannal reminder the day before says tomorrow', () {
    // Midhun's Dhanu pirannal falls in January 2027; schedule from
    // mid-December so it is within the window.
    final list = _scheduler().schedule(_db, DateTime.utc(2026, 12, 20));
    final pirannal = list.where((n) => n.eventId == 2).toList();
    expect(pirannal, hasLength(2));
    final (eve, day) = (pirannal[0], pirannal[1]);
    expect(day.title, "Midhun's pirannal (Pooradam)");
    expect(day.body, startsWith('Today, '));
    expect(day.body, contains('Dhanu'));
    expect(eve.body, startsWith('Tomorrow, '));
    expect(day.time.difference(eve.time), const Duration(hours: 11));
    expect(eve.id, isNot(day.id));
  });

  test('templates in Malayalam', () {
    final list = _scheduler(l10n: _ml, script: MalayalamScript.malayalam)
        .schedule(_db, _now);
    final birthday = list.firstWhere((n) => n.eventId == 4);
    expect(birthday.title, 'Midhun – ജന്മദിനം');
    expect(birthday.body, contains('ഇന്ന്'));
    expect(birthday.body, contains('36 വയസ്സ്'));
    final monthly = list.firstWhere((n) => n.eventId == 3);
    expect(monthly.title, 'Midhun – നക്ഷത്രം (പൂരാടം)');
  });

  test('nothing in the past, and an empty database gives nothing', () {
    expect(_scheduler().schedule(const DbSnapshot(), _now), isEmpty);
    // 22:00 on the birthday itself: the 07:00 reminder has passed.
    final late = _scheduler().schedule(_db, DateTime.utc(2026, 12, 1, 16, 30));
    expect(late.where((n) => n.eventId == 4), isEmpty);
  });

  group('month and year starts', () {
    test('the evening before each month start', () {
      final list = _scheduler(options: const ReminderOptions(monthStarts: true))
          .schedule(const DbSnapshot(), _now);
      // Vrischikam and Dhanu 1202 start within 60 days of 2 November.
      expect(list.map((n) => n.title),
          ['Vrischikam 1 tomorrow', 'Dhanu 1 tomorrow']);
      final vrischikam = list.first;
      final start = _cal.monthStart(1202, MalayalamMonth.vrischikam);
      expect(vrischikam.date.toGregorian(), start);
      expect(
          vrischikam.time,
          DateTime.utc(start.year, start.month, start.day - 1, 20)
              .subtract(const Duration(hours: 5, minutes: 30)));
      expect(vrischikam.body, startsWith('Sankranti at '));
      expect(vrischikam.kind, NotificationKind.monthStart);
    });

    test('Chingam 1 tomorrow: Malayalam New Year', () {
      final list = _scheduler(options: const ReminderOptions())
          .schedule(const DbSnapshot(), DateTime.utc(2027, 7, 20));
      expect(list.single.title, 'Chingam 1 tomorrow: Malayalam New Year 1203');
      expect(list.single.kind, NotificationKind.yearStart);
      final ml = _scheduler(
              l10n: _ml,
              script: MalayalamScript.malayalam,
              options: const ReminderOptions())
          .schedule(const DbSnapshot(), DateTime.utc(2027, 7, 20));
      expect(ml.single.title, 'നാളെ ചിങ്ങം 1: പുതുവർഷം 1203');
    });

    test('off by default for months, so no year start in November', () {
      final list = _scheduler(options: const ReminderOptions())
          .schedule(const DbSnapshot(), _now);
      expect(list, isEmpty);
    });
  });

  group('options', () {
    test('the master switch and event types filter reminders', () {
      expect(
          _scheduler(options: const ReminderOptions(enabled: false))
              .schedule(_db, _now),
          isEmpty);
      final noBirthdays = _scheduler(
              options: const ReminderOptions(
                  yearStart: false,
                  eventTypes: {EventType.pirannal, EventType.nakshatram}))
          .schedule(_db, _now);
      expect(noBirthdays.where((n) => n.eventId == 4), isEmpty);
      expect(noBirthdays.where((n) => n.eventId == 3), isNotEmpty);
    });

    test('festivals by category, the evening before', () {
      final list = _scheduler(
              options: const ReminderOptions(
                  yearStart: false, festivals: {FestivalCategory.christian}))
          .schedule(const DbSnapshot(), _now);
      final christmas =
          list.singleWhere((n) => n.title == 'Christmas tomorrow');
      expect(christmas.kind, NotificationKind.festival);
      expect(christmas.time, DateTime.utc(2026, 12, 24, 14, 30));
      // Only the chosen category.
      expect(list.where((n) => n.title.contains('Deepavali')), isEmpty);
      final hindu = _scheduler(
              options: const ReminderOptions(
                  yearStart: false, festivals: {FestivalCategory.hindu}))
          .schedule(const DbSnapshot(), _now);
      expect(
          hindu.map((n) => n.title), contains('Mandala Kalam begins tomorrow'));
    });

    test('daily panchangam for the next 7 mornings', () {
      final list = _scheduler(
              options: const ReminderOptions(
                  yearStart: false, dailyPanchangam: true))
          .schedule(const DbSnapshot(), _now);
      // 09:00 today is past 06:00, so tomorrow onwards.
      expect(list, hasLength(6));
      expect(list.first.time, DateTime.utc(2026, 11, 3, 0, 30));
      final day = _cal.fromGregorian(DateTime(2026, 11, 3));
      expect(list.first.body,
          'Star ${day.nakshatra.english} · Tithi ${day.tithi.name(MalayalamScript.english)}');
    });

    test('are saved and read back', () async {
      final prefs = await testPrefs();
      const o = ReminderOptions(
          enabled: false,
          eventTypes: {EventType.shraddham},
          monthStarts: true,
          yearStart: false,
          minuteOfDay: 19 * 60,
          festivals: {FestivalCategory.muslim},
          dailyPanchangam: true,
          dailyMinute: 5 * 60 + 30);
      await ReminderOptionsStore(prefs).save(o);
      expect(ReminderOptionsStore(prefs).load(), o);
      await prefs.setInt('reminders.minuteOfDay', 5000);
      expect(ReminderOptionsStore(prefs).load().minuteOfDay, 20 * 60);
    });
  });
}
