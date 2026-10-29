import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

/// The Malayalam Calendar app.
class CalendarApp extends StatefulWidget {
  /// Creates the app. [locale] and [themeMode] override the system
  /// settings (used by tests until the settings screen exists).
  const CalendarApp({super.key, this.locale, this.themeMode});

  /// Interface language; the device language if null.
  final Locale? locale;

  /// Light, dark or system theme; system if null.
  final ThemeMode? themeMode;

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: widget.locale,
        theme: appTheme(Brightness.light),
        darkTheme: appTheme(Brightness.dark),
        themeMode: widget.themeMode ?? ThemeMode.system,
        routerConfig: _router,
      );
}
