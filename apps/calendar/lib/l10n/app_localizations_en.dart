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

  @override
  String get panchangam => 'Panchangam';

  @override
  String get nakshatra => 'Star';

  @override
  String get tithi => 'Tithi';

  @override
  String get paksha => 'Paksha';

  @override
  String get yoga => 'Yoga';

  @override
  String get karana => 'Karana';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get moonrise => 'Moonrise';

  @override
  String get moonset => 'Moonset';

  @override
  String get noTime => 'None';

  @override
  String untilTime(String name, String time) {
    return '$name until $time';
  }

  @override
  String timeNextDay(String time) {
    return '$time (next day)';
  }

  @override
  String timeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String get nextFestival => 'Next festival';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'tomorrow',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String get dayDetails => 'Day details';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get monthStartClose =>
      'The month starts within minutes of the cut-off, so some almanacs may give a different first day.';

  @override
  String get timesForLocation =>
      'Times are for the location chosen in Settings.';

  @override
  String get peopleEmpty =>
      'No people yet. Add someone to keep their pirannal, birthday or shraddham.';

  @override
  String get addPerson => 'Add person';

  @override
  String get newPerson => 'New person';

  @override
  String get editPerson => 'Edit person';

  @override
  String get personName => 'Name';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get relation => 'Relation';

  @override
  String get relationSelf => 'Me';

  @override
  String get relationFamily => 'Family';

  @override
  String get relationFriend => 'Friend';

  @override
  String get relationOther => 'Other';

  @override
  String get colour => 'Colour';

  @override
  String colourOption(int number) {
    return 'Colour $number';
  }

  @override
  String get notes => 'Notes';

  @override
  String get delete => 'Delete';

  @override
  String deletePersonTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deletePersonBody => 'Their events and reminders are deleted too.';

  @override
  String get events => 'Events';

  @override
  String get noEvents => 'No events yet.';

  @override
  String get personNotFound => 'This person is no longer in your list.';

  @override
  String get eventPirannal => 'Pirannal';

  @override
  String get eventNakshatram => 'Nakshatram';

  @override
  String get eventBirthday => 'Birthday';

  @override
  String get eventShraddham => 'Shraddham';

  @override
  String get eventAnniversary => 'Anniversary';

  @override
  String get eventCustom => 'Event';
}
