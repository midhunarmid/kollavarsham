import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';
import 'settings.dart';
import 'theme.dart';

/// The Malayalam Calendar app.
class CalendarApp extends ConsumerStatefulWidget {
  /// Creates the app; language and theme come from [settingsProvider].
  const CalendarApp({super.key});

  @override
  ConsumerState<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends ConsumerState<CalendarApp> {
  late final GoRouter _router = createRouter(
      needsOnboarding: () => !ref.read(settingsProvider).onboardingDone);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.language.locale,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: settings.themeMode,
      routerConfig: _router,
    );
  }
}
