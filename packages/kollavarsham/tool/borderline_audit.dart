// Lists months whose sankranti fell close to the Kerala cut-off, where
// almanacs may disagree about the first day of the month.
//
// Usage: dart run tool/borderline_audit.dart [minutes=10]
// Writes test/fixtures/borderline_months.csv.
import 'dart:io';

import 'package:kollavarsham/kollavarsham.dart';

/// Sources for [KollavarshamCalendar.verifiedMonthStarts].
const _sources = {
  (1197, MalayalamMonth.vrischikam):
      'Mandala Pooja held 2021-12-26 (PTI); season opened 2021-11-16',
  (1199, MalayalamMonth.chingam): 'Kerala New Year observed 2023-08-17',
};

void main(List<String> args) {
  final limit = Duration(minutes: args.isEmpty ? 10 : int.parse(args.first));
  final cal = KollavarshamCalendar();
  const ist = Duration(hours: 5, minutes: 30);
  String date(DateTime d) => d.toIso8601String().split('T').first;

  final out = StringBuffer(
      'year,month,sankranti_ist,margin_min,start,verified,source\n');
  var count = 0;
  for (var year = 1075; year <= 1276; year++) {
    for (final month in MalayalamMonth.values) {
      final margin = cal.monthStartMargin(year, month);
      if (margin.abs() > limit) continue;
      final sankranti = cal.sankranti(year, month).add(ist);
      final start = cal.monthStart(year, month);
      final verified = KollavarshamCalendar.verifiedMonthStarts[(year, month)];
      out.writeln([
        year,
        month.english,
        sankranti.toIso8601String().substring(0, 16),
        (margin.inSeconds / 60).toStringAsFixed(1),
        date(start),
        verified == null ? '' : date(verified),
        _sources[(year, month)] ?? '',
      ].join(','));
      count++;
    }
  }
  File('test/fixtures/borderline_months.csv').writeAsStringSync('$out');
  stdout.writeln('$count months within ${limit.inMinutes} min of the cut-off');
}
