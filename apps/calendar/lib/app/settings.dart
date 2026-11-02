import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// The user's app settings.
@immutable
class AppSettings {
  /// Creates settings; the defaults are the first-run values.
  const AppSettings({
    this.language = AppLanguage.system,
    this.themeMode = ThemeMode.system,
  });

  /// Interface language.
  final AppLanguage language;

  /// Light, dark or system theme.
  final ThemeMode themeMode;

  /// A copy with the given values replaced.
  AppSettings copyWith({AppLanguage? language, ThemeMode? themeMode}) =>
      AppSettings(
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.language == language &&
      other.themeMode == themeMode;

  @override
  int get hashCode => Object.hash(language, themeMode);
}

/// Holds the current [AppSettings].
class SettingsController extends Notifier<AppSettings> {
  /// Creates a controller starting from [initial].
  SettingsController([this.initial = const AppSettings()]);

  /// The settings before any change.
  final AppSettings initial;

  @override
  AppSettings build() => initial;

  /// Replaces the settings with [settings].
  void update(AppSettings settings) => state = settings;
}

/// The current settings.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
