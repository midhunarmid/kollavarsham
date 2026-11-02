import 'package:go_router/go_router.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/day/day_screen.dart';
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

  /// Day detail, over the tabs; see [dayPath].
  static const day = '/day/:date';

  /// The Day detail path of a Gregorian [date], e.g. `/day/2026-11-02`.
  static String dayPath(DateTime date) => '/day/${_iso(date)}';

  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// The date in a Day detail path parameter, or null if malformed.
  static DateTime? parseDay(String? value) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value ?? '');
    if (m == null) return null;
    final (y, mo, d) = (int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    final date = DateTime(y, mo, d);
    // Reject dates that roll over, like 2026-02-30.
    if (date.month != mo || date.day != d) return null;
    return date;
  }
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
        GoRoute(
          path: AppRoutes.day,
          redirect: (_, state) =>
              AppRoutes.parseDay(state.pathParameters['date']) == null
                  ? AppRoutes.calendar
                  : null,
          builder: (_, state) => DayScreen(
              date: AppRoutes.parseDay(state.pathParameters['date'])!),
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
