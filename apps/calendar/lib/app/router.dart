import 'package:go_router/go_router.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../features/agenda/agenda_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/calendar/year_screen.dart';
import '../data/models.dart';
import '../features/day/day_screen.dart';
import '../features/events/event_editor.dart';
import '../features/events/find_star_screen.dart';
import '../features/festival/festival_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/people/people_screen.dart';
import '../features/people/person_editor.dart';
import '../features/people/person_screen.dart';
import '../features/settings/reminders_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../features/tools/tool_screens.dart';
import '../features/tools/tools_screen.dart';
import 'shell.dart';

/// Paths of the bottom-bar tabs, in bar order.
abstract final class AppRoutes {
  /// Today (home).
  static const today = '/today';

  /// Month calendar.
  static const calendar = '/calendar';

  /// Year view, under the Calendar tab; pops with the month tapped.
  static const year = '/calendar/year';

  /// Agenda, under the Calendar tab.
  static const agenda = '/calendar/agenda';

  /// People and their events.
  static const people = '/people';

  /// Converter and other tools.
  static const tools = '/tools';

  /// Settings.
  static const settings = '/settings';

  /// Tools → Date converter.
  static const converter = '/tools/converter';

  /// Tools → Age calculator.
  static const age = '/tools/age';

  /// Tools → Days between dates.
  static const between = '/tools/between';

  /// Tools → Kollavarsham year.
  static const yearInfo = '/tools/year';

  /// Settings → Reminders.
  static const reminders = '/settings/reminders';

  /// First-run onboarding (outside the tabs).
  static const onboarding = '/onboarding';

  /// Day detail, over the tabs; see [dayPath].
  static const day = '/day/:date';

  /// The Day detail path of a Gregorian [date], e.g. `/day/2026-11-02`.
  static String dayPath(DateTime date) => '/day/${_iso(date)}';

  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Person editor for a new person.
  static const newPerson = '/person/new';

  /// Person detail; see [personPath].
  static const person = '/person/:id';

  /// The detail path of the person with [id].
  static String personPath(int id) => '/person/$id';

  /// The editor path of the person with [id].
  static String editPersonPath(int id) => '/person/$id/edit';

  /// Event editor for a new event; see [newEventPath].
  static const newEvent = '/event/new';

  /// The editor of a new event, optionally for a person and of a type.
  static String newEventPath({int? personId, EventType? type}) =>
      Uri(path: newEvent, queryParameters: {
        if (personId != null) 'person': '$personId',
        if (type != null) 'type': type.name,
      }).toString();

  /// Event editor of a saved event; see [editEventPath].
  static const editEvent = '/event/:id/edit';

  /// The editor path of the event with [id].
  static String editEventPath(int id) => '/event/$id/edit';

  /// Festival detail; see [festivalPath].
  static const festival = '/festival/:id';

  /// The detail path of festival [id], showing its day on [date] if given.
  static String festivalPath(String id, [DateTime? date]) => Uri(
        path: '/festival/$id',
        queryParameters: date == null ? null : {'date': _iso(date)},
      ).toString();

  /// "Find my star"; pops with the BirthDetails taken.
  static const findStar = '/find-star';

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
        GoRoute(
          path: AppRoutes.newEvent,
          builder: (_, state) {
            final q = state.uri.queryParameters;
            return EventEditor(
              personId: int.tryParse(q['person'] ?? ''),
              type: EventType.values.asNameMap()[q['type']],
            );
          },
        ),
        GoRoute(
          path: AppRoutes.editEvent,
          redirect: (_, state) =>
              int.tryParse(state.pathParameters['id']!) == null
                  ? AppRoutes.people
                  : null,
          builder: (_, state) =>
              EventEditor(eventId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: AppRoutes.festival,
          builder: (_, state) => FestivalScreen(
            id: state.pathParameters['id']!,
            date: AppRoutes.parseDay(state.uri.queryParameters['date']),
          ),
        ),
        GoRoute(
          path: AppRoutes.findStar,
          builder: (_, __) => const FindStarScreen(),
        ),
        GoRoute(
          path: AppRoutes.newPerson,
          builder: (_, __) => const PersonEditor(),
        ),
        GoRoute(
          path: AppRoutes.person,
          redirect: (_, state) =>
              int.tryParse(state.pathParameters['id']!) == null
                  ? AppRoutes.people
                  : null,
          builder: (_, state) =>
              PersonScreen(personId: int.parse(state.pathParameters['id']!)),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, state) => PersonEditor(
                  personId: int.parse(state.pathParameters['id']!)),
            ),
          ],
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              _tab(AppRoutes.today, (_, __) => const TodayScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (_, __) => const CalendarScreen(),
                routes: [
                  GoRoute(
                    path: 'agenda',
                    builder: (_, __) => const AgendaScreen(),
                  ),
                  GoRoute(
                    path: 'year',
                    builder: (_, state) => YearScreen(
                        initial: state.extra is MalayalamDate
                            ? state.extra! as MalayalamDate
                            : null),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              _tab(AppRoutes.people, (_, __) => const PeopleScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.tools,
                builder: (_, __) => const ToolsScreen(),
                routes: [
                  GoRoute(
                      path: 'converter',
                      builder: (_, __) => const ConverterScreen()),
                  GoRoute(path: 'age', builder: (_, __) => const AgeScreen()),
                  GoRoute(
                      path: 'between',
                      builder: (_, __) => const BetweenScreen()),
                  GoRoute(
                      path: 'year', builder: (_, __) => const YearInfoScreen()),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (_, __) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'reminders',
                    builder: (_, __) => const RemindersScreen(),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ],
    );
