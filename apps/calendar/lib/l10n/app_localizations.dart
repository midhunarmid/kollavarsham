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

  /// Button: close a dialog without changes.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button: save the editor.
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

  /// Progress label at the top of each onboarding page.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStep(int step, int total);

  /// Onboarding page 1 title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingWelcomeTitle;

  /// Onboarding page 1 text, above the language choice.
  ///
  /// In en, this message translates to:
  /// **'Malayalam dates, stars, festivals and star birthdays (pirannal) for your family, all on this phone. Choose the language for the app.'**
  String get onboardingWelcomeBody;

  /// Onboarding page 2 title.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get onboardingLocationTitle;

  /// Onboarding page 2 text, above the location choice.
  ///
  /// In en, this message translates to:
  /// **'Sunrise decides the star of the day and the day a Malayalam month begins, so choose the nearest city. Outside Kerala, enter your coordinates and time zone. You can change this later in Settings.'**
  String get onboardingLocationBody;

  /// Button that opens a picker to change a value.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Onboarding page 3 title.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get onboardingNotificationsTitle;

  /// Onboarding page 3 text, above the list of reminder kinds.
  ///
  /// In en, this message translates to:
  /// **'The app can send notifications so you don\'t miss:'**
  String get onboardingNotificationsBody;

  /// Onboarding: first kind of reminder.
  ///
  /// In en, this message translates to:
  /// **'Pirannal and monthly nakshatram of the people you add'**
  String get onboardingNotifyPirannal;

  /// Onboarding: second kind of reminder.
  ///
  /// In en, this message translates to:
  /// **'Shraddham, birthdays and anniversaries'**
  String get onboardingNotifyShraddham;

  /// Onboarding: third kind of reminder.
  ///
  /// In en, this message translates to:
  /// **'The start of each Malayalam month and year'**
  String get onboardingNotifyMonthStart;

  /// Onboarding page 3: when the permission is asked, and the privacy promise.
  ///
  /// In en, this message translates to:
  /// **'Android asks for permission when you set up your first reminder. Your events stay on this phone; the app has no account and sends nothing to a server.'**
  String get onboardingNotificationsPrivacy;

  /// Onboarding button: previous page.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Onboarding button: next page.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Onboarding button on the last page: finish and open the app.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Heading of the day's almanac details (star, tithi, sunrise, kalams).
  ///
  /// In en, this message translates to:
  /// **'Panchangam'**
  String get panchangam;

  /// Panchangam row: the nakshatra (lunar mansion) of the day.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get nakshatra;

  /// Panchangam row: the lunar day.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get tithi;

  /// Panchangam row: waxing or waning fortnight.
  ///
  /// In en, this message translates to:
  /// **'Paksha'**
  String get paksha;

  /// Panchangam row: the yoga of the day.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// Panchangam row: the karana (half tithi).
  ///
  /// In en, this message translates to:
  /// **'Karana'**
  String get karana;

  /// Panchangam row: time of sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// Panchangam row: time of sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// Panchangam row: time of moonrise.
  ///
  /// In en, this message translates to:
  /// **'Moonrise'**
  String get moonrise;

  /// Panchangam row: time of moonset.
  ///
  /// In en, this message translates to:
  /// **'Moonset'**
  String get moonset;

  /// Shown instead of a time when the event (e.g. moonrise) does not happen that day.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noTime;

  /// A star, tithi etc. and the time it ends, e.g. 'Pooradam until 14:20'.
  ///
  /// In en, this message translates to:
  /// **'{name} until {time}'**
  String untilTime(String name, String time);

  /// A time that falls on the following calendar day.
  ///
  /// In en, this message translates to:
  /// **'{time} (next day)'**
  String timeNextDay(String time);

  /// A time range, e.g. Rahu kalam 13:30–15:00.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end}'**
  String timeRange(String start, String end);

  /// Heading on the Today tab for the next upcoming festival.
  ///
  /// In en, this message translates to:
  /// **'Next festival'**
  String get nextFestival;

  /// Countdown to a date.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{today} =1{tomorrow} other{in {count} days}}'**
  String inDays(int count);

  /// Button and title for the full panchangam of a day.
  ///
  /// In en, this message translates to:
  /// **'Day details'**
  String get dayDetails;

  /// Tooltip: go to the previous day.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// Tooltip: go to the next day.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// Note on a month's first day when the sankranti is close to the cut-off time.
  ///
  /// In en, this message translates to:
  /// **'The month starts within minutes of the cut-off, so some almanacs may give a different first day.'**
  String get monthStartClose;

  /// Footnote under the panchangam times.
  ///
  /// In en, this message translates to:
  /// **'Times are for the location chosen in Settings.'**
  String get timesForLocation;

  /// Empty People tab.
  ///
  /// In en, this message translates to:
  /// **'No people yet. Add someone to keep their pirannal, birthday or shraddham.'**
  String get peopleEmpty;

  /// Button: add a person.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// Title of the person editor when adding.
  ///
  /// In en, this message translates to:
  /// **'New person'**
  String get newPerson;

  /// Title of the person editor when editing, and its button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// Person editor: name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get personName;

  /// Error when the name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// Person editor: relation to the user.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// Relation: the user themselves.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get relationSelf;

  /// Relation: family member.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get relationFamily;

  /// Relation: friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationFriend;

  /// Relation: anyone else.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationOther;

  /// Editor: marker colour for the calendar.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// Accessibility label of a colour swatch.
  ///
  /// In en, this message translates to:
  /// **'Colour {number}'**
  String colourOption(int number);

  /// Editor: free-text notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Button: delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm dialog title for deleting a person.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deletePersonTitle(String name);

  /// Confirm dialog text for deleting a person.
  ///
  /// In en, this message translates to:
  /// **'Their events and reminders are deleted too.'**
  String get deletePersonBody;

  /// Heading of a person's recurring events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// Shown when a person has no events.
  ///
  /// In en, this message translates to:
  /// **'No events yet.'**
  String get noEvents;

  /// Shown when opening a deleted person.
  ///
  /// In en, this message translates to:
  /// **'This person is no longer in your list.'**
  String get personNotFound;

  /// Event type: yearly star birthday.
  ///
  /// In en, this message translates to:
  /// **'Pirannal'**
  String get eventPirannal;

  /// Event type: monthly birth star day.
  ///
  /// In en, this message translates to:
  /// **'Nakshatram'**
  String get eventNakshatram;

  /// Event type: Gregorian birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get eventBirthday;

  /// Event type: yearly death anniversary.
  ///
  /// In en, this message translates to:
  /// **'Shraddham'**
  String get eventShraddham;

  /// Event type: wedding or other anniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get eventAnniversary;

  /// Event type: any other recurring event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventCustom;
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
