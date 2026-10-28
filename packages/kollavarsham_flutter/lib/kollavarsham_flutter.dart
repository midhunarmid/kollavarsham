/// Flutter widgets for the Malayalam calendar (Kollavarsham).
///
/// Re-exports `package:kollavarsham/kollavarsham.dart`.
library;

export 'package:kollavarsham/kollavarsham.dart';

export 'src/date_picker.dart' show showMalayalamDatePicker;
export 'src/date_text.dart' show MalayalamDateText;
export 'src/month_view.dart'
    show
        CalendarMode,
        MalayalamDayBuilder,
        MalayalamDayState,
        MalayalamMarkerBuilder,
        MalayalamMonthView,
        MalayalamMonthViewController,
        festivalEventLoader;
export 'src/script.dart' show resolveScript;
export 'src/theme.dart'
    show KollavarshamCalendarTheme, ResolvedKollavarshamCalendarTheme;
