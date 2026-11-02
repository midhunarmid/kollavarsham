import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml')
  ];

  /// App name shown in the title bar and task switcher.
  ///
  /// In en, this message translates to:
  /// **'Malayalam Calendar'**
  String get appTitle;

  /// Button that jumps back to today's date.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Heading above today's date card.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayHeading;

  /// Heading for the selected day's festivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals'**
  String get festivals;

  /// Shown when the selected day has no festivals.
  ///
  /// In en, this message translates to:
  /// **'No festivals on this day'**
  String get noFestivals;

  /// Heading for today's festivals on the Today tab.
  ///
  /// In en, this message translates to:
  /// **'Today\'s festivals'**
  String get todaysFestivals;

  /// Shown on the Today tab when today has no festival.
  ///
  /// In en, this message translates to:
  /// **'No festival today'**
  String get noFestivalToday;

  /// Bottom bar tab: today's date and panchangam.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Bottom bar tab and title: the month calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Bottom bar tab and title: people and their star birthdays.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get navPeople;

  /// Bottom bar tab and title: date converter and calculators.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// Bottom bar tab and title: app settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Placeholder on the People tab until it is built.
  ///
  /// In en, this message translates to:
  /// **'Add people and their pirannal, birthdays and shraddham here. Coming in a later update.'**
  String get peopleComingSoon;

  /// Placeholder on the Tools tab until it is built.
  ///
  /// In en, this message translates to:
  /// **'The date converter, age calculator and star finder will be here. Coming in a later update.'**
  String get toolsComingSoon;

  /// Settings: interface language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option: follow the device language.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get languageSystem;

  /// Settings: light or dark appearance.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme option: follow the device setting.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme option: light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option: dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Settings: script for month, star and festival names.
  ///
  /// In en, this message translates to:
  /// **'Names of months and stars'**
  String get settingsNameScript;

  /// Name script option: follow the interface language.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get nameScriptAuto;

  /// Name script option: Malayalam script.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get nameScriptMalayalam;

  /// Name script option: English transliteration in Latin letters.
  ///
  /// In en, this message translates to:
  /// **'Latin'**
  String get nameScriptLatin;

  /// Settings switch: write Malayalam dates with Malayalam digits.
  ///
  /// In en, this message translates to:
  /// **'Malayalam digits'**
  String get settingsMalayalamDigits;

  /// Help text under the Malayalam digits switch.
  ///
  /// In en, this message translates to:
  /// **'Write Malayalam dates as ൧൨൦൨ instead of 1202'**
  String get settingsMalayalamDigitsHelp;

  /// Settings: the place used for sunrise and month starts; also the title of the location picker.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// Help text under the location setting.
  ///
  /// In en, this message translates to:
  /// **'Used for sunrise, month starts and the panchangam'**
  String get settingsLocationHelp;

  /// Location picker option and dialog title: type latitude, longitude and time zone.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates'**
  String get locationManual;

  /// Field label: latitude in degrees.
  ///
  /// In en, this message translates to:
  /// **'Latitude (north +)'**
  String get latitude;

  /// Field label: longitude in degrees.
  ///
  /// In en, this message translates to:
  /// **'Longitude (east +)'**
  String get longitude;

  /// Field label: time zone as hours ahead of UTC.
  ///
  /// In en, this message translates to:
  /// **'Time zone (hours from UTC)'**
  String get utcOffsetHours;

  /// Examples under the time zone field.
  ///
  /// In en, this message translates to:
  /// **'India 5.5, UAE 4, Saudi Arabia 3'**
  String get utcOffsetHelp;

  /// Validation error for latitude.
  ///
  /// In en, this message translates to:
  /// **'Enter a latitude from −66 to 66'**
  String get invalidLatitude;

  /// Validation error for longitude.
  ///
  /// In en, this message translates to:
  /// **'Enter a longitude from −180 to 180'**
  String get invalidLongitude;

  /// Validation error for the time zone.
  ///
  /// In en, this message translates to:
  /// **'Enter hours from −12 to 14, in quarter hours'**
  String get invalidUtcOffset;

  /// Dialog button: close without saving.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Dialog button: save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Settings: which month starts the Kollavarsham year.
  ///
  /// In en, this message translates to:
  /// **'Year starts in'**
  String get settingsYearStart;

  /// Help text under the year start setting.
  ///
  /// In en, this message translates to:
  /// **'Kanni is the North Malabar custom; it changes only the year number'**
  String get settingsYearStartHelp;

  /// Settings: whether the month calendar shows Malayalam or English months.
  ///
  /// In en, this message translates to:
  /// **'Calendar opens with'**
  String get settingsCalendarMode;

  /// Calendar mode option: Chingam, Kanni…
  ///
  /// In en, this message translates to:
  /// **'Malayalam months'**
  String get calendarModeMalayalam;

  /// Calendar mode option: January, February…
  ///
  /// In en, this message translates to:
  /// **'English months'**
  String get calendarModeGregorian;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
