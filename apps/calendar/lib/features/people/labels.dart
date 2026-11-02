import '../../data/festival_days.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

/// The localized name of [relation].
String relationLabel(AppLocalizations l10n, Relation relation) =>
    switch (relation) {
      Relation.self => l10n.relationSelf,
      Relation.family => l10n.relationFamily,
      Relation.friend => l10n.relationFriend,
      Relation.other => l10n.relationOther,
    };

/// The localized name of an event [type].
String eventTypeLabel(AppLocalizations l10n, EventType type) => switch (type) {
      EventType.pirannal => l10n.eventPirannal,
      EventType.nakshatram => l10n.eventNakshatram,
      EventType.birthday => l10n.eventBirthday,
      EventType.shraddham => l10n.eventShraddham,
      EventType.anniversary => l10n.eventAnniversary,
      EventType.custom => l10n.eventCustom,
    };

/// The display title of [event]: its own title, else its type, prefixed
/// with the [person]'s name when there is one ("Midhun's Pirannal").
String eventTitle(AppLocalizations l10n, CalendarEvent event, Person? person) {
  final label =
      event.title.isNotEmpty ? event.title : eventTypeLabel(l10n, event.type);
  return person == null ? label : l10n.personEvent(person.name, label);
}

/// The localized name of a festival [category].
String categoryLabel(AppLocalizations l10n, FestivalCategory category) =>
    switch (category) {
      FestivalCategory.hindu => l10n.categoryHindu,
      FestivalCategory.christian => l10n.categoryChristian,
      FestivalCategory.muslim => l10n.categoryMuslim,
      FestivalCategory.national => l10n.categoryNational,
      FestivalCategory.government => l10n.categoryGovernment,
      FestivalCategory.bank => l10n.categoryBank,
    };

/// The localized badge of a holiday [kind].
String holidayLabel(AppLocalizations l10n, HolidayKind kind) => switch (kind) {
      HolidayKind.public => l10n.holidayPublic,
      HolidayKind.restricted => l10n.holidayRestricted,
      HolidayKind.bank => l10n.holidayBank,
    };
