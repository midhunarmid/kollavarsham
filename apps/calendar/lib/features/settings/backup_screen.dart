import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/clock.dart';
import '../../app/settings.dart';
import '../../app/share.dart';
import '../../backup/backup.dart';
import '../../backup/ics.dart';
import '../../data/database.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_options.dart';
import '../people/labels.dart';

/// Picks a file and returns its text, or null if none was picked.
typedef FilePick = Future<String?> Function();

/// The file picker; tests override it.
final pickFileProvider = Provider<FilePick>((ref) => () async {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      final bytes = result?.files.single.bytes;
      return bytes == null ? null : utf8.decode(bytes);
    });

/// The .ics events for [events] from [from] for [years] years.
List<IcsEvent> icsEventsFor(
  List<CalendarEvent> events,
  Map<int, Person> people,
  MalayalamDate from,
  int years,
  AppLocalizations l10n,
  MalayalamScript script,
) {
  final to = from.toGregorian().add(Duration(days: 365 * years));
  return [
    for (final e in events)
      for (final d in e.recurrence
          .occurrencesBetween(from.toGregorian(), to, calendar: from.calendar))
        IcsEvent(
          uid:
              'event-${e.id}-${d.toGregorian().toIso8601String().substring(0, 10)}'
              '@calendar.armid.in',
          date: d,
          summary: eventTitle(l10n, e, people[e.personId]),
          description: [
            d.format('d MMMM y', script: script),
            if (e.recurrence
                case NakshatraInMonth(:final nakshatra) ||
                    NakshatraMonthly(:final nakshatra))
              nakshatra.name(script),
            if (e.notes.isNotEmpty) e.notes,
          ].join('\n'),
        ),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

/// Settings → Backup and export.
class BackupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  int _years = 5;
  Set<int>? _selected;

  Future<void> _exportIcs(List<IcsEvent> events) async {
    final text = buildIcs(events, now: ref.read(clockProvider)());
    await ref.read(shareProvider)(
      files: [
        XFile.fromData(Uint8List.fromList(utf8.encode(text)),
            mimeType: 'text/calendar', name: 'malayalam-calendar.ics'),
      ],
      fileNames: ['malayalam-calendar.ics'],
    );
  }

  Future<void> _saveBackup() async {
    final now = ref.read(clockProvider)();
    final text = createBackup(ref.read(sharedPreferencesProvider), now);
    final name = 'malayalam-calendar-backup-'
        '${now.toIso8601String().substring(0, 10)}.json';
    await ref.read(shareProvider)(
      files: [
        XFile.fromData(Uint8List.fromList(utf8.encode(text)),
            mimeType: 'application/json', name: name),
      ],
      fileNames: [name],
    );
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final text = await ref.read(pickFileProvider)();
    if (text == null || !mounted) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final Backup backup;
    try {
      backup = Backup.parse(text, AppDatabase(prefs));
    } on FormatException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.restoreFailed)));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreTitle),
        content: Text(
            l10n.restoreBody(backup.db.people.length, backup.db.events.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirm-restore'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.restoreAction),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await restoreBackup(prefs, backup);
    ref
      ..invalidate(repositoryProvider)
      ..invalidate(settingsProvider)
      ..invalidate(reminderOptionsProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final db = ref.watch(repositoryProvider);
    final people = {for (final p in db.people) p.id: p};
    final selected = _selected ?? {for (final e in db.events) e.id};
    final ics = icsEventsFor(
      [
        for (final e in db.events)
          if (selected.contains(e.id)) e,
      ],
      people,
      ref.watch(todayProvider),
      _years,
      l10n,
      script,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsBackup)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.exportIcs, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(l10n.exportIcsHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                key: const Key('export-years'),
                segments: [
                  for (final y in const [1, 2, 5, 10])
                    ButtonSegment(value: y, label: Text(l10n.exportYears(y))),
                ],
                selected: {_years},
                onSelectionChanged: (s) => setState(() => _years = s.single),
              ),
              for (final e in db.events)
                CheckboxListTile(
                  key: Key('export-event-${e.id}'),
                  contentPadding: EdgeInsets.zero,
                  value: selected.contains(e.id),
                  title: Text(eventTitle(l10n, e, people[e.personId])),
                  onChanged: (on) => setState(() => _selected = on!
                      ? {...selected, e.id}
                      : ({...selected}..remove(e.id))),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('export-ics'),
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.exportButton(ics.length)),
                onPressed: ics.isEmpty ? null : () => _exportIcs(ics),
              ),
              const Divider(height: 40),
              Text(l10n.backupHeading, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(l10n.backupHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    key: const Key('save-backup'),
                    icon: const Icon(Icons.save_alt),
                    label: Text(l10n.saveBackup),
                    onPressed: _saveBackup,
                  ),
                  OutlinedButton.icon(
                    key: const Key('restore-backup'),
                    icon: const Icon(Icons.restore),
                    label: Text(l10n.restoreBackup),
                    onPressed: _restore,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
