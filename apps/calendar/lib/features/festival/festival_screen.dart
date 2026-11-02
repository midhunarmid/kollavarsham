import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/clock.dart';
import '../../app/router.dart';
import '../../app/settings.dart';
import '../../app/share.dart';
import '../../data/festival_days.dart';
import '../../data/festival_index.dart';
import '../../data/festival_info.dart';
import '../../l10n/app_localizations.dart';
import '../day/festival_tile.dart';
import '../people/labels.dart';

/// Festival detail: what the festival is, how its date is found, and its
/// next five dates. Shows the occurrence on [date] if given, else the next.
class FestivalScreen extends ConsumerWidget {
  /// Creates the screen for the festival with [id].
  const FestivalScreen({super.key, required this.id, this.date});

  /// Festival id (see [FestivalDay.id]).
  final String id;

  /// Gregorian date of the occurrence to show, if any.
  final DateTime? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final calendar = ref.watch(calendarProvider);
    final holidays = ref.watch(holidaysProvider);
    final today = ref.watch(todayProvider);

    FestivalDay? shown;
    if (date != null) {
      final d = calendar.fromGregorian(date!);
      for (final f in festivalDaysBetween(calendar, d, d, holidays: holidays)) {
        if (f.id == id) shown = f;
      }
    }
    final next = festivalDates(id, today.addDays(-1), holidays);
    shown ??= next.isEmpty ? null : next.first;
    if (shown == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.festivalNotFound)),
      );
    }
    final festival = shown;
    final info = festivalInfo(id);
    final local = MaterialLocalizations.of(context);
    String dateText(MalayalamDate d) =>
        '${local.formatFullDate(d.toGregorian())}'
        ' · ${d.format('d MMMM y', script: script, malayalamDigits: settings.malayalamDigits)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(festival.name(script)),
        actions: [
          IconButton(
            key: const Key('share-festival'),
            tooltip: l10n.share,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => ref.read(shareProvider)(
              text: l10n.shareFestivalText(
                  festival.name(script), dateText(festival.date)),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FestivalTile(
                day: festival,
                script: script,
                subtitlePrefix: dateText(festival.date),
                interactive: false,
              ),
              if (info.about(script).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.festivalAbout, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(info.about(script), key: const Key('festival-about')),
              ],
              if (info.rule(script).isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.festivalRule, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(info.rule(script), key: const Key('festival-rule')),
              ],
              if (festival.source != null) ...[
                const SizedBox(height: 8),
                SelectableText(l10n.festivalSource(festival.source!),
                    style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 16),
              Text(l10n.nextDates, style: theme.textTheme.titleSmall),
              for (final f in next)
                ListTile(
                  key: Key('festival-date-${f.date.dayNumber}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(dateText(f.date)),
                  subtitle: Text(
                    [
                      l10n.inDays(today.daysUntil(f.date)),
                      if (f.holiday != null) holidayLabel(l10n, f.holiday!),
                      if (f.tentative) l10n.tentativeDate,
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(AppRoutes.dayPath(f.date.toGregorian())),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
