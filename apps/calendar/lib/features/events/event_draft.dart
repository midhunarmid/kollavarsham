import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../data/models.dart';

/// How a custom event recurs.
enum CustomKind {
  /// A Malayalam date every year (e.g. Medam 1).
  malayalamYearly,

  /// A Malayalam day of every month.
  malayalamMonthly,

  /// A Gregorian date every year.
  gregorianYearly,

  /// A tithi in every fortnight, or in one paksha (e.g. every Ekadashi).
  tithiEveryPaksha,
}

/// The fields of the event editor, whatever the type; [recurrence] builds
/// the rule for the chosen [type].
class EventDraft {
  /// A new event of [type] with the editor's defaults.
  EventDraft({this.type = EventType.pirannal, this.personId});

  /// The editor fields of a saved [event].
  factory EventDraft.fromEvent(CalendarEvent event) {
    final d = EventDraft(type: event.type, personId: event.personId)
      ..id = event.id
      ..title = event.title
      ..notes = event.notes
      ..startYear = event.startYear;
    switch (event.recurrence) {
      case NakshatraInMonth r:
        d
          ..nakshatra = r.nakshatra
          ..month = r.month
          ..duplicateRule = r.duplicateRule
          ..shraddhamByStar = true;
      case NakshatraMonthly r:
        d.nakshatra = r.nakshatra;
      case TithiInMonth r:
        d
          ..tithi = r.tithi.number
          ..month = r.month
          ..duplicateRule = r.duplicateRule
          ..shraddhamByStar = false;
      case TithiEveryPaksha r:
        d
          ..customKind = CustomKind.tithiEveryPaksha
          ..tithi = r.dayOfPaksha
          ..paksha = r.paksha;
      case MalayalamDateYearly r:
        d
          ..customKind = CustomKind.malayalamYearly
          ..month = r.month
          ..malayalamDay = r.day;
      case MalayalamDateMonthly r:
        d
          ..customKind = CustomKind.malayalamMonthly
          ..malayalamDay = r.day;
      case GregorianYearly r:
        d
          ..customKind = CustomKind.gregorianYearly
          ..gregorianMonth = r.month
          ..gregorianDay = r.day;
    }
    return d;
  }

  /// Id of the saved event, or 0 for a new one.
  int id = 0;

  /// Kind of event.
  EventType type;

  /// Person the event belongs to.
  int? personId;

  /// Title (custom events) .
  String title = '';

  /// Notes.
  String notes = '';

  /// Birth or wedding year, for ages.
  int? startYear;

  /// Star of a pirannal, nakshatram or shraddham by star.
  Nakshatra nakshatra = Nakshatra.ashwathi;

  /// Malayalam month of a pirannal, shraddham or Malayalam yearly date.
  MalayalamMonth month = MalayalamMonth.chingam;

  /// Day to use when the star or tithi falls twice in the month. Pirannal
  /// defaults to the second (R1); shraddham by star to the first (rules
  /// doc, R4).
  DuplicateRule duplicateRule = DuplicateRule.second;

  /// Whether a shraddham follows the star rather than the tithi.
  bool shraddhamByStar = false;

  /// Tithi number: 1–30 for a shraddham, 1–15 (day of the paksha) for a
  /// custom tithi.
  int tithi = 1;

  /// Paksha of a custom tithi; null for both.
  Paksha? paksha;

  /// How a custom event recurs.
  CustomKind customKind = CustomKind.malayalamYearly;

  /// Day of a Malayalam date (1–32).
  int malayalamDay = 1;

  /// Month (1–12) of a Gregorian date.
  int gregorianMonth = 1;

  /// Day of a Gregorian date.
  int gregorianDay = 1;

  /// Whether the type uses the Gregorian date fields.
  bool get usesGregorianDate =>
      type == EventType.birthday ||
      type == EventType.anniversary ||
      (type == EventType.custom && customKind == CustomKind.gregorianYearly);

  /// Sets the shraddham basis and the matching default duplicate rule.
  void setShraddhamByStar(bool byStar) {
    shraddhamByStar = byStar;
    duplicateRule = byStar ? DuplicateRule.first : DuplicateRule.second;
  }

  /// Sets the type and the matching default duplicate rule.
  void setType(EventType value) {
    type = value;
    duplicateRule = value == EventType.shraddham && shraddhamByStar
        ? DuplicateRule.first
        : DuplicateRule.second;
  }

  /// Fills a pirannal from [details]: its star and Malayalam month, and the
  /// Gregorian year of birth.
  void applyBirthDetails(BirthDetails details) {
    nakshatra = details.nakshatra;
    month = details.date.month;
    startYear = details.date.toGregorian().year;
  }

  /// The rule for the current fields.
  Recurrence get recurrence => switch (type) {
        EventType.pirannal =>
          NakshatraInMonth(nakshatra, month, duplicateRule: duplicateRule),
        EventType.nakshatram => NakshatraMonthly(nakshatra),
        EventType.shraddham => shraddhamByStar
            ? NakshatraInMonth(nakshatra, month, duplicateRule: duplicateRule)
            : TithiInMonth(Tithi(tithi.clamp(1, 30)), month,
                duplicateRule: duplicateRule),
        EventType.birthday ||
        EventType.anniversary =>
          GregorianYearly(gregorianMonth, gregorianDay),
        EventType.custom => switch (customKind) {
            CustomKind.malayalamYearly =>
              MalayalamDateYearly(month, malayalamDay),
            CustomKind.malayalamMonthly => MalayalamDateMonthly(malayalamDay),
            CustomKind.gregorianYearly =>
              GregorianYearly(gregorianMonth, gregorianDay),
            CustomKind.tithiEveryPaksha =>
              TithiEveryPaksha(tithi.clamp(1, 15), paksha: paksha),
          },
      };

  /// The event to save.
  CalendarEvent toEvent() => CalendarEvent(
        id: id,
        personId: personId,
        type: type,
        recurrence: recurrence,
        title: title.trim(),
        notes: notes.trim(),
        startYear: startYear,
      );
}
