import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';

void main() => runApp(const ProviderScope(child: CalendarApp()));

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        body: Center(child: Text(AppLocalizations.of(context).appTitle)),
      ),
    ),
  ],
);

/// The Malayalam Calendar app.
class CalendarApp extends StatelessWidget {
  /// Creates the app.
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      );
}
