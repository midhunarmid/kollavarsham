# kollavarsham_flutter

Flutter widgets for the Malayalam calendar (Kollavarsham), built on [`kollavarsham`](https://github.com/midhunarmid/kollavarsham/tree/main/packages/kollavarsham).

- **`MalayalamMonthView`:** a Malayalam month shown as a week grid. Each cell gives the Malayalam day, the Gregorian day and, optionally, the nakshatra. It supports a selected date, date bounds and custom day cells.
- **`showMalayalamDatePicker`:** a date-picker dialog that returns a `MalayalamDate`.
- **`MalayalamDateText`:** a `Text` widget that formats a Malayalam date (today's by default).

Names appear in Malayalam script when the app's locale is `ml` and in transliteration otherwise. Pass `script:` to override this.

```dart
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

MalayalamMonthView(
  selectedDate: selected,
  showNakshatra: true,
  onDateSelected: (date) => setState(() => selected = date),
);

final picked = await showMalayalamDatePicker(
  context: context,
  initialDate: MalayalamDate.today(),
  script: MalayalamScript.malayalam,
);

const MalayalamDateText(pattern: 'EEEE, d MMMM y');
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
