import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../data/festival_days.dart';
import '../../data/festival_index.dart';
import '../../data/occurrences.dart';
import '../../l10n/app_localizations.dart';
import '../day/festival_tile.dart';
import '../people/labels.dart';

/// How far ahead the agenda looks.
const agendaDays = 366;

/// Agenda: the coming year's festivals, holidays and personal events, with
/// a search box and category filters.
class AgendaScreen extends ConsumerStatefulWidget {
  /// Creates the agenda.
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(FestivalCategory c, bool on) {
    final controller = ref.read(settingsProvider.notifier);
    final s = ref.read(settingsProvider);
    controller.update(s.copyWith(
        categories:
            on ? {...s.categories, c} : ({...s.categories}..remove(c))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final today = ref.watch(todayProvider);
    final query = _search.text.trim().toLowerCase();
    bool matches(Iterable<String> names) =>
        query.isEmpty || names.any((n) => n.toLowerCase().contains(query));

    final rows = <(MalayalamDate, Widget)>[];
    String dateText(MalayalamDate d) =>
        '${MaterialLocalizations.of(context).formatMediumDate(d.toGregorian())}'
        ' · ${d.format('d MMMM', script: script, malayalamDigits: settings.malayalamDigits)}';
    for (final f
        in ref.watch(festivalIndexProvider).upcoming(today, agendaDays)) {
      if (!matches([f.malayalam, f.english])) continue;
      rows.add((
        f.date,
        FestivalTile(
          day: f,
          script: script,
          subtitlePrefix: dateText(f.date),
        ),
      ));
    }
    for (final o in ref.watch(eventIndexProvider).upcoming(today, agendaDays)) {
      final title = eventTitle(l10n, o.event, o.person);
      if (!matches([title, o.person?.name ?? '', o.event.title])) continue;
      rows.add((
        o.date,
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.event_repeat,
              color: o.color == null ? null : Color(o.color!)),
          title: Text(title),
          subtitle: Text(dateText(o.date), style: theme.textTheme.bodySmall),
          onTap: () => context.push(AppRoutes.dayPath(o.date.toGregorian())),
        ),
      ));
    }
    rows.sort((a, b) => a.$1.compareTo(b.$1));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.agenda)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                key: const Key('agenda-search'),
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.categoriesHeading, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in FestivalCategory.values)
                    FilterChip(
                      key: Key('filter-${c.name}'),
                      label: Text(categoryLabel(l10n, c)),
                      selected: settings.categories.contains(c),
                      onSelected: (on) => _toggle(c, on),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(l10n.agendaEmpty, textAlign: TextAlign.center),
                )
              else
                for (final (_, row) in rows) row,
            ],
          ),
        ),
      ),
    );
  }
}
