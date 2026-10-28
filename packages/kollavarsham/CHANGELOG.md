## 1.0.0

First stable release. The public API is now covered by semantic
versioning.

- `KollavarshamCalendar.verifiedMonthStarts` is unmodifiable.
- Tests run on the web (Chrome) as well as the VM.

Changes since 0.1.0, in summary:

- Gregorian ↔ Kollavarsham conversion, cross-checked against the Swiss
  Ephemeris for every month 1900–2100 and backed by a precomputed table.
- Verified month starts for borderline months, with `monthStartMargin`.
- `MalayalamDate` formatting and parsing in Malayalam script and
  transliteration, with Malayalam digits.
- Nakshatra and tithi, with start and end times.
- Kerala festivals: Onam, Vishu, Attukal Pongala, Thrissur Pooram,
  Karkidaka Vavu, Mandala season and more.
- North Malabar year numbering (`YearStart.kanni`).

## 0.3.0

**Breaking**

- `MalayalamDate.internal` and `KollavarshamCalendar.dayNumberOf`,
  `fromDayNumber`, `dateOfDayNumber` and `dayNumberOfGregorian` are now
  `@internal`.
- `MalayalamDate ==` compares calendars by value (location, year
  convention, overrides) instead of identity.

**Added**

- `MalayalamDate.parse` / `tryParse`, `MalayalamMonth.tryParseName`.
- Format tokens `MMM`, `E`, `G` and `GGGG`.
- `YearStart.kanni` for North Malabar year numbering.
- `ObserverLocation` and `KollavarshamCalendar` value equality.
- Festivals: Attukal Pongala, Thrissur Pooram, Karkidaka Vavu;
  `KeralaFestival`, `festivalsIn(year)` and `festivalsOn(date)`.
- Every public member is documented.

## 0.2.0

- Solar theory cross-checked against the Swiss Ephemeris for every
  sankranti 1900–2100 (all within one minute).
- ΔT now comes from a yearly table (IERS observed values, then the
  Stephenson–Morrison–Hohenkerk 2016 extrapolation) for 1900–2100.
- Precomputed month-start table for ME 1075–1276: conversions for the
  default location take well under a microsecond. Disable with
  `KollavarshamCalendar(usePrecomputedTable: false)`.
- Verified month start: Vrischikam 1197 began on 2021-11-16.
- Borderline-month audit (`tool/borderline_audit.dart`) and its list in
  `test/fixtures/borderline_months.csv`.
- Supported range is now explicit: `KollavarshamCalendar.minYear` (1) to
  `maxYear` (2000); dates outside throw a `RangeError`.
- Internal caches are bounded.

## 0.1.0-dev

- Gregorian ↔ Kollavarsham conversion using the Kerala sankranti rule
  (VSOP87 Sun, Lahiri ayanamsa, location-aware sunrise and sunset).
- `MalayalamDate` with arithmetic, comparison, formatting and a
  `DateTime.toMalayalamDate()` extension.
- Month, weekday, nakshatra and tithi names in Malayalam script and
  transliteration; Malayalam digit helpers.
- Nakshatra and tithi at sunrise or any instant, with start and end times.
- Festival dates: Onam, Atham, Vishu, Mandala season, Mandala Pooja and
  Makaravilakku.
- Verified month-start overrides and `monthStartMargin` for borderline months.
