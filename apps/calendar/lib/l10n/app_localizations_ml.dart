// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'മലയാളം കലണ്ടർ';

  @override
  String get today => 'ഇന്ന്';

  @override
  String get todayHeading => 'ഇന്ന്';

  @override
  String get festivals => 'വിശേഷങ്ങൾ';

  @override
  String get noFestivals => 'ഈ ദിവസം വിശേഷങ്ങളില്ല';

  @override
  String get todaysFestivals => 'ഇന്നത്തെ വിശേഷങ്ങൾ';

  @override
  String get noFestivalToday => 'ഇന്ന് വിശേഷങ്ങളില്ല';

  @override
  String get navToday => 'ഇന്ന്';

  @override
  String get navCalendar => 'കലണ്ടർ';

  @override
  String get navPeople => 'ആളുകൾ';

  @override
  String get navTools => 'ഉപകരണങ്ങൾ';

  @override
  String get navSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get toolsComingSoon =>
      'തീയതി മാറ്റൽ, വയസ്സ് കണക്കാക്കൽ, നക്ഷത്രം കണ്ടെത്തൽ എന്നിവ ഇവിടെ ഉണ്ടാകും. അടുത്ത അപ്ഡേറ്റിൽ വരും.';

  @override
  String get settingsLanguage => 'ഭാഷ';

  @override
  String get languageSystem => 'ഉപകരണം';

  @override
  String get settingsTheme => 'തീം';

  @override
  String get themeSystem => 'സിസ്റ്റം';

  @override
  String get themeLight => 'ലൈറ്റ്';

  @override
  String get themeDark => 'ഡാർക്ക്';

  @override
  String get settingsNameScript => 'മാസങ്ങളുടെയും നക്ഷത്രങ്ങളുടെയും പേരുകൾ';

  @override
  String get nameScriptAuto => 'സ്വയം';

  @override
  String get nameScriptMalayalam => 'മലയാളം';

  @override
  String get nameScriptLatin => 'ലാറ്റിൻ';

  @override
  String get settingsMalayalamDigits => 'മലയാള അക്കങ്ങൾ';

  @override
  String get settingsMalayalamDigitsHelp =>
      'മലയാളം തീയതികൾ 1202 എന്നതിനു പകരം ൧൨൦൨ എന്ന് എഴുതുക';

  @override
  String get settingsLocation => 'സ്ഥലം';

  @override
  String get settingsLocationHelp =>
      'സൂര്യോദയം, മാസാരംഭം, പഞ്ചാംഗം എന്നിവയ്ക്ക്';

  @override
  String get locationManual => 'അക്ഷാംശവും രേഖാംശവും നൽകുക';

  @override
  String get latitude => 'അക്ഷാംശം (വടക്ക് +)';

  @override
  String get longitude => 'രേഖാംശം (കിഴക്ക് +)';

  @override
  String get utcOffsetHours => 'സമയമേഖല (UTC-യിൽ നിന്നുള്ള മണിക്കൂർ)';

  @override
  String get utcOffsetHelp => 'ഇന്ത്യ 5.5, യുഎഇ 4, സൗദി അറേബ്യ 3';

  @override
  String get invalidLatitude => '−66 മുതൽ 66 വരെയുള്ള അക്ഷാംശം നൽകുക';

  @override
  String get invalidLongitude => '−180 മുതൽ 180 വരെയുള്ള രേഖാംശം നൽകുക';

  @override
  String get invalidUtcOffset => '−12 മുതൽ 14 വരെ, കാൽ മണിക്കൂർ കണക്കിൽ നൽകുക';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get save => 'സേവ് ചെയ്യുക';

  @override
  String get settingsYearStart => 'വർഷാരംഭം';

  @override
  String get settingsYearStartHelp =>
      'കന്നി വടക്കേ മലബാറിലെ രീതിയാണ്; വർഷസംഖ്യ മാത്രമേ മാറൂ';

  @override
  String get settingsCalendarMode => 'കലണ്ടർ തുറക്കുമ്പോൾ';

  @override
  String get calendarModeMalayalam => 'മലയാള മാസങ്ങൾ';

  @override
  String get calendarModeGregorian => 'ഇംഗ്ലീഷ് മാസങ്ങൾ';

  @override
  String onboardingStep(int step, int total) {
    return '$total-ൽ $step-ാം ഘട്ടം';
  }

  @override
  String get onboardingWelcomeTitle => 'സ്വാഗതം';

  @override
  String get onboardingWelcomeBody =>
      'മലയാളം തീയതികൾ, നക്ഷത്രങ്ങൾ, വിശേഷങ്ങൾ, കുടുംബാംഗങ്ങളുടെ പിറന്നാൾ എന്നിവ ഈ ഫോണിൽത്തന്നെ. ആപ്പിന്റെ ഭാഷ തിരഞ്ഞെടുക്കുക.';

  @override
  String get onboardingLocationTitle => 'നിങ്ങളുടെ സ്ഥലം';

  @override
  String get onboardingLocationBody =>
      'ദിവസത്തിന്റെ നക്ഷത്രവും മലയാളമാസം തുടങ്ങുന്ന ദിവസവും സൂര്യോദയം അനുസരിച്ചാണ്, അതിനാൽ ഏറ്റവും അടുത്തുള്ള നഗരം തിരഞ്ഞെടുക്കുക. കേരളത്തിനു പുറത്താണെങ്കിൽ അക്ഷാംശവും രേഖാംശവും സമയമേഖലയും നൽകുക. ഇത് പിന്നീട് ക്രമീകരണങ്ങളിൽ മാറ്റാം.';

  @override
  String get change => 'മാറ്റുക';

  @override
  String get onboardingNotificationsTitle => 'ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String get onboardingNotificationsBody =>
      'ഇവ മറക്കാതിരിക്കാൻ ആപ്പിന് അറിയിപ്പുകൾ അയയ്ക്കാം:';

  @override
  String get onboardingNotifyPirannal =>
      'നിങ്ങൾ ചേർക്കുന്നവരുടെ പിറന്നാളും മാസന്തോറുമുള്ള നക്ഷത്രവും';

  @override
  String get onboardingNotifyShraddham => 'ശ്രാദ്ധം, ജന്മദിനം, വാർഷികങ്ങൾ';

  @override
  String get onboardingNotifyMonthStart =>
      'ഓരോ മലയാളമാസത്തിന്റെയും വർഷത്തിന്റെയും തുടക്കം';

  @override
  String get onboardingNotificationsPrivacy =>
      'ആദ്യത്തെ ഓർമ്മപ്പെടുത്തൽ ചേർക്കുമ്പോൾ ആൻഡ്രോയിഡ് അനുമതി ചോദിക്കും. നിങ്ങളുടെ വിവരങ്ങൾ ഈ ഫോണിൽ മാത്രം; ആപ്പിന് അക്കൗണ്ടില്ല, ഒന്നും സെർവറിലേക്ക് അയയ്ക്കുന്നില്ല.';

  @override
  String get back => 'പിന്നോട്ട്';

  @override
  String get next => 'അടുത്തത്';

  @override
  String get getStarted => 'തുടങ്ങാം';

  @override
  String get panchangam => 'പഞ്ചാംഗം';

  @override
  String get nakshatra => 'നക്ഷത്രം';

  @override
  String get tithi => 'തിഥി';

  @override
  String get paksha => 'പക്ഷം';

  @override
  String get yoga => 'യോഗം';

  @override
  String get karana => 'കരണം';

  @override
  String get sunrise => 'സൂര്യോദയം';

  @override
  String get sunset => 'സൂര്യാസ്തമയം';

  @override
  String get moonrise => 'ചന്ദ്രോദയം';

  @override
  String get moonset => 'ചന്ദ്രാസ്തമയം';

  @override
  String get noTime => 'ഇല്ല';

  @override
  String untilTime(String name, String time) {
    return '$name $time വരെ';
  }

  @override
  String timeNextDay(String time) {
    return '$time (പിറ്റേന്ന്)';
  }

  @override
  String timeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String get nextFestival => 'അടുത്ത വിശേഷം';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസം കഴിഞ്ഞ്',
      one: 'നാളെ',
      zero: 'ഇന്ന്',
    );
    return '$_temp0';
  }

  @override
  String get dayDetails => 'ദിവസ വിവരങ്ങൾ';

  @override
  String get previousDay => 'മുൻ ദിവസം';

  @override
  String get nextDay => 'അടുത്ത ദിവസം';

  @override
  String get monthStartClose =>
      'സംക്രമം അതിർത്തി സമയത്തോട് വളരെ അടുത്തായതിനാൽ ചില പഞ്ചാംഗങ്ങളിൽ മാസാരംഭം മറ്റൊരു ദിവസമാകാം.';

  @override
  String get timesForLocation =>
      'സമയങ്ങൾ ക്രമീകരണങ്ങളിൽ തിരഞ്ഞെടുത്ത സ്ഥലത്തേതാണ്.';

  @override
  String get peopleEmpty =>
      'ഇതുവരെ ആരെയും ചേർത്തിട്ടില്ല. പിറന്നാൾ, ജന്മദിനം, ശ്രാദ്ധം എന്നിവ ഓർക്കാൻ ഒരാളെ ചേർക്കുക.';

  @override
  String get addPerson => 'ആളെ ചേർക്കുക';

  @override
  String get newPerson => 'പുതിയ ആൾ';

  @override
  String get editPerson => 'വിവരങ്ങൾ മാറ്റുക';

  @override
  String get personName => 'പേര്';

  @override
  String get nameRequired => 'പേര് നൽകുക';

  @override
  String get relation => 'ബന്ധം';

  @override
  String get relationSelf => 'ഞാൻ';

  @override
  String get relationFamily => 'കുടുംബം';

  @override
  String get relationFriend => 'സുഹൃത്ത്';

  @override
  String get relationOther => 'മറ്റുള്ളവർ';

  @override
  String get colour => 'നിറം';

  @override
  String colourOption(int number) {
    return 'നിറം $number';
  }

  @override
  String get notes => 'കുറിപ്പുകൾ';

  @override
  String get delete => 'നീക്കം ചെയ്യുക';

  @override
  String deletePersonTitle(String name) {
    return '$name നീക്കം ചെയ്യണോ?';
  }

  @override
  String get deletePersonBody =>
      'അവരുടെ ദിവസങ്ങളും ഓർമ്മപ്പെടുത്തലുകളും കൂടി നീക്കം ചെയ്യും.';

  @override
  String get events => 'ദിവസങ്ങൾ';

  @override
  String get noEvents => 'ദിവസങ്ങൾ ഒന്നും ചേർത്തിട്ടില്ല.';

  @override
  String get personNotFound => 'ഈ ആൾ ഇപ്പോൾ പട്ടികയിൽ ഇല്ല.';

  @override
  String get eventPirannal => 'പിറന്നാൾ';

  @override
  String get eventNakshatram => 'നക്ഷത്രം';

  @override
  String get eventBirthday => 'ജന്മദിനം';

  @override
  String get eventShraddham => 'ശ്രാദ്ധം';

  @override
  String get eventAnniversary => 'വാർഷികം';

  @override
  String get eventCustom => 'ദിവസം';

  @override
  String get newEvent => 'പുതിയ ദിവസം';

  @override
  String get editEvent => 'ദിവസം മാറ്റുക';

  @override
  String get addEvent => 'ദിവസം ചേർക്കുക';

  @override
  String get eventType => 'തരം';

  @override
  String get person => 'ആൾ';

  @override
  String get noPerson => 'ആരുമില്ല';

  @override
  String get malayalamMonth => 'മലയാള മാസം';

  @override
  String get duplicateRuleHeading => 'മാസത്തിൽ രണ്ടു ദിവസം വന്നാൽ';

  @override
  String get duplicateSecond => 'രണ്ടാമത്തെ ദിവസം';

  @override
  String get duplicateFirst => 'ആദ്യത്തെ ദിവസം';

  @override
  String get duplicateSecondHelp =>
      'ജന്മനക്ഷത്രത്തിന് കേരളത്തിലെ പതിവുപോലെ പിന്നത്തെ ദിവസം എടുക്കുന്നു.';

  @override
  String get duplicateFirstHelp =>
      'നക്ഷത്രപ്രകാരമുള്ള ശ്രാദ്ധത്തിന് പതിവുപോലെ ആദ്യത്തെ ദിവസം എടുക്കുന്നു.';

  @override
  String get shraddhamByTithi => 'തിഥിപ്രകാരം';

  @override
  String get shraddhamByStar => 'നക്ഷത്രപ്രകാരം';

  @override
  String get date => 'തീയതി';

  @override
  String get chooseDate => 'തീയതി തിരഞ്ഞെടുക്കുക';

  @override
  String get year => 'വർഷം (ഐച്ഛികം)';

  @override
  String get invalidYear => '1800-നും 2200-നും ഇടയിലുള്ള വർഷം നൽകുക';

  @override
  String get eventTitle => 'പേര്';

  @override
  String get titleRequired => 'പേര് നൽകുക';

  @override
  String get repeats => 'ആവർത്തനം';

  @override
  String get kindMalayalamYearly => 'മലയാള തീയതി, എല്ലാ വർഷവും';

  @override
  String get kindMalayalamMonthly => 'മലയാള തീയതി, എല്ലാ മാസവും';

  @override
  String get kindGregorianYearly => 'ഇംഗ്ലീഷ് തീയതി, എല്ലാ വർഷവും';

  @override
  String get kindTithi => 'തിഥി, എല്ലാ പക്ഷത്തിലും';

  @override
  String get day => 'ദിവസം';

  @override
  String get bothPakshas => 'രണ്ടും';

  @override
  String get nextDates => 'അടുത്ത തീയതികൾ';

  @override
  String get findMyStar => 'എന്റെ നക്ഷത്രം കണ്ടെത്തുക';

  @override
  String get findStarIntro =>
      'ജനന തീയതിയും സമയവും നൽകുക. സ്ഥലം ക്രമീകരണങ്ങളിൽ തിരഞ്ഞെടുത്തതാണ്.';

  @override
  String get birthDate => 'ജനന തീയതി';

  @override
  String get birthTime => 'ജനന സമയം';

  @override
  String starResult(String star, int pada) {
    return '$star, $pada-ാം പാദം';
  }

  @override
  String rashiResult(String rashi) {
    return '$rashi രാശി';
  }

  @override
  String get useThisStar => 'ഈ നക്ഷത്രം ഉപയോഗിക്കുക';

  @override
  String get deleteEventTitle => 'ഈ ദിവസം നീക്കം ചെയ്യണോ?';

  @override
  String get deleteEventBody => 'അതിന്റെ ഓർമ്മപ്പെടുത്തലുകളും നീക്കം ചെയ്യും.';

  @override
  String get upcoming => 'വരാനിരിക്കുന്നവ';

  @override
  String get noUpcoming => 'അടുത്ത 30 ദിവസത്തിൽ ഒന്നുമില്ല.';

  @override
  String personEvent(String name, String event) {
    return '$name – $event';
  }

  @override
  String get pirannalAndEvents => 'പിറന്നാളും മറ്റു ദിവസങ്ങളും';

  @override
  String notifyPirannal(String name, String star) {
    return '$name – പിറന്നാൾ ($star)';
  }

  @override
  String notifyNakshatram(String name, String star) {
    return '$name – നക്ഷത്രം ($star)';
  }

  @override
  String notifyBirthday(String name) {
    return '$name – ജന്മദിനം';
  }

  @override
  String notifyShraddham(String name) {
    return '$name – ശ്രാദ്ധം';
  }

  @override
  String notifyAnniversary(String name) {
    return '$name – വാർഷികം';
  }

  @override
  String notifyWhen(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസം കഴിഞ്ഞ്',
      one: 'നാളെ',
      zero: 'ഇന്ന്',
    );
    return '$_temp0, $date';
  }

  @override
  String notifyAge(int age) {
    return '$age വയസ്സ്';
  }

  @override
  String notifyYears(int age) {
    return '$age വർഷം';
  }

  @override
  String notifyMonthStart(String month) {
    return 'നാളെ $month 1';
  }

  @override
  String notifyYearStart(String month, String year) {
    return 'നാളെ $month 1: പുതുവർഷം $year';
  }

  @override
  String notifyMonthStartBody(String time) {
    return 'സംക്രമം $time-ന്';
  }

  @override
  String notifyFestival(String name) {
    return 'നാളെ $name';
  }

  @override
  String notifyDailyBody(String star, String tithi) {
    return 'നക്ഷത്രം $star · തിഥി $tithi';
  }

  @override
  String get channelEvents => 'പിറന്നാളും വ്യക്തിപരമായ ഓർമ്മപ്പെടുത്തലുകളും';

  @override
  String get channelCalendar => 'മാസാരംഭവും വിശേഷങ്ങളും';

  @override
  String get channelDaily => 'ദിവസേനയുള്ള പഞ്ചാംഗം';

  @override
  String get actionOpen => 'തുറക്കുക';

  @override
  String get actionSnooze => '1 മണിക്കൂർ കഴിഞ്ഞ് ഓർമ്മിപ്പിക്കുക';

  @override
  String get settingsReminders => 'ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String get settingsRemindersHelp =>
      'പിറന്നാൾ, വിശേഷങ്ങൾ, മാസാരംഭം, ദിവസേനയുള്ള പഞ്ചാംഗം';

  @override
  String get remindersEnabled => 'അറിയിപ്പുകൾ';

  @override
  String get remindersNotifyFor => 'ഇവ ഓർമ്മിപ്പിക്കുക';

  @override
  String get remindersMonthStarts => 'എല്ലാ മാസാരംഭവും';

  @override
  String get remindersYearStart => 'മലയാള പുതുവർഷം';

  @override
  String get remindersEveningTime => 'തലേന്നത്തെ ഓർമ്മപ്പെടുത്തൽ സമയം';

  @override
  String get remindersFestivals => 'വിശേഷങ്ങൾ, തലേന്ന്';

  @override
  String get categoryHindu => 'ഹിന്ദു';

  @override
  String get categoryChristian => 'ക്രിസ്ത്യൻ';

  @override
  String get categoryMuslim => 'മുസ്ലിം';

  @override
  String get muslimTentative =>
      'ചന്ദ്രനെ കാണുന്നതുവരെ മുസ്ലിം വിശേഷ തീയതികൾ താൽക്കാലികമാണ്.';

  @override
  String get remindersDaily => 'ദിവസേനയുള്ള പഞ്ചാംഗം';

  @override
  String get remindersDailyTime => 'പഞ്ചാംഗം അറിയിക്കുന്ന സമയം';

  @override
  String get remindersPermission => 'അറിയിപ്പുകൾ അനുവദിക്കുക';

  @override
  String get remindersExact => 'കൃത്യ സമയം';

  @override
  String get remindersExactOn => 'ഓർമ്മപ്പെടുത്തലുകൾ കൃത്യസമയത്ത് വരും.';

  @override
  String get remindersExactOff =>
      'ഓർമ്മപ്പെടുത്തലുകൾ കുറച്ചു മിനിറ്റ് വൈകിയേക്കാം. കൃത്യസമയം അനുവദിക്കാൻ തൊടുക.';

  @override
  String remindersScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'അടുത്ത 60 ദിവസത്തിൽ $count ഓർമ്മപ്പെടുത്തലുകൾ',
      zero: 'അടുത്ത 60 ദിവസത്തിൽ ഓർമ്മപ്പെടുത്തലുകളില്ല',
    );
    return '$_temp0';
  }

  @override
  String get remindersWeb =>
      'ബ്രൗസറിൽ ഓർമ്മപ്പെടുത്തലുകൾ \'ഇന്ന്\' ടാബിൽ കാണാം. അറിയിപ്പുകൾ ആൻഡ്രോയിഡ് ആപ്പിലാണ്.';

  @override
  String get categoryNational => 'ദേശീയം';

  @override
  String get categoryGovernment => 'സർക്കാർ';

  @override
  String get categoryBank => 'ബാങ്ക്';

  @override
  String get holidayPublic => 'പൊതു അവധി';

  @override
  String get holidayRestricted => 'നിയന്ത്രിത അവധി';

  @override
  String get holidayBank => 'ബാങ്ക് അവധി';

  @override
  String get tentativeDate => 'തീയതി മാറിയേക്കാം';

  @override
  String get agenda => 'അജണ്ട';

  @override
  String get searchHint => 'വിശേഷങ്ങളും ദിവസങ്ങളും തിരയുക';

  @override
  String get agendaEmpty => 'അടുത്ത ഒരു വർഷത്തിൽ ഒന്നും കണ്ടെത്തിയില്ല.';

  @override
  String get yourEvents => 'നിങ്ങളുടെ ദിവസങ്ങൾ';

  @override
  String get categoriesHeading => 'കാണിക്കുക';
}
