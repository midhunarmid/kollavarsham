import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

/// Categories of festivals and holidays, for filters and reminders (C6).
enum FestivalCategory {
  /// Kerala Hindu festivals and seasons.
  hindu,

  /// Christian feasts.
  christian,

  /// Muslim festivals (tentative until announced).
  muslim,

  /// National days.
  national,

  /// Kerala government holidays (jayanthis and the like).
  government,

  /// Bank-only closures.
  bank,
}

/// How a day is a holiday, from the holiday data.
enum HolidayKind {
  /// A public holiday.
  public,

  /// An optional holiday for some communities.
  restricted,

  /// A bank-only closure.
  bank,
}

/// One entry of `data/holidays/YYYY.json` (see `data/holidays/schema.md`).
@immutable
class HolidayEntry {
  /// Creates an entry.
  const HolidayEntry({
    required this.date,
    required this.name,
    required this.category,
    required this.kind,
    required this.tentative,
    required this.source,
    this.nameMl,
    this.sourceNote,
  });

  /// Reads an entry; throws a [FormatException] for a malformed one.
  factory HolidayEntry.fromJson(Map<String, Object?> json) {
    T byName<T extends Enum>(List<T> values, String field) {
      final name = json[field];
      for (final v in values) {
        if (v.name == name) return v;
      }
      throw FormatException('Bad $field: $name');
    }

    final date = DateTime.tryParse(json['date'] as String? ?? '');
    final name = json['name'];
    final source = json['source'];
    if (date == null || name is! String || source is! String) {
      throw FormatException('Bad holiday entry: $json');
    }
    return HolidayEntry(
      date: DateTime(date.year, date.month, date.day),
      name: name,
      category: byName(FestivalCategory.values, 'category'),
      kind: byName(HolidayKind.values, 'kind'),
      tentative: json['tentative'] == true,
      source: source,
      nameMl: json['name_ml'] as String?,
      sourceNote: json['sourceNote'] as String?,
    );
  }

  /// Gregorian date (Kerala local).
  final DateTime date;

  /// English name as the source gives it.
  final String name;

  /// Malayalam name, if the file has one.
  final String? nameMl;

  /// Stable id across years, e.g. `holiday.gandhijayanthi`.
  String get id => 'holiday.${_normal(name)}';

  /// Category.
  final FestivalCategory category;

  /// Public, restricted or bank.
  final HolidayKind kind;

  /// Whether the date may still move.
  final bool tentative;

  /// Source URL.
  final String source;

  /// Note on the source, e.g. "falls on Sunday".
  final String? sourceNote;
}

/// The bundled holiday lists, by Gregorian year.
@immutable
class HolidayData {
  /// Creates the data from [byYear].
  const HolidayData(this.byYear);

  /// No holiday data.
  static const empty = HolidayData({});

  /// Reads the files' JSON texts; a malformed file is skipped (and
  /// reported in debug builds) rather than failing the app.
  factory HolidayData.parse(Iterable<String> files) {
    final byYear = <int, List<HolidayEntry>>{};
    for (final text in files) {
      try {
        final json = (jsonDecode(text) as Map).cast<String, Object?>();
        final year = json['year']! as int;
        byYear[year] = [
          for (final h in json['holidays']! as List)
            HolidayEntry.fromJson((h as Map).cast<String, Object?>()),
        ];
      } on Object catch (e) {
        debugPrint('Skipping a holiday file: $e');
      }
    }
    return HolidayData(byYear);
  }

  /// Entries by Gregorian year.
  final Map<int, List<HolidayEntry>> byYear;

  /// Entries of Gregorian [year] (none if there is no file).
  List<HolidayEntry> inYear(int year) => byYear[year] ?? const [];
}

/// A festival or holiday on a day: computed by the engine, listed in the
/// holiday data, or both.
@immutable
class FestivalDay {
  /// Creates a festival day.
  const FestivalDay(
    this.id,
    this.category,
    this.date,
    this.malayalam,
    this.english, {
    this.tentative = false,
    this.holiday,
    this.source,
  });

  /// Stable id across years: `hindu.onam`, `christian.easter`,
  /// `muslim.bakrid` or `holiday.<name>`.
  final String id;

  /// Its category.
  final FestivalCategory category;

  /// The day.
  final MalayalamDate date;

  /// Name in Malayalam script (the English name where the data has no
  /// Malayalam one yet).
  final String malayalam;

  /// Name in English.
  final String english;

  /// Whether the date may still move.
  final bool tentative;

  /// How the day is a holiday, if the holiday data lists it.
  final HolidayKind? holiday;

  /// Source URL of the holiday entry.
  final String? source;

  /// Name in the requested [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? malayalam : english;

  /// A copy marked as a holiday of [entry].
  FestivalDay withHoliday(HolidayEntry entry) =>
      FestivalDay(id, category, date, malayalam, english,
          tentative: tentative && entry.tentative,
          holiday: entry.kind,
          source: entry.source);
}

String _normal(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z]'), '');

/// Words in a holiday's name that identify an engine festival.
const _keralaAliases = {
  KeralaFestival.sivaratri: ['sivarat', 'shivarat'],
  KeralaFestival.vishu: ['vishu'],
  KeralaFestival.onam: ['thiruvonam'],
  KeralaFestival.karkidakaVavu: ['vavu'],
  KeralaFestival.ashtamiRohini: ['krishnajayanthi', 'ashtamirohini'],
  KeralaFestival.durgashtami: ['durgashtami'],
  KeralaFestival.mahanavami: ['mahanavami'],
  KeralaFestival.vijayadasami: ['vijayadasami'],
  KeralaFestival.deepavali: ['deepavali', 'diwali'],
  KeralaFestival.thaipooyam: ['thaipooyam'],
};

const _hijriAliases = {
  HijriFestival.eidUlFitr: ['fitr', 'ramzan'],
  HijriFestival.bakrid: ['adha', 'bakrid'],
  HijriFestival.muharram: ['muharam', 'muharram'],
  HijriFestival.miladISherif: ['milad'],
};

bool _matches(String holiday, List<String> aliases) {
  final n = _normal(holiday);
  return aliases.any(n.contains);
}

/// The festivals and holidays of [categories] from [from] to [to]
/// (inclusive), in date order.
///
/// A holiday entry naming a computed festival marks it as a holiday
/// instead of adding a second item. An announced Muslim holiday replaces
/// the tentative computed date of that festival in its year.
List<FestivalDay> festivalDaysBetween(
  KollavarshamCalendar calendar,
  MalayalamDate from,
  MalayalamDate to, {
  Set<FestivalCategory> categories = const {...FestivalCategory.values},
  HolidayData holidays = HolidayData.empty,
}) {
  final days = <FestivalDay>[];
  bool inRange(MalayalamDate d) => !d.isBefore(from) && !d.isAfter(to);
  final firstYear = from.toGregorian().year;
  final lastYear = to.toGregorian().year;

  // Holiday entries in range (and a little around it, for Muslim dates that
  // move the computed ones across the range edge).
  final entries = [
    for (var y = firstYear; y <= lastYear; y++) ...holidays.inYear(y),
  ];
  final used = <HolidayEntry>{};

  if (categories.contains(FestivalCategory.hindu)) {
    final seen = <String>{};
    for (var y = from.year; y <= to.year + 1; y++) {
      for (final (f, d) in calendar.festivalsIn(y)) {
        // Atham can be listed under two years; keep each day once.
        if (!inRange(d) || !seen.add('${f.english}|${d.dayNumber}')) continue;
        var day = FestivalDay('hindu.${EnumName(f).name}',
            FestivalCategory.hindu, d, f.malayalam, f.english);
        final aliases = _keralaAliases[f];
        for (final e in entries) {
          if (aliases != null &&
              e.category == FestivalCategory.hindu &&
              calendar.fromGregorian(e.date).isAtSameDayAs(d) &&
              _matches(e.name, aliases)) {
            day = day.withHoliday(e);
            used.add(e);
          }
        }
        days.add(day);
      }
    }
  }

  for (var y = firstYear; y <= lastYear; y++) {
    if (categories.contains(FestivalCategory.christian)) {
      for (final (f, g) in christianFeastsIn(y)) {
        final d = calendar.fromGregorian(g);
        if (!inRange(d)) continue;
        var day = FestivalDay('christian.${EnumName(f).name}',
            FestivalCategory.christian, d, f.malayalam, f.english);
        for (final e in entries) {
          if (e.category == FestivalCategory.christian &&
              calendar.fromGregorian(e.date).isAtSameDayAs(d) &&
              _normal(e.name) == _normal(f.english)) {
            day = day.withHoliday(e);
            used.add(e);
          }
        }
        days.add(day);
      }
    }
    if (categories.contains(FestivalCategory.muslim)) {
      for (final (f, g) in hijriFestivalsIn(y)) {
        // An announced date for this festival in this year wins.
        HolidayEntry? announced;
        for (final e in holidays.inYear(y)) {
          final aliases = _hijriAliases[f];
          if (e.category == FestivalCategory.muslim &&
              aliases != null &&
              _matches(e.name, aliases)) {
            announced = e;
          }
        }
        final d = calendar.fromGregorian(announced?.date ?? g);
        if (announced != null) used.add(announced);
        if (!inRange(d)) continue;
        final day = FestivalDay('muslim.${EnumName(f).name}',
            FestivalCategory.muslim, d, f.malayalam, f.english,
            tentative: true);
        days.add(announced == null ? day : day.withHoliday(announced));
      }
    }
  }

  // The rest of the holiday entries stand on their own.
  for (final e in entries) {
    if (used.contains(e) || !categories.contains(e.category)) continue;
    final d = calendar.fromGregorian(e.date);
    if (!inRange(d)) continue;
    days.add(FestivalDay(e.id, e.category, d, e.nameMl ?? e.name, e.name,
        tentative: e.tentative, holiday: e.kind, source: e.source));
  }

  return days..sort((a, b) => a.date.compareTo(b.date));
}
