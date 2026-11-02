import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  test('every English string has a Malayalam translation', () {
    final en = _arb('en');
    final ml = _arb('ml');
    expect(_messageKeys(ml), _messageKeys(en));
    for (final key in _messageKeys(ml)) {
      expect((ml[key] as String).trim(), isNotEmpty, reason: key);
    }
  });

  test('every English string has a description for translators', () {
    final en = _arb('en');
    for (final key in _messageKeys(en)) {
      final meta = en['@$key'] as Map<String, dynamic>?;
      expect(meta?['description'], isA<String>(), reason: key);
    }
  });
}
