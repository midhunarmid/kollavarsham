@TestOn('windows')
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// 25 August 2026, 10:00 in Kerala: the day before Thiruvonam.
final _now = DateTime.utc(2026, 8, 25, 4, 30);

const _size = Size(400, 1000);

void main() {
  setUpAll(loadRealFonts);

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
