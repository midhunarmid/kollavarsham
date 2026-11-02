import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../l10n/app_localizations.dart';

/// Calendar tab: a month view and the selected day's festivals.
class CalendarScreen extends StatefulWidget {
  /// Creates the Calendar screen.
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _controller = MalayalamMonthViewController();
  final _today = MalayalamDate.today();
  late MalayalamDate _selected = _today;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToToday() {
    setState(() => _selected = _today);
    _controller.jumpTo(_today);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final script = resolveScript(context, null);
    final festivals = KollavarshamCalendar.standard.festivalsOn(_selected);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCalendar),
        actions: [
          IconButton(
            tooltip: l10n.today,
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              MalayalamMonthView(
                controller: _controller,
                initialMonth: _selected,
                selectedDate: _selected,
                showNakshatra: true,
                eventLoader: festivalEventLoader(),
                onDateSelected: (d) => setState(() => _selected = d),
              ),
              const Divider(height: 32),
              MalayalamDateText(
                date: _selected,
                pattern: 'EEEE, d MMMM y',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(l10n.festivals, style: theme.textTheme.labelLarge),
              if (festivals.isEmpty)
                Text(l10n.noFestivals)
              else
                for (final f in festivals) Text(f.name(script)),
            ],
          ),
        ),
      ),
    );
  }
}
