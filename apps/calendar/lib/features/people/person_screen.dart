import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../data/repository.dart';
import '../../l10n/app_localizations.dart';
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
            for (final e in events)
              ListTile(
                leading: const Icon(Icons.event_repeat),
                title: Text(e.title.isNotEmpty
                    ? e.title
                    : eventTypeLabel(l10n, e.type)),
              ),
        ],
      ),
    );
  }
}
