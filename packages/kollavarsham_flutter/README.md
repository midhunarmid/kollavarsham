# kollavarsham_flutter

Flutter widgets for the Malayalam calendar (Kollavarsham), built on [`kollavarsham`](https://github.com/midhunarmid/kollavarsham/tree/main/packages/kollavarsham).

| Malayalam months | Gregorian months with festival markers |
|---|---|
| ![Malayalam month view](https://raw.githubusercontent.com/midhunarmid/kollavarsham/main/packages/kollavarsham_flutter/doc/screenshots/malayalam_mode.png) | ![Gregorian month view](https://raw.githubusercontent.com/midhunarmid/kollavarsham/main/packages/kollavarsham_flutter/doc/screenshots/gregorian_mode.png) |

- **`MalayalamMonthView`:** a month as a week grid, paging through Malayalam months or, with `mode: CalendarMode.gregorian`, Gregorian months in the style of a Kerala wall calendar. Each cell shows the other calendar's date (labelled where its month changes), and optionally the nakshatra and event markers. Swipe or use the arrows to change month, or tap the header to jump to any month and year.
- **`MalayalamMonthViewController`:** reads and changes the displayed month (`jumpTo`, `next`, `previous`).
- **`showMalayalamDatePicker`:** a date-picker dialog that returns a `MalayalamDate`.
- **`MalayalamDateText`:** a `Text` widget that formats a Malayalam date (today's by default).
- **`KollavarshamCalendarTheme`:** a `ThemeExtension` for the calendar's colours and cell shape.

Names appear in Malayalam script when the app's locale is `ml` and in transliteration otherwise. Pass `script:` to override this. Cells scale their text down to fit, so large accessibility text sizes don't overflow.

```dart
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

MalayalamMonthView(
  mode: CalendarMode.gregorian,
  selectedDate: selected,
  showNakshatra: true,
  eventLoader: festivalEventLoader(), // marks Onam, Vishu, …
  onDateSelected: (date) => setState(() => selected = date),
);

final picked = await showMalayalamDatePicker(
  context: context,
  initialDate: MalayalamDate.today(),
  script: MalayalamScript.malayalam,
);

const MalayalamDateText(pattern: 'EEEE, d MMMM y');
```

### Theming

```dart
ThemeData(
  extensions: const [
    KollavarshamCalendarTheme(
      holidayColor: Colors.deepOrange,
      markerColor: Colors.amber,
    ),
  ],
)
```

Values you leave out fall back to the app's `ColorScheme`, so the calendar follows light and dark themes automatically.

### Your own events

`eventLoader` can return anything: festivals, birthdays or appointments. Use `markerBuilder` to draw them your own way.

```dart
MalayalamMonthView(
  eventLoader: (date) => myEvents[date] ?? const [],
  markerBuilder: (context, date, events) => Badge(label: Text('${events.length}')),
)
```

This package re-exports `package:kollavarsham/kollavarsham.dart`, so `MalayalamDate`, `Nakshatra`, the festival helpers and the rest are available from the one import.

## Example

`example/` contains a web demo:

```
cd example
flutter run -d chrome
```

## License

MIT
