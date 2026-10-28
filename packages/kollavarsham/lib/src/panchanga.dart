import 'names.dart';

/// The 27 nakshatras (lunar mansions), each spanning 13°20′ of the
/// sidereal zodiac, starting with Ashwathi (Ashwini) at 0° Mesha.
enum Nakshatra {
  /// Ashwathi (അശ്വതി); Sanskrit Ashwini.
  ashwathi('അശ്വതി', 'Ashwathi', 'Ashwini'),

  /// Bharani (ഭരണി); Sanskrit Bharani.
  bharani('ഭരണി', 'Bharani', 'Bharani'),

  /// Karthika (കാർത്തിക); Sanskrit Krittika.
  karthika('കാർത്തിക', 'Karthika', 'Krittika'),

  /// Rohini (രോഹിണി); Sanskrit Rohini.
  rohini('രോഹിണി', 'Rohini', 'Rohini'),

  /// Makayiram (മകയിരം); Sanskrit Mrigashira.
  makayiram('മകയിരം', 'Makayiram', 'Mrigashira'),

  /// Thiruvathira (തിരുവാതിര); Sanskrit Ardra.
  thiruvathira('തിരുവാതിര', 'Thiruvathira', 'Ardra'),

  /// Punartham (പുണർതം); Sanskrit Punarvasu.
  punartham('പുണർതം', 'Punartham', 'Punarvasu'),

  /// Pooyam (പൂയം); Sanskrit Pushya.
  pooyam('പൂയം', 'Pooyam', 'Pushya'),

  /// Ayilyam (ആയില്യം); Sanskrit Ashlesha.
  ayilyam('ആയില്യം', 'Ayilyam', 'Ashlesha'),

  /// Makam (മകം); Sanskrit Magha.
  makam('മകം', 'Makam', 'Magha'),

  /// Pooram (പൂരം); Sanskrit Purva Phalguni.
  pooram('പൂരം', 'Pooram', 'Purva Phalguni'),

  /// Uthram (ഉത്രം); Sanskrit Uttara Phalguni.
  uthram('ഉത്രം', 'Uthram', 'Uttara Phalguni'),

  /// Atham (അത്തം); Sanskrit Hasta.
  atham('അത്തം', 'Atham', 'Hasta'),

  /// Chithira (ചിത്തിര); Sanskrit Chitra.
  chithira('ചിത്തിര', 'Chithira', 'Chitra'),

  /// Chothi (ചോതി); Sanskrit Swati.
  chothi('ചോതി', 'Chothi', 'Swati'),

  /// Vishakham (വിശാഖം); Sanskrit Vishakha.
  vishakham('വിശാഖം', 'Vishakham', 'Vishakha'),

  /// Anizham (അനിഴം); Sanskrit Anuradha.
  anizham('അനിഴം', 'Anizham', 'Anuradha'),

  /// Thrikketta (തൃക്കേട്ട); Sanskrit Jyeshtha.
  thrikketta('തൃക്കേട്ട', 'Thrikketta', 'Jyeshtha'),

  /// Moolam (മൂലം); Sanskrit Mula.
  moolam('മൂലം', 'Moolam', 'Mula'),

  /// Pooradam (പൂരാടം); Sanskrit Purva Ashadha.
  pooradam('പൂരാടം', 'Pooradam', 'Purva Ashadha'),

  /// Uthradam (ഉത്രാടം); Sanskrit Uttara Ashadha.
  uthradam('ഉത്രാടം', 'Uthradam', 'Uttara Ashadha'),

  /// Thiruvonam (തിരുവോണം); Sanskrit Shravana.
  thiruvonam('തിരുവോണം', 'Thiruvonam', 'Shravana'),

  /// Avittam (അവിട്ടം); Sanskrit Dhanishta.
  avittam('അവിട്ടം', 'Avittam', 'Dhanishta'),

  /// Chathayam (ചതയം); Sanskrit Shatabhisha.
  chathayam('ചതയം', 'Chathayam', 'Shatabhisha'),

  /// Pooruruttathi (പൂരുരുട്ടാതി); Sanskrit Purva Bhadrapada.
  pooruruttathi('പൂരുരുട്ടാതി', 'Pooruruttathi', 'Purva Bhadrapada'),

  /// Uthrattathi (ഉത്രട്ടാതി); Sanskrit Uttara Bhadrapada.
  uthrattathi('ഉത്രട്ടാതി', 'Uthrattathi', 'Uttara Bhadrapada'),

  /// Revathi (രേവതി); Sanskrit Revati.
  revathi('രേവതി', 'Revathi', 'Revati');

  const Nakshatra(this.malayalam, this.english, this.sanskrit);

  /// Name in Malayalam script.
  final String malayalam;

  /// Malayalam name in Latin transliteration.
  final String english;

  /// Sanskrit name.
  final String sanskrit;

  /// Arc of the zodiac covered by one nakshatra, in degrees.
  static const double span = 360 / 27;

  /// The nakshatra containing sidereal longitude [degrees].
  static Nakshatra fromSiderealLongitude(double degrees) =>
      values[((degrees % 360) / span).floor() % 27];

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;

  /// The following nakshatra, wrapping from Revathi to Ashwathi.
  Nakshatra get next => values[(index + 1) % 27];
}

/// Lunar fortnight.
enum Paksha {
  /// Waxing fortnight (വെളുത്ത പക്ഷം), new moon to full moon.
  shukla('വെളുത്ത പക്ഷം', 'Shukla Paksha'),

  /// Waning fortnight (കറുത്ത പക്ഷം), full moon to new moon.
  krishna('കറുത്ത പക്ഷം', 'Krishna Paksha');

  const Paksha(this.malayalam, this.english);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in English.
  final String english;

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}

const _tithiMalayalam = [
  'പ്രഥമ', 'ദ്വിതീയ', 'തൃതീയ', 'ചതുർത്ഥി', 'പഞ്ചമി', //
  'ഷഷ്ഠി', 'സപ്തമി', 'അഷ്ടമി', 'നവമി', 'ദശമി', //
  'ഏകാദശി', 'ദ്വാദശി', 'ത്രയോദശി', 'ചതുർദശി',
];
const _tithiEnglish = [
  'Prathama', 'Dwitheeya', 'Thritheeya', 'Chathurthi', 'Panchami', //
  'Shashti', 'Sapthami', 'Ashtami', 'Navami', 'Dashami', //
  'Ekadashi', 'Dwadashi', 'Thrayodashi', 'Chathurdashi',
];

/// A tithi (lunar day): one of 30 divisions of the lunar month, each the
/// time for the Moon to gain 12° on the Sun.
class Tithi {
  /// Creates the tithi with 1-based [number] (1–30). 15 is the full moon
  /// (Pournami) and 30 the new moon (Amavasya).
  Tithi(this.number) {
    RangeError.checkValueInInterval(number, 1, 30, 'number');
  }

  /// The tithi for a Moon–Sun elongation in degrees.
  factory Tithi.fromElongation(double degrees) =>
      Tithi(((degrees % 360) / 12).floor() % 30 + 1);

  /// 1-based position in the lunar month, 1–30.
  final int number;

  /// Fortnight this tithi belongs to.
  Paksha get paksha => number <= 15 ? Paksha.shukla : Paksha.krishna;

  /// Position within the fortnight, 1–15.
  int get dayOfPaksha => (number - 1) % 15 + 1;

  /// Full moon.
  bool get isPournami => number == 15;

  /// New moon.
  bool get isAmavasya => number == 30;

  /// Ekadashi of either fortnight.
  bool get isEkadashi => dayOfPaksha == 11;

  /// Name in the requested [script], e.g. ഏകാദശി, പൗർണ്ണമി, അമാവാസി.
  String name(MalayalamScript script) {
    final ml = script == MalayalamScript.malayalam;
    if (number == 15) return ml ? 'പൗർണ്ണമി' : 'Pournami';
    if (number == 30) return ml ? 'അമാവാസി' : 'Amavasi';
    final i = dayOfPaksha - 1;
    return ml ? _tithiMalayalam[i] : _tithiEnglish[i];
  }

  @override
  bool operator ==(Object other) => other is Tithi && other.number == number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Tithi($number, ${name(MalayalamScript.english)})';
}

/// A span of time during which a nakshatra or tithi prevails.
class PanchangaSpan<T> {
  /// Creates a span during which [value] prevails, from [start] to [end].
  const PanchangaSpan(this.value, this.start, this.end);

  /// The nakshatra or tithi.
  final T value;

  /// When it began (UTC).
  final DateTime start;

  /// When it ends (UTC).
  final DateTime end;

  /// Whether [instant] falls within this span.
  bool contains(DateTime instant) =>
      !instant.isBefore(start) && instant.isBefore(end);

  @override
  String toString() => '$value: $start – $end';
}
