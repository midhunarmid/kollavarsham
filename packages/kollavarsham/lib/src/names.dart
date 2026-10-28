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
  chingam('ചിങ്ങം', 'Chingam', 'Simha'),
  kanni('കന്നി', 'Kanni', 'Kanya'),
  thulam('തുലാം', 'Thulam', 'Tula'),
  vrischikam('വൃശ്ചികം', 'Vrischikam', 'Vrischika'),
  dhanu('ധനു', 'Dhanu', 'Dhanu'),
  makaram('മകരം', 'Makaram', 'Makara'),
  kumbham('കുംഭം', 'Kumbham', 'Kumbha'),
  meenam('മീനം', 'Meenam', 'Meena'),
  medam('മേടം', 'Medam', 'Mesha'),
  edavam('ഇടവം', 'Edavam', 'Vrishabha'),
  mithunam('മിഥുനം', 'Mithunam', 'Mithuna'),
  karkidakam('കർക്കടകം', 'Karkidakam', 'Karka');

  const MalayalamMonth(this.malayalam, this.english, this.sanskrit);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in Latin transliteration.
  final String english;

  /// Sanskrit name of the corresponding rashi (zodiac sign).
  final String sanskrit;

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
  njayar('ഞായർ', 'Njayar', 'Sunday', 'ഞാ'),
  thinkal('തിങ്കൾ', 'Thinkal', 'Monday', 'തി'),
  chovva('ചൊവ്വ', 'Chovva', 'Tuesday', 'ചൊ'),
  budhan('ബുധൻ', 'Budhan', 'Wednesday', 'ബു'),
  vyazham('വ്യാഴം', 'Vyazham', 'Thursday', 'വ്യാ'),
  velli('വെള്ളി', 'Velli', 'Friday', 'വെ'),
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

  /// Converts a [DateTime.weekday] value (1 = Monday … 7 = Sunday).
  static MalayalamWeekday fromDateTimeWeekday(int weekday) =>
      values[weekday % 7];

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}
