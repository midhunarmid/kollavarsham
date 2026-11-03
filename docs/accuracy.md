# How dates are computed, and how accurate they are

## The rule

A Malayalam month begins at the **sankranti**, the moment the Sun's sidereal (nirayana) longitude crosses a multiple of 30°. Kerala then applies a cut-off: if the sankranti falls within the first **three-fifths of the daytime** (sunrise to sunset), that day is day 1 of the month. Otherwise day 1 is the next day.

The year begins at Chingam 1 (Simha sankranti), or at Kanni 1 with `YearStart.kanni` (North Malabar), and Kollavarsham year = Gregorian year − 824 from Chingam until December.

## The astronomy

| Quantity | Method | Accuracy |
|---|---|---|
| Sun's longitude | Truncated VSOP87 (Meeus, *Astronomical Algorithms* ch. 32), plus nutation and aberration | ≈ 1″ (about 1 second of time) |
| Ayanamsa | Lahiri, calibrated to published Kerala panchangams | see below |
| ΔT (Earth's rotation) | Yearly table 1900–2100: IERS observed values, then the Stephenson–Morrison–Hohenkerk (2016) extrapolation; polynomials outside that range | a few seconds today, ~1 min by 2100 |
| Sunrise and sunset | Upper limb on the horizon, standard refraction (−0.833°) | ≈ 1 min |
| Moon (nakshatra, tithi, yoga, karana) | ELP-2000/82 abridgement (Meeus ch. 47) | ≈ 10″ (about 20 s for a nakshatra change) |
| Moonrise and moonset | Moon's centre on the true horizon, no refraction, from shortened latitude and distance series | ≈ 30 s against drikpanchang |

### Calibration and cross-checks

- **Against published panchangams:** all 20 sankranti moments of 2024–2025 published by drikpanchang.com are reproduced to within one minute. This fixes the ayanamsa convention (apparent solar longitude minus a Lahiri ayanamsa of 23.863092° at J2000.0).
- **Against an independent ephemeris:** every sankranti from 1900 to 2100 (2,412 of them) agrees with the Swiss Ephemeris within one minute, after allowing for the known difference between its "Lahiri" mode and the panchang convention (`test/reference_test.dart`). That validates the solar theory, ΔT and precession over two centuries.
- **Against observed dates:** month starts and festivals are checked against Kerala dates in `test/conversion_test.dart` and `test/panchanga_test.dart`.

## Borderline months

When a sankranti falls within a few minutes of the cut-off, almanacs can disagree with each other and with any computation, because they use slightly different sankranti times, sunrise conventions or locations. Between 1900 and 2100 there are **31 months within 10 minutes** of the cut-off, listed in [`packages/kollavarsham/test/fixtures/borderline_months.csv`](../packages/kollavarsham/test/fixtures/borderline_months.csv).

- `KollavarshamCalendar.monthStartMargin(year, month)` returns how far a month's sankranti was from the cut-off.
- `KollavarshamCalendar.verifiedMonthStarts` overrides the computation where the observed date is known:

| Month | Computed | Observed | Evidence |
|---|---|---|---|
| Vrischikam 1197 | 2021-11-17 (margin −0.7 min) | 2021-11-16 | Mandala Pooja on 2021-12-26 |
| Chingam 1199 | 2023-08-18 (margin −3.7 min) | 2023-08-17 | Kerala New Year observed 2023-08-17 |

In both verified cases the almanac started the month on the sankranti day although the sankranti fell a few minutes *after* the computed cut-off. With more examples this may turn out to be a systematic offset (for instance a different sunrise definition), at which point the rule itself could be adjusted. Please report any borderline month you can source.

You can add your own overrides with `KollavarshamCalendar(monthStartOverrides: {...})`.

## Daily panchangam

| Element | Rule | Verified against drikpanchang.com, Thiruvananthapuram, 30 days of 2025–2026 |
|---|---|---|
| Yoga | Sun's plus Moon's sidereal longitude, in 13°20′ steps | All 30 names; end times 30–89 s later than published |
| Karana | Half a tithi, 6° of elongation | All 30 names; end times 38–96 s later than published |
| Rahu kalam, Gulika kalam, Yamagandam | One eighth of sunrise to sunset, by weekday | Starts and ends within 2 minutes |
| Moonrise, moonset | See the table above | Within 30 s |
| Chandrashtamam | The Moon in the eighth rashi from the birth rashi | The 13 Mesha periods of 2026 (hindupad.com, panchangbodh.com), within 2 minutes |

Rounding of the published minutes explains part of the yoga and karana offset. The rest would equal about 15″ of the Moon's longitude; its cause isn't known, and it isn't corrected. The offset stays under 2 minutes.

Moonrise doesn't use the Sun's convention. The upper limb with refraction gives times 3.7 minutes wider than drikpanchang; the Moon's centre on the true horizon matches it. Printed Kerala almanacs haven't been compared.

Chandrashtamam is defined by rashi in every source found. Some sources also name a star, but disagree on whether it is the 16th or 17th from the birth star, so the package doesn't offer one. A birth star that straddles two rashis needs its pada (`Nakshatra.rashiOf`).

## Festivals

Festivals tied to a nakshatra or tithi depend on the time of day they are observed:

| Festival | Rule | Verified |
|---|---|---|
| Vishu | The first sunrise after the Mesha sankranti (Medam 2 when the sankranti falls between sunrise and the month-start cut-off) | 2021–2026 (news reports and the 2026 Kerala list); fixed on Day 23, before which Vishu was Medam 1 and 2026 was a day early |
| Onam (Thiruvonam) | Thiruvonam at sunrise in Chingam; the later day if it occurs twice | 2009–2025 except 2016 |
| Attukal Pongala | Pooram at sunset in Kumbham; the later occurrence | 2015–2025 |
| Thrissur Pooram | Pooram at midnight in Medam; the later occurrence | 2016–2025 |
| Karkidaka Vavu | Amavasya at the end of the afternoon (⅘ of daytime) in Karkidakam, else at sunrise; the first if there are two | 2015–2025 |
| Sivaratri | Waning Chathurdashi at midnight, in the lunar month holding Kumbham's sankranti | 2019–2026 (Kerala lists), 2029 |
| Ashtami Rohini | Waning Ashtami at midnight in Chingam; if several nights qualify, the first with Rohini at midnight, else the first; if none, the first night with Rohini | 2021–2025 (Kerala lists) |
| Vinayaka Chathurthi | Waxing Chathurthi at mid-day, in the lunar month holding Kanni's sankranti | 2019–2026 (national lists) |
| Vijayadasami | Waxing Dashami at sunrise, in the lunar month holding Thulam's sankranti | 2019–2026 (Kerala lists) |
| Mahanavami | The day before Vijayadasami | 2019 and 2021–2026 (Kerala lists) |
| Durgashtami | Two days before Vijayadasami | 2019 and 2021–2026 (national lists, Kerala orders for 2024 and 2026) |
| Deepavali | Waning Chathurdashi at dawn (96 minutes before sunrise), in the lunar month holding Thulam's sankranti | 2019–2026 (Kerala lists) |
| Guruvayur Ekadashi | First waxing Ekadashi at sunrise from Vrischikam 1 | 2019–2025 |
| Thaipooyam | The day with Pooyam at sunrise or sunset nearest the first full moon after Makaram's sankranti | 2020–2027 (Tamil Nadu and Malaysian lists) |

A lunar month here runs from new moon to new moon and takes its name from the sankranti inside it. So Sivaratri can fall in Makaram (11 February 2029), although the sankranti is that of Kumbham.

"Kerala lists" are the state's yearly public holiday orders, which carry a note that moon-dependent dates can change. All the sources are in the comments of `test/panchanga_test.dart`.

Known ambiguities: Onam 2016 is given as 13 September by some panchangs and 14 September by the press (the package gives the 14th). Thrissur Pooram 2015 is listed as both 28 and 29 April.

- **Navaratri 2020:** Kerala's list gives Mahanavami on 24 October and Vijayadasami on the 26th. The package gives the 25th for Mahanavami, so 2020 isn't in the Mahanavami and Durgashtami tests.
- **Ashtami Rohini:** the rule was fitted to five years of Kerala lists and isn't simple. Dates computed before 2021 aren't checked. Drikpanchang gives 29 August 2021, a day before Kerala's list.
- **Guruvayur Ekadashi:** sources differ by a day in 2019 (7 or 8 December) and 2022 (3 or 4 December). The package gives 8 December 2019 and 3 December 2022, the days with Ekadashi at sunrise.
- **Thaipooyam:** no Kerala list was found, and the rule misses at least one year. It gives 10 February 2017 where lists from Tamil Nadu and Malaysia give the 9th.
- **Vinayaka Chathurthi:** Kerala's lists don't include it, and some national sources differ by a day in several years.

**Dhanu Thiruvathira is left out.** The sources found disagree: 19 or 20 December 2021, 26 or 27 December 2023, and 2 or 3 January 2026. Only 2023 (6 January), 2025 (13 January) and 2026 have a Kerala date, which is short of the five years a festival needs.

## Vrat days

| Vrat | Rule | Verified |
|---|---|---|
| Ekadashi | Lunar day 11 at sunrise, each fortnight | Drikpanchang, New Delhi, 2025: 24 of 25 days |
| Pradosham | Lunar day 13, 72 minutes after sunset, each fortnight | Drikpanchang, New Delhi, 2025: all 24 days. A Tamil Nadu list for 2026 at Thiruvananthapuram: 23 of 25 |
| Shashti | Waxing lunar day 6 at sunset | Drikpanchang, New Delhi, 2025: all 13 days |
| Pournami | Full moon at mid-day | Drikpanchang, New Delhi, 2025: all 12 fasting days |
| Amavasya | New moon at sunrise | Drikpanchang, New Delhi, 2025: all 12 days, taking the later date where the page lists two |

The reading times were chosen to fit these lists, not taken from a Kerala source, and no Kerala vrat list was found. The Ekadashi difference is 2025-11-02, where the package gives the sunrise day and drikpanchang's Smarta list gives the 1st. Its Vaishnava list gives the 2nd. The 2026 Pradosham differences are 28 February and 28 April, a day before the list.

## Christian and Muslim days

Easter uses the Gregorian computus, the date Western and most Kerala churches keep. It matches Kerala's holiday lists for 2019–2025, along with Good Friday. Palm Sunday and Maundy Thursday are counted back from Easter.

Hijri dates come from the tabular calendar (civil epoch, leap years 2, 5, 7, 10, 13, 16, 18, 21, 24, 26 and 29 of each 30-year cycle). It is arithmetic, while the real dates follow the moon, so these are marked tentative and announced dates replace them. Eid ul-Fitr, Bakrid and Milad-i-Sherif for 2019–2025, and Muharram for 2021–2025, are within two days of Kerala's lists. Those lists were published ahead of the sighting, so they aren't the observed dates either.

## Range

Years ME 1–2000 (825–2825 CE) are supported. Accuracy is best between 1900 and 2100. Outside it, ΔT is extrapolated and its uncertainty grows to many minutes within a few centuries, so borderline month starts become unreliable.
