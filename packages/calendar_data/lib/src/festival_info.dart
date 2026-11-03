import 'package:kollavarsham/kollavarsham.dart';

/// What a festival is and how its date is found, in both languages.
///
/// The Malayalam text awaits the native-editor review (Day 24).
class FestivalInfo {
  /// Creates the description.
  const FestivalInfo(this.aboutMl, this.aboutEn, this.ruleMl, this.ruleEn);

  /// What the day is, in Malayalam.
  final String aboutMl;

  /// What the day is, in English.
  final String aboutEn;

  /// How the date is found, in Malayalam.
  final String ruleMl;

  /// How the date is found, in English.
  final String ruleEn;

  /// [aboutMl] or [aboutEn] for [script].
  String about(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? aboutMl : aboutEn;

  /// [ruleMl] or [ruleEn] for [script].
  String rule(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? ruleMl : ruleEn;
}

const _listed = FestivalInfo(
  'കേരള സർക്കാരിന്റെ അവധി പട്ടികയിലുള്ള ദിവസം.',
  'A day on the Kerala government holiday list.',
  'തീയതി സർക്കാർ ഉത്തരവിലെ പട്ടികയിൽ നിന്ന്.',
  'The date is taken from the published holiday list.',
);

/// The description of the festival with [id] (see `FestivalDay.id`).
///
/// Holiday-list entries without their own text get a general one.
FestivalInfo festivalInfo(String id) =>
    festivalInfos[id] ?? (id.startsWith('holiday.') ? _listed : _unknown);

const _unknown = FestivalInfo('', '', '', '');

/// Descriptions by festival id.
const festivalInfos = <String, FestivalInfo>{
  // Kerala festivals computed by the engine.
  'hindu.newYear': FestivalInfo(
    'കൊല്ലവർഷത്തിന്റെ ആദ്യ ദിവസം. ചിങ്ങം ഒന്ന് കർഷകദിനമായും ആചരിക്കുന്നു.',
    'The first day of the Kollavarsham year. Chingam 1 is also kept as '
        "Farmers' Day.",
    'ചിങ്ങം 1 (വടക്കേ മലബാറിൽ കന്നി 1).',
    'Chingam 1 (Kanni 1 in North Malabar reckoning).',
  ),
  'hindu.atham': FestivalInfo(
    'ഓണത്തിന്റെ പത്തു ദിവസത്തെ ആഘോഷങ്ങൾ തുടങ്ങുന്ന ദിവസം. അന്നുമുതൽ വീട്ടുമുറ്റത്ത് പൂക്കളമിടുന്നു.',
    'The first of the ten days of Onam, when homes begin laying the '
        'pookkalam, the flower carpet.',
    'തിരുവോണത്തിന് ഒമ്പതു ദിവസം മുമ്പ്.',
    'Nine days before Thiruvonam.',
  ),
  'hindu.onam': FestivalInfo(
    'കേരളത്തിന്റെ ദേശീയോത്സവം. മഹാബലിയെ വരവേൽക്കുന്ന ദിവസം; ഓണസദ്യയും പൂക്കളവുമായി എല്ലാവരും ആഘോഷിക്കുന്നു.',
    "Kerala's harvest festival, welcoming King Mahabali, with the Onam "
        'sadya and pookkalam, celebrated by all communities.',
    'ചിങ്ങമാസത്തിൽ സൂര്യോദയത്തിൽ തിരുവോണം നക്ഷത്രമുള്ള ദിവസം. നക്ഷത്രം രണ്ടു തവണ വന്നാൽ രണ്ടാമത്തേത്.',
    'The day in Chingam with the Thiruvonam star at sunrise; the second '
        'if the star comes twice in the month.',
  ),
  'hindu.mandalaKalamStart': FestivalInfo(
    'ശബരിമല തീർത്ഥാടനത്തിന്റെ 41 ദിവസത്തെ മണ്ഡലകാലം തുടങ്ങുന്നു. ഭക്തർ വ്രതം ആരംഭിക്കുന്നു.',
    'The 41-day Mandala season of the Sabarimala pilgrimage begins; '
        'devotees start their vratham.',
    'വൃശ്ചികം 1.',
    'Vrischikam 1.',
  ),
  'hindu.mandalaPooja': FestivalInfo(
    'മണ്ഡലകാലത്തിന്റെ സമാപനം കുറിക്കുന്ന ശബരിമലയിലെ പൂജ.',
    'The pooja at Sabarimala that closes the Mandala season.',
    'മണ്ഡലകാലത്തിന്റെ 41-ാം ദിവസം.',
    'The 41st day of the Mandala season.',
  ),
  'hindu.makaravilakku': FestivalInfo(
    'ശബരിമലയിലെ മകരവിളക്ക് ദർശനവും മകരസംക്രമവും.',
    'The Makaravilakku at Sabarimala, at the start of Makaram.',
    'മകരം 1.',
    'Makaram 1.',
  ),
  'hindu.attukalPongala': FestivalInfo(
    'തിരുവനന്തപുരം ആറ്റുകാൽ ഭഗവതിക്ക് ലക്ഷക്കണക്കിന് സ്ത്രീകൾ പൊങ്കാല അർപ്പിക്കുന്ന ദിവസം.',
    'Women by the hundred thousand offer pongala to the goddess of '
        'Attukal temple in Thiruvananthapuram.',
    'കുംഭമാസത്തിൽ സൂര്യാസ്തമയത്തിൽ പൂരം നക്ഷത്രമുള്ള ദിവസം.',
    'The day in Kumbham with the Pooram star at sunset.',
  ),
  'hindu.vishu': FestivalInfo(
    'ജ്യോതിശാസ്ത്രപരമായ പുതുവർഷം. വിഷുക്കണി കണ്ടുണരുന്നു; മുതിർന്നവർ വിഷുക്കൈനീട്ടം നൽകുന്നു.',
    'The astronomical new year: the day begins with the Vishukkani and '
        'elders give vishukkaineettam.',
    'മേടം 1 (സൂര്യൻ മേടം രാശിയിൽ കടക്കുന്ന സംക്രമം).',
    "Medam 1, after the Sun's entry into Mesha.",
  ),
  'hindu.thrissurPooram': FestivalInfo(
    'തൃശ്ശൂർ വടക്കുന്നാഥ ക്ഷേത്രമുറ്റത്ത് ആനകളും മേളവും കുടമാറ്റവുമായി നടക്കുന്ന പൂരം.',
    'The festival of elephants, percussion and kudamattam at the '
        'Vadakkunnathan temple grounds in Thrissur.',
    'മേടമാസത്തിൽ അർദ്ധരാത്രി പൂരം നക്ഷത്രമുള്ള ദിവസം.',
    'The day in Medam whose midnight falls in the Pooram star.',
  ),
  'hindu.karkidakamStart': FestivalInfo(
    'രാമായണ മാസം തുടങ്ങുന്നു. വീടുകളിലും ക്ഷേത്രങ്ങളിലും രാമായണം വായിക്കുന്നു.',
    'The Ramayana month begins; the Ramayana is read in homes and '
        'temples.',
    'കർക്കടകം 1.',
    'Karkidakam 1.',
  ),
  'hindu.karkidakaVavu': FestivalInfo(
    'പിതൃക്കൾക്ക് ബലിയിടുന്ന ദിവസം. ആലുവ, വർക്കല, തിരുനെല്ലി തുടങ്ങിയ സ്ഥലങ്ങളിൽ ബലിതർപ്പണം നടക്കുന്നു.',
    'The day of bali for the ancestors, offered at Aluva, Varkala, '
        'Thirunelli and other shores and temples.',
    'കർക്കടകത്തിലെ അമാവാസി, ഉച്ചതിരിഞ്ഞ് (അപരാഹ്നം) അമാവാസിയുള്ള ദിവസം.',
    'The new moon of Karkidakam, on the day it holds the afternoon '
        '(aparahna).',
  ),
  'hindu.ashtamiRohini': FestivalInfo(
    'ശ്രീകൃഷ്ണന്റെ ജന്മദിനം. ശോഭായാത്രകളും ഉറിയടിയും ഉണ്ടാകും.',
    "Sree Krishna's birthday, with Shobha Yatras and uriyadi.",
    'ചിങ്ങമാസത്തിൽ കറുത്ത പക്ഷ അഷ്ടമി അർദ്ധരാത്രിയിലുള്ള ദിവസം; രോഹിണി നക്ഷത്രമുള്ള രാത്രിക്ക് മുൻഗണന.',
    'The night of the waning Ashtami in Chingam, preferring the night '
        'with the Rohini star at midnight.',
  ),
  'hindu.vinayakaChathurthi': FestivalInfo(
    'ഗണപതിയുടെ ജന്മദിനം. ക്ഷേത്രങ്ങളിൽ അഷ്ടദ്രവ്യ ഗണപതിഹോമം നടക്കുന്നു.',
    "Lord Ganesha's birthday, with Ganapathi homam in temples.",
    'കന്നി സംക്രമം വരുന്ന ചാന്ദ്രമാസത്തിലെ വെളുത്ത പക്ഷ ചതുർത്ഥി, മദ്ധ്യാഹ്നത്തിൽ.',
    "The waxing Chathurthi at midday, in the lunar month that holds "
        "Kanni's sankranti.",
  ),
  'hindu.durgashtami': FestivalInfo(
    'നവരാത്രിയിലെ എട്ടാം ദിവസം. വൈകുന്നേരം പുസ്തകങ്ങളും പണിയായുധങ്ങളും പൂജയ്ക്ക് വയ്ക്കുന്നു.',
    'The eighth day of Navaratri, when books and tools are placed for '
        'pooja in the evening.',
    'വിജയദശമിക്ക് രണ്ടു ദിവസം മുമ്പ്.',
    'Two days before Vijayadasami.',
  ),
  'hindu.mahanavami': FestivalInfo(
    'നവരാത്രിയിലെ ഒമ്പതാം ദിവസം; ആയുധപൂജ.',
    'The ninth day of Navaratri: Ayudha Pooja.',
    'വിജയദശമിയുടെ തലേന്ന്.',
    'The day before Vijayadasami.',
  ),
  'hindu.vijayadasami': FestivalInfo(
    'പൂജയെടുപ്പും വിദ്യാരംഭവും. കുട്ടികൾ ആദ്യാക്ഷരം കുറിക്കുന്നു.',
    'Pooja ends and children are initiated into letters (Vidyarambham).',
    'തുലാം സംക്രമം വരുന്ന ചാന്ദ്രമാസത്തിലെ വെളുത്ത പക്ഷ ദശമി, സൂര്യോദയത്തിൽ.',
    "The waxing Dashami at sunrise, in the lunar month that holds "
        "Thulam's sankranti.",
  ),
  'hindu.deepavali': FestivalInfo(
    'ദീപങ്ങളുടെ ഉത്സവം. കേരളത്തിൽ നരകചതുർദശി ദിവസം ആഘോഷിക്കുന്നു.',
    'The festival of lights, kept in Kerala on Naraka Chathurdashi.',
    'തുലാം സംക്രമം വരുന്ന ചാന്ദ്രമാസത്തിൽ കറുത്ത പക്ഷ ചതുർദശി അരുണോദയത്തിൽ ഉള്ള ദിവസം.',
    'The waning Chathurdashi at dawn (arunodaya), in the lunar month '
        "that holds Thulam's sankranti.",
  ),
  'hindu.guruvayurEkadashi': FestivalInfo(
    'ഗുരുവായൂർ ക്ഷേത്രത്തിലെ പ്രധാന ഏകാദശി; ഭക്തർ ഉപവസിക്കുന്നു.',
    'The great Ekadashi of the Guruvayur temple, a day of fasting.',
    'വൃശ്ചികത്തിലെ വെളുത്ത പക്ഷ ഏകാദശി.',
    'The waxing Ekadashi of Vrischikam.',
  ),
  'hindu.thaipooyam': FestivalInfo(
    'സുബ്രഹ്മണ്യ ക്ഷേത്രങ്ങളിലെ കാവടിയാട്ടം.',
    'Kavadi processions at Subrahmanya temples.',
    'മകര സംക്രമത്തിനു ശേഷമുള്ള പൗർണ്ണമിയോട് അടുത്ത്, പൂയം നക്ഷത്രമുള്ള ദിവസം.',
    "The day with the Pooyam star nearest the first full moon after "
        "Makaram's sankranti.",
  ),
  'hindu.sivaratri': FestivalInfo(
    'ശിവഭക്തർ ഉറക്കമൊഴിഞ്ഞ് ഉപവസിക്കുന്ന രാത്രി. ആലുവ മണപ്പുറത്ത് ബലിതർപ്പണം.',
    'A night of fasting and vigil for Shiva; bali is offered at the '
        'Aluva Manappuram.',
    'കുംഭ സംക്രമം വരുന്ന ചാന്ദ്രമാസത്തിൽ കറുത്ത പക്ഷ ചതുർദശി അർദ്ധരാത്രിയിലുള്ള ആദ്യ രാത്രി.',
    'The first night of the waning Chathurdashi at midnight, in the lunar '
        "month that holds Kumbham's sankranti.",
  ),
  // Christian feasts.
  'christian.newYear': FestivalInfo(
    'ഗ്രിഗോറിയൻ കലണ്ടറിലെ പുതുവർഷം.',
    'The Gregorian new year.',
    'ജനുവരി 1.',
    '1 January.',
  ),
  'christian.palmSunday': FestivalInfo(
    'യേശുവിന്റെ ജറുസലേം പ്രവേശനത്തിന്റെ ഓർമ്മ; ഓശാന ഞായർ.',
    "Jesus's entry into Jerusalem, remembered with palms.",
    'ഈസ്റ്ററിന് ഒരാഴ്ച മുമ്പുള്ള ഞായർ.',
    'The Sunday a week before Easter.',
  ),
  'christian.maundyThursday': FestivalInfo(
    'അന്ത്യത്താഴത്തിന്റെ ഓർമ്മ; കേരളത്തിൽ പെസഹ അപ്പം മുറിക്കുന്നു.',
    'The Last Supper, kept in Kerala with Pesaha appam.',
    'ഈസ്റ്ററിന് മൂന്നു ദിവസം മുമ്പ്.',
    'Three days before Easter.',
  ),
  'christian.goodFriday': FestivalInfo(
    'യേശുവിന്റെ കുരിശുമരണത്തിന്റെ ഓർമ്മ.',
    'The crucifixion of Jesus.',
    'ഈസ്റ്ററിന് രണ്ടു ദിവസം മുമ്പ്.',
    'Two days before Easter.',
  ),
  'christian.easter': FestivalInfo(
    'യേശുവിന്റെ ഉയിർപ്പ്.',
    'The resurrection of Jesus.',
    'വസന്ത വിഷുവത്തിനു ശേഷമുള്ള ആദ്യ പൗർണ്ണമി കഴിഞ്ഞുള്ള ഞായർ (ഗ്രിഗോറിയൻ ഗണന).',
    'The Sunday after the first full moon after the spring equinox '
        '(Gregorian computus).',
  ),
  'christian.christmas': FestivalInfo(
    'യേശുവിന്റെ ജനനത്തിരുനാൾ.',
    'The birth of Jesus.',
    'ഡിസംബർ 25.',
    '25 December.',
  ),
  // Muslim festivals.
  'muslim.muharram': FestivalInfo(
    'ഹിജ്റ വർഷാരംഭത്തിലെ മുഹറം 10 (ആശൂറ).',
    'The 10th of Muharram (Ashura), early in the Hijri year.',
    'ഹിജ്റ കലണ്ടറിലെ മുഹറം 10. ചന്ദ്രനെ കാണുന്നതനുസരിച്ച് തീയതി മാറാം.',
    '10 Muharram of the Hijri calendar; the date follows the moon '
        'sighting and may move.',
  ),
  'muslim.miladISherif': FestivalInfo(
    'നബിദിനം: പ്രവാചകന്റെ ജന്മദിനം.',
    "Nabidinam, the Prophet's birthday.",
    'റബീഉൽ അവ്വൽ 12. ചന്ദ്രനെ കാണുന്നതനുസരിച്ച് തീയതി മാറാം.',
    '12 Rabi al-Awwal; the date follows the moon sighting and may move.',
  ),
  'muslim.ramadanStart': FestivalInfo(
    'റമദാൻ നോമ്പിന്റെ ആദ്യ ദിവസം.',
    'The first day of the Ramadan fast.',
    'റമദാൻ 1. ചന്ദ്രനെ കാണുന്നതനുസരിച്ച് തീയതി മാറാം.',
    '1 Ramadan; the date follows the moon sighting and may move.',
  ),
  'muslim.eidUlFitr': FestivalInfo(
    'ചെറിയ പെരുന്നാൾ: റമദാൻ നോമ്പിന്റെ സമാപനം.',
    'Cheriya Perunnal, the end of the Ramadan fast.',
    'ശവ്വാൽ 1. ചന്ദ്രനെ കാണുന്നതനുസരിച്ച് തീയതി മാറാം.',
    '1 Shawwal; the date follows the moon sighting and may move.',
  ),
  'muslim.bakrid': FestivalInfo(
    'ബലിപെരുന്നാൾ: ഇബ്രാഹിം നബിയുടെ ത്യാഗത്തിന്റെ ഓർമ്മ.',
    "Valiya Perunnal, remembering Ibrahim's sacrifice.",
    'ദുൽഹിജ്ജ 10. ചന്ദ്രനെ കാണുന്നതനുസരിച്ച് തീയതി മാറാം.',
    '10 Dhu al-Hijjah; the date follows the moon sighting and may move.',
  ),
  // Holiday-list entries.
  'holiday.republicday': FestivalInfo(
    'ഇന്ത്യൻ ഭരണഘടന നിലവിൽ വന്ന ദിവസം (1950).',
    'The day the Constitution of India came into force (1950).',
    'ജനുവരി 26.',
    '26 January.',
  ),
  'holiday.independenceday': FestivalInfo(
    'ഇന്ത്യയുടെ സ്വാതന്ത്ര്യ ദിനം (1947).',
    "India's Independence Day (1947).",
    'ഓഗസ്റ്റ് 15.',
    '15 August.',
  ),
  'holiday.gandhijayanthi': FestivalInfo(
    'മഹാത്മാ ഗാന്ധിയുടെ ജന്മദിനം.',
    "Mahatma Gandhi's birthday.",
    'ഒക്ടോബർ 2.',
    '2 October.',
  ),
  'holiday.mayday': FestivalInfo(
    'തൊഴിലാളി ദിനം.',
    "International Workers' Day.",
    'മേയ് 1.',
    '1 May.',
  ),
  'holiday.drbrambedkarjayanthi': FestivalInfo(
    'ഭരണഘടനാ ശില്പി ഡോ. ബി.ആർ. അംബേദ്കറുടെ ജന്മദിനം.',
    'The birthday of Dr B. R. Ambedkar, architect of the Constitution.',
    'ഏപ്രിൽ 14.',
    '14 April.',
  ),
  'holiday.mannamjayanthi': FestivalInfo(
    'സാമൂഹിക പരിഷ്കർത്താവ് മന്നത്ത് പത്മനാഭന്റെ ജന്മദിനം.',
    'The birthday of the social reformer Mannathu Padmanabhan.',
    'ജനുവരി 2.',
    '2 January.',
  ),
  'holiday.firstonam': FestivalInfo(
    'ഉത്രാടം: തിരുവോണത്തിന്റെ തലേന്ന്, ഒന്നാം ഓണം.',
    'Uthradam, the eve of Thiruvonam.',
    'സർക്കാർ അവധി പട്ടികയിൽ നിന്ന് (തിരുവോണത്തിന്റെ തലേന്ന്).',
    'From the holiday list: the day before Thiruvonam.',
  ),
  'holiday.thirdonam': FestivalInfo(
    'അവിട്ടം: തിരുവോണത്തിന്റെ പിറ്റേന്ന്.',
    'Avittam, the day after Thiruvonam.',
    'സർക്കാർ അവധി പട്ടികയിൽ നിന്ന് (തിരുവോണത്തിന്റെ പിറ്റേന്ന്).',
    'From the holiday list: the day after Thiruvonam.',
  ),
  'holiday.fourthonam': FestivalInfo(
    'ചതയം: ഓണാഘോഷത്തിന്റെ നാലാം ദിവസം.',
    'Chathayam, the fourth day of Onam.',
    'സർക്കാർ അവധി പട്ടികയിൽ നിന്ന്.',
    'From the holiday list.',
  ),
  'holiday.sreenarayanagurujayanthi': FestivalInfo(
    'ശ്രീനാരായണ ഗുരുവിന്റെ ജന്മദിനം (ചിങ്ങത്തിലെ ചതയം).',
    "Sree Narayana Guru's birthday, on Chathayam in Chingam.",
    'സർക്കാർ അവധി പട്ടികയിൽ നിന്ന്.',
    'From the holiday list.',
  ),
  'holiday.sreenarayanagurusamadhi': FestivalInfo(
    'ശ്രീനാരായണ ഗുരുവിന്റെ മഹാസമാധി ദിനം.',
    'The day of Sree Narayana Guru\'s mahasamadhi.',
    'സർക്കാർ അവധി പട്ടികയിൽ നിന്ന്.',
    'From the holiday list.',
  ),
  'holiday.ayyankalijayanthi': FestivalInfo(
    'നവോത്ഥാന നായകൻ അയ്യങ്കാളിയുടെ ജന്മദിനം.',
    'The birthday of the reformer Ayyankali.',
    'സർക്കാർ അവധി പട്ടികയിൽ നിന്ന്.',
    'From the holiday list.',
  ),
  'holiday.annualclosingofaccountsbanks': FestivalInfo(
    'സാമ്പത്തിക വർഷാവസാന കണക്കെടുപ്പിനായി ബാങ്കുകൾക്ക് അവധി.',
    'Banks close for the year-end closing of accounts.',
    'ഏപ്രിൽ 1.',
    '1 April.',
  ),
};
