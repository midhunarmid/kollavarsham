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
