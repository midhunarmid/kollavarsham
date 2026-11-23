/// Public subscription feeds (.ics) of festivals and holidays, published by
/// the site at `/ics/<lang>/<feed>.ics`. Personal events never go in them:
/// those stay in the app and its own .ics export.
library;

import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';

/// A feed: its file name, what it holds, and its title in both languages.
class Feed {
  /// A feed with its file name, titles and membership test.
  const Feed(this.id, this.en, this.ml, this.contains);

  /// File name without `.ics`.
  final String id;

  /// Title in English.
  final String en;

  /// Title in Malayalam.
  final String ml;

  /// Whether the feed has [day].
  final bool Function(FestivalDay day) contains;
}

bool _all(FestivalDay d) => true;
bool _hindu(FestivalDay d) => d.category == FestivalCategory.hindu;
bool _christian(FestivalDay d) => d.category == FestivalCategory.christian;
bool _muslim(FestivalDay d) => d.category == FestivalCategory.muslim;
// Public holidays and the bank-only closures of the Kerala lists; the lists
// don't mark which public holidays close banks, so there is no bank feed.
bool _holiday(FestivalDay d) =>
    d.holiday == HolidayKind.public || d.holiday == HolidayKind.bank;

/// Every feed.
const feeds = [
  Feed('all', 'Malayalam Calendar: festivals and holidays',
      'മലയാളം കലണ്ടർ: വിശേഷങ്ങളും അവധികളും', _all),
  Feed('hindu', 'Malayalam Calendar: Hindu festivals',
      'മലയാളം കലണ്ടർ: ഹിന്ദു വിശേഷങ്ങൾ', _hindu),
  Feed('christian', 'Malayalam Calendar: Christian feasts',
      'മലയാളം കലണ്ടർ: ക്രിസ്ത്യൻ പെരുന്നാളുകൾ', _christian),
  Feed('muslim', 'Malayalam Calendar: Muslim festivals',
      'മലയാളം കലണ്ടർ: മുസ്ലിം വിശേഷങ്ങൾ', _muslim),
  Feed('holidays', 'Malayalam Calendar: Kerala holidays',
      'മലയാളം കലണ്ടർ: കേരളത്തിലെ അവധികൾ', _holiday),
];

String _holidayText(HolidayKind? kind, bool ml) => switch (kind) {
      HolidayKind.public => ml ? 'പൊതു അവധി' : 'Public holiday',
      HolidayKind.restricted => ml ? 'നിയന്ത്രിത അവധി' : 'Restricted holiday',
      HolidayKind.bank => ml ? 'ബാങ്ക് അവധി' : 'Bank holiday',
      null => '',
    };

/// The feeds for festivals from Gregorian year [from] to [to], keyed by
/// path (`en/hindu.ics`), stamped at [now].
///
/// Each occurrence's UID is the festival id and Gregorian year (with a
/// count for a second occurrence that year), not the date: when a
/// tentative date moves, subscribed calendars move the event rather than
/// add another.
Map<String, String> icsFeeds(
  int from,
  int to,
  KollavarshamCalendar calendar,
  HolidayData holidays, {
  required DateTime now,
}) {
  final days = festivalDaysBetween(
    calendar,
    calendar.fromGregorian(DateTime(from)),
    calendar.fromGregorian(DateTime(to, 12, 31)),
    holidays: holidays,
  )..sort((a, b) => a.date.compareTo(b.date));
  final seen = <String, int>{};
  final uids = <FestivalDay, String>{};
  for (final d in days) {
    final key = '${d.id}-${d.date.toGregorian().year}';
    final n = seen.update(key, (n) => n + 1, ifAbsent: () => 1);
    uids[d] = '${n == 1 ? key : '$key-$n'}@calendar.armid.in';
  }

  IcsEvent event(FestivalDay d, bool ml) {
    final script = ml ? MalayalamScript.malayalam : MalayalamScript.english;
    final iso = isoDate(d.date.toGregorian());
    return IcsEvent(
      uid: uids[d]!,
      date: d.date,
      summary: ml
          ? '${d.malayalam}${d.tentative ? ' (തീയതി മാറിയേക്കാം)' : ''}'
          : '${d.english}${d.tentative ? ' (tentative)' : ''}',
      description: [
        d.date.format('d MMMM y', script: script),
        if (d.holiday != null) _holidayText(d.holiday, ml),
        if (d.tentative)
          ml
              ? 'ചന്ദ്രദർശനം അനുസരിച്ച് തീയതി മാറിയേക്കാം.'
              : 'The date depends on the moon sighting and may change.',
        if (d.source != null) d.source!,
        'https://calendar.armid.in${ml ? '/ml' : ''}/day/$iso/',
      ].join('\n'),
    );
  }

  return {
    for (final ml in [false, true])
      for (final feed in feeds)
        '${ml ? 'ml' : 'en'}/${feed.id}.ics': buildIcs(
          [
            for (final d in days)
              if (feed.contains(d)) event(d, ml),
          ],
          now: now,
          name: ml ? feed.ml : feed.en,
        ),
  };
}
