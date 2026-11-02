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

  @override
  String get newEvent => 'New event';

  @override
  String get editEvent => 'Edit event';

  @override
  String get addEvent => 'Add event';

  @override
  String get eventType => 'Type';

  @override
  String get person => 'Person';

  @override
  String get noPerson => 'No one';

  @override
  String get malayalamMonth => 'Malayalam month';

  @override
  String get duplicateRuleHeading => 'If it falls on two days of the month';

  @override
  String get duplicateSecond => 'Second day';

  @override
  String get duplicateFirst => 'First day';

  @override
  String get duplicateSecondHelp =>
      'The later day is used, as in the usual Kerala practice for a birth star.';

  @override
  String get duplicateFirstHelp =>
      'The earlier day is used, as is usual for a shraddham by star.';

  @override
  String get shraddhamByTithi => 'By tithi';

  @override
  String get shraddhamByStar => 'By star';

  @override
  String get date => 'Date';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get year => 'Year (optional)';

  @override
  String get invalidYear => 'Enter a year between 1800 and 2200';

  @override
  String get eventTitle => 'Title';

  @override
  String get titleRequired => 'Enter a title';

  @override
  String get repeats => 'Repeats';

  @override
  String get kindMalayalamYearly => 'Malayalam date, every year';

  @override
  String get kindMalayalamMonthly => 'Malayalam date, every month';

  @override
  String get kindGregorianYearly => 'English date, every year';

  @override
  String get kindTithi => 'Tithi, every fortnight';

  @override
  String get day => 'Day';

  @override
  String get bothPakshas => 'Both';

  @override
  String get nextDates => 'Next dates';

  @override
  String get findMyStar => 'Find my star';

  @override
  String get findStarIntro =>
      'Enter the date and time of birth. The place is the location chosen in Settings.';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get birthTime => 'Time of birth';

  @override
  String starResult(String star, int pada) {
    return '$star, pada $pada';
  }

  @override
  String rashiResult(String rashi) {
    return '$rashi rashi';
  }

  @override
  String get useThisStar => 'Use this star';

  @override
  String get deleteEventTitle => 'Delete this event?';

  @override
  String get deleteEventBody => 'Its reminders are deleted too.';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noUpcoming => 'Nothing in the next 30 days.';

  @override
  String personEvent(String name, String event) {
    return '$name\'s $event';
  }

  @override
  String get pirannalAndEvents => 'Pirannal and events';

  @override
  String notifyPirannal(String name, String star) {
    return '$name\'s pirannal ($star)';
  }

  @override
  String notifyNakshatram(String name, String star) {
    return '$name\'s nakshatram ($star)';
  }

  @override
  String notifyBirthday(String name) {
    return '$name\'s birthday';
  }

  @override
  String notifyShraddham(String name) {
    return '$name\'s shraddham';
  }

  @override
  String notifyAnniversary(String name) {
    return '$name\'s anniversary';
  }

  @override
  String notifyWhen(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0, $date';
  }

  @override
  String notifyAge(int age) {
    return 'turns $age';
  }

  @override
  String notifyYears(int age) {
    return '$age years';
  }

  @override
  String notifyMonthStart(String month) {
    return '$month 1 tomorrow';
  }

  @override
  String notifyYearStart(String month, String year) {
    return '$month 1 tomorrow: Malayalam New Year $year';
  }

  @override
  String notifyMonthStartBody(String time) {
    return 'Sankranti at $time';
  }

  @override
  String notifyFestival(String name) {
    return '$name tomorrow';
  }

  @override
  String notifyDailyBody(String star, String tithi) {
    return 'Star $star · Tithi $tithi';
  }

  @override
  String get channelEvents => 'Pirannal and personal reminders';

  @override
  String get channelCalendar => 'Month starts and festivals';

  @override
  String get channelDaily => 'Daily panchangam';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionSnooze => 'Remind in 1 hour';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsRemindersHelp =>
      'Pirannal, festivals, month starts and the daily panchangam';

  @override
  String get remindersEnabled => 'Notifications';

  @override
  String get remindersNotifyFor => 'Remind me of';

  @override
  String get remindersMonthStarts => 'Every month start';

  @override
  String get remindersYearStart => 'Malayalam New Year';

  @override
  String get remindersEveningTime => 'Evening-before reminders at';

  @override
  String get remindersFestivals => 'Festivals, the evening before';

  @override
  String get categoryHindu => 'Hindu';

  @override
  String get categoryChristian => 'Christian';

  @override
  String get categoryMuslim => 'Muslim';

  @override
  String get muslimTentative =>
      'Muslim festival dates are tentative until the moon is sighted.';

  @override
  String get remindersDaily => 'Daily panchangam';

  @override
  String get remindersDailyTime => 'Daily panchangam at';

  @override
  String get remindersPermission => 'Allow notifications';

  @override
  String get remindersExact => 'Exact times';

  @override
  String get remindersExactOn => 'Reminders arrive on time.';

  @override
  String get remindersExactOff =>
      'Android may deliver reminders a few minutes late. Tap to allow exact times.';

  @override
  String remindersScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders in the next 60 days',
      one: '1 reminder in the next 60 days',
      zero: 'No reminders in the next 60 days',
    );
    return '$_temp0';
  }

  @override
  String get remindersWeb =>
      'In the browser, reminders show in the Today tab. Notifications come with the Android app.';

  @override
  String get categoryNational => 'National';

  @override
  String get categoryGovernment => 'Government';

  @override
  String get categoryBank => 'Bank';

  @override
  String get holidayPublic => 'Public holiday';

  @override
  String get holidayRestricted => 'Restricted holiday';

  @override
  String get holidayBank => 'Bank holiday';

  @override
  String get tentativeDate => 'Date may change';

  @override
  String get agenda => 'Agenda';

  @override
  String get searchHint => 'Search festivals and events';

  @override
  String get agendaEmpty => 'Nothing found in the next year.';

  @override
  String get yourEvents => 'Your events';

  @override
  String get categoriesHeading => 'Show';

  @override
  String get festivalAbout => 'About';

  @override
  String get festivalRule => 'How the date is found';

  @override
  String festivalSource(String url) {
    return 'Source: $url';
  }

  @override
  String get festivalNotFound => 'This festival is not in the calendar.';

  @override
  String get share => 'Share';

  @override
  String shareFestivalText(String name, String date) {
    return '$name: $date\nMalayalam Calendar · calendar.armid.in';
  }

  @override
  String get yearView => 'Year';

  @override
  String get previousYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String get toolConverter => 'Date converter';

  @override
  String get toolConverterHelp =>
      'Malayalam ⇄ English dates, with star and tithi';

  @override
  String get toolAge => 'Age calculator';

  @override
  String get toolAgeHelp =>
      'Age in years, months and days, and the next birthday';

  @override
  String get toolBetween => 'Days between dates';

  @override
  String get toolBetweenHelp => 'Count the days from one date to another';

  @override
  String get toolYearInfo => 'Kollavarsham year';

  @override
  String get toolYearInfoHelp =>
      'When each month starts, its length and sankranti';

  @override
  String get toolFindStarHelp =>
      'Birth star, pada and rashi from the time of birth';

  @override
  String get englishDate => 'English date';

  @override
  String get malayalamDate => 'Malayalam date';

  @override
  String get pickEnglishDate => 'Choose an English date';

  @override
  String get pickMalayalamDate => 'Choose a Malayalam date';

  @override
  String ageResult(int years, int months, int days) {
    return '$years years, $months months, $days days';
  }

  @override
  String totalDays(int count) {
    return '$count days in all';
  }

  @override
  String nextBirthday(String date, String when) {
    return 'Next birthday: $date ($when)';
  }

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String daysResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String weeksResult(int weeks, int days) {
    return '$weeks weeks and $days days';
  }

  @override
  String yearLength(int count, String first, String last) {
    return '$count days, from $first to $last';
  }

  @override
  String monthInfo(String start, int days, String time) {
    return '$start · $days days · sankranti $time';
  }

  @override
  String get shareCard => 'Share as image';

  @override
  String greetingPirannal(String name) {
    return 'Happy pirannal, $name!';
  }

  @override
  String greetingBirthday(String name) {
    return 'Happy birthday, $name!';
  }

  @override
  String get greeting => 'Greeting card';

  @override
  String get settingsBackup => 'Backup and export';

  @override
  String get settingsBackupHelp =>
      'Save or restore your data; export dates to another calendar';

  @override
  String get exportIcs => 'Export to another calendar (.ics)';

  @override
  String get exportIcsHelp =>
      'Each date is written out, so Google Calendar and others show the right day without knowing the Malayalam calendar.';

  @override
  String exportYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String exportButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dates',
      one: '1 date',
    );
    return 'Export $_temp0';
  }

  @override
  String get backupHeading => 'Backup';

  @override
  String get backupHelp =>
      'Your data stays on this device. Save a backup file to keep it safe or move it to another phone.';

  @override
  String get saveBackup => 'Save a backup';

  @override
  String get restoreBackup => 'Restore from a backup';

  @override
  String get restoreTitle => 'Replace your data?';

  @override
  String restoreBody(int people, int events) {
    return 'Your people, events, reminders and settings are replaced by the backup: $people people and $events events.';
  }

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreDone => 'Backup restored.';

  @override
  String get restoreFailed => 'That file is not a backup from this app.';

  @override
  String get reportWrongDate => 'Report a wrong date';
}
