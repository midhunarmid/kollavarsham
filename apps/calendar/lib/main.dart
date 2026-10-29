import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/fonts.dart';

void main() {
  registerFontLicenses();
  runApp(const ProviderScope(child: CalendarApp()));
}
