import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kollavarsham',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MalayalamDate _selected = MalayalamDate.today();
  MalayalamScript _script = MalayalamScript.malayalam;
  bool _malayalamDigits = false;

  @override
  Widget build(BuildContext context) {
    final cal = KollavarshamCalendar.standard;
    final year = _selected.year;
    String fmt(MalayalamDate d) =>
        '${d.format('d MMMM y', script: _script)}  ·  '
        '${d.toGregorian().toIso8601String().split('T').first}';

    return Scaffold(
      appBar: AppBar(
        title: const MalayalamDateText(
          pattern: 'EEEE, d MMMM y',
          script: MalayalamScript.malayalam,
        ),
        actions: [
          IconButton(
            tooltip: 'Pick a date',
            icon: const Icon(Icons.event),
            onPressed: () async {
              final picked = await showMalayalamDatePicker(
                context: context,
                initialDate: _selected,
                script: _script,
                malayalamDigits: _malayalamDigits,
              );
              if (picked != null) setState(() => _selected = picked);
            },
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
                children: [
                  ChoiceChip(
                    label: const Text('മലയാളം'),
                    selected: _script == MalayalamScript.malayalam,
                    onSelected: (_) =>
                        setState(() => _script = MalayalamScript.malayalam),
                  ),
                  ChoiceChip(
                    label: const Text('English'),
                    selected: _script == MalayalamScript.english,
                    onSelected: (_) =>
                        setState(() => _script = MalayalamScript.english),
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
                key: ValueKey((_selected.year, _selected.month)),
                selectedDate: _selected,
                script: _script,
                malayalamDigits: _malayalamDigits,
                showNakshatra: true,
                onDateSelected: (d) => setState(() => _selected = d),
              ),
              const Divider(height: 32),
              Text(
                _selected.format('EEEE, d MMMM y', script: _script),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('Nakshatra: ${_selected.nakshatra.name(_script)}'),
              Text(
                  'Tithi: ${_selected.format('TTTT (PPPP)', script: _script)}'),
              const Divider(height: 32),
              Text('Festivals', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                  title: const Text('Onam (Thiruvonam)'),
                  subtitle: Text(fmt(cal.onam(year)))),
              ListTile(
                  title: const Text('Mandala Kalam'),
                  subtitle: Text(fmt(cal.mandalaKalamStart(year)))),
              ListTile(
                  title: const Text('Makaravilakku'),
                  subtitle: Text(fmt(cal.makaravilakku(year)))),
              ListTile(
                  title: const Text('Vishu'),
                  subtitle: Text(fmt(cal.vishu(year)))),
            ],
          ),
        ),
      ),
    );
  }
}
