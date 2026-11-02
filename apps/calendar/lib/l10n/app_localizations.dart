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

  /// Title of the event editor when adding.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEvent;

  /// Title of the event editor when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// Button: add a recurring event (pirannal, birthday...).
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// Event editor: kind of event.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get eventType;

  /// Event editor: whose event it is.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// Person option: the event belongs to no person.
  ///
  /// In en, this message translates to:
  /// **'No one'**
  String get noPerson;

  /// Event editor: Malayalam month field.
  ///
  /// In en, this message translates to:
  /// **'Malayalam month'**
  String get malayalamMonth;

  /// Event editor: heading of the choice between the first and second day.
  ///
  /// In en, this message translates to:
  /// **'If it falls on two days of the month'**
  String get duplicateRuleHeading;

  /// Duplicate rule option: the later day.
  ///
  /// In en, this message translates to:
  /// **'Second day'**
  String get duplicateSecond;

  /// Duplicate rule option: the earlier day.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get duplicateFirst;

  /// Explanation of the second-day rule.
  ///
  /// In en, this message translates to:
  /// **'The later day is used, as in the usual Kerala practice for a birth star.'**
  String get duplicateSecondHelp;

  /// Explanation of the first-day rule.
  ///
  /// In en, this message translates to:
  /// **'The earlier day is used, as is usual for a shraddham by star.'**
  String get duplicateFirstHelp;

  /// Shraddham option: kept on the tithi of death.
  ///
  /// In en, this message translates to:
  /// **'By tithi'**
  String get shraddhamByTithi;

  /// Shraddham option: kept on the star of death.
  ///
  /// In en, this message translates to:
  /// **'By star'**
  String get shraddhamByStar;

  /// Event editor: the Gregorian date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Button: open the date picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// Event editor: year of birth or wedding, for ages.
  ///
  /// In en, this message translates to:
  /// **'Year (optional)'**
  String get year;

  /// Error for an out-of-range year.
  ///
  /// In en, this message translates to:
  /// **'Enter a year between 1800 and 2200'**
  String get invalidYear;

  /// Event editor: title of a custom event.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitle;

  /// Error when a custom event has no title.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get titleRequired;

  /// Event editor: how a custom event repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// Custom repeat option.
  ///
  /// In en, this message translates to:
  /// **'Malayalam date, every year'**
  String get kindMalayalamYearly;

  /// Custom repeat option.
  ///
  /// In en, this message translates to:
  /// **'Malayalam date, every month'**
  String get kindMalayalamMonthly;

  /// Custom repeat option: a Gregorian date.
  ///
  /// In en, this message translates to:
  /// **'English date, every year'**
  String get kindGregorianYearly;

  /// Custom repeat option: a tithi such as Ekadashi.
  ///
  /// In en, this message translates to:
  /// **'Tithi, every fortnight'**
  String get kindTithi;

  /// Event editor: day of the month.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Paksha option: both fortnights.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get bothPakshas;

  /// Event editor: preview of the next occurrences.
  ///
  /// In en, this message translates to:
  /// **'Next dates'**
  String get nextDates;

  /// Button and title: work out the birth star from the birth date and time.
  ///
  /// In en, this message translates to:
  /// **'Find my star'**
  String get findMyStar;

  /// Find my star: instructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the date and time of birth. The place is the location chosen in Settings.'**
  String get findStarIntro;

  /// Find my star: date field.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDate;

  /// Find my star: time field.
  ///
  /// In en, this message translates to:
  /// **'Time of birth'**
  String get birthTime;

  /// Find my star: the star and its quarter.
  ///
  /// In en, this message translates to:
  /// **'{star}, pada {pada}'**
  String starResult(String star, int pada);

  /// Find my star: the Moon sign.
  ///
  /// In en, this message translates to:
  /// **'{rashi} rashi'**
  String rashiResult(String rashi);

  /// Find my star: fill the pirannal with the result.
  ///
  /// In en, this message translates to:
  /// **'Use this star'**
  String get useThisStar;

  /// Confirm dialog title for deleting an event.
  ///
  /// In en, this message translates to:
  /// **'Delete this event?'**
  String get deleteEventTitle;

  /// Confirm dialog text for deleting an event.
  ///
  /// In en, this message translates to:
  /// **'Its reminders are deleted too.'**
  String get deleteEventBody;

  /// Heading of the upcoming events list.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Shown when no personal event falls in the next 30 days.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the next 30 days.'**
  String get noUpcoming;

  /// A person's event, e.g. 'Midhun's Pirannal'.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s {event}'**
  String personEvent(String name, String event);

  /// Today tab: heading of upcoming personal events.
  ///
  /// In en, this message translates to:
  /// **'Pirannal and events'**
  String get pirannalAndEvents;

  /// Reminder title for a star birthday. {star} is the nakshatra.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s pirannal ({star})'**
  String notifyPirannal(String name, String star);

  /// Reminder title for the monthly birth star day.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s nakshatram ({star})'**
  String notifyNakshatram(String name, String star);

  /// Reminder title for a Gregorian birthday.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s birthday'**
  String notifyBirthday(String name);

  /// Reminder title for a death anniversary.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s shraddham'**
  String notifyShraddham(String name);

  /// Reminder title for an anniversary.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s anniversary'**
  String notifyAnniversary(String name);

  /// Reminder text: when the day is, and its date ({date}, e.g. '14 Dhanu').
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{Tomorrow} other{In {count} days}}, {date}'**
  String notifyWhen(int count, String date);

  /// Added to a birthday reminder when the birth year is known.
  ///
  /// In en, this message translates to:
  /// **'turns {age}'**
  String notifyAge(int age);

  /// Added to an anniversary reminder when the year is known.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String notifyYears(int age);

  /// Reminder the day before a Malayalam month starts. {month} is e.g. Thulam.
  ///
  /// In en, this message translates to:
  /// **'{month} 1 tomorrow'**
  String notifyMonthStart(String month);

  /// Reminder the day before the Kollavarsham year starts, e.g. 'Chingam 1 tomorrow: Malayalam New Year 1202'.
  ///
  /// In en, this message translates to:
  /// **'{month} 1 tomorrow: Malayalam New Year {year}'**
  String notifyYearStart(String month, String year);

  /// Text of a month start reminder: the time of the sun's entry into the sign.
  ///
  /// In en, this message translates to:
  /// **'Sankranti at {time}'**
  String notifyMonthStartBody(String time);

  /// Festival reminder on the evening before.
  ///
  /// In en, this message translates to:
  /// **'{name} tomorrow'**
  String notifyFestival(String name);

  /// Text of the morning panchangam notification.
  ///
  /// In en, this message translates to:
  /// **'Star {star} · Tithi {tithi}'**
  String notifyDailyBody(String star, String tithi);

  /// Android notification channel name for personal event reminders.
  ///
  /// In en, this message translates to:
  /// **'Pirannal and personal reminders'**
  String get channelEvents;

  /// Android notification channel name for month start and festival reminders.
  ///
  /// In en, this message translates to:
  /// **'Month starts and festivals'**
  String get channelCalendar;

  /// Android notification channel name for the morning panchangam.
  ///
  /// In en, this message translates to:
  /// **'Daily panchangam'**
  String get channelDaily;

  /// Notification button: open the day in the app.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// Notification button: snooze for an hour.
  ///
  /// In en, this message translates to:
  /// **'Remind in 1 hour'**
  String get actionSnooze;

  /// Settings entry and title of the reminder settings screen.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// Subtitle of the Reminders entry in Settings.
  ///
  /// In en, this message translates to:
  /// **'Pirannal, festivals, month starts and the daily panchangam'**
  String get settingsRemindersHelp;

  /// Reminder settings: master switch.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get remindersEnabled;

  /// Reminder settings: heading of the event type choices.
  ///
  /// In en, this message translates to:
  /// **'Remind me of'**
  String get remindersNotifyFor;

  /// Reminder settings: remind the evening before each Malayalam month starts.
  ///
  /// In en, this message translates to:
  /// **'Every month start'**
  String get remindersMonthStarts;

  /// Reminder settings: remind the evening before the year starts.
  ///
  /// In en, this message translates to:
  /// **'Malayalam New Year'**
  String get remindersYearStart;

  /// Reminder settings: time of month start and festival reminders on the evening before.
  ///
  /// In en, this message translates to:
  /// **'Evening-before reminders at'**
  String get remindersEveningTime;

  /// Reminder settings: heading of festival categories.
  ///
  /// In en, this message translates to:
  /// **'Festivals, the evening before'**
  String get remindersFestivals;

  /// Festival category.
  ///
  /// In en, this message translates to:
  /// **'Hindu'**
  String get categoryHindu;

  /// Festival category.
  ///
  /// In en, this message translates to:
  /// **'Christian'**
  String get categoryChristian;

  /// Festival category.
  ///
  /// In en, this message translates to:
  /// **'Muslim'**
  String get categoryMuslim;

  /// Note under the festival categories.
  ///
  /// In en, this message translates to:
  /// **'Muslim festival dates are tentative until the moon is sighted.'**
  String get muslimTentative;

  /// Reminder settings: a morning notification with the day's star and tithi.
  ///
  /// In en, this message translates to:
  /// **'Daily panchangam'**
  String get remindersDaily;

  /// Reminder settings: time of the morning panchangam.
  ///
  /// In en, this message translates to:
  /// **'Daily panchangam at'**
  String get remindersDailyTime;

  /// Button: ask Android for permission to show notifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get remindersPermission;

  /// Reminder settings: whether Android allows exact alarm times.
  ///
  /// In en, this message translates to:
  /// **'Exact times'**
  String get remindersExact;

  /// Exact alarms are allowed.
  ///
  /// In en, this message translates to:
  /// **'Reminders arrive on time.'**
  String get remindersExactOn;

  /// Exact alarms are not allowed; tapping opens the system setting.
  ///
  /// In en, this message translates to:
  /// **'Android may deliver reminders a few minutes late. Tap to allow exact times.'**
  String get remindersExactOff;

  /// Reminder settings: how many notifications are scheduled.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reminders in the next 60 days} =1{1 reminder in the next 60 days} other{{count} reminders in the next 60 days}}'**
  String remindersScheduled(int count);

  /// Reminder settings note on the web.
  ///
  /// In en, this message translates to:
  /// **'In the browser, reminders show in the Today tab. Notifications come with the Android app.'**
  String get remindersWeb;

  /// Festival category: national days.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get categoryNational;

  /// Festival category: Kerala government holidays such as jayanthis.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get categoryGovernment;

  /// Festival category: bank-only closures.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get categoryBank;

  /// Badge: the day is a public holiday.
  ///
  /// In en, this message translates to:
  /// **'Public holiday'**
  String get holidayPublic;

  /// Badge: an optional holiday for some communities.
  ///
  /// In en, this message translates to:
  /// **'Restricted holiday'**
  String get holidayRestricted;

  /// Badge: banks are closed.
  ///
  /// In en, this message translates to:
  /// **'Bank holiday'**
  String get holidayBank;

  /// Badge on a festival whose date depends on the moon being sighted.
  ///
  /// In en, this message translates to:
  /// **'Date may change'**
  String get tentativeDate;

  /// Title and button: list of upcoming festivals, holidays and events.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// Hint in the agenda search field.
  ///
  /// In en, this message translates to:
  /// **'Search festivals and events'**
  String get searchHint;

  /// Agenda: no matches.
  ///
  /// In en, this message translates to:
  /// **'Nothing found in the next year.'**
  String get agendaEmpty;

  /// Day detail: heading of the user's own events on that day.
  ///
  /// In en, this message translates to:
  /// **'Your events'**
  String get yourEvents;

  /// Heading of the festival category filter.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get categoriesHeading;

  /// Festival detail: heading of the description.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get festivalAbout;

  /// Festival detail: heading of the date rule.
  ///
  /// In en, this message translates to:
  /// **'How the date is found'**
  String get festivalRule;

  /// Festival detail: where a holiday entry comes from.
  ///
  /// In en, this message translates to:
  /// **'Source: {url}'**
  String festivalSource(String url);

  /// Shown when a festival link has no dates.
  ///
  /// In en, this message translates to:
  /// **'This festival is not in the calendar.'**
  String get festivalNotFound;

  /// Button: share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Text shared for a festival.
  ///
  /// In en, this message translates to:
  /// **'{name}: {date}\nMalayalam Calendar · calendar.armid.in'**
  String shareFestivalText(String name, String date);

  /// Button and title: the year view with twelve small months.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearView;

  /// Tooltip: previous year.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// Tooltip: next year.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// Tool: convert between Malayalam and English dates.
  ///
  /// In en, this message translates to:
  /// **'Date converter'**
  String get toolConverter;

  /// Subtitle of the date converter tool.
  ///
  /// In en, this message translates to:
  /// **'Malayalam ⇄ English dates, with star and tithi'**
  String get toolConverterHelp;

  /// Tool: age from a date of birth.
  ///
  /// In en, this message translates to:
  /// **'Age calculator'**
  String get toolAge;

  /// Subtitle of the age calculator.
  ///
  /// In en, this message translates to:
  /// **'Age in years, months and days, and the next birthday'**
  String get toolAgeHelp;

  /// Tool: number of days between two dates.
  ///
  /// In en, this message translates to:
  /// **'Days between dates'**
  String get toolBetween;

  /// Subtitle of the days-between tool.
  ///
  /// In en, this message translates to:
  /// **'Count the days from one date to another'**
  String get toolBetweenHelp;

  /// Tool: the months of a Kollavarsham year.
  ///
  /// In en, this message translates to:
  /// **'Kollavarsham year'**
  String get toolYearInfo;

  /// Subtitle of the year info tool.
  ///
  /// In en, this message translates to:
  /// **'When each month starts, its length and sankranti'**
  String get toolYearInfoHelp;

  /// Subtitle of the Find my star tool.
  ///
  /// In en, this message translates to:
  /// **'Birth star, pada and rashi from the time of birth'**
  String get toolFindStarHelp;

  /// Label: the Gregorian date.
  ///
  /// In en, this message translates to:
  /// **'English date'**
  String get englishDate;

  /// Label: the Malayalam (Kollavarsham) date.
  ///
  /// In en, this message translates to:
  /// **'Malayalam date'**
  String get malayalamDate;

  /// Button: open the Gregorian date picker.
  ///
  /// In en, this message translates to:
  /// **'Choose an English date'**
  String get pickEnglishDate;

  /// Button: open the Malayalam date picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a Malayalam date'**
  String get pickMalayalamDate;

  /// Age calculator result.
  ///
  /// In en, this message translates to:
  /// **'{years} years, {months} months, {days} days'**
  String ageResult(int years, int months, int days);

  /// Total number of days.
  ///
  /// In en, this message translates to:
  /// **'{count} days in all'**
  String totalDays(int count);

  /// Age calculator: next birthday and countdown.
  ///
  /// In en, this message translates to:
  /// **'Next birthday: {date} ({when})'**
  String nextBirthday(String date, String when);

  /// Days between: the first date.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// Days between: the second date.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// Number of days between two dates.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysResult(int count);

  /// Days between, in weeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks and {days} days'**
  String weeksResult(int weeks, int days);

  /// Year info: length and Gregorian span of a Kollavarsham year.
  ///
  /// In en, this message translates to:
  /// **'{count} days, from {first} to {last}'**
  String yearLength(int count, String first, String last);

  /// Year info row: month start, length and sankranti time.
  ///
  /// In en, this message translates to:
  /// **'{start} · {days} days · sankranti {time}'**
  String monthInfo(String start, int days, String time);

  /// Button: share a card image.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get shareCard;

  /// Pirannal greeting card title.
  ///
  /// In en, this message translates to:
  /// **'Happy pirannal, {name}!'**
  String greetingPirannal(String name);

  /// Birthday greeting card title.
  ///
  /// In en, this message translates to:
  /// **'Happy birthday, {name}!'**
  String greetingBirthday(String name);

  /// Button: make a greeting card for a pirannal or birthday.
  ///
  /// In en, this message translates to:
  /// **'Greeting card'**
  String get greeting;
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
