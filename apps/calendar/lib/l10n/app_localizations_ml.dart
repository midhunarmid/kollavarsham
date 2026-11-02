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
  String get peopleComingSoon =>
      'ആളുകളെയും അവരുടെ പിറന്നാൾ, ജന്മദിനം, ശ്രാദ്ധം എന്നിവയും ഇവിടെ ചേർക്കാം. അടുത്ത അപ്ഡേറ്റിൽ വരും.';

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
}
