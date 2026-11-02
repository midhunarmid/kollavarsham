import 'dart:convert';

import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

/// One all-day event for an .ics file.
class IcsEvent {
  /// Creates an event on [date].
  const IcsEvent({
    required this.uid,
    required this.date,
    required this.summary,
    this.description = '',
  });

  /// Globally unique id; the same occurrence keeps the same id, so a
  /// re-import updates rather than duplicates.
  final String uid;

  /// The day.
  final MalayalamDate date;

  /// Title.
  final String summary;

  /// Longer text.
  final String description;
}

String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}'
    '${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

String _stamp(DateTime t) {
  final u = t.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${_date(u)}T${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
}

/// Escapes a TEXT value (RFC 5545 §3.3.11).
String icsEscape(String text) => text
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll('\r\n', r'\n')
    .replaceAll('\n', r'\n');

/// Folds [line] into lines of at most 75 octets (RFC 5545 §3.1), without
/// splitting a UTF-8 character.
String icsFold(String line) {
  final out = StringBuffer();
  var octets = 0;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final size = utf8.encode(char).length;
    if (octets + size > 75) {
      out.write('\r\n ');
      octets = 1;
    }
    out.write(char);
    octets += size;
  }
  return out.toString();
}

/// A VCALENDAR with [events] as all-day events, stamped at [now].
String buildIcs(List<IcsEvent> events, {required DateTime now}) {
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//armid.in//Malayalam Calendar//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
    for (final e in events) ...[
      'BEGIN:VEVENT',
      'UID:${e.uid}',
      'DTSTAMP:${_stamp(now)}',
      'DTSTART;VALUE=DATE:${_date(e.date.toGregorian())}',
      'DTEND;VALUE=DATE:${_date(e.date.addDays(1).toGregorian())}',
      'SUMMARY:${icsEscape(e.summary)}',
      if (e.description.isNotEmpty) 'DESCRIPTION:${icsEscape(e.description)}',
      'TRANSP:TRANSPARENT',
      'END:VEVENT',
    ],
    'END:VCALENDAR',
  ];
  return '${lines.map(icsFold).join('\r\n')}\r\n';
}
