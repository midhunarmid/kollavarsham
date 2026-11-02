import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/settings.dart';
import '../data/festival_days.dart';
import '../data/models.dart';

/// The user's reminder settings (Settings → Reminders).
@immutable
class ReminderOptions {
  /// Creates the options; the defaults are the first-run values.
  const ReminderOptions({
    this.enabled = true,
    this.eventTypes = const {...EventType.values},
    this.monthStarts = false,
    this.yearStart = true,
    this.minuteOfDay = 20 * 60,
    this.festivals = const {},
    this.dailyPanchangam = false,
    this.dailyMinute = 6 * 60,
  });

  /// Whether any notification is scheduled.
  final bool enabled;

  /// Event types whose reminders are scheduled.
  final Set<EventType> eventTypes;

  /// Remind the evening before each Malayalam month starts.
  final bool monthStarts;

  /// Remind the evening before the year starts (also when [monthStarts] is
  /// off).
  final bool yearStart;

  /// Local time of month start and festival reminders on the evening
  /// before, in minutes after midnight.
  final int minuteOfDay;

  /// Festival categories reminded of the evening before.
  final Set<FestivalCategory> festivals;

  /// A morning notification with the day's star and tithi.
  final bool dailyPanchangam;

  /// Local time of the daily panchangam, in minutes after midnight.
  final int dailyMinute;

  /// A copy with the given values replaced.
  ReminderOptions copyWith({
    bool? enabled,
    Set<EventType>? eventTypes,
    bool? monthStarts,
    bool? yearStart,
    int? minuteOfDay,
    Set<FestivalCategory>? festivals,
    bool? dailyPanchangam,
    int? dailyMinute,
  }) =>
      ReminderOptions(
        enabled: enabled ?? this.enabled,
        eventTypes: eventTypes ?? this.eventTypes,
        monthStarts: monthStarts ?? this.monthStarts,
        yearStart: yearStart ?? this.yearStart,
        minuteOfDay: minuteOfDay ?? this.minuteOfDay,
        festivals: festivals ?? this.festivals,
        dailyPanchangam: dailyPanchangam ?? this.dailyPanchangam,
        dailyMinute: dailyMinute ?? this.dailyMinute,
      );

  @override
  bool operator ==(Object other) =>
      other is ReminderOptions &&
      other.enabled == enabled &&
      setEquals(other.eventTypes, eventTypes) &&
      other.monthStarts == monthStarts &&
      other.yearStart == yearStart &&
      other.minuteOfDay == minuteOfDay &&
      setEquals(other.festivals, festivals) &&
      other.dailyPanchangam == dailyPanchangam &&
      other.dailyMinute == dailyMinute;

  @override
  int get hashCode => Object.hash(
      enabled,
      Object.hashAllUnordered(eventTypes),
      monthStarts,
      yearStart,
      minuteOfDay,
      Object.hashAllUnordered(festivals),
      dailyPanchangam,
      dailyMinute);
}

Set<T> _names<T extends Enum>(List<T> values, List<String>? names, Set<T> d) =>
    names == null
        ? d
        : {
            for (final v in values)
              if (names.contains(v.name)) v,
          };

/// Reads and writes [ReminderOptions] in [SharedPreferences].
class ReminderOptionsStore {
  /// Creates a store backed by [prefs].
  const ReminderOptionsStore(this.prefs);

  /// The preferences the options live in.
  final SharedPreferences prefs;

  static const _enabled = 'reminders.enabled';
  static const _eventTypes = 'reminders.eventTypes';
  static const _monthStarts = 'reminders.monthStarts';
  static const _yearStart = 'reminders.yearStart';
  static const _minute = 'reminders.minuteOfDay';
  static const _festivals = 'reminders.festivals';
  static const _daily = 'reminders.dailyPanchangam';
  static const _dailyMinute = 'reminders.dailyMinute';

  static int _minuteOr(int? v, int d) =>
      v != null && v >= 0 && v < 1440 ? v : d;

  /// The stored options; missing or damaged values fall back to defaults.
  ReminderOptions load() {
    const d = ReminderOptions();
    return ReminderOptions(
      enabled: prefs.getBool(_enabled) ?? d.enabled,
      eventTypes: _names(
          EventType.values, prefs.getStringList(_eventTypes), d.eventTypes),
      monthStarts: prefs.getBool(_monthStarts) ?? d.monthStarts,
      yearStart: prefs.getBool(_yearStart) ?? d.yearStart,
      minuteOfDay: _minuteOr(prefs.getInt(_minute), d.minuteOfDay),
      festivals: _names(FestivalCategory.values,
          prefs.getStringList(_festivals), d.festivals),
      dailyPanchangam: prefs.getBool(_daily) ?? d.dailyPanchangam,
      dailyMinute: _minuteOr(prefs.getInt(_dailyMinute), d.dailyMinute),
    );
  }

  /// Saves [o].
  Future<void> save(ReminderOptions o) async {
    await prefs.setBool(_enabled, o.enabled);
    await prefs
        .setStringList(_eventTypes, [for (final t in o.eventTypes) t.name]);
    await prefs.setBool(_monthStarts, o.monthStarts);
    await prefs.setBool(_yearStart, o.yearStart);
    await prefs.setInt(_minute, o.minuteOfDay);
    await prefs
        .setStringList(_festivals, [for (final f in o.festivals) f.name]);
    await prefs.setBool(_daily, o.dailyPanchangam);
    await prefs.setInt(_dailyMinute, o.dailyMinute);
  }
}

/// Holds the reminder options and saves every change.
class ReminderOptionsController extends Notifier<ReminderOptions> {
  @override
  ReminderOptions build() =>
      ReminderOptionsStore(ref.watch(sharedPreferencesProvider)).load();

  /// Replaces the options with [options] and saves them.
  Future<void> update(ReminderOptions options) {
    state = options;
    return ReminderOptionsStore(ref.read(sharedPreferencesProvider))
        .save(options);
  }
}

/// The current reminder options.
final reminderOptionsProvider =
    NotifierProvider<ReminderOptionsController, ReminderOptions>(
  ReminderOptionsController.new,
);
