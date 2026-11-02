import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/festival_days.dart';
import 'locations.dart';

/// Where wrong dates are reported.
const issuesUrl = 'https://github.com/midhunarmid/kollavarsham/issues/new';

/// A pre-filled "wrong date" issue for [day]: what the app shows, and the
/// settings that decide it. A manual location is not included, since
/// coordinates can identify a home; only "manual" and the time zone are.
Uri wrongDateReport(
  MalayalamDate day,
  List<FestivalDay> festivals, {
  required String appVersion,
}) {
  final cal = day.calendar;
  final g = day.toGregorian();
  final iso = '${g.year}-${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';
  final city = keralaCityAt(cal.location);
  final offset = cal.location.utcOffset;
  final place = city?.nameEn ??
      'manual location (UTC${offset.isNegative ? '-' : '+'}'
          '${offset.inHours.abs().toString().padLeft(2, '0')}:'
          '${(offset.inMinutes.abs() % 60).toString().padLeft(2, '0')})';
  final body = '''
**Date:** $iso

**The app shows**
- Malayalam date: ${day.format('d MMMM y', script: MalayalamScript.english)} (${day.format('d MMMM y', script: MalayalamScript.malayalam)})
- Star: ${day.nakshatra.english}
- Tithi: ${day.tithi.name(MalayalamScript.english)}
- Festivals: ${festivals.isEmpty ? 'none' : festivals.map((f) => f.english).join(', ')}

**What it should be, and your source** (almanac name and year, or a link):


**Settings:** $place, year starts in ${cal.firstMonth.english}, app $appVersion
''';
  return Uri.parse(issuesUrl).replace(queryParameters: {
    'title': 'Wrong date: $iso',
    'labels': 'wrong-date',
    'body': body,
  });
}

/// Opens a URL outside the app; tests override it.
final openUrlProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);
