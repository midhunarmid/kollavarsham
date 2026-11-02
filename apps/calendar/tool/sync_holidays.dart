// Copies the holiday lists from data/holidays/ into the app's assets.
//
// Run from apps/calendar after editing data/holidays/*.json:
//   dart run tool/sync_holidays.dart
// test/holidays_test.dart fails while the copies differ.
import 'dart:io';

void main() {
  final from = Directory('../../data/holidays');
  final to = Directory('assets/holidays')..createSync(recursive: true);
  for (final f in to.listSync().whereType<File>()) {
    if (f.path.endsWith('.json')) f.deleteSync();
  }
  for (final f in from.listSync().whereType<File>()) {
    if (!f.path.endsWith('.json')) continue;
    final name = f.uri.pathSegments.last;
    f.copySync('${to.path}/$name');
    stdout.writeln('Copied $name');
  }
}
