@TestOn('windows')
@Tags(['golden'])
library;

import 'dart:io';

import 'package:calendar/app/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// 25 August 2026, 10:00 in Kerala: the day before Thiruvonam.
final _now = DateTime.utc(2026, 8, 25, 4, 30);

const _size = Size(400, 1000);

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader
        .addFont(Future.value(ByteData.sublistView(File(p).readAsBytesSync())));
  }
  await loader.load();
}

/// Loads the real fonts, since tests otherwise draw every glyph as a box.
///
/// Noto Sans Malayalam has no Latin letters; on devices the system font
/// supplies them, so Roboto from the Flutter SDK stands in here.
Future<void> _loadFonts() async {
  final sdk = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final material = '$sdk/bin/cache/artifacts/material_fonts';
  await _loadFont(appFontFamily, [
    'assets/fonts/NotoSansMalayalam-Regular.ttf',
    'assets/fonts/NotoSansMalayalam-Bold.ttf',
  ]);
  await _loadFont('Roboto', [
    '$material/roboto-regular.ttf',
    '$material/roboto-medium.ttf',
    '$material/roboto-bold.ttf',
  ]);
  await _loadFont('MaterialIcons', ['$material/materialicons-regular.otf']);
}

void main() {
  setUpAll(_loadFonts);

  for (final (lang, base) in [('en', enSettings), ('ml', mlSettings)]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      final name = '${lang}_${mode.name}';
      final settings = base.copyWith(themeMode: mode);

      testWidgets('Today $name', (tester) async {
        await pumpApp(tester, settings: settings, now: _now, size: _size);
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('goldens/today_$name.png'));
      });

      testWidgets('Month $name', (tester) async {
        await pumpApp(tester, settings: settings, now: _now, size: _size);
        await tapTab(tester, lang == 'en' ? 'Calendar' : 'കലണ്ടർ');
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('goldens/month_$name.png'));
      });

      testWidgets('Day $name', (tester) async {
        await pumpApp(tester, settings: settings, now: _now, size: _size);
        await tester.tap(find.byKey(const Key('next-festival')));
        await tester.pumpAndSettle();
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('goldens/day_$name.png'));
      });
    }
  }
}
