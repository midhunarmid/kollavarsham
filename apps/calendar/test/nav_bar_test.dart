import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  // Real glyph widths matter here: the test font draws square boxes.
  setUpAll(() async {
    if (realFontsAvailable) await loadRealFonts();
  });

  for (final (name, settings) in [
    ('English', enSettings),
    ('Malayalam', mlSettings),
  ]) {
    testWidgets('bottom-bar labels stay on one line at 320 dp in $name',
        // Real glyph widths need the SDK's Material fonts (not on Linux CI).
        skip: !realFontsAvailable, (tester) async {
      await pumpApp(tester, settings: settings, size: const Size(320, 640));
      // Icons are RichText too, in the private-use area; skip them.
      final labels = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byWidgetPredicate((w) =>
              w is RichText && w.text.toPlainText().codeUnitAt(0) < 0xE000));
      expect(labels, findsAtLeastNWidgets(5));
      for (final element in labels.evaluate()) {
        final paragraph = element.renderObject! as RenderParagraph;
        final lineHeight =
            paragraph.getFullHeightForCaret(const TextPosition(offset: 0));
        expect(paragraph.size.height, lessThan(lineHeight * 1.5),
            reason: paragraph.text.toPlainText());
      }
    });
  }
}
