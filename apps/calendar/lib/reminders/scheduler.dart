import 'package:flutter/foundation.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../data/database.dart';
import '../data/festival_days.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'reminder_options.dart';

export 'reminder_options.dart' show ReminderOptions;

/// What a scheduled notification is about.
enum NotificationKind {
  /// A reminder of a personal event.
  event,

  /// The day before a Malayalam month starts.
  monthStart,

  /// The day before the Kollavarsham year starts.
  yearStart,

  /// The day before a festival.
  festival,

  /// The morning panchangam.
  daily,
}

/// One notification to show at [time].
@immutable
class ScheduledNotification {
  /// Creates a notification.
  const ScheduledNotification({
    required this.id,
    required this.time,
    required this.kind,
    required this.date,
    required this.title,
    required this.body,
    this.eventId,
  });

  /// Stable id: the same (event, date, days before) always gives the same
  /// id, so rescheduling replaces rather than duplicates.
  final int id;

  /// When to show it (UTC).
  final DateTime time;

  /// What it is about.
  final NotificationKind kind;

  /// The day it reminds of.
  final MalayalamDate date;

  /// Notification title.
  final String title;

  /// Notification text.
  final String body;

  /// The event reminded of, for [NotificationKind.event].
  final int? eventId;

  @override
  String toString() => 'ScheduledNotification($id, $time, $title | $body)';
}

/// A stable 31-bit id for [key] (FNV-1a), the range Android accepts for
/// notification ids.
int stableNotificationId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

/// Computes the notifications for the next [days] days.
///
/// Pure: everything comes in as arguments, including [now], so it runs the
/// same in the app, a background job and tests.
class ReminderScheduler {
  /// Creates a scheduler.
  const ReminderScheduler({
    required this.calendar,
    required this.l10n,
    required this.script,
    this.malayalamDigits = false,
    this.options = const ReminderOptions(),
    this.days = 60,
    this.dailyDays = 7,
    this.holidays = HolidayData.empty,
  });

  /// Holiday lists merged with the computed festivals.
  final HolidayData holidays;

  /// Calendar (location) of the dates and of the reminder times.
  final KollavarshamCalendar calendar;

  /// Message templates in the notification language.
  final AppLocalizations l10n;

  /// Script of star and month names.
  final MalayalamScript script;

  /// Whether Malayalam dates use Malayalam digits.
  final bool malayalamDigits;

  /// Month and year start reminders.
  final ReminderOptions options;

  /// How far ahead to schedule.
  final int days;

  /// How many mornings of daily panchangam to schedule; the daily job
  /// tops them up.
  final int dailyDays;

  /// The instant of [minuteOfDay] on [date] at the calendar's location.
  DateTime _at(DateTime date, int minuteOfDay) => DateTime.utc(
          date.year, date.month, date.day, minuteOfDay ~/ 60, minuteOfDay % 60)
      .subtract(calendar.location.utcOffset);

  /// The notifications due after [now] and within [days] days, in time
  /// order.
  List<ScheduledNotification> schedule(DbSnapshot db, DateTime now) {
    final local = now.toUtc().add(calendar.location.utcOffset);
    final today = calendar.fromGregorian(local);
    final end = today.addDays(days);
    final people = {for (final p in db.people) p.id: p};
    final events = {for (final e in db.events) e.id: e};
    final result = <ScheduledNotification>[];
    if (!options.enabled) return result;

    final remindersByEvent = <int, List<Reminder>>{};
    for (final r in db.reminders) {
      final event = events[r.eventId];
      if (r.enabled &&
          event != null &&
          options.eventTypes.contains(event.type)) {
        (remindersByEvent[r.eventId] ??= []).add(r);
      }
    }
    for (final MapEntry(key: eventId, value: reminders)
        in remindersByEvent.entries) {
      final event = events[eventId]!;
      final maxBefore =
          reminders.map((r) => r.daysBefore).reduce((a, b) => a > b ? a : b);
      // An occurrence up to maxBefore days after the window still has
      // reminders inside it.
      final dates = event.recurrence.occurrencesBetween(
          today.toGregorian(), end.addDays(maxBefore).toGregorian(),
          calendar: calendar);
      for (final date in dates) {
        for (final r in reminders) {
          final day = date.addDays(-r.daysBefore);
          final time = _at(day.toGregorian(), r.minuteOfDay);
          if (!time.isAfter(now) || day.isAfter(end)) continue;
          result.add(ScheduledNotification(
            id: stableNotificationId(
                'event|$eventId|${date.dayNumber}|${r.daysBefore}'),
            time: time,
            kind: NotificationKind.event,
            date: date,
            eventId: eventId,
            title: eventTitle(event, people[event.personId]),
            body: eventBody(event, date, r.daysBefore),
          ));
        }
      }
    }

    if (options.monthStarts || options.yearStart) {
      for (var d = today.firstDayOfMonth;
          !d.isAfter(end.addDays(1));
          d = d.lastDayOfMonth.addDays(1)) {
        final isYearStart = d.month == calendar.firstMonth;
        if (!(options.monthStarts || isYearStart)) continue;
        final eve = d.addDays(-1);
        final time = _at(eve.toGregorian(), options.minuteOfDay);
        if (!time.isAfter(now) || eve.isAfter(end)) continue;
        result.add(_monthStart(d, time, isYearStart));
      }
    }

    if (options.festivals.isNotEmpty) {
      for (final f in festivalDaysBetween(calendar, today, end.addDays(1),
          categories: options.festivals, holidays: holidays)) {
        final eve = f.date.addDays(-1);
        final time = _at(eve.toGregorian(), options.minuteOfDay);
        if (!time.isAfter(now)) continue;
        result.add(ScheduledNotification(
          id: stableNotificationId('festival|${f.english}|${f.date.dayNumber}'),
          time: time,
          kind: NotificationKind.festival,
          date: f.date,
          title: l10n.notifyFestival(f.name(script)),
          body: f.date.format('d MMMM y',
              script: script, malayalamDigits: malayalamDigits),
        ));
      }
    }

    if (options.dailyPanchangam) {
      for (var i = 0; i < dailyDays; i++) {
        final day = today.addDays(i);
        final g = day.toGregorian();
        final time = _at(g, options.dailyMinute);
        if (!time.isAfter(now)) continue;
        result.add(ScheduledNotification(
          id: stableNotificationId('daily|${day.dayNumber}'),
          time: time,
          kind: NotificationKind.daily,
          date: day,
          title: day.format('EEEE, d MMMM y',
              script: script, malayalamDigits: malayalamDigits),
          body: l10n.notifyDailyBody(calendar.nakshatraOn(g).name(script),
              calendar.tithiOn(g).name(script)),
        ));
      }
    }

    return result..sort((a, b) => a.time.compareTo(b.time));
  }

  ScheduledNotification _monthStart(
      MalayalamDate first, DateTime time, bool isYearStart) {
    final month = first.month.name(script);
    final sankranti = calendar
        .sankranti(first.year, first.month)
        .toUtc()
        .add(calendar.location.utcOffset);
    final year =
        malayalamDigits ? toMalayalamDigits('${first.year}') : '${first.year}';
    return ScheduledNotification(
      id: stableNotificationId('month|${first.dayNumber}'),
      time: time,
      kind: isYearStart
          ? NotificationKind.yearStart
          : NotificationKind.monthStart,
      date: first,
      title: isYearStart
          ? l10n.notifyYearStart(month, year)
          : l10n.notifyMonthStart(month),
      body: l10n.notifyMonthStartBody(
          '${_two(sankranti.hour)}:${_two(sankranti.minute)}'),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// The title of [event]'s reminder, e.g. "Midhun's pirannal (Pooradam)".
  String eventTitle(CalendarEvent event, Person? person) {
    final name = person?.name ?? event.title;
    final star = switch (event.recurrence) {
      NakshatraInMonth(:final nakshatra) ||
      NakshatraMonthly(:final nakshatra) =>
        nakshatra.name(script),
      _ => '',
    };
    if (event.type == EventType.custom || name.isEmpty) {
      return event.title.isNotEmpty ? event.title : l10n.eventCustom;
    }
    return switch (event.type) {
      EventType.pirannal => l10n.notifyPirannal(name, star),
      EventType.nakshatram => l10n.notifyNakshatram(name, star),
      EventType.birthday => l10n.notifyBirthday(name),
      EventType.shraddham => l10n.notifyShraddham(name),
      EventType.anniversary => l10n.notifyAnniversary(name),
      EventType.custom => event.title,
    };
  }

  /// The text of a reminder [daysBefore] days ahead of [event] on [date]:
  /// when, the Malayalam date and, for birthdays and anniversaries with a
  /// year, the age.
  String eventBody(CalendarEvent event, MalayalamDate date, int daysBefore) {
    final day =
        date.format('d MMMM', script: script, malayalamDigits: malayalamDigits);
    final when = l10n.notifyWhen(daysBefore, day);
    final start = event.startYear;
    if (start == null) return when;
    final age = date.toGregorian().year - start;
    if (age <= 0) return when;
    return switch (event.type) {
      EventType.birthday => '$when · ${l10n.notifyAge(age)}',
      EventType.anniversary => '$when · ${l10n.notifyYears(age)}',
      _ => when,
    };
  }
}
