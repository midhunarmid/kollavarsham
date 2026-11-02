import 'package:go_router/go_router.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/people/people_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../features/tools/tools_screen.dart';
import 'shell.dart';

/// Paths of the bottom-bar tabs, in bar order.
abstract final class AppRoutes {
  /// Today (home).
  static const today = '/today';

  /// Month calendar.
  static const calendar = '/calendar';

  /// People and their events.
  static const people = '/people';

  /// Converter and other tools.
  static const tools = '/tools';

  /// Settings.
  static const settings = '/settings';

  /// First-run onboarding (outside the tabs).
  static const onboarding = '/onboarding';
}

GoRoute _tab(String path, GoRouterWidgetBuilder builder) =>
    GoRoute(path: path, builder: builder);

/// Creates the app's router: five tabs under a bottom navigation bar, and
/// the onboarding flow while [needsOnboarding] returns true.
GoRouter createRouter({required bool Function() needsOnboarding}) => GoRouter(
      initialLocation: AppRoutes.today,
      redirect: (context, state) {
        final onboarding = state.matchedLocation == AppRoutes.onboarding;
        if (needsOnboarding()) return onboarding ? null : AppRoutes.onboarding;
        return onboarding ? AppRoutes.today : null;
      },
      routes: [
        GoRoute(path: '/', redirect: (_, __) => AppRoutes.today),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              _tab(AppRoutes.today, (_, __) => const TodayScreen()),
            ]),
            StatefulShellBranch(routes: [
              _tab(AppRoutes.calendar, (_, __) => const CalendarScreen()),
            ]),
            StatefulShellBranch(routes: [
              _tab(AppRoutes.people, (_, __) => const PeopleScreen()),
            ]),
            StatefulShellBranch(routes: [
              _tab(AppRoutes.tools, (_, __) => const ToolsScreen()),
            ]),
            StatefulShellBranch(routes: [
              _tab(AppRoutes.settings, (_, __) => const SettingsScreen()),
            ]),
          ],
        ),
      ],
    );
