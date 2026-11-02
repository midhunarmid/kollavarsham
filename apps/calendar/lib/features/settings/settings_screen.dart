import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';

/// Settings tab.
class SettingsScreen extends ConsumerWidget {
  /// Creates the Settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _Section(
            title: l10n.settingsLanguage,
            child: SegmentedButton<AppLanguage>(
              key: const Key('settings-language'),
              segments: [
                ButtonSegment(
                    value: AppLanguage.system,
                    label: Text(l10n.languageSystem)),
                // Language names are shown in their own script.
                const ButtonSegment(
                    value: AppLanguage.malayalam, label: Text('മലയാളം')),
                const ButtonSegment(
                    value: AppLanguage.english, label: Text('English')),
              ],
              selected: {settings.language},
              onSelectionChanged: (s) =>
                  controller.update(settings.copyWith(language: s.single)),
            ),
          ),
          _Section(
            title: l10n.settingsTheme,
            child: SegmentedButton<ThemeMode>(
              key: const Key('settings-theme'),
              segments: [
                ButtonSegment(
                    value: ThemeMode.system, label: Text(l10n.themeSystem)),
                ButtonSegment(
                    value: ThemeMode.light, label: Text(l10n.themeLight)),
                ButtonSegment(
                    value: ThemeMode.dark, label: Text(l10n.themeDark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) =>
                  controller.update(settings.copyWith(themeMode: s.single)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );
}
