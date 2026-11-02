import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

/// Groups of festivals that can be shown and reminded of separately.
enum FestivalCategory {
  /// Kerala Hindu festivals and seasons.
  hindu,

  /// Christian feasts.
  christian,

  /// Muslim festivals (tentative dates from the tabular Hijri calendar).
  muslim,
}

/// A festival on a day.
class FestivalDay {
  /// Creates a festival day.
  const FestivalDay(this.category, this.date, this.malayalam, this.english,
      {this.tentative = false});

  /// Its category.
  final FestivalCategory category;

  /// The day.
  final MalayalamDate date;

  /// Name in Malayalam script.
  final String malayalam;

  /// Name in English.
  final String english;

  /// Whether the date may still move (Muslim festivals before announcement).
  final bool tentative;

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;
}

/// The festivals of [categories] from [from] to [to] (inclusive), by date.
List<FestivalDay> festivalDaysBetween(
  KollavarshamCalendar calendar,
  MalayalamDate from,
  MalayalamDate to, {
  Set<FestivalCategory> categories = const {...FestivalCategory.values},
}) {
  final days = <FestivalDay>[];
  bool inRange(MalayalamDate d) => !d.isBefore(from) && !d.isAfter(to);
  if (categories.contains(FestivalCategory.hindu)) {
    for (var y = from.year; y <= to.year + 1; y++) {
      for (final (f, d) in calendar.festivalsIn(y)) {
        if (inRange(d)) {
          days.add(
              FestivalDay(FestivalCategory.hindu, d, f.malayalam, f.english));
        }
      }
    }
  }
  final firstYear = from.toGregorian().year;
  final lastYear = to.toGregorian().year;
  for (var y = firstYear; y <= lastYear; y++) {
    if (categories.contains(FestivalCategory.christian)) {
      for (final (f, g) in christianFeastsIn(y)) {
        final d = calendar.fromGregorian(g);
        if (inRange(d)) {
          days.add(FestivalDay(
              FestivalCategory.christian, d, f.malayalam, f.english));
        }
      }
    }
    if (categories.contains(FestivalCategory.muslim)) {
      for (final (f, g) in hijriFestivalsIn(y)) {
        final d = calendar.fromGregorian(g);
        if (inRange(d)) {
          days.add(FestivalDay(
              FestivalCategory.muslim, d, f.malayalam, f.english,
              tentative: true));
        }
      }
    }
  }
  // Atham can be listed under two years; keep each festival day once.
  final seen = <String>{};
  days.retainWhere((f) => seen.add('${f.english}|${f.date.dayNumber}'));
  return days..sort((a, b) => a.date.compareTo(b.date));
}
