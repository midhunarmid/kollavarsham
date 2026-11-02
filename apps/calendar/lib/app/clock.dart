import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'settings.dart';

/// The current instant; overridden in tests for a fixed day.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today's Malayalam date at the chosen location.
///
/// Read once per build: it does not tick over at midnight by itself.
final todayProvider = Provider.autoDispose<MalayalamDate>((ref) {
  final calendar = ref.watch(calendarProvider);
  final now = ref.watch(clockProvider)();
  return calendar.fromGregorian(now.toUtc().add(calendar.location.utcOffset));
});
