/// Rewrites old-style chillu letters (consonant + virama + ZWJ) as the
/// atomic chillu code points, so both encodings of e.g. കർക്കടകം compare
/// equal.
String normalizeMalayalam(String input) => input
    .replaceAll('ന്\u200D', 'ൻ')
    .replaceAll('ണ്\u200D', 'ൺ')
    .replaceAll('ര്\u200D', 'ർ')
    .replaceAll('ല്\u200D', 'ൽ')
    .replaceAll('ള്\u200D', 'ൾ');

/// Script used when rendering names and numbers.
enum MalayalamScript {
  /// Malayalam script, e.g. ചിങ്ങം.
  malayalam,

  /// Latin transliteration, e.g. Chingam.
  english,
}

/// The twelve months of the Malayalam calendar, in Kollavarsham order
/// (the year begins with Chingam).
///
/// Each month starts when the Sun enters the corresponding sidereal sign
/// (rashi); Chingam corresponds to Simha (Leo).
enum MalayalamMonth {
  /// Chingam (ചിങ്ങം): the Sun in Simha.
  chingam('ചിങ്ങം', 'Chingam', 'Simha', ['Chingom', 'Chingham']),

  /// Kanni (കന്നി): the Sun in Kanya.
  kanni('കന്നി', 'Kanni', 'Kanya', ['Kanny']),

  /// Thulam (തുലാം): the Sun in Tula.
  thulam('തുലാം', 'Thulam', 'Tula', ['Tulam', 'Thulaam']),

  /// Vrischikam (വൃശ്ചികം): the Sun in Vrischika.
  vrischikam('വൃശ്ചികം', 'Vrischikam', 'Vrischika',
      ['Vrishchikam', 'Vrichikam', 'Vruschikam', 'Vrischikom']),

  /// Dhanu (ധനു): the Sun in Dhanu.
  dhanu('ധനു', 'Dhanu', 'Dhanu', ['Dhanus']),

  /// Makaram (മകരം): the Sun in Makara.
  makaram('മകരം', 'Makaram', 'Makara', ['Makarom']),

  /// Kumbham (കുംഭം): the Sun in Kumbha.
  kumbham('കുംഭം', 'Kumbham', 'Kumbha', ['Kumbam', 'Kumbhom']),

  /// Meenam (മീനം): the Sun in Meena.
  meenam('മീനം', 'Meenam', 'Meena', ['Minam', 'Meenom']),

  /// Medam (മേടം): the Sun in Mesha.
  medam('മേടം', 'Medam', 'Mesha', ['Metam', 'Medom']),

  /// Edavam (ഇടവം): the Sun in Vrishabha.
  edavam('ഇടവം', 'Edavam', 'Vrishabha', ['Idavam', 'Edavom']),

  /// Mithunam (മിഥുനം): the Sun in Mithuna.
  mithunam('മിഥുനം', 'Mithunam', 'Mithuna', ['Midhunam', 'Mithunom']),

  /// Karkidakam (കർക്കടകം): the Sun in Karka.
  karkidakam('കർക്കടകം', 'Karkidakam', 'Karka', [
    'കർക്കിടകം',
    'Karkkidakam',
    'Karkadakam',
    'Karkkadakam',
    'Karkatakam',
  ]);

  const MalayalamMonth(
      this.malayalam, this.english, this.sanskrit, this._variants);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in Latin transliteration.
  final String english;

  /// Sanskrit name of the corresponding rashi (zodiac sign).
  final String sanskrit;

  /// Other common spellings, accepted when parsing.
  final List<String> _variants;

  /// Abbreviated name: the first three letters of the transliteration
  /// (Chi, Kan, …). Malayalam script has no customary abbreviation, so the
  /// full name is used there.
  String shortName(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english.substring(0, 3);

  /// Every name accepted by [tryParseName], across all months.
  static Iterable<String> get allNames => [
        for (final m in values) ...[
          m.malayalam,
          m.english,
          m.english.substring(0, 3),
          ...m._variants,
        ],
      ];

  /// The month named [name] in Malayalam script or transliteration
  /// (ignoring case, and accepting common spelling variants such as
  /// Karkkidakam or കർക്കിടകം), or `null` if not recognised.
  static MalayalamMonth? tryParseName(String name) {
    final key = normalizeMalayalam(name.trim()).toLowerCase();
    for (final m in values) {
      if (m.malayalam == key ||
          m.english.toLowerCase() == key ||
          m.english.substring(0, 3).toLowerCase() == key ||
          m._variants.any((v) => v.toLowerCase() == key)) {
        return m;
      }
    }
    return null;
  }

  /// Month number, 1 (Chingam) to 12 (Karkidakam).
  int get number => index + 1;

  /// Index of the corresponding sidereal sign, 0 (Mesha) to 11 (Meena).
  int get signIndex => (index + 4) % 12;

  /// Returns the month for a 1-based [number] (1 = Chingam).
  static MalayalamMonth fromNumber(int number) {
    RangeError.checkValueInInterval(number, 1, 12, 'number');
    return values[number - 1];
  }

  /// Returns the month that starts when the Sun enters sign [signIndex]
  /// (0 = Mesha).
  static MalayalamMonth fromSignIndex(int signIndex) =>
      values[(signIndex - 4) % 12];

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;

  /// The following month, wrapping from Karkidakam to Chingam.
  MalayalamMonth get next => values[(index + 1) % 12];

  /// The preceding month, wrapping from Chingam to Karkidakam.
  MalayalamMonth get previous => values[(index + 11) % 12];
}

/// Days of the week, starting Sunday (ഞായർ).
enum MalayalamWeekday {
  /// Sunday: Njayar (ഞായർ).
  njayar('ഞായർ', 'Njayar', 'Sunday', 'ഞാ'),

  /// Monday: Thinkal (തിങ്കൾ).
  thinkal('തിങ്കൾ', 'Thinkal', 'Monday', 'തി'),

  /// Tuesday: Chovva (ചൊവ്വ).
  chovva('ചൊവ്വ', 'Chovva', 'Tuesday', 'ചൊ'),

  /// Wednesday: Budhan (ബുധൻ).
  budhan('ബുധൻ', 'Budhan', 'Wednesday', 'ബു'),

  /// Thursday: Vyazham (വ്യാഴം).
  vyazham('വ്യാഴം', 'Vyazham', 'Thursday', 'വ്യാ'),

  /// Friday: Velli (വെള്ളി).
  velli('വെള്ളി', 'Velli', 'Friday', 'വെ'),

  /// Saturday: Shani (ശനി).
  shani('ശനി', 'Shani', 'Saturday', 'ശ');

  const MalayalamWeekday(
      this.malayalam, this.english, this.gregorianName, this.shortMalayalam);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in Latin transliteration.
  final String english;

  /// The English weekday name, e.g. "Sunday".
  final String gregorianName;

  /// Abbreviated name in Malayalam script, e.g. ഞാ.
  final String shortMalayalam;

  /// Abbreviated name for calendar headers: ഞാ in Malayalam script,
  /// the English abbreviation (Sun) otherwise.
  String shortName(MalayalamScript script) =>
      script == MalayalamScript.malayalam
          ? shortMalayalam
          : gregorianName.substring(0, 3);

  /// Every weekday name in Malayalam script, transliteration and English,
  /// full and abbreviated; accepted when parsing.
  static Iterable<String> get allNames => [
        for (final w in values) ...[
          w.malayalam,
          w.english,
          w.gregorianName,
          w.shortMalayalam,
          w.gregorianName.substring(0, 3),
        ],
      ];

  /// Converts a [DateTime.weekday] value (1 = Monday … 7 = Sunday).
  static MalayalamWeekday fromDateTimeWeekday(int weekday) =>
      values[weekday % 7];

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}
