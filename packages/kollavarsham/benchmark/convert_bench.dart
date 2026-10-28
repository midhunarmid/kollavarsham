// Measures conversion speed. Run: dart run benchmark/convert_bench.dart
// (or compile with `dart compile exe` for AOT numbers).
import 'package:kollavarsham/kollavarsham.dart';

void main() {
  // Dates spread over 1900–2100, inside the precomputed table.
  final first = DateTime.utc(1900, 1, 1);
  final dates = [
    for (var i = 0; i < 20000; i++) first.add(Duration(days: i * 3 % 73000)),
  ];

  void bench(String name, KollavarshamCalendar cal) {
    for (final d in dates.take(1000)) {
      cal.fromGregorian(d); // warm up
    }
    final sw = Stopwatch()..start();
    for (final d in dates) {
      cal.fromGregorian(d);
    }
    sw.stop();
    print('$name: ${(sw.elapsedMicroseconds / dates.length).toStringAsFixed(3)}'
        ' µs per fromGregorian');
  }

  bench('precomputed table', KollavarshamCalendar());
  bench('engine (no table)', KollavarshamCalendar(usePrecomputedTable: false));
}
