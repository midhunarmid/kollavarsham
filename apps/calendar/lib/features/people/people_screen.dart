import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../../l10n/app_localizations.dart';
import 'labels.dart';

/// People tab: everyone whose days the user keeps.
class PeopleScreen extends ConsumerWidget {
  /// Creates the People screen.
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final people = ref.watch(peopleProvider);
    final events = ref.watch(repositoryProvider).events;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPeople)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-person'),
        onPressed: () => context.push(AppRoutes.newPerson),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.addPerson),
      ),
      body: people.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline,
                        size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(l10n.peopleEmpty, textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final p in people)
                  ListTile(
                    key: Key('person-${p.id}'),
                    leading: PersonAvatar(person: p),
                    title: Text(p.name),
                    subtitle: Text([
                      relationLabel(l10n, p.relation),
                      for (final e in events)
                        if (e.personId == p.id) eventTypeLabel(l10n, e.type),
                    ].join(' · ')),
                    onTap: () => context.push(AppRoutes.personPath(p.id)),
                  ),
              ],
            ),
    );
  }
}

/// A circle in the person's colour with their initial.
class PersonAvatar extends StatelessWidget {
  /// Creates the avatar of [person].
  const PersonAvatar({super.key, required this.person});

  /// The person.
  final Person person;

  @override
  Widget build(BuildContext context) {
    final color = Color(person.color);
    final name = person.name.trim();
    return CircleAvatar(
      backgroundColor: color,
      foregroundColor:
          ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black,
      child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase()),
    );
  }
}
