import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// The bottom navigation bar around the five tabs.
class AppShell extends StatelessWidget {
  /// Creates the shell around [shell]'s current tab.
  const AppShell({super.key, required this.shell});

  /// The tab navigator from the router.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tapping the current tab again returns it to its first page.
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          for (final d in [
            NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              selectedIcon: const Icon(Icons.today),
              label: l10n.navToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l10n.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l10n.navPeople,
            ),
            NavigationDestination(
              icon: const Icon(Icons.handyman_outlined),
              selectedIcon: const Icon(Icons.handyman),
              label: l10n.navTools,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.navSettings,
            ),
          ])
            // Labels stay on one line on narrow phones and in long
            // languages: NavigationBar's label Text takes its wrapping
            // from here.
            DefaultTextStyle.merge(
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: d,
            ),
        ],
      ),
    );
  }
}
