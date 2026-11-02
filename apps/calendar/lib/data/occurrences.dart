import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../app/settings.dart';
import 'models.dart';
import 'repository.dart';

/// One day on which an event falls.
class Occurrence {
  /// Creates an occurrence of [event] on [date].
  const Occurrence(this.event, this.person, this.date);

  /// The event.
  final CalendarEvent event;

  /// The event's person, if any.
  final Person? person;

  /// The day.
  final MalayalamDate date;

  /// Marker colour: the event's own, else its person's, else null.
  int? get color => event.color ?? person?.color;
}

/// The days of all events, computed a Gregorian year at a time on first
/// use and kept.
class EventIndex {
  /// Indexes [events] (with their [people]) in [calendar].
  EventIndex(List<CalendarEvent> events, List<Person> people, this.calendar)
      : _events = events,
        _people = {for (final p in people) p.id: p};

  /// The calendar dates are computed in.
  final KollavarshamCalendar calendar;

  final List<CalendarEvent> _events;
  final Map<int, Person> _people;
  final Map<int, Map<int, List<Occurrence>>> _years = {};

  Map<int, List<Occurrence>> _year(int year) => _years[year] ??= () {
        final days = <int, List<Occurrence>>{};
        for (final e in _events) {
          final person = _people[e.personId];
          for (final d in e.recurrence.occurrencesBetween(
              DateTime(year), DateTime(year, 12, 31),
              calendar: calendar)) {
            (days[d.dayNumber] ??= []).add(Occurrence(e, person, d));
          }
        }
        return days;
      }();

  /// The events on [date].
  List<Occurrence> on(MalayalamDate date) =>
      _year(date.toGregorian().year)[date.dayNumber] ?? const [];

  /// The occurrences from [from] for [days] days (from included), by date.
  List<Occurrence> upcoming(MalayalamDate from, int days) {
    final last = from.addDays(days - 1);
    final result = <Occurrence>[
      for (var y = from.toGregorian().year; y <= last.toGregorian().year; y++)
        for (final MapEntry(:key, :value) in _year(y).entries)
          if (key >= from.dayNumber && key <= last.dayNumber) ...value,
    ];
    return result..sort((a, b) => a.date.compareTo(b.date));
  }
}

/// The index of every saved event in the current calendar.
final eventIndexProvider = Provider<EventIndex>((ref) {
  final db = ref.watch(repositoryProvider);
  return EventIndex(db.events, db.people, ref.watch(calendarProvider));
});

/// The next [count] days of a [recurrence] after [after] (exclusive).
List<MalayalamDate> nextOccurrences(
  Recurrence recurrence,
  MalayalamDate after,
  int count,
) {
  final result = <MalayalamDate>[];
  var from = after;
  while (result.length < count) {
    final next = recurrence.next(from.toGregorian(), calendar: after.calendar);
    if (next == null) break;
    result.add(next);
    from = next;
  }
  return result;
}
