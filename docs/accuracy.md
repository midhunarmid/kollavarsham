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
| Onam (Thiruvonam) | Thiruvonam at sunrise in Chingam; the later day if it occurs twice | 2009–2025 except 2016 |
| Attukal Pongala | Pooram at sunset in Kumbham; the later occurrence | 2015–2025 |
| Thrissur Pooram | Pooram at midnight in Medam; the later occurrence | 2016–2025 |
| Karkidaka Vavu | Amavasya at the end of the afternoon (⅘ of daytime) in Karkidakam, else at sunrise; the first if there are two | 2015–2025 |

Known ambiguities: Onam 2016 is given as 13 September by some panchangs and 14 September by the press (the package gives the 14th). Thrissur Pooram 2015 is listed as both 28 and 29 April. Dhanu Thiruvathira is not included yet because published dates disagree on the rule.

## Range

Years ME 1–2000 (825–2825 CE) are supported. Accuracy is best between 1900 and 2100. Outside it, ΔT is extrapolated and its uncertainty grows to many minutes within a few centuries, so borderline month starts become unreliable.
