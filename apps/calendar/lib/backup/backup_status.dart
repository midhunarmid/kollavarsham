import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/clock.dart';
import '../app/settings.dart';

/// When the last backup was saved, and the web app's reminders about it
/// and about installing, kept in preferences.
@immutable
class BackupStatus {
  /// Creates a status.
  const BackupStatus({
    this.lastBackup,
    this.nudgeSnoozedUntil,
    this.installDismissed = false,
  });

  /// When a backup file was last saved; null if never.
  final DateTime? lastBackup;

  /// The backup reminder stays hidden until then.
  final DateTime? nudgeSnoozedUntil;

  /// Whether the "Install the app" card was dismissed.
  final bool installDismissed;

  /// How long a backup counts as recent.
  static const backupAge = Duration(days: 30);

  /// How long "Not now" hides the backup reminder.
  static const snooze = Duration(days: 7);

  /// Whether to remind a web user with [eventCount] events to save a
  /// backup at [now].
  bool shouldNudge(DateTime now, int eventCount) =>
      eventCount > 0 &&
      (lastBackup == null || now.difference(lastBackup!) > backupAge) &&
      (nudgeSnoozedUntil == null || now.isAfter(nudgeSnoozedUntil!));
}

/// The backup status, in preferences.
class BackupStatusNotifier extends Notifier<BackupStatus> {
  static const _last = 'backup.last';
  static const _snooze = 'backup.nudgeSnoozedUntil';
  static const _install = 'install.dismissed';

  @override
  BackupStatus build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    DateTime? time(String key) => switch (prefs.getInt(key)) {
          final ms? => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
          null => null,
        };
    return BackupStatus(
      lastBackup: time(_last),
      nudgeSnoozedUntil: time(_snooze),
      installDismissed: prefs.getBool(_install) ?? false,
    );
  }

  DateTime get _now => ref.read(clockProvider)().toUtc();

  /// Records a backup saved now.
  Future<void> backupSaved() async {
    final now = _now;
    state = BackupStatus(
      lastBackup: now,
      nudgeSnoozedUntil: state.nudgeSnoozedUntil,
      installDismissed: state.installDismissed,
    );
    await ref
        .read(sharedPreferencesProvider)
        .setInt(_last, now.millisecondsSinceEpoch);
  }

  /// Hides the backup reminder for [BackupStatus.snooze].
  Future<void> snoozeNudge() async {
    final until = _now.add(BackupStatus.snooze);
    state = BackupStatus(
      lastBackup: state.lastBackup,
      nudgeSnoozedUntil: until,
      installDismissed: state.installDismissed,
    );
    await ref
        .read(sharedPreferencesProvider)
        .setInt(_snooze, until.millisecondsSinceEpoch);
  }

  /// Hides the "Install the app" card for good.
  Future<void> dismissInstall() async {
    state = BackupStatus(
      lastBackup: state.lastBackup,
      nudgeSnoozedUntil: state.nudgeSnoozedUntil,
      installDismissed: true,
    );
    await ref.read(sharedPreferencesProvider).setBool(_install, true);
  }
}

/// The backup status.
final backupStatusProvider =
    NotifierProvider<BackupStatusNotifier, BackupStatus>(
        BackupStatusNotifier.new);
