import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../data/models.dart';
import '../../data/occurrences.dart';
import '../../data/repository.dart';
import '../../l10n/app_localizations.dart';
import '../people/labels.dart';
import 'event_draft.dart';

/// Adds an event, or edits the one with [eventId].
///
/// A new event can start with a [personId] and a [type].
class EventEditor extends ConsumerStatefulWidget {
  /// Creates the editor.
  const EventEditor({super.key, this.eventId, this.personId, this.type});

  /// The event edited, or null to add one.
  final int? eventId;

  /// Person of a new event.
  final int? personId;

  /// Type of a new event.
  final EventType? type;

  @override
  ConsumerState<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends ConsumerState<EventEditor> {
  final _form = GlobalKey<FormState>();
  late final EventDraft _draft;
  late final TextEditingController _title;
  late final TextEditingController _year;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final id = widget.eventId;
    CalendarEvent? existing;
    if (id != null) {
      for (final e in ref.read(repositoryProvider).events) {
        if (e.id == id) existing = e;
      }
    }
    _draft = existing != null
        ? EventDraft.fromEvent(existing)
        : (EventDraft(personId: widget.personId)
          ..setType(widget.type ?? EventType.pirannal));
    _title = TextEditingController(text: _draft.title);
    _year = TextEditingController(text: _draft.startYear?.toString() ?? '');
    _notes = TextEditingController(text: _draft.notes);
  }

  @override
  void dispose() {
    _title.dispose();
    _year.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _edit(void Function(EventDraft d) change) =>
      setState(() => change(_draft));

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    _draft
      ..title = _title.text
      ..notes = _notes.text
      ..startYear = int.tryParse(_year.text.trim());
    final repo = ref.read(repositoryProvider.notifier);
    final saved = await repo.saveEvent(_draft.toEvent());
    // A new event is reminded of on the day, at 07:00 (design.md §3.6).
    if (widget.eventId == null) {
      await repo.saveReminder(Reminder(id: 0, eventId: saved.id));
    }
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEventTitle),
        content: Text(l10n.deleteEventBody),
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
    if (ok != true || !mounted) return;
    await ref.read(repositoryProvider.notifier).deleteEvent(_draft.id);
    if (mounted) context.pop();
  }

  Future<void> _findStar() async {
    final details = await context.push<BirthDetails>(AppRoutes.findStar);
    if (details == null) return;
    _edit((d) => d.applyBirthDetails(details));
    _year.text = '${_draft.startYear}';
  }

  Future<void> _pickDate() async {
    final year = int.tryParse(_year.text.trim()) ?? 2000;
    final initial = DateTime(year.clamp(1800, 2200), _draft.gregorianMonth,
        _draft.gregorianDay.clamp(1, 28));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1800),
      lastDate: DateTime(2200),
    );
    if (picked == null) return;
    _edit((d) => d
      ..gregorianMonth = picked.month
      ..gregorianDay = picked.day);
    if (_draft.type != EventType.custom) _year.text = '${picked.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final people = ref.watch(peopleProvider);
    final today = ref.watch(todayProvider);
    final d = _draft;
    final usesStar = d.type == EventType.pirannal ||
        d.type == EventType.nakshatram ||
        (d.type == EventType.shraddham && d.shraddhamByStar);
    final usesMonth = d.type == EventType.pirannal ||
        d.type == EventType.shraddham ||
        (d.type == EventType.custom &&
            d.customKind == CustomKind.malayalamYearly);
    final usesDuplicateRule =
        d.type == EventType.pirannal || d.type == EventType.shraddham;
    final previews = nextOccurrences(d.recurrence, today.addDays(-1), 3);
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(widget.eventId == null ? l10n.newEvent : l10n.editEvent),
        actions: [
          TextButton(
            key: const Key('save-event'),
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
            _Select<int?>(
              key: const Key('event-person'),
              value: d.personId,
              label: l10n.person,
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.noPerson)),
                for (final p in people)
                  DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: (v) => _edit((d) => d.personId = v),
            ),
            gap,
            _Select<EventType>(
              key: const Key('event-type'),
              value: d.type,
              label: l10n.eventType,
              items: [
                for (final t in EventType.values)
                  DropdownMenuItem(
                      value: t, child: Text(eventTypeLabel(l10n, t))),
              ],
              onChanged: (v) => _edit((d) => d.setType(v!)),
            ),
            if (d.type == EventType.custom) ...[
              gap,
              TextFormField(
                key: const Key('event-title'),
                controller: _title,
                decoration: InputDecoration(
                    labelText: l10n.eventTitle,
                    border: const OutlineInputBorder()),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.titleRequired : null,
              ),
              gap,
              _Select<CustomKind>(
                key: const Key('event-kind'),
                value: d.customKind,
                label: l10n.repeats,
                items: [
                  for (final (k, label) in [
                    (CustomKind.malayalamYearly, l10n.kindMalayalamYearly),
                    (CustomKind.malayalamMonthly, l10n.kindMalayalamMonthly),
                    (CustomKind.gregorianYearly, l10n.kindGregorianYearly),
                    (CustomKind.tithiEveryPaksha, l10n.kindTithi),
                  ])
                    DropdownMenuItem(value: k, child: Text(label)),
                ],
                onChanged: (v) => _edit((d) => d.customKind = v!),
              ),
            ],
            if (d.type == EventType.shraddham) ...[
              gap,
              SegmentedButton<bool>(
                key: const Key('shraddham-basis'),
                segments: [
                  ButtonSegment(
                      value: false, label: Text(l10n.shraddhamByTithi)),
                  ButtonSegment(value: true, label: Text(l10n.shraddhamByStar)),
                ],
                selected: {d.shraddhamByStar},
                onSelectionChanged: (s) =>
                    _edit((d) => d.setShraddhamByStar(s.single)),
              ),
            ],
            if (usesStar) ...[
              gap,
              _Select<Nakshatra>(
                key: const Key('event-star'),
                value: d.nakshatra,
                label: l10n.nakshatra,
                items: [
                  for (final n in Nakshatra.values)
                    DropdownMenuItem(value: n, child: Text(n.name(script))),
                ],
                onChanged: (v) => _edit((d) => d.nakshatra = v!),
              ),
            ],
            if (d.type == EventType.shraddham && !d.shraddhamByStar) ...[
              gap,
              _Select<int>(
                key: const Key('event-tithi'),
                value: d.tithi,
                label: l10n.tithi,
                items: [
                  for (var t = 1; t <= 30; t++)
                    DropdownMenuItem(
                      value: t,
                      child: Text('${Tithi(t).name(script)} · '
                          '${Tithi(t).paksha.name(script)}'),
                    ),
                ],
                onChanged: (v) => _edit((d) => d.tithi = v!),
              ),
            ],
            if (d.type == EventType.custom &&
                d.customKind == CustomKind.tithiEveryPaksha) ...[
              gap,
              _Select<int>(
                key: const Key('event-tithi'),
                value: d.tithi.clamp(1, 15),
                label: l10n.tithi,
                items: [
                  for (var t = 1; t <= 15; t++)
                    DropdownMenuItem(
                      value: t,
                      // Name the 15th "Pournami / Amavasi" by its paksha.
                      child: Text(
                          Tithi(d.paksha == Paksha.krishna && t == 15 ? 30 : t)
                              .name(script)),
                    ),
                ],
                onChanged: (v) => _edit((d) => d.tithi = v!),
              ),
              gap,
              SegmentedButton<Paksha?>(
                segments: [
                  ButtonSegment(value: null, label: Text(l10n.bothPakshas)),
                  for (final p in Paksha.values)
                    ButtonSegment(value: p, label: Text(p.name(script))),
                ],
                selected: {d.paksha},
                onSelectionChanged: (s) => _edit((d) => d.paksha = s.single),
              ),
            ],
            if (usesMonth) ...[
              gap,
              _Select<MalayalamMonth>(
                key: const Key('event-month'),
                value: d.month,
                label: l10n.malayalamMonth,
                items: [
                  for (final m in MalayalamMonth.values)
                    DropdownMenuItem(value: m, child: Text(m.name(script))),
                ],
                onChanged: (v) => _edit((d) => d.month = v!),
              ),
            ],
            if (d.type == EventType.custom &&
                (d.customKind == CustomKind.malayalamYearly ||
                    d.customKind == CustomKind.malayalamMonthly)) ...[
              gap,
              _Select<int>(
                key: const Key('event-day'),
                value: d.malayalamDay,
                label: l10n.day,
                items: [
                  for (var i = 1; i <= 32; i++)
                    DropdownMenuItem(value: i, child: Text('$i')),
                ],
                onChanged: (v) => _edit((d) => d.malayalamDay = v!),
              ),
            ],
            if (d.usesGregorianDate) ...[
              gap,
              ListTile(
                key: const Key('event-date'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(l10n.date),
                subtitle: Text(MaterialLocalizations.of(context)
                    .formatMediumDate(
                        DateTime(2000, d.gregorianMonth, d.gregorianDay))
                    .replaceAll(RegExp(r',? 2000'), '')),
                trailing: TextButton(
                    onPressed: _pickDate, child: Text(l10n.chooseDate)),
              ),
            ],
            if (d.type == EventType.pirannal) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  key: const Key('find-my-star'),
                  onPressed: _findStar,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.findMyStar),
                ),
              ),
            ],
            if (usesDuplicateRule) ...[
              gap,
              Text(l10n.duplicateRuleHeading,
                  style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<DuplicateRule>(
                key: const Key('duplicate-rule'),
                segments: [
                  ButtonSegment(
                      value: DuplicateRule.second,
                      label: Text(l10n.duplicateSecond)),
                  ButtonSegment(
                      value: DuplicateRule.first,
                      label: Text(l10n.duplicateFirst)),
                ],
                selected: {d.duplicateRule},
                onSelectionChanged: (s) =>
                    _edit((d) => d.duplicateRule = s.single),
              ),
              const SizedBox(height: 4),
              Text(
                d.duplicateRule == DuplicateRule.second
                    ? l10n.duplicateSecondHelp
                    : l10n.duplicateFirstHelp,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (d.type != EventType.nakshatram &&
                d.type != EventType.custom) ...[
              gap,
              TextFormField(
                key: const Key('event-year'),
                controller: _year,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: l10n.year, border: const OutlineInputBorder()),
                validator: (v) {
                  final text = (v ?? '').trim();
                  if (text.isEmpty) return null;
                  final y = int.tryParse(text);
                  return y == null || y < 1800 || y > 2200
                      ? l10n.invalidYear
                      : null;
                },
              ),
            ],
            gap,
            TextField(
              key: const Key('event-notes'),
              controller: _notes,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: l10n.notes, border: const OutlineInputBorder()),
            ),
            gap,
            Text(l10n.nextDates, style: theme.textTheme.labelLarge),
            Column(
              key: const Key('event-previews'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final date in previews)
                  Text(
                    '${MaterialLocalizations.of(context).formatMediumDate(date.toGregorian())}'
                    ' · ${date.format('d MMMM', script: script, malayalamDigits: settings.malayalamDigits)}',
                  ),
              ],
            ),
            if (widget.eventId != null) ...[
              gap,
              OutlinedButton.icon(
                key: const Key('delete-event'),
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A labelled, outlined dropdown whose value always follows the editor.
class _Select<T> extends StatelessWidget {
  const _Select({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
          ),
        ),
      );
}
