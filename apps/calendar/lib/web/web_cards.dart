import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/clock.dart';
import '../app/router.dart';
import '../backup/backup_status.dart';
import '../data/repository.dart';
import '../l10n/app_localizations.dart';
import 'browser.dart';

/// The web app's suggestions on Today: save a backup (data that lives
/// only in the browser), and install the app. Nothing on Android.
class WebSuggestions extends ConsumerWidget {
  /// Creates the suggestions.
  const WebSuggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browser = ref.watch(browserProvider);
    if (!browser.isWeb) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: browser.changes,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final status = ref.watch(backupStatusProvider);
        final events = ref.watch(repositoryProvider).events.length;
        final now = ref.watch(clockProvider)().toUtc();
        final notifier = ref.read(backupStatusProvider.notifier);
        final install = !status.installDismissed &&
            !browser.isInstalled &&
            (browser.canInstall || browser.isIos);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (status.shouldNudge(now, events))
              _Suggestion(
                key: const Key('backup-nudge'),
                icon: Icons.save_alt,
                title: l10n.backupNudgeTitle,
                body: l10n.backupNudgeBody,
                actions: [
                  TextButton(
                    key: const Key('backup-nudge-later'),
                    onPressed: notifier.snoozeNudge,
                    child: Text(l10n.notNow),
                  ),
                  FilledButton.tonal(
                    key: const Key('backup-nudge-save'),
                    onPressed: () => context.push(AppRoutes.backup),
                    child: Text(l10n.saveBackup),
                  ),
                ],
              ),
            if (install)
              _Suggestion(
                key: const Key('install-card'),
                icon: Icons.install_mobile,
                title: l10n.installTitle,
                body:
                    browser.canInstall ? l10n.installBody : l10n.installIosBody,
                actions: [
                  TextButton(
                    key: const Key('install-later'),
                    onPressed: notifier.dismissInstall,
                    child: Text(l10n.notNow),
                  ),
                  if (browser.canInstall)
                    FilledButton.tonal(
                      key: const Key('install-now'),
                      onPressed: browser.install,
                      child: Text(l10n.installAction),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: theme.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer)),
                        const SizedBox(height: 4),
                        Text(body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer)),
                      ],
                    ),
                  ),
                ],
              ),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows "A new version is ready · Reload" once the web app has downloaded
/// a newer version; wraps the app's shell.
class UpdateListener extends ConsumerStatefulWidget {
  /// Wraps [child].
  const UpdateListener({super.key, required this.child});

  /// The shell.
  final Widget child;

  @override
  ConsumerState<UpdateListener> createState() => _UpdateListenerState();
}

class _UpdateListenerState extends ConsumerState<UpdateListener> {
  late final BrowserApi _browser = ref.read(browserProvider);
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _browser.changes.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _browser.changes.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_shown || !mounted || !_browser.updateReady) return;
    _shown = true;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      key: const Key('update-ready'),
      content: Text(l10n.updateReady),
      duration: const Duration(days: 1),
      action:
          SnackBarAction(label: l10n.updateReload, onPressed: _browser.reload),
    ));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
