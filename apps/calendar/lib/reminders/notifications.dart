import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../app/router.dart';
import '../l10n/app_localizations.dart';
import 'scheduler.dart';

/// Where scheduled notifications go: the Android notification system, or
/// nowhere (the web, tests).
abstract class NotificationSink {
  /// Makes the pending notifications exactly [list]: cancels the others
  /// and schedules (or replaces) these. [l10n] names the channels and
  /// actions.
  Future<void> sync(List<ScheduledNotification> list, AppLocalizations l10n);

  /// Asks for permission to post notifications (Android 13+); returns
  /// whether they are allowed.
  Future<bool> requestPermission();

  /// Whether alarms can be exact; null where the question does not apply.
  Future<bool?> canScheduleExact();

  /// Opens the system screen that allows exact alarms (Android 12+).
  Future<void> requestExactAlarms();
}

/// A sink that schedules nothing.
class NoNotifications implements NotificationSink {
  /// Creates the sink.
  const NoNotifications();

  @override
  Future<void> sync(List<ScheduledNotification> list, AppLocalizations l10n) =>
      Future.value();

  @override
  Future<bool> requestPermission() => Future.value(false);

  @override
  Future<bool?> canScheduleExact() => Future.value(null);

  @override
  Future<void> requestExactAlarms() => Future.value();
}

/// Android allows 500 alarms per app; stay well below it.
const maxScheduled = 400;

/// Action id of "Snooze" on a notification.
const snoozeAction = 'snooze';

/// How long "Snooze" puts a notification off.
const snoozeDelay = Duration(hours: 1);

/// What a notification carries to its tap and action handlers.
@immutable
class NotificationPayload {
  /// Creates a payload.
  const NotificationPayload(this.route, this.title, this.body, this.channel);

  /// Reads [text] written by [encode], or null if it is not one.
  static NotificationPayload? decode(String? text) {
    if (text == null) return null;
    try {
      final j = (jsonDecode(text) as Map).cast<String, Object?>();
      return NotificationPayload(j['route']! as String, j['title']! as String,
          j['body']! as String, j['channel']! as String);
    } on Object {
      return null;
    }
  }

  /// The app route to open, e.g. a Day detail path.
  final String route;

  /// Title, for snoozing.
  final String title;

  /// Text, for snoozing.
  final String body;

  /// Channel id, for snoozing.
  final String channel;

  /// The payload as a string.
  String encode() => jsonEncode(
      {'route': route, 'title': title, 'body': body, 'channel': channel});
}

/// The notification channel of a [kind].
String channelOf(NotificationKind kind) => switch (kind) {
      NotificationKind.event => 'events',
      NotificationKind.monthStart ||
      NotificationKind.yearStart ||
      NotificationKind.festival =>
        'calendar',
      NotificationKind.daily => 'daily',
    };

String _channelName(AppLocalizations l10n, String channel) => switch (channel) {
      'events' => l10n.channelEvents,
      'daily' => l10n.channelDaily,
      _ => l10n.channelCalendar,
    };

NotificationDetails _details(AppLocalizations l10n, String channel) =>
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        _channelName(l10n, channel),
        importance:
            channel == 'daily' ? Importance.low : Importance.defaultImportance,
        priority: channel == 'daily' ? Priority.low : Priority.defaultPriority,
        actions: [
          AndroidNotificationAction('open', l10n.actionOpen,
              showsUserInterface: true),
          AndroidNotificationAction(snoozeAction, l10n.actionSnooze),
        ],
      ),
    );

/// Snoozes the notification of [response], from the app or the background.
Future<void> snooze(FlutterLocalNotificationsPlugin plugin,
    NotificationResponse response, AppLocalizations l10n) async {
  final payload = NotificationPayload.decode(response.payload);
  if (payload == null || response.id == null) return;
  await plugin.zonedSchedule(
    response.id!,
    payload.title,
    payload.body,
    tz.TZDateTime.from(DateTime.now().toUtc().add(snoozeDelay), tz.UTC),
    _details(l10n, payload.channel),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: payload.encode(),
  );
}

/// Schedules notifications with flutter_local_notifications on Android.
class AndroidNotifications implements NotificationSink {
  /// Creates the sink around [plugin].
  AndroidNotifications(this.plugin);

  /// The plugin, already initialised.
  final FlutterLocalNotificationsPlugin plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> sync(
      List<ScheduledNotification> list, AppLocalizations l10n) async {
    try {
      final wanted = list.take(maxScheduled).toList();
      final ids = {for (final n in wanted) n.id};
      for (final p in await plugin.pendingNotificationRequests()) {
        if (!ids.contains(p.id)) await plugin.cancel(p.id);
      }
      final exact = await canScheduleExact() ?? false;
      for (final n in wanted) {
        final channel = channelOf(n.kind);
        await plugin.zonedSchedule(
          n.id,
          n.title,
          n.body,
          tz.TZDateTime.from(n.time, tz.UTC),
          _details(l10n, channel),
          // Without the exact-alarm permission Android may deliver a few
          // minutes late, which is fine for a day's reminder.
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          payload: NotificationPayload(AppRoutes.dayPath(n.date.toGregorian()),
                  n.title, n.body, channel)
              .encode(),
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Scheduling notifications failed: $e');
    } on MissingPluginException catch (e) {
      debugPrint('No notification plugin: $e');
    }
  }

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<bool?> canScheduleExact() async =>
      _android?.canScheduleExactNotifications();

  @override
  Future<void> requestExactAlarms() async =>
      _android?.requestExactAlarmsPermission();
}
