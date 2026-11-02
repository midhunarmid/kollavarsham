import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../../l10n/app_localizations.dart';
import 'labels.dart';

/// Adds a person, or edits the one with [personId].
class PersonEditor extends ConsumerStatefulWidget {
  /// Creates the editor; a null [personId] adds a new person.
  const PersonEditor({super.key, this.personId});

  /// The person edited, or null to add one.
  final int? personId;

  @override
  ConsumerState<PersonEditor> createState() => _PersonEditorState();
}

class _PersonEditorState extends ConsumerState<PersonEditor> {
  final _form = GlobalKey<FormState>();
  late final Person _initial;
  late final TextEditingController _name;
  late final TextEditingController _notes;
  late Relation _relation;
  late int _color;

  @override
  void initState() {
    super.initState();
    final id = widget.personId;
    final existing = id == null ? null : ref.read(personProvider(id));
    // A new person takes the first colour no one has yet.
    final used = {for (final p in ref.read(peopleProvider)) p.color};
    _initial = existing ??
        Person(
          id: 0,
          name: '',
          color: personColors.firstWhere((c) => !used.contains(c),
              orElse: () => personColors[used.length % personColors.length]),
        );
    _name = TextEditingController(text: _initial.name);
    _notes = TextEditingController(text: _initial.notes);
    _relation = _initial.relation;
    _color = _initial.color;
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final saved = await ref.read(repositoryProvider.notifier).savePerson(
          _initial.copyWith(
            name: _name.text.trim(),
            relation: _relation,
            color: _color,
            notes: _notes.text.trim(),
          ),
        );
    if (!mounted) return;
    if (widget.personId == null) {
      context.pushReplacement(AppRoutes.personPath(saved.id));
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(widget.personId == null ? l10n.newPerson : l10n.editPerson),
        actions: [
          TextButton(
            key: const Key('save-person'),
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('person-name'),
              controller: _name,
              autofocus: widget.personId == null,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  labelText: l10n.personName,
                  border: const OutlineInputBorder()),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.relation, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final r in Relation.values)
                  ChoiceChip(
                    key: Key('relation-${r.name}'),
                    label: Text(relationLabel(l10n, r)),
                    selected: _relation == r,
                    onSelected: (_) => setState(() => _relation = r),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.colour, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, c) in personColors.indexed)
                  Semantics(
                    label: l10n.colourOption(i + 1),
                    selected: c == _color,
                    button: true,
                    child: InkResponse(
                      key: Key('colour-$i'),
                      onTap: () => setState(() => _color = c),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(c),
                        child: c == _color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('person-notes'),
              controller: _notes,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: l10n.notes, border: const OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}
