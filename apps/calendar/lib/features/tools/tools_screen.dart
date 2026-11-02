import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../l10n/app_localizations.dart';

/// Tools tab: the converter and calculators.
class ToolsScreen extends StatelessWidget {
  /// Creates the Tools screen.
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget tool(String key, IconData icon, String title, String help,
            String route) =>
        Card(
          child: ListTile(
            key: Key(key),
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(help),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(route),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTools)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              tool('tool-converter', Icons.swap_horiz, l10n.toolConverter,
                  l10n.toolConverterHelp, AppRoutes.converter),
              tool('tool-find-star', Icons.auto_awesome, l10n.findMyStar,
                  l10n.toolFindStarHelp, AppRoutes.findStar),
              tool('tool-age', Icons.cake_outlined, l10n.toolAge,
                  l10n.toolAgeHelp, AppRoutes.age),
              tool('tool-between', Icons.date_range, l10n.toolBetween,
                  l10n.toolBetweenHelp, AppRoutes.between),
              tool('tool-year', Icons.calendar_view_month, l10n.toolYearInfo,
                  l10n.toolYearInfoHelp, AppRoutes.yearInfo),
            ],
          ),
        ),
      ),
    );
  }
}
