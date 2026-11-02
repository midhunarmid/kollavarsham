import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/router.dart';
import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';
import 'location_picker.dart';

/// Settings tab.
class SettingsScreen extends ConsumerWidget {
  /// Creates the Settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final script = resolveScript(context, settings.nameScript.script);
    // Read the latest state so quick successive changes all apply.
    void edit(AppSettings Function(AppSettings) change) =>
        controller.update(change(ref.read(settingsProvider)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            key: const Key('settings-reminders'),
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsReminders),
            subtitle: Text(l10n.settingsRemindersHelp),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.reminders),
          ),
          _Section(
            title: l10n.settingsLanguage,
            child: LanguageChooser(
              value: settings.language,
              onChanged: (v) => edit((cur) => cur.copyWith(language: v)),
            ),
          ),
          _Section(
            title: l10n.settingsNameScript,
            child: SegmentedButton<NameScript>(
              key: const Key('settings-name-script'),
              segments: [
                ButtonSegment(
                    value: NameScript.auto, label: Text(l10n.nameScriptAuto)),
                ButtonSegment(
                    value: NameScript.malayalam,
                    label: Text(l10n.nameScriptMalayalam)),
                ButtonSegment(
                    value: NameScript.english,
                    label: Text(l10n.nameScriptLatin)),
              ],
              selected: {settings.nameScript},
              onSelectionChanged: (s) =>
                  edit((cur) => cur.copyWith(nameScript: s.single)),
            ),
          ),
          SwitchListTile(
            key: const Key('settings-digits'),
            title: Text(l10n.settingsMalayalamDigits),
            subtitle: Text(l10n.settingsMalayalamDigitsHelp),
            value: settings.malayalamDigits,
            onChanged: (v) => edit((cur) => cur.copyWith(malayalamDigits: v)),
          ),
          ListTile(
            key: const Key('settings-location'),
            title: Text(l10n.settingsLocation),
            subtitle: Text('${locationLabel(settings.location, script)}\n'
                '${l10n.settingsLocationHelp}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showLocationPicker(context,
                  current: settings.location, script: script);
              if (picked != null) {
                edit((cur) => cur.copyWith(location: picked));
              }
            },
          ),
          _Section(
            title: l10n.settingsYearStart,
            help: l10n.settingsYearStartHelp,
            child: SegmentedButton<YearStart>(
              key: const Key('settings-year-start'),
              segments: [
                ButtonSegment(
                    value: YearStart.chingam,
                    label: Text(MalayalamMonth.chingam.name(script))),
                ButtonSegment(
                    value: YearStart.kanni,
                    label: Text(MalayalamMonth.kanni.name(script))),
              ],
              selected: {settings.yearStart},
              onSelectionChanged: (s) =>
                  edit((cur) => cur.copyWith(yearStart: s.single)),
            ),
          ),
          _Section(
            title: l10n.settingsCalendarMode,
            child: SegmentedButton<CalendarMode>(
              key: const Key('settings-calendar-mode'),
              segments: [
                ButtonSegment(
                    value: CalendarMode.malayalam,
                    label: Text(l10n.calendarModeMalayalam)),
                ButtonSegment(
                    value: CalendarMode.gregorian,
                    label: Text(l10n.calendarModeGregorian)),
              ],
              selected: {settings.calendarMode},
              onSelectionChanged: (s) =>
                  edit((cur) => cur.copyWith(calendarMode: s.single)),
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
                  edit((cur) => cur.copyWith(themeMode: s.single)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented buttons for the interface language; each language is named
/// in its own script.
class LanguageChooser extends StatelessWidget {
  /// Creates a chooser showing [value].
  const LanguageChooser(
      {super.key, required this.value, required this.onChanged});

  /// The selected language.
  final AppLanguage value;

  /// Called with the newly selected language.
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<AppLanguage>(
        key: const Key('settings-language'),
        segments: [
          ButtonSegment(
              value: AppLanguage.system,
              label: Text(AppLocalizations.of(context).languageSystem)),
          const ButtonSegment(
              value: AppLanguage.malayalam, label: Text('മലയാളം')),
          const ButtonSegment(
              value: AppLanguage.english, label: Text('English')),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.single),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.help});

  final String title;
  final Widget child;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
          if (help != null) ...[
            const SizedBox(height: 4),
            Text(help!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
