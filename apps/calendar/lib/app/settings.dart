import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locations.dart';

/// Interface language.
enum AppLanguage {
  /// The device language (Malayalam if it is Malayalam, else English).
  system,

  /// Malayalam.
  malayalam,

  /// English.
  english;

  /// The locale to force, or null to follow the device.
  Locale? get locale => switch (this) {
        system => null,
        malayalam => const Locale('ml'),
        english => const Locale('en'),
      };
}

/// Script for month, star and festival names.
enum NameScript {
  /// Malayalam script in a Malayalam interface, Latin otherwise.
  auto,

  /// Always Malayalam script.
  malayalam,

  /// Always Latin transliteration.
  english;

  /// The script to pass to the widgets; null means "follow the locale".
  MalayalamScript? get script => switch (this) {
        auto => null,
        malayalam => MalayalamScript.malayalam,
        english => MalayalamScript.english,
      };
}

/// The user's app settings.
@immutable
class AppSettings {
  /// Creates settings; the defaults are the first-run values.
  const AppSettings({
    this.language = AppLanguage.system,
    this.nameScript = NameScript.auto,
    this.malayalamDigits = false,
    this.location = ObserverLocation.thiruvananthapuram,
    this.yearStart = YearStart.chingam,
    this.calendarMode = CalendarMode.malayalam,
    this.themeMode = ThemeMode.system,
    this.onboardingDone = false,
  });

  /// Interface language.
  final AppLanguage language;

  /// Script for month, star and festival names.
  final NameScript nameScript;

  /// Whether numbers in Malayalam dates use Malayalam digits (൧൨൩).
  final bool malayalamDigits;

  /// Where sunrise and month starts are reckoned; a Kerala city from
  /// [keralaCities] or a manual location.
  final ObserverLocation location;

  /// Month that starts the Kollavarsham year.
  final YearStart yearStart;

  /// Whether the month calendar opens on Malayalam or Gregorian months.
  final CalendarMode calendarMode;

  /// Light, dark or system theme.
  final ThemeMode themeMode;

  /// Whether the first-run onboarding has been completed.
  final bool onboardingDone;

  /// A copy with the given values replaced.
  AppSettings copyWith({
    AppLanguage? language,
    NameScript? nameScript,
    bool? malayalamDigits,
    ObserverLocation? location,
    YearStart? yearStart,
    CalendarMode? calendarMode,
    ThemeMode? themeMode,
    bool? onboardingDone,
  }) =>
      AppSettings(
        language: language ?? this.language,
        nameScript: nameScript ?? this.nameScript,
        malayalamDigits: malayalamDigits ?? this.malayalamDigits,
        location: location ?? this.location,
        yearStart: yearStart ?? this.yearStart,
        calendarMode: calendarMode ?? this.calendarMode,
        themeMode: themeMode ?? this.themeMode,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.language == language &&
      other.nameScript == nameScript &&
      other.malayalamDigits == malayalamDigits &&
      other.location == location &&
      other.yearStart == yearStart &&
      other.calendarMode == calendarMode &&
      other.themeMode == themeMode &&
      other.onboardingDone == onboardingDone;

  @override
  int get hashCode => Object.hash(language, nameScript, malayalamDigits,
      location, yearStart, calendarMode, themeMode, onboardingDone);
}

T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// Reads and writes [AppSettings] in [SharedPreferences].
///
/// Unknown or missing values fall back to the defaults, so old or damaged
/// preferences never stop the app from starting.
class SettingsStore {
  /// Creates a store backed by [prefs].
  const SettingsStore(this.prefs);

  /// The preferences the settings live in.
  final SharedPreferences prefs;

  static const _language = 'settings.language';
  static const _nameScript = 'settings.nameScript';
  static const _malayalamDigits = 'settings.malayalamDigits';
  static const _location = 'settings.location';
  static const _latitude = 'settings.latitude';
  static const _longitude = 'settings.longitude';
  static const _utcOffset = 'settings.utcOffsetMinutes';
  static const _yearStart = 'settings.yearStart';
  static const _calendarMode = 'settings.calendarMode';
  static const _themeMode = 'settings.themeMode';
  static const _onboardingDone = 'settings.onboardingDone';

  /// Value of the location key for a manual location.
  static const manualLocation = 'manual';

  /// The stored settings.
  AppSettings load() {
    const d = AppSettings();
    return AppSettings(
      language:
          _byName(AppLanguage.values, prefs.getString(_language), d.language),
      nameScript: _byName(
          NameScript.values, prefs.getString(_nameScript), d.nameScript),
      malayalamDigits: prefs.getBool(_malayalamDigits) ?? d.malayalamDigits,
      location: _loadLocation() ?? d.location,
      yearStart:
          _byName(YearStart.values, prefs.getString(_yearStart), d.yearStart),
      calendarMode: _byName(
          CalendarMode.values, prefs.getString(_calendarMode), d.calendarMode),
      themeMode:
          _byName(ThemeMode.values, prefs.getString(_themeMode), d.themeMode),
      onboardingDone: prefs.getBool(_onboardingDone) ?? d.onboardingDone,
    );
  }

  ObserverLocation? _loadLocation() {
    final id = prefs.getString(_location);
    if (id != manualLocation) return keralaCityById(id ?? '')?.location;
    final lat = prefs.getDouble(_latitude);
    final lng = prefs.getDouble(_longitude);
    final offset = prefs.getInt(_utcOffset);
    if (lat == null || lng == null || offset == null) return null;
    if (!isValidLocation(lat, lng, offset)) return null;
    return ObserverLocation(
        latitude: lat, longitude: lng, utcOffset: Duration(minutes: offset));
  }

  /// Saves [s].
  Future<void> save(AppSettings s) async {
    await prefs.setString(_language, s.language.name);
    await prefs.setString(_nameScript, s.nameScript.name);
    await prefs.setBool(_malayalamDigits, s.malayalamDigits);
    final city = keralaCityAt(s.location);
    await prefs.setString(_location, city?.id ?? manualLocation);
    await prefs.setDouble(_latitude, s.location.latitude);
    await prefs.setDouble(_longitude, s.location.longitude);
    await prefs.setInt(_utcOffset, s.location.utcOffset.inMinutes);
    await prefs.setString(_yearStart, s.yearStart.name);
    await prefs.setString(_calendarMode, s.calendarMode.name);
    await prefs.setString(_themeMode, s.themeMode.name);
    await prefs.setBool(_onboardingDone, s.onboardingDone);
  }
}

/// Whether a manual location is usable: latitude within ±66° (beyond the
/// polar circles the Sun need not rise), longitude within ±180°, and a UTC
/// offset from −12:00 to +14:00 in quarter hours.
bool isValidLocation(double latitude, double longitude, int utcOffsetMinutes) =>
    latitude.abs() <= 66 &&
    longitude.abs() <= 180 &&
    utcOffsetMinutes >= -12 * 60 &&
    utcOffsetMinutes <= 14 * 60 &&
    utcOffsetMinutes % 15 == 0;

/// The app's preferences; overridden in `main` with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider'),
);

/// Holds the current [AppSettings] and saves every change.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() =>
      SettingsStore(ref.watch(sharedPreferencesProvider)).load();

  /// Replaces the settings with [settings] and saves them.
  Future<void> update(AppSettings settings) {
    state = settings;
    return SettingsStore(ref.read(sharedPreferencesProvider)).save(settings);
  }
}

/// The current settings.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// The calendar for the chosen location and year start.
final calendarProvider = Provider<KollavarshamCalendar>((ref) {
  final (location, yearStart) =
      ref.watch(settingsProvider.select((s) => (s.location, s.yearStart)));
  if (location == ObserverLocation.thiruvananthapuram &&
      yearStart == YearStart.chingam) {
    return KollavarshamCalendar.standard;
  }
  return KollavarshamCalendar(location: location, yearStart: yearStart);
});
