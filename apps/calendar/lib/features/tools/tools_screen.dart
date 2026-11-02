import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../placeholder.dart';

/// Tools tab. The converter and calculators arrive on Day 15.
class ToolsScreen extends StatelessWidget {
  /// Creates the Tools screen.
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ComingSoon(
      title: l10n.navTools,
      icon: Icons.handyman_outlined,
      message: l10n.toolsComingSoon,
    );
  }
}
