import 'names.dart';

/// Christian feast days observed in Kerala.
enum ChristianFeast {
  /// New Year's Day, 1 January.
  newYear('പുതുവത്സരം', "New Year's Day"),

  /// Palm Sunday, a week before Easter.
  palmSunday('ഓശാന ഞായർ', 'Palm Sunday'),

  /// Maundy Thursday (Pesaha), three days before Easter.
  maundyThursday('പെസഹ വ്യാഴം', 'Maundy Thursday'),

  /// Good Friday, two days before Easter.
  goodFriday('ദുഃഖ വെള്ളി', 'Good Friday'),

  /// Easter Sunday.
  easter('ഈസ്റ്റർ', 'Easter'),

  /// Christmas, 25 December.
  christmas('ക്രിസ്മസ്', 'Christmas');

  const ChristianFeast(this.malayalam, this.english);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in English.
  final String english;

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}

/// Easter Sunday of Gregorian [year], by the Gregorian computus (the
/// anonymous algorithm in Meeus, *Astronomical Algorithms*, ch. 8).
DateTime easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime(year, month, day);
}

/// Every [ChristianFeast] of Gregorian [year], in date order.
List<(ChristianFeast, DateTime)> christianFeastsIn(int year) {
  final easter = easterSunday(year);
  DateTime before(int days) =>
      DateTime(easter.year, easter.month, easter.day - days);
  return [
    (ChristianFeast.newYear, DateTime(year)),
    (ChristianFeast.palmSunday, before(7)),
    (ChristianFeast.maundyThursday, before(3)),
    (ChristianFeast.goodFriday, before(2)),
    (ChristianFeast.easter, easter),
    (ChristianFeast.christmas, DateTime(year, 12, 25)),
  ];
}
