// Prints the app's values for the accuracy checklist as markdown.
//
//   dart run site_data:accuracy_checklist [--from 2026] [--to 2027]
//
// Run from apps/site_data; docs/accuracy-checklist.md is this output under
// a short introduction.
import 'dart:io';

import 'package:calendar_data/calendar_data.dart';
import 'package:kollavarsham/kollavarsham.dart';
import 'package:site_data/accuracy.dart';

void main(List<String> args) {
  final options = <String, String>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    options[args[i].replaceFirst('--', '')] = args[i + 1];
  }
  final from = int.parse(options['from'] ?? '2026');
  final to = int.parse(options['to'] ?? '2027');
  final holidays = HolidayData.parse([
    for (final f in Directory(options['holidays'] ?? '../../data/holidays')
        .listSync()
        .whereType<File>())
      if (f.path.endsWith('.json')) f.readAsStringSync(),
  ]);
  stdout.write(
      accuracyChecklist(from, to, KollavarshamCalendar.standard, holidays));
}
