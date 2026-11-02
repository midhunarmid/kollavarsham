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
}
