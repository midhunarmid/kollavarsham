import 'dart:typed_data';

import 'data/month_starts.dart';

/// Decoded form of the precomputed month starts in `data/month_starts.dart`.
///
/// Holds the start day number (days since 1970-01-01) of every month from
/// Chingam [monthStartTableFirstYear] onwards, for Thiruvananthapuram in IST
/// with [KollavarshamCalendar.verifiedMonthStarts] applied.
class MonthStartTable {
  MonthStartTable._(this._starts);

  /// The shared table, decoded on first use.
  static final MonthStartTable instance = MonthStartTable._(_decode());

  /// `_starts[i]` is the first day of month `i` (0 = Chingam of the first
  /// year); the extra last entry is the day after the table ends.
  final Int32List _starts;

  static Int32List _decode() {
    final lengths = monthStartTableLengths;
    final starts = Int32List(lengths.length + 1);
    var day = monthStartTableFirstDay;
    for (var i = 0; i < lengths.length; i++) {
      starts[i] = day;
      day += 29 + lengths.codeUnitAt(i) - 0x30;
    }
    starts[lengths.length] = day;
    return starts;
  }

  /// Number of months in the table.
  int get length => _starts.length - 1;

  /// Start day number of month [monthIndex] (0 = Chingam) of Kollavarsham
  /// [year], or `null` if outside the table.
  int? startOf(int year, int monthIndex) {
    final i = (year - monthStartTableFirstYear) * 12 + monthIndex;
    return i >= 0 && i < length ? _starts[i] : null;
  }

  /// `(year, monthIndex)` of the month containing day number [day], or
  /// `null` if outside the table.
  (int, int)? locate(int day) {
    if (day < _starts[0] || day >= _starts[length]) return null;
    // Largest i with _starts[i] <= day.
    var lo = 0, hi = length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_starts[mid] <= day) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return (monthStartTableFirstYear + lo ~/ 12, lo % 12);
  }
}
