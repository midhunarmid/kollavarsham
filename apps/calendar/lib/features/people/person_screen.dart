import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../../l10n/app_localizations.dart';
import '../share/share_card.dart';
import 'labels.dart';
import 'people_screen.dart';

/// Person detail: relation, notes and events of the person with [personId].
class PersonScreen extends ConsumerWidget {
  /// Creates the detail screen.
  const PersonScreen({super.key, required this.personId});

  /// The person shown.
  final int personId;

  Future<void> _delete(BuildContext context, WidgetRef ref, String name) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePersonTitle(name)),
        content: Text(l10n.deletePersonBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(repositoryProvider.notifier).deletePerson(personId);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final person = ref.watch(personProvider(personId));
    if (person == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.personNotFound)),
      );
    }
    final events = ref.watch(personEventsProvider(personId));
    final today = ref.watch(todayProvider);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        actions: [
          IconButton(
            key: const Key('edit-person'),
            tooltip: l10n.editPerson,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editPersonPath(personId)),
          ),
          IconButton(
            key: const Key('delete-person'),
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref, person.name),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: PersonAvatar(person: person),
            title: Text(person.name, style: theme.textTheme.titleLarge),
            subtitle: Text(relationLabel(l10n, person.relation)),
          ),
          if (person.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(person.notes),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(l10n.events, style: theme.textTheme.titleSmall),
          ),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.noEvents),
            )
          else
            for (final (e, next) in [
              for (final e in events)
                (
                  e,
                  e.recurrence.next(today.addDays(-1).toGregorian(),
                      calendar: today.calendar)
                ),
            ]..sort((a, b) => _compareDates(a.$2, b.$2)))
              ListTile(
                key: Key('event-${e.id}'),
                leading: const Icon(Icons.event_repeat),
                title: Text(e.title.isNotEmpty
                    ? e.title
                    : eventTypeLabel(l10n, e.type)),
                subtitle: next == null
                    ? null
                    : Text(
                        '${MaterialLocalizations.of(context).formatMediumDate(next.toGregorian())}'
                        ' · ${next.format('d MMMM', script: script, malayalamDigits: settings.malayalamDigits)}'
                        ' · ${l10n.inDays(today.daysUntil(next))}'),
                trailing: next != null &&
                        (e.type == EventType.pirannal ||
                            e.type == EventType.birthday)
                    ? IconButton(
                        key: Key('greeting-${e.id}'),
                        tooltip: l10n.greeting,
                        icon: const Icon(Icons.card_giftcard),
                        onPressed: () => showShareCardDialog(
                          context,
                          ref,
                          card: GreetingCard(
                            greeting: e.type == EventType.pirannal
                                ? l10n.greetingPirannal(person.name)
                                : l10n.greetingBirthday(person.name),
                            lines: [
                              if (e.recurrence
                                  case NakshatraInMonth(:final nakshatra))
                                nakshatra.name(script),
                              next.format('d MMMM y',
                                  script: script,
                                  malayalamDigits: settings.malayalamDigits),
                              MaterialLocalizations.of(context)
                                  .formatFullDate(next.toGregorian()),
                            ],
                          ),
                          fileName: 'greeting-${e.id}.png',
                        ),
                      )
                    : const Icon(Icons.edit_outlined),
                onTap: () => context.push(AppRoutes.editEventPath(e.id)),
              ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                key: const Key('add-event'),
                onPressed: () => context.push(AppRoutes.newEventPath(
                    personId: personId,
                    type: events.isEmpty ? EventType.pirannal : null)),
                icon: const Icon(Icons.add),
                label: Text(l10n.addEvent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int _compareDates(MalayalamDate? a, MalayalamDate? b) => a == null
    ? (b == null ? 0 : 1)
    : b == null
        ? -1
        : a.compareTo(b);
