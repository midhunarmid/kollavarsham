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
