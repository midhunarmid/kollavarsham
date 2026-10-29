import 'package:go_router/go_router.dart';

import '../features/today/home_screen.dart';

/// Creates the app's router.
GoRouter createRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      ],
    );
