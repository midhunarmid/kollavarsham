import 'package:calendar/app/locations.dart';
import 'package:calendar/app/settings.dart';
import 'package:calendar/features/day/day_screen.dart';
import 'package:calendar/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding-next')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first run goes through onboarding to Today', (tester) async {
    final prefs = await pumpApp(tester, settings: null);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // Step 1: language, applied at once.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await _next(tester);

    // Step 2: location.
    expect(find.text('Your location'), findsOneWidget);
    expect(find.text('Thiruvananthapuram'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-location')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thrissur'));
    await tester.pumpAndSettle();
    expect(find.text('Thrissur'), findsOneWidget);

    // Back keeps the choice.
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    await _next(tester);
    expect(find.text('Thrissur'), findsOneWidget);
    await _next(tester);

    // Step 3: what notifications are for; no permission asked here.
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.textContaining('Android asks for permission'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    await _next(tester);

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byKey(const Key('today-date')), findsOneWidget);
    final saved = SettingsStore(prefs).load();
    expect(saved.onboardingDone, isTrue);
    expect(saved.language, AppLanguage.english);
    expect(saved.location, keralaCityById('thrissur')!.location);
  });

  testWidgets('onboarding is in Malayalam when chosen', (tester) async {
    await pumpApp(tester, settings: null);
    await tester.tap(find.text('മലയാളം'));
    await tester.pumpAndSettle();
    expect(find.text('സ്വാഗതം'), findsOneWidget);
    await _next(tester);
    expect(find.text('തിരുവനന്തപുരം'), findsOneWidget);
  });

  testWidgets('a finished onboarding is not shown again', (tester) async {
    await pumpApp(tester, settings: enSettings);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('a deep link opens after onboarding', (tester) async {
    await pumpApp(tester, settings: null);
    GoRouter.of(tester.element(find.byType(OnboardingScreen)))
        .go('/day/2026-11-08');
    await tester.pumpAndSettle();
    final screen =
        tester.widget<OnboardingScreen>(find.byType(OnboardingScreen));
    expect(screen.from, '/day/2026-11-08');
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await _next(tester);
    }
    expect(tester.widget<DayScreen>(find.byType(DayScreen)).date,
        DateTime(2026, 11, 8));
  });

  testWidgets('an outside URL in from is ignored', (tester) async {
    await pumpApp(tester, settings: null);
    GoRouter.of(tester.element(find.byType(OnboardingScreen)))
        .go('/onboarding?from=//evil.example/x');
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await _next(tester);
    }
    expect(find.byKey(const Key('today-date')), findsOneWidget);
  });
}
