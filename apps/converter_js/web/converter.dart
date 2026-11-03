// Exposes the converter to JavaScript as globalThis.kollavarsham:
//
//   kollavarsham.toMalayalam("2026-11-02")
//   kollavarsham.toGregorian(1202, "thulam", 17)
//   kollavarsham.findStar("1990-01-15T06:30")
//
// Each takes an optional latitude, longitude and UTC offset (minutes) last,
// and returns a plain object, or null for bad input.
//
// Build: dart compile js -O2 -o build/kollavarsham.js web/converter.dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:converter_js/converter.dart';
import 'package:kollavarsham/kollavarsham.dart';

KollavarshamCalendar _place(JSNumber? lat, JSNumber? lng, JSNumber? offset) =>
    calendarFor(
      latitude: lat?.toDartDouble,
      longitude: lng?.toDartDouble,
      utcOffsetMinutes: offset?.toDartInt,
    );

JSAny? _out(Map<String, Object>? result) => result?.jsify();

JSAny? _toMalayalam(String date,
        [JSNumber? lat, JSNumber? lng, JSNumber? offset]) =>
    _out(toMalayalam(date, _place(lat, lng, offset)));

JSAny? _toGregorian(int year, String month, int day,
        [JSNumber? lat, JSNumber? lng, JSNumber? offset]) =>
    _out(toGregorian(year, month, day, _place(lat, lng, offset)));

JSAny? _findStar(String time,
        [JSNumber? lat, JSNumber? lng, JSNumber? offset]) =>
    _out(findStar(time, _place(lat, lng, offset)));

void main() {
  final api = JSObject()
    ..setProperty('toMalayalam'.toJS, _toMalayalam.toJS)
    ..setProperty('toGregorian'.toJS, _toGregorian.toJS)
    ..setProperty('findStar'.toJS, _findStar.toJS);
  globalContext.setProperty('kollavarsham'.toJS, api);
}
