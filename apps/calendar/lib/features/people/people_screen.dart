import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../placeholder.dart';

/// People tab. The list and editors arrive with the database (Day 9).
class PeopleScreen extends StatelessWidget {
  /// Creates the People screen.
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ComingSoon(
      title: l10n.navPeople,
      icon: Icons.people_outline,
      message: l10n.peopleComingSoon,
    );
  }
}
