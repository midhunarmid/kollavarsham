import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData _theme(Brightness brightness) => ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: brightness,
        extensions: const [
          KollavarshamCalendarTheme(holidayColor: Color(0xFFD84315)),
        ],
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kollavarsham',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: _themeMode,
        home: HomePage(
          onToggleTheme: () => setState(() => _themeMode =
              _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
        ),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = MalayalamMonthViewController();
  MalayalamDate _selected = MalayalamDate.today();
  MalayalamScript _script = MalayalamScript.malayalam;
  CalendarMode _mode = CalendarMode.malayalam;
  bool _malayalamDigits = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cal = KollavarshamCalendar.standard;
    final textTheme = Theme.of(context).textTheme;
    final festivalsToday = cal.festivalsOn(_selected);

    return Scaffold(
      appBar: AppBar(
        title: const MalayalamDateText(
          pattern: 'EEEE, d MMMM y',
          script: MalayalamScript.malayalam,
        ),
        actions: [
          IconButton(
            tooltip: 'Today',
            icon: const Icon(Icons.today),
            onPressed: () {
              final today = MalayalamDate.today();
              setState(() => _selected = today);
              _controller.jumpTo(today);
            },
          ),
          IconButton(
            tooltip: 'Pick a date',
            icon: const Icon(Icons.event),
            onPressed: () async {
              final picked = await showMalayalamDatePicker(
                context: context,
                initialDate: _selected,
                script: _script,
                mode: _mode,
                malayalamDigits: _malayalamDigits,
              );
              if (picked != null) {
                setState(() => _selected = picked);
                _controller.jumpTo(picked);
              }
            },
          ),
          IconButton(
            tooltip: 'Light / dark',
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SegmentedButton<CalendarMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: CalendarMode.malayalam, label: Text('കൊ.വ.')),
                      ButtonSegment(
                          value: CalendarMode.gregorian, label: Text('AD')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                  ),
                  SegmentedButton<MalayalamScript>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: MalayalamScript.malayalam,
                          label: Text('മലയാളം')),
                      ButtonSegment(
                          value: MalayalamScript.english,
                          label: Text('English')),
                    ],
                    selected: {_script},
                    onSelectionChanged: (s) =>
                        setState(() => _script = s.first),
                  ),
                  FilterChip(
                    label: const Text('൧൨൩'),
                    selected: _malayalamDigits,
                    onSelected: (v) => setState(() => _malayalamDigits = v),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              MalayalamMonthView(
                mode: _mode,
                controller: _controller,
                initialMonth: _selected,
                selectedDate: _selected,
                script: _script,
                malayalamDigits: _malayalamDigits,
                showNakshatra: true,
                eventLoader: festivalEventLoader(),
                onDateSelected: (d) => setState(() => _selected = d),
              ),
              const Divider(height: 32),
              Text(
                _selected.format('EEEE, d MMMM y', script: _script),
                style: textTheme.titleMedium,
              ),
              Text(_selected.toGregorian().toIso8601String().split('T').first),
              Text('Nakshatra: ${_selected.nakshatra.name(_script)}'),
              Text(
                  'Tithi: ${_selected.format('TTTT (PPPP)', script: _script)}'),
              for (final f in festivalsToday)
                Text('★ ${f.name(_script)}',
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              const Divider(height: 32),
              Text('Festivals ${_selected.year}', style: textTheme.titleMedium),
              for (final (festival, date) in cal.festivalsIn(_selected.year))
                ListTile(
                  dense: true,
                  title: Text(festival.name(_script)),
                  subtitle: Text(
                      '${date.format('d MMMM y', script: _script)}  ·  '
                      '${date.toGregorian().toIso8601String().split('T').first}'),
                  onTap: () {
                    setState(() => _selected = date);
                    _controller.jumpTo(date);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
