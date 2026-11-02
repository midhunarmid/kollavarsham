// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Malayalam Calendar';

  @override
  String get today => 'Today';

  @override
  String get todayHeading => 'Today';

  @override
  String get festivals => 'Festivals';

  @override
  String get noFestivals => 'No festivals on this day';

  @override
  String get todaysFestivals => 'Today\'s festivals';

  @override
  String get noFestivalToday => 'No festival today';

  @override
  String get navToday => 'Today';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navPeople => 'People';

  @override
  String get navTools => 'Tools';

  @override
  String get navSettings => 'Settings';

  @override
  String get peopleComingSoon =>
      'Add people and their pirannal, birthdays and shraddham here. Coming in a later update.';

  @override
  String get toolsComingSoon =>
      'The date converter, age calculator and star finder will be here. Coming in a later update.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Device';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsNameScript => 'Names of months and stars';

  @override
  String get nameScriptAuto => 'Auto';

  @override
  String get nameScriptMalayalam => 'Malayalam';

  @override
  String get nameScriptLatin => 'Latin';

  @override
  String get settingsMalayalamDigits => 'Malayalam digits';

  @override
  String get settingsMalayalamDigitsHelp =>
      'Write Malayalam dates as ൧൨൦൨ instead of 1202';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsLocationHelp =>
      'Used for sunrise, month starts and the panchangam';

  @override
  String get locationManual => 'Enter coordinates';

  @override
  String get latitude => 'Latitude (north +)';

  @override
  String get longitude => 'Longitude (east +)';

  @override
  String get utcOffsetHours => 'Time zone (hours from UTC)';

  @override
  String get utcOffsetHelp => 'India 5.5, UAE 4, Saudi Arabia 3';

  @override
  String get invalidLatitude => 'Enter a latitude from −66 to 66';

  @override
  String get invalidLongitude => 'Enter a longitude from −180 to 180';

  @override
  String get invalidUtcOffset => 'Enter hours from −12 to 14, in quarter hours';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get settingsYearStart => 'Year starts in';

  @override
  String get settingsYearStartHelp =>
      'Kanni is the North Malabar custom; it changes only the year number';

  @override
  String get settingsCalendarMode => 'Calendar opens with';

  @override
  String get calendarModeMalayalam => 'Malayalam months';

  @override
  String get calendarModeGregorian => 'English months';

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome';

  @override
  String get onboardingWelcomeBody =>
      'Malayalam dates, stars, festivals and star birthdays (pirannal) for your family, all on this phone. Choose the language for the app.';

  @override
  String get onboardingLocationTitle => 'Your location';

  @override
  String get onboardingLocationBody =>
      'Sunrise decides the star of the day and the day a Malayalam month begins, so choose the nearest city. Outside Kerala, enter your coordinates and time zone. You can change this later in Settings.';

  @override
  String get change => 'Change';

  @override
  String get onboardingNotificationsTitle => 'Reminders';

  @override
  String get onboardingNotificationsBody =>
      'The app can send notifications so you don\'t miss:';

  @override
  String get onboardingNotifyPirannal =>
      'Pirannal and monthly nakshatram of the people you add';

  @override
  String get onboardingNotifyShraddham =>
      'Shraddham, birthdays and anniversaries';

  @override
  String get onboardingNotifyMonthStart =>
      'The start of each Malayalam month and year';

  @override
  String get onboardingNotificationsPrivacy =>
      'Android asks for permission when you set up your first reminder. Your events stay on this phone; the app has no account and sends nothing to a server.';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';
}
