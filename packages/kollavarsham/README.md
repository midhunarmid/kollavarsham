# kollavarsham

Malayalam calendar (Kollavarsham / Malayalam Era) for Dart. It converts dates between the Gregorian and Malayalam calendars and gives month and weekday names, nakshatra, tithi and Kerala festival dates. The calculations are pure Dart, need no network access and work on every platform.

```dart
import 'package:kollavarsham/kollavarsham.dart';

final today = MalayalamDate.today();
print(today.format('EEEE, d MMMM y')); // ബുധൻ, 11 തുലാം 1202
print(today.format('d MMMM y', script: MalayalamScript.english)); // 11 Thulam 1202

final chingam1 = DateTime(2025, 8, 17).toMalayalamDate();
print(chingam1); // 1201 Chingam 1

final vishu = MalayalamDate(1201, MalayalamMonth.medam, 1).toGregorian();
print(vishu); // 2026-04-14
```

## Features

- **Conversion** both ways between Gregorian and Kollavarsham dates, plus date arithmetic (`addDays`, `addMonths`, `daysUntil`) and comparison operators.
- **Names** of months, weekdays, nakshatras and tithis, in Malayalam script (ചിങ്ങം) or Latin transliteration (Chingam).
- **Formatting** with patterns, optionally using Malayalam digits (൧൨൦൧).
- **Panchanga:** the nakshatra and tithi of any day (taken at sunrise) or any moment, with their start and end times.
- **Festivals:** Onam (Thiruvonam), Atham, Vishu, the Mandala season, Mandala Pooja and Makaravilakku.
- **Birthdays by star:** `daysWithNakshatra` finds the day(s) in a month that carry a given nakshatra.
- **Configurable location:** sunrise and sunset are computed for Thiruvananthapuram in IST by default. Kochi and Kozhikode are built in, and you can supply any location.

### Format tokens

| Token | Meaning | Example |
|---|---|---|
| `y` | year | 1201 |
| `M` / `MM` | month number | 1 / 01 |
| `MMMM` | month name | ചിങ്ങം |
| `d` / `dd` | day | 7 / 07 |
| `EEEE` | weekday | ഞായർ |
| `NNNN` | nakshatra | തിരുവോണം |
| `TTTT` | tithi | ഏകാദശി |
| `PPPP` | paksha | വെളുത്ത പക്ഷം |

Wrap literal text in single quotes, e.g. `"d MMMM 'ME' y"`.

### Panchanga and festivals

```dart
final cal = KollavarshamCalendar.standard;

cal.onam(1201); // 1201 Chingam 20 (2025-09-05)
cal.nakshatraOn(DateTime(2025, 9, 5)); // Nakshatra.thiruvonam
cal.tithiAt(DateTime.now());
cal.nakshatraSpanAt(DateTime.now()); // start and end of the current star

// Malayalam birthday: the Avittam day in Kanni 1202.
cal.daysWithNakshatra(1202, MalayalamMonth.kanni, Nakshatra.avittam);
```

## How it works

The Malayalam calendar is sidereal and solar. A month begins at the **sankranti**, the moment the Sun's sidereal longitude (Lahiri ayanamsa) crosses a multiple of 30°. Kerala applies this rule:

> If the sankranti falls within the first three-fifths of the daytime (sunrise to sunset), that day is day 1 of the new month. Otherwise the month starts the next day.

As a result, months run 29 to 32 days, and their lengths differ from year to year. The package computes everything from astronomy rather than lookup tables:

- **Sun:** the truncated VSOP87 theory (Meeus, *Astronomical Algorithms*, ch. 32), accurate to about 1″.
- **Moon:** ELP-2000/82 (Meeus ch. 47), accurate to about 10″.
- **Ayanamsa:** Lahiri, calibrated so that computed sankranti moments match published panchangams to within a minute (checked against all 2024–2025 sankrantis).
- **ΔT** (Earth's rotation): yearly IERS values, then the Stephenson–Morrison–Hohenkerk (2016) extrapolation, for 1900–2100.
- **Sunrise and sunset:** apparent upper limb, with refraction.

All 2,412 sankrantis from 1900 to 2100 agree with the Swiss Ephemeris to within one minute (after allowing for the known difference between its Lahiri mode and the panchang convention). Month starts for that range ship as a 3 KB precomputed table, so a conversion takes well under a microsecond.

Supported years are `KollavarshamCalendar.minYear` to `maxYear` (ME 1–2000). Accuracy is best between 1900 and 2100.

### Borderline months

If a sankranti falls within a few minutes of the cut-off, almanacs can disagree about which day starts the month. Between 1900 and 2100 there are 31 such months (within 10 minutes), listed in [`test/fixtures/borderline_months.csv`](test/fixtures/borderline_months.csv). `monthStartMargin(year, month)` tells you how close any month came. Month starts already confirmed against Kerala sources are listed in `KollavarshamCalendar.verifiedMonthStarts`, and you can add your own:

```dart
final cal = KollavarshamCalendar(monthStartOverrides: {
  (1210, MalayalamMonth.kanni): DateTime(2034, 9, 17),
});
```

### Conventions and limits

- The nakshatra and tithi of a day are the ones in effect at sunrise.
- Onam is the day in Chingam whose sunrise nakshatra is Thiruvonam. If that star falls on two days in Chingam, Onam is the later one. This matches every year from 2009 to 2025 except 2016, where sources themselves disagree (13 or 14 September); the package gives the 14th.
- The year starts with Chingam, as in Travancore and Kochi. North Malabar's convention of starting the year in Kanni is not supported yet.
- In both verified borderline cases so far (2021 and 2023), almanacs started the month on the sankranti day even though it fell a few minutes after the computed cut-off. If you find another, please open an issue with the source.

## Flutter

For calendar widgets and a date picker, see [`kollavarsham_flutter`](https://github.com/midhunarmid/kollavarsham/tree/main/packages/kollavarsham_flutter).

## License

MIT
