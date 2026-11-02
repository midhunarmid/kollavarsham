import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../app/router.dart';
import '../../app/settings.dart';
import '../../l10n/app_localizations.dart';
import '../settings/location_picker.dart';
import '../settings/settings_screen.dart';

/// First-run flow: language, location, and what notifications are for.
///
/// It only explains notifications; Android asks for the permission when
/// the first reminder is set up.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding flow.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 3;
  int _step = 0;

  SettingsController get _controller => ref.read(settingsProvider.notifier);

  void _edit(AppSettings Function(AppSettings) change) =>
      _controller.update(change(ref.read(settingsProvider)));

  Future<void> _finish() async {
    await _controller
        .update(ref.read(settingsProvider).copyWith(onboardingDone: true));
    if (mounted) context.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final script = resolveScript(context, settings.nameScript.script);
    final theme = Theme.of(context);
    final last = _step == _steps - 1;

    final (title, body) = switch (_step) {
      0 => (
          l10n.onboardingWelcomeTitle,
          <Widget>[
            Text(l10n.onboardingWelcomeBody),
            const SizedBox(height: 24),
            Text(l10n.settingsLanguage, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            LanguageChooser(
              value: settings.language,
              onChanged: (v) => _edit((s) => s.copyWith(language: v)),
            ),
          ],
        ),
      1 => (
          l10n.onboardingLocationTitle,
          <Widget>[
            Text(l10n.onboardingLocationBody),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                key: const Key('onboarding-location'),
                leading: const Icon(Icons.place_outlined),
                title: Text(locationLabel(settings.location, script)),
                trailing: Text(l10n.change),
                onTap: () async {
                  final picked = await showLocationPicker(context,
                      current: settings.location, script: script);
                  if (picked != null) {
                    _edit((s) => s.copyWith(location: picked));
                  }
                },
              ),
            ),
          ],
        ),
      _ => (
          l10n.onboardingNotificationsTitle,
          <Widget>[
            Text(l10n.onboardingNotificationsBody),
            const SizedBox(height: 16),
            for (final item in [
              l10n.onboardingNotifyPirannal,
              l10n.onboardingNotifyShraddham,
              l10n.onboardingNotifyMonthStart,
            ])
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(item),
              ),
            const SizedBox(height: 8),
            Text(l10n.onboardingNotificationsPrivacy,
                style: theme.textTheme.bodySmall),
          ],
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(value: (_step + 1) / _steps),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        l10n.onboardingStep(_step + 1, _steps),
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      ...body,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_step > 0)
                        TextButton(
                          onPressed: () => setState(() => _step--),
                          child: Text(l10n.back),
                        ),
                      const Spacer(),
                      FilledButton(
                        key: const Key('onboarding-next'),
                        onPressed:
                            last ? _finish : () => setState(() => _step++),
                        child: Text(last ? l10n.getStarted : l10n.next),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
