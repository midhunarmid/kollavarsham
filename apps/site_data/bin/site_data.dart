// Writes the site's data files.
//
//   dart run site_data [--from YEAR] [--to YEAR] [--out DIR]
//
// Defaults: two years back to ten years ahead of the current year, into
// ../site/src/data (run from apps/site_data). Holiday lists are read from
// ../../data/holidays.
import 'dart:convert';
import 'dart:io';

import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:site_data/site_data.dart';

void main(List<String> args) {
  final options = <String, String>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    options[args[i].replaceFirst('--', '')] = args[i + 1];
  }
  final now = DateTime.now().year;
  final from = int.parse(options['from'] ?? '${now - 2}');
  final to = int.parse(options['to'] ?? '${now + 10}');
  final out = Directory(options['out'] ?? '../site/src/data');
  final holidayDir = Directory(options['holidays'] ?? '../../data/holidays');

  final holidays = HolidayData.parse([
    for (final f in holidayDir.listSync().whereType<File>())
      if (f.path.endsWith('.json')) f.readAsStringSync(),
  ]);
  if (holidays.errors.isNotEmpty) {
    stderr.writeln('Holiday files skipped: ${holidays.errors.join('; ')}');
    exitCode = 1;
    return;
  }
  final calendar = KollavarshamCalendar.standard;
  const encoder = JsonEncoder();

  void write(String path, Object json) {
    final file = File('${out.path}/$path')..createSync(recursive: true);
    file.writeAsStringSync('${encoder.convert(json)}\n');
  }

  write('meta.json', metaJson(from, to, calendar));
  write('names.json', namesJson());
  write('months.json', monthsJson(from, to, calendar));
  write('festivals.json', festivalsJson(from, to, calendar, holidays));
  for (var y = from; y <= to; y++) {
    write('days/$y.json', daysJson(y, calendar, holidays));
  }
  stdout.writeln('Wrote ${to - from + 1} years of site data to ${out.path}');
}
