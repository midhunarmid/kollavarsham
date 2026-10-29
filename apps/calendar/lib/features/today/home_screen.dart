import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import '../../l10n/app_localizations.dart';

/// Home screen: today's Malayalam date and a month calendar.
class HomeScreen extends StatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        title: Text(l10n.appTitle),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.todayHeading,
                          style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      MalayalamDateText(
                        key: const Key('today-date'),
                        date: _today,
                        pattern: 'EEEE, d MMMM y',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        MaterialLocalizations.of(context)
                            .formatFullDate(_today.toGregorian()),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        _today.nakshatra.name(script),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
