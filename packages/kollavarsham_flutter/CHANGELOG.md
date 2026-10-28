## 1.0.0

First stable release, requiring `kollavarsham` 1.0.0. The public API is
now covered by semantic versioning.

## 0.4.0

**Breaking**

- `MalayalamMonthView.showGregorian` is now `showSecondaryDate`.

**Added**

- `CalendarMode.gregorian`: page through Gregorian months with Malayalam
  dates, labelling where each Malayalam month begins.
- Swipe between months; tap the header for a month/year chooser.
- `MalayalamMonthViewController` (`jumpTo`, `next`, `previous`,
  `displayedMonth`).
- `eventLoader` / `markerBuilder` for event markers, and
  `festivalEventLoader()` for Kerala festivals.
- `KollavarshamCalendarTheme` theme extension.
- Malayalam tooltips and chooser text; event counts in semantics.
- Cells scale down to fit at large text sizes; the date picker accepts
  `mode`.

## 0.3.0

- Requires `kollavarsham` 0.3.0.

## 0.2.0

- Requires `kollavarsham` 0.2.0 (faster conversions, verified dates).

## 0.1.0-dev

- MalayalamMonthView, showMalayalamDatePicker and MalayalamDateText.
