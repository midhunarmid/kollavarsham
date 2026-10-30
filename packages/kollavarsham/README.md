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
- **Formatting and parsing** with patterns, optionally using Malayalam digits (൧൨൦൧). Parsing accepts both scripts and common spelling variants.
- **Panchanga:** the nakshatra, tithi, yoga and karana of any day (taken at sunrise) or any moment, with their start and end times; Rahu kalam, Gulika kalam and Yamagandam; moonrise and moonset; Chandrashtamam.
- **Festivals:** Onam (Thiruvonam), Atham, Vishu, Attukal Pongala, Thrissur Pooram, Karkidaka Vavu, the Mandala season, Mandala Pooja, Makaravilakku and more, individually or as a list for a year.
- **Birth details:** the nakshatra with pada, rashi, tithi and Malayalam date of any moment of birth.
- **Recurring dates:** star birthdays (pirannal), monthly nakshatram, shraddham by tithi, every Ekadashi and other vrat-style days, Malayalam and Gregorian anniversaries, with rules for doubled and missing days.
- **North Malabar years:** `YearStart.kanni` numbers years from Kanni instead of Chingam.
- **Configurable location:** sunrise and sunset are computed for Thiruvananthapuram in IST by default. Kochi and Kozhikode are built in, and you can supply any location.

### Format tokens

| Token | Meaning | Example |
|---|---|---|
| `y` | year | 1201 |
| `M` / `MM` | month number | 1 / 01 |
| `MMM` | short month name | Chi |
| `MMMM` | month name | ചിങ്ങം |
| `d` / `dd` | day | 7 / 07 |
| `E` | short weekday | ഞാ / Sun |
| `EEEE` | weekday | ഞായർ |
| `G` / `GGGG` | era | കൊ.വ. / കൊല്ലവർഷം |
| `NNNN` | nakshatra | തിരുവോണം |
| `TTTT` | tithi | ഏകാദശി |
| `PPPP` | paksha | വെളുത്ത പക്ഷം |

Wrap literal text in single quotes, e.g. `"d MMMM 'ME' y"`.

### Parsing

```dart
MalayalamDate.parse('1 ചിങ്ങം 1201'); // 1201 Chingam 1
MalayalamDate.parse('Karkkidakam 3, 1200', pattern: 'MMMM d, y');
MalayalamDate.tryParse('൧ ചിങ്ങം ൧൨൦൧'); // Malayalam digits work too
```

Month names match in either script, ignoring case and accepting common variants (Karkkidakam, കർക്കിടകം, Vrishchikam…).

### Panchanga and festivals

```dart
final cal = KollavarshamCalendar.standard;

cal.onam(1201); // 1201 Chingam 20 (2025-09-05)
cal.nakshatraOn(DateTime(2025, 9, 5)); // Nakshatra.thiruvonam
cal.tithiAt(DateTime.now());
cal.nakshatraSpanAt(DateTime.now()); // start and end of the current star

// Malayalam birthday: the Avittam day in Kanni 1202.
cal.daysWithNakshatra(1202, MalayalamMonth.kanni, Nakshatra.avittam);

// Every festival of a year, in order.
for (final (festival, date) in cal.festivalsIn(1201)) {
  print('${festival.malayalam}: ${date.toGregorian()}');
}
```

| Festival | Rule | Checked against |
|---|---|---|
| Onam | Thiruvonam at sunrise in Chingam (the later one if it occurs twice) | 2009–2025 |
| Attukal Pongala | Pooram at sunset in Kumbham (later occurrence) | 2015–2025 |
| Thrissur Pooram | Pooram at midnight in Medam (later occurrence) | 2016–2025 |
| Karkidaka Vavu | Amavasya at the end of the afternoon in Karkidakam, else at sunrise | 2015–2025 |

### Daily panchangam

```dart
final cal = KollavarshamCalendar.standard;
final day = DateTime(2025, 1, 15);

cal.yogaOn(day); // Yoga.priti
cal.karanaOn(day); // Karana.taitila
cal.yogaSpanAt(cal.sunrise(day)!).end; // when that yoga ends (UTC)

cal.kalamOn(day, Kalam.rahu); // 12:32–13:59 IST, as a span in UTC
cal.moonrise(day); // 14:21 UTC, or null if the Moon doesn't rise that day

// Chandrashtamam: the Moon in the eighth rashi from the birth rashi.
cal.chandrashtamam(
  Nakshatra.karthika.rashiOf(1), // Mesha; padas 2-4 are in Vrishabha
  DateTime.utc(2026),
  DateTime.utc(2027),
);
```

The kalams are eighths of the daytime, so they need a sunrise and sunset; `kalamOn` returns `null` where there are none. Times follow the published convention: the Moon rises when its centre reaches the true horizon, without refraction.

### Birth details

```dart
// A clock time at the calendar's location, whatever the device's time zone.
final birth = BirthDetails.fromLocalTime(DateTime(1950, 9, 17, 11));
birth.nakshatra; // Nakshatra.anizham
birth.pada; // 2
birth.rashi; // Rashi.vrischika
birth.date; // 1126 Kanni 1

// An exact moment.
BirthDetails.fromInstant(DateTime.utc(2025, 9, 4, 19));
```

`date` is the civil day at the calendar's location, so a birth after midnight and before sunrise has the new day's date.

### Recurring dates

A `Recurrence` gives the occurrences in a range and the next one. Recurrences compare by value and convert to and from JSON.

```dart
// A pirannal: Pooradam in Dhanu each year.
const pirannal = NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu);
pirannal.next(DateTime.now());

// A nakshatram: every Pooradam, about every 27 days.
const NakshatraMonthly(Nakshatra.pooradam)
    .occurrencesBetween(DateTime(2027), DateTime(2027, 12, 31));

// A shraddham: waning Ekadashi in Karkidakam each year.
TithiInMonth(Tithi(26), MalayalamMonth.karkidakam);

// Every Ekadashi, or every waxing Shashti.
const TithiEveryPaksha(11);
const TithiEveryPaksha(6, paksha: Paksha.shukla);

// Anniversaries.
const MalayalamDateYearly(MalayalamMonth.thulam, 12);
const MalayalamDateMonthly(1);
const GregorianYearly(2, 29);

final json = pirannal.toJson();
Recurrence.fromJson(json); // == pirannal
```

| Recurrence | A day counts when | Doubled | Missing |
|---|---|---|---|
| `NakshatraInMonth` | the star is present 6 nazhika after sunrise | later day (`DuplicateRule`) | last such day of the previous month (`AbsentRule`) |
| `NakshatraMonthly` | as above | every such day | the earlier of the two days around it |
| `TithiInMonth` | the tithi covers more of that day's afternoon | later day (`DuplicateRule`) | last such day of the previous month (`AbsentRule`) |
| `TithiEveryPaksha` | the tithi is present at sunrise | the first day | the earlier of the two days around it |

These rules differ between families and almanacs. They are drafts, explained with their sources in [`docs/pirannal-rules.md`](https://github.com/midhunarmid/kollavarsham/blob/main/docs/pirannal-rules.md), and pirannal dates haven't been checked against a printed almanac yet.

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
- The year starts with Chingam, as in Travancore and Kochi, unless you pass `yearStart: YearStart.kanni`.
- Two `MalayalamDate`s are equal when they denote the same day in equivalent calendars (same location, year convention and overrides). `isAtSameDayAs` compares days only.
- In both verified borderline cases so far (2021 and 2023), almanacs started the month on the sankranti day even though it fell a few minutes after the computed cut-off. If you find another, please open an issue with the source.

## Flutter

For calendar widgets and a date picker, see [`kollavarsham_flutter`](https://github.com/midhunarmid/kollavarsham/tree/main/packages/kollavarsham_flutter).

## License

MIT
