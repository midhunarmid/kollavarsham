import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../app/clock.dart';
import '../app/settings.dart';
import '../data/database.dart';
import '../data/festival_index.dart';
import '../data/repository.dart';
import '../l10n/app_localizations.dart';
import '../data/occurrences.dart';
import 'home_widgets.dart';
import 'notifications.dart';
import 'reminder_options.dart';
import 'scheduler.dart';

/// The notification language and name script for [settings] on a device
/// whose language is [deviceLocale].
(AppLocalizations, MalayalamScript) notificationLanguage(
    AppSettings settings, Locale deviceLocale) {
  final locale = settings.language.locale ??
      (deviceLocale.languageCode == 'ml'
          ? const Locale('ml')
          : const Locale('en'));
  final ml = locale.languageCode == 'ml';
  final script = settings.nameScript.script ??
      (ml ? MalayalamScript.malayalam : MalayalamScript.english);
  return (lookupAppLocalizations(locale), script);
}

/// Recomputes and replaces the scheduled notifications from what is
/// stored in [prefs]; used by the daily background job.
Future<void> rescheduleFromPrefs(
    SharedPreferences prefs, NotificationSink sink, DateTime now,
    {HomeWidgetSink widgets = const HomeWidgetSink()}) async {
  final settings = SettingsStore(prefs).load();
  final (l10n, script) =
      notificationLanguage(settings, PlatformDispatcher.instance.locale);
  final calendar = calendarFor(settings.location, settings.yearStart);
  final holidays = await loadHolidays();
  final scheduler = ReminderScheduler(
    calendar: calendar,
    l10n: l10n,
    script: script,
    malayalamDigits: settings.malayalamDigits,
    options: ReminderOptionsStore(prefs).load(),
    holidays: holidays,
  );
  final db = AppDatabase(prefs).load();
  await sink.sync(scheduler.schedule(db, now), l10n);
  await widgets.update(homeWidgetData(
    today: calendar.fromGregorian(now.toUtc().add(calendar.location.utcOffset)),
    festivals: FestivalIndex(calendar, holidays, settings.categories),
    events: EventIndex(db.events, db.people, calendar),
    l10n: l10n,
    script: script,
    malayalamDigits: settings.malayalamDigits,
  ));
}

/// The plugin, once initialised in `main` on Android.
FlutterLocalNotificationsPlugin? notificationsPlugin;

/// Where notifications go; [NoNotifications] unless `main` set up Android.
final notificationSinkProvider = Provider<NotificationSink>((ref) {
  final plugin = notificationsPlugin;
  return plugin == null
      ? const NoNotifications()
      : AndroidNotifications(plugin);
});

/// Whether this is the Android app (set up in `main`).
bool isAndroidApp = false;

/// Where home-screen widget text goes; a no-op except in the Android app.
final homeWidgetSinkProvider =
    Provider<HomeWidgetSink>((ref) => HomeWidgetSink(enabled: isAndroidApp));

/// The notifications the current data and settings call for.
final scheduledNotificationsProvider =
    Provider<List<ScheduledNotification>>((ref) {
  final settings = ref.watch(settingsProvider);
  final (l10n, script) =
      notificationLanguage(settings, PlatformDispatcher.instance.locale);
  return ReminderScheduler(
    calendar: ref.watch(calendarProvider),
    l10n: l10n,
    script: script,
    malayalamDigits: settings.malayalamDigits,
    options: ref.watch(reminderOptionsProvider),
    holidays: ref.watch(holidaysProvider),
  ).schedule(ref.watch(repositoryProvider), ref.watch(clockProvider)());
});

/// Keeps the system's notifications in step with the app: schedules on
/// start and again a moment after any change to events or settings.
class ReminderSync {
  /// Starts syncing within [ref]'s container.
  ReminderSync(this._ref) {
    _ref.listen(scheduledNotificationsProvider, (_, __) => _soon(),
        fireImmediately: true);
  }

  final Ref _ref;
  Timer? _timer;

  void _soon() {
    _timer?.cancel();
    // Edits often come in bursts (an event and its reminder).
    _timer = Timer(const Duration(milliseconds: 500), syncNow);
  }

  /// Schedules now.
  Future<void> syncNow() async {
    _timer?.cancel();
    final settings = _ref.read(settingsProvider);
    final (l10n, script) =
        notificationLanguage(settings, PlatformDispatcher.instance.locale);
    await _ref
        .read(notificationSinkProvider)
        .sync(_ref.read(scheduledNotificationsProvider), l10n);
    await _ref.read(homeWidgetSinkProvider).update(homeWidgetData(
          today: _ref.read(todayProvider),
          festivals: _ref.read(festivalIndexProvider),
          events: _ref.read(eventIndexProvider),
          l10n: l10n,
          script: script,
          malayalamDigits: settings.malayalamDigits,
        ));
  }

  /// Stops listening.
  void dispose() => _timer?.cancel();
}

/// The running [ReminderSync]; read it once to start syncing.
final reminderSyncProvider = Provider<ReminderSync>((ref) {
  final sync = ReminderSync(ref);
  ref.onDispose(sync.dispose);
  return sync;
});

/// Route opened from a tapped notification, for the app to push.
final notificationRoute = ValueNotifier<String?>(null);

/// Name of the daily background job.
const dailyJob = 'in.armid.calendar.reschedule';

/// Background entry point of the daily job: tops up the 60-day window.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    await rescheduleFromPrefs(await SharedPreferences.getInstance(),
        AndroidNotifications(plugin), DateTime.now(),
        widgets: const HomeWidgetSink(enabled: true));
    return true;
  });
}

/// Handles a notification action while the app is not running.
@pragma('vm:entry-point')
void notificationBackgroundResponse(NotificationResponse response) {
  if (response.actionId != snoozeAction) return;
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(() async {
    final prefs = await SharedPreferences.getInstance();
    final (l10n, _) = notificationLanguage(
        SettingsStore(prefs).load(), PlatformDispatcher.instance.locale);
    await snooze(FlutterLocalNotificationsPlugin(), response, l10n);
  }());
}

/// Sets up notifications and the daily job on Android; does nothing on
/// other platforms. Call before `runApp`.
Future<void> initReminders(SharedPreferences prefs) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    onDidReceiveNotificationResponse: (response) async {
      if (response.actionId == snoozeAction) {
        final (l10n, _) = notificationLanguage(
            SettingsStore(prefs).load(), PlatformDispatcher.instance.locale);
        await snooze(plugin, response, l10n);
        return;
      }
      notificationRoute.value =
          NotificationPayload.decode(response.payload)?.route;
    },
    onDidReceiveBackgroundNotificationResponse: notificationBackgroundResponse,
  );
  notificationsPlugin = plugin;
  isAndroidApp = true;
  final launch = await plugin.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp ?? false) {
    notificationRoute.value =
        NotificationPayload.decode(launch!.notificationResponse?.payload)
            ?.route;
  }
  await Workmanager().initialize(backgroundDispatcher);
  await Workmanager().registerPeriodicTask(
    dailyJob,
    dailyJob,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
