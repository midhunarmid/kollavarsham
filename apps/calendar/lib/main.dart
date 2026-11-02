import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/fonts.dart';
import 'app/settings.dart';
import 'data/festival_index.dart';
import 'reminders/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  final prefs = await SharedPreferences.getInstance();
  await initReminders(prefs);
  final holidays = await loadHolidays();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      holidaysProvider.overrideWithValue(holidays),
    ],
    child: const CalendarApp(),
  ));
}
