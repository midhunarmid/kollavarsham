import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/router.dart';
import '../../data/festival_days.dart';
import '../../l10n/app_localizations.dart';
import '../people/labels.dart';

/// The icon of a festival [category].
IconData categoryIcon(FestivalCategory category) => switch (category) {
      FestivalCategory.hindu => Icons.temple_hindu_outlined,
      FestivalCategory.christian => Icons.church_outlined,
      FestivalCategory.muslim => Icons.mosque_outlined,
      FestivalCategory.national => Icons.flag_outlined,
      FestivalCategory.government => Icons.account_balance_outlined,
      FestivalCategory.bank => Icons.savings_outlined,
    };

/// A festival or holiday: its name, category, holiday kind and whether the
/// date is tentative. [subtitlePrefix] (e.g. a date) goes first.
class FestivalTile extends StatelessWidget {
  /// Creates the tile.
  const FestivalTile({
    super.key,
    required this.day,
    required this.script,
    this.subtitlePrefix,
    this.onTap,
    this.interactive = true,
  });

  /// The festival day.
  final FestivalDay day;

  /// Script of the name.
  final MalayalamScript script;

  /// Text before the category, e.g. the date.
  final String? subtitlePrefix;

  /// Called when tapped; by default opens the festival's detail.
  final VoidCallback? onTap;

  /// Whether the tile reacts to taps at all.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final holiday = day.holiday;
    final calTheme = KollavarshamCalendarTheme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(categoryIcon(day.category),
          color: holiday == HolidayKind.public ? calTheme.holidayColor : null),
      title: Text(day.name(script)),
      subtitle: Text([
        if (subtitlePrefix != null) subtitlePrefix!,
        categoryLabel(l10n, day.category),
        if (holiday != null) holidayLabel(l10n, holiday),
        if (day.tentative) l10n.tentativeDate,
      ].join(' · ')),
      subtitleTextStyle: theme.textTheme.bodySmall,
      onTap: !interactive
          ? null
          : onTap ??
              () => context
                  .push(AppRoutes.festivalPath(day.id, day.date.toGregorian())),
    );
  }
}
