import 'package:flutter/foundation.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

/// How a person is related to the user.
enum Relation {
  /// The user.
  self,

  /// A family member.
  family,

  /// A friend.
  friend,

  /// Anyone else.
  other,
}

/// Colours offered for people and events, as ARGB values.
const personColors = [
  0xFF00796B, // teal
  0xFFD84315, // deep orange
  0xFF3949AB, // indigo
  0xFF8E24AA, // purple
  0xFF7CB342, // light green
  0xFF6D4C41, // brown
  0xFFE91E63, // pink
  0xFF0288D1, // light blue
];

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// A person whose days the user keeps.
@immutable
class Person {
  /// Creates a person.
  const Person({
    required this.id,
    required this.name,
    this.relation = Relation.other,
    this.color = 0xFF00796B,
    this.notes = '',
  });

  /// Reads a person written by [toJson].
  factory Person.fromJson(Map<String, Object?> json) => Person(
        id: json['id']! as int,
        name: json['name']! as String,
        relation:
            _enumByName(Relation.values, json['relation'], Relation.other),
        color: json['color'] as int? ?? personColors.first,
        notes: json['notes'] as String? ?? '',
      );

  /// Database id; 0 for a person not saved yet.
  final int id;

  /// Display name.
  final String name;

  /// Relation to the user.
  final Relation relation;

  /// Marker colour (ARGB).
  final int color;

  /// Free-text notes.
  final String notes;

  /// A copy with the given values replaced.
  Person copyWith({
    int? id,
    String? name,
    Relation? relation,
    int? color,
    String? notes,
  }) =>
      Person(
        id: id ?? this.id,
        name: name ?? this.name,
        relation: relation ?? this.relation,
        color: color ?? this.color,
        notes: notes ?? this.notes,
      );

  /// The JSON form stored in the database.
  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'relation': relation.name,
        'color': color,
        'notes': notes,
      };

  @override
  bool operator ==(Object other) =>
      other is Person && mapEquals(other.toJson(), toJson());

  @override
  int get hashCode => Object.hash(id, name, relation, color, notes);

  @override
  String toString() => 'Person($id, $name)';
}

/// Kind of a recurring event; decides its default title and reminder text.
enum EventType {
  /// Yearly star birthday (nakshatra in a Malayalam month).
  pirannal,

  /// Monthly return of the birth star.
  nakshatram,

  /// Gregorian birthday.
  birthday,

  /// Yearly death anniversary by tithi or star.
  shraddham,

  /// Wedding or other anniversary.
  anniversary,

  /// Any other recurrence.
  custom,
}

/// A recurring event, usually of a [Person].
@immutable
class CalendarEvent {
  /// Creates an event.
  const CalendarEvent({
    required this.id,
    required this.type,
    required this.recurrence,
    this.personId,
    this.title = '',
    this.color,
    this.notes = '',
    this.startYear,
  });

  /// Reads an event written by [toJson].
  factory CalendarEvent.fromJson(Map<String, Object?> json) => CalendarEvent(
        id: json['id']! as int,
        personId: json['personId'] as int?,
        type: _enumByName(EventType.values, json['type'], EventType.custom),
        recurrence: Recurrence.fromJson(
            (json['recurrence']! as Map).cast<String, Object?>()),
        title: json['title'] as String? ?? '',
        color: json['color'] as int?,
        notes: json['notes'] as String? ?? '',
        startYear: json['startYear'] as int?,
      );

  /// Database id; 0 for an event not saved yet.
  final int id;

  /// The person the event belongs to, if any.
  final int? personId;

  /// Kind of event.
  final EventType type;

  /// When the event recurs.
  final Recurrence recurrence;

  /// Title for custom events; others are titled from [type].
  final String title;

  /// Marker colour (ARGB); null to use the person's colour.
  final int? color;

  /// Free-text notes.
  final String notes;

  /// Gregorian year of the first occurrence (birth or wedding year), for
  /// ages; null if unknown.
  final int? startYear;

  /// A copy with the given values replaced.
  CalendarEvent copyWith({
    int? id,
    int? personId,
    EventType? type,
    Recurrence? recurrence,
    String? title,
    int? color,
    String? notes,
    int? startYear,
  }) =>
      CalendarEvent(
        id: id ?? this.id,
        personId: personId ?? this.personId,
        type: type ?? this.type,
        recurrence: recurrence ?? this.recurrence,
        title: title ?? this.title,
        color: color ?? this.color,
        notes: notes ?? this.notes,
        startYear: startYear ?? this.startYear,
      );

  /// The JSON form stored in the database.
  Map<String, Object?> toJson() => {
        'id': id,
        if (personId != null) 'personId': personId,
        'type': type.name,
        'recurrence': recurrence.toJson(),
        'title': title,
        if (color != null) 'color': color,
        'notes': notes,
        if (startYear != null) 'startYear': startYear,
      };

  @override
  bool operator ==(Object other) =>
      other is CalendarEvent &&
      other.toJson().toString() == toJson().toString();

  @override
  int get hashCode => Object.hash(id, personId, type, title);

  @override
  String toString() => 'CalendarEvent($id, ${type.name}, person $personId)';
}

/// A reminder for an event: [daysBefore] days ahead, at [minuteOfDay].
@immutable
class Reminder {
  /// Creates a reminder.
  const Reminder({
    required this.id,
    required this.eventId,
    this.daysBefore = 0,
    this.minuteOfDay = 7 * 60,
    this.enabled = true,
  });

  /// Reads a reminder written by [toJson].
  factory Reminder.fromJson(Map<String, Object?> json) => Reminder(
        id: json['id']! as int,
        eventId: json['eventId']! as int,
        daysBefore: json['daysBefore'] as int? ?? 0,
        minuteOfDay: json['minuteOfDay'] as int? ?? 7 * 60,
        enabled: json['enabled'] as bool? ?? true,
      );

  /// Database id; 0 for a reminder not saved yet.
  final int id;

  /// The event reminded of.
  final int eventId;

  /// How many days before the event (0 is the same day).
  final int daysBefore;

  /// Local time of day, in minutes after midnight.
  final int minuteOfDay;

  /// Whether the reminder is on.
  final bool enabled;

  /// A copy with the given values replaced.
  Reminder copyWith({
    int? id,
    int? eventId,
    int? daysBefore,
    int? minuteOfDay,
    bool? enabled,
  }) =>
      Reminder(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        daysBefore: daysBefore ?? this.daysBefore,
        minuteOfDay: minuteOfDay ?? this.minuteOfDay,
        enabled: enabled ?? this.enabled,
      );

  /// The JSON form stored in the database.
  Map<String, Object?> toJson() => {
        'id': id,
        'eventId': eventId,
        'daysBefore': daysBefore,
        'minuteOfDay': minuteOfDay,
        'enabled': enabled,
      };

  @override
  bool operator ==(Object other) =>
      other is Reminder && mapEquals(other.toJson(), toJson());

  @override
  int get hashCode => Object.hash(id, eventId, daysBefore, minuteOfDay);
}
