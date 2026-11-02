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
