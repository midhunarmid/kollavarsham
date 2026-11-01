import 'calendar.dart';
import 'malayalam_date.dart';
import 'names.dart';

/// Regular fasting days, each set by a lunar day read at a fixed time of day.
enum Vrat {
  /// The eleventh day of each fortnight, read at sunrise.
  ekadashi('ഏകാദശി', 'Ekadashi', {11, 26}),

  /// The thirteenth day of each fortnight, read in the evening twilight
  /// (pradosha), 72 minutes after sunset.
  pradosham('പ്രദോഷം', 'Pradosham', {13, 28}),

  /// The sixth day of the waxing fortnight, read at sunset.
  shashti('ഷഷ്ഠി', 'Shashti', {6}),

  /// The full moon, read at the middle of the day.
  pournami('പൗർണ്ണമി', 'Pournami', {15}),

  /// The new moon, read at sunrise.
  amavasya('അമാവാസി', 'Amavasya', {30});

  const Vrat(this.malayalam, this.english, this._tithis);

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in English.
  final String english;

  final Set<int> _tithis;

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}

/// Fasting days by Kollavarsham year.
extension VratDays on KollavarshamCalendar {
  /// Every day of [vrat] in Kollavarsham [year], in date order.
  ///
  /// One lunar day gives one fast: a lunar day present at two readings
  /// counts on the first, and one that falls wholly between two readings
  /// counts on the earlier day.
  List<MalayalamDate> vratDays(Vrat vrat, int year) {
    int tithiOn(MalayalamDate d) => tithiAt(_reading(vrat, d)).number;

    final days = <MalayalamDate>[];
    var d = MalayalamDate(year, firstMonth, 1, calendar: this);
    var previous = tithiOn(d.addDays(-1));
    var current = tithiOn(d);
    while (d.year == year) {
      final next = d.addDays(1);
      final following = tithiOn(next);
      final skipped = (following - current) % 30 == 2 ? current % 30 + 1 : null;
      if ((current != previous && vrat._tithis.contains(current)) ||
          vrat._tithis.contains(skipped)) {
        days.add(d);
      }
      previous = current;
      current = following;
      d = next;
    }
    return days;
  }

  DateTime _reading(Vrat vrat, MalayalamDate d) {
    final date = d.toGregorian();
    final rise = sunrise(date)!;
    final set = sunset(date)!;
    return switch (vrat) {
      Vrat.ekadashi || Vrat.amavasya => rise,
      Vrat.pradosham => set.add(const Duration(minutes: 72)),
      Vrat.shashti => set,
      Vrat.pournami => rise.add(set.difference(rise) * 0.5),
    };
  }
}
