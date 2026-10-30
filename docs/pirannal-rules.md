# Pirannal and shraddham rules

Status: **draft for owner review** (Needs you, see [progress.md](progress.md)). This document picks a default for each rare case, explains why, and lists what the owner must confirm. The defaults are what `DuplicateRule` (Day 3) will use until the owner changes them.

Terms used below:

- **Pirannal (star birthday):** the Malayalam month and birth nakshatra (star) of a person. The app's yearly event is the day in the birth Malayalam month when that star falls.
- **Nakshatram:** each day the birth star recurs (about every 27.3 days). This is the monthly event.
- **Nazhika:** a Kerala time unit, about 24 minutes ([sourcelibrary.org](https://sourcelibrary.org/book/699069002f82e0fda480401e/page-number/28)). 6 nazhika is about 2 hours 24 minutes.

## Sources

Most sources below are blogs, almanac sites and news pages. None is a primary Sanskrit or Kerala text. Each rule is marked with how strong its support is.

| Ref | Source | Used for |
|---|---|---|
| S1 | Janma Nakshatra blog, [tuningmymelody.blogspot.com](https://tuningmymelody.blogspot.com/2019/04/the-reasoning-behind-janma-nakshatra.html) | Second occurrence in a solar month counts (example: Revathi on 15 April and 12 May, the 12 May one is used) |
| S2 | On Being essay, [onbeing.org/?p=1337341](https://onbeing.org/?p=1337341) | Second occurrence celebrates the star birthday; no fixed doctrine on its significance |
| S3 | Obidos Tech Malayalam calendar, [obidostech.com/malayalam-calendar](https://obidostech.com/malayalam-calendar) | 6 nazhika test; if the star is shorter, the pooja moves to the previous day |
| S4 | Vedadhara, [vedadhara.com/one-nakshatra-two-days-which-one-is-right-for-your-birthday](https://www.vedadhara.com/one-nakshatra-two-days-which-one-is-right-for-your-birthday) | Dharma Sindhu rule for a star on two days: prefer the day when the star is present at sunrise and lasts about 96 minutes; otherwise the earlier day |
| S5 | Malayalam Panchangam glossary, [malayalam-calendar.pages.dev/glossary](https://malayalam-calendar.pages.dev/glossary) | Terms only |
| S6 | Onmanorama, [pithru sradham bali karkidaka vavu](https://www.onmanorama.com/lifestyle/astro/2019/07/31/pithru-sradham-bali-karkidaka-vavu.html) | Karkidaka Vavu is a separate fixed observance (Amavasya of Karkidakam) |
| S7 | Advaita-l mailing list, [2019-October/053381](https://advaita-vedanta.org/archives/advaita-l/2019-October/053381.html) | Tamil annual shraddham uses the solar month, then the same paksha and tithi; one writer says "the procedure is same in kerala also", and that some communities use the nakshatra of death; "no universal pattern" |
| S8 | HinduPad, [Shraddha Vidhi](https://hindupad.com/shraddha-vidhi/) | Shraddham is in the afternoon, after 18 nazhika; a tithi on two days uses the day with more of the afternoon, the first on a tie; a tithi twice in a solar month uses the second; a month without it falls back to an earlier or later month |
| S9 | Hindu Blog, [how to find shradh tithi](https://www.hindu-blog.com/2012/09/how-to-find-shradh-tithi.html) | Shraddham by nakshatra uses the first of two nakshatras in a month; a tithi should hold for most of the day |
| S10 | Drik Panchang, [shraddha tithi pages](https://www.drikpanchang.com/shraddha/tithi/shashthi-shraddha-date-time.html?year=2022) | Published shraddha days and afternoon (aparahna) times for New Delhi |

## R1. Star occurs twice in the Malayalam month

**Default: the second occurrence** in the birth Malayalam month.

- Support: S1 and S2 agree. S4 gives the Dharma Sindhu alternative for the same case (see R3).
- Options in the app: `second` (default) or `first`.
- Example to check against an almanac (not yet verified, Needs you): a star that falls on two dates in one Malayalam month uses the later date, after R3 is applied to both.

## R2. Star does not occur in the Malayalam month

The Moon moves about 11° to 15° a day, and a nakshatra spans 13.33°. So a nakshatra can be skipped in a month. Then there is no candidate day in the month.

**Default (unsourced, owner to confirm):** use the **last day of the previous Malayalam month** on which the star is present (after R3 is applied), which is the closest day before the birth month.

- No source in this research covers this case. The default is a proposal, not a cited rule. Two alternatives: the first day of the next month, or no pirannal that year (with a note in the app).
- Options in the app: `previousMonth` (default), `nextMonth`, `skip`.

## R3. Which day counts (sunrise and 6 nazhika)

**Default: the star must be present at sunrise + 6 nazhika (about 2 h 24 min after sunrise) on that day.** This matches the "sunrise + 6 nazhika" option in [app-roadmap.md](app-roadmap.md) and the 6 nazhika rule in S3.

- A day that fails the test is skipped. The pooja then falls on the previous day, which is the rule in S3.
- S3 says "at least 6 nazhika on that day" and does not say whether the count starts at sunrise. S4 uses "present at sunrise and lasts about 96 minutes". The app's default is closest to S3 with the sunrise anchor from the roadmap. Owner to confirm the anchor.
- Options in the app: `firstOccurrence`, `sunrisePlusSixNazhika` (default), `dharmaSindhu` (present at sunrise and at least 96 minutes; otherwise the earlier day).

Combined default for R1 + R3: take the candidate days in the month where the star is present at sunrise + 6 nazhika; if there are two, use the later one (R1 second).

## R4. Shraddham (death anniversary, aandu)

Two methods are used. The app supports both, and the default is **tithi**.

- **`TithiInMonth` (default):** the same lunar tithi as the day of death, in the same Malayalam month. Support: S7 and S8 use the solar month, the same paksha and the tithi.
- **`NakshatraInMonth`:** the same nakshatra of death in the month. S7 says some communities use it, and where two dates occur in one month the first is chosen (S9). This is the opposite of R1, so an app should store `DuplicateRule.first` for it.
- **Which day a tithi belongs to:** the day on which it covers more of the afternoon (aparahna, the fourth of five equal parts of the daytime), the first day on a tie (S8). A tithi that misses both afternoons belongs to the later day, the one it covers at sunrise; this last step is ours, unsourced, and every tithi then has one day. The rule reproduces three published days for New Delhi (S10), including Ashtami 2022, which is on both afternoons. S9 instead says a tithi should hold for most of the day; the app follows the more specific S8.
- **A tithi twice in the month:** the later day (`DuplicateRule.second`, S8). S8 adds an exception when a day coincides with the sankranti; the engine doesn't implement it.
- **A tithi absent from the month:** the last such day of the previous month (`AbsentRule.previousMonth`). S8 falls back to the previous lunar month and then the next solar month, so this is close to S8 but not the same.
- Open question (Needs you): whether a Kerala family's month is solar (Malayalam) or lunar for a tithi observance. S7 suggests solar but is one brief remark. The default uses the Malayalam (solar) month for the window and the tithi inside it.
- Karkidaka Vavu is a fixed festival (Amavasya of Karkidakam, S6). It is not a shraddham recurrence and is handled as a festival. Its published dates follow a different reading (Amavasya at the end of the afternoon, the first such day; see [accuracy.md](accuracy.md)). `TithiInMonth(Tithi(30), karkidakam)` with `DuplicateRule.first` agrees with the published Vavu in 10 of 11 years, 2015–2025. In 2024 Amavasya covered only the last minutes of the 3 August afternoon: the festival was on 3 August, and this rule gives 4 August. Owner to confirm that a Kerala shraddham follows S8 rather than the Vavu reading.

## R5. Other recurrences

- **Monthly nakshatram:** every day the birth star is present at sunrise + 6 nazhika (R3). It does not use R1 or R2. Sometimes the Moon passes the whole star between one day's reading and the next, so no day has it. The engine then uses the earlier of the two days, following S3 (a short star moves to the previous day). Without this, about one cycle in a few dozen would have no nakshatram (gaps of up to 55 days in 1950–2100).
- **Gregorian birthday:** the Gregorian date. Age is computed from the birth date.
- **Malayalam-date anniversaries:** the same Malayalam day and month each year. If the day is missing in a shorter month, the last day of that month is used (proposed, unsourced; Needs you).

## Implementation (Day 3)

`packages/kollavarsham/lib/src/recurrence.dart` implements R1 (`DuplicateRule.second` / `first`), R2 (`AbsentRule.previousMonth` / `nextMonth` / `skip`) and the R3 default anchor (sunrise + 6 nazhika). The other R3 options (`firstOccurrence`, `dharmaSindhu`) are not implemented yet; they wait for the owner's answer to question 3.

`TithiInMonth` (Day 4) implements R4. `TithiEveryPaksha` covers vrat-style days such as every Ekadashi. It reads the tithi at sunrise, as an almanac's daily tithi does: one day per tithi, the first if the tithi is at two sunrises, and the earlier day if it falls between two sunrises.

Cross-check: `NakshatraInMonth(thiruvonam, chingam)` with the default rules gives the published Onam date for all 16 years in the festival tests (2009–2025 except 2016). That includes 2013 and 2024, when Thiruvonam falls twice in Chingam and the later day is Onam. This supports R1 `second` and the 6-nazhika anchor for one festival. It does not verify a personal pirannal.

## Worked examples

These examples use the rules above. The dates are placeholders until the engine (Day 3) computes them. Each one must be checked against a printed almanac before it is used in tests (Day 23).

1. **Pirannal, normal case.** Birth star Pooradam, birth month Dhanu. The star is present at sunrise + 6 nazhika on one day of Dhanu. The pirannal is that day each year. Check: the engine returns one date per year, and that date is the same Malayalam day as the almanac's Pooradam day in Dhanu.
2. **Pirannal, star twice in month (R1).** The star occurs on day A and day B of the month, both passing R3. Default: day B.
3. **Pirannal, 6 nazhika fails (R3).** The star starts at 14:00 on day C and is present at sunrise on day D only briefly, so it is not present at sunrise + 6 nazhika on D. Default: the pirannal falls on the earlier day that passes R3.
4. **Pirannal, no occurrence (R2).** No day in the month passes R3. Default: the last passing day of the previous month.
5. **Shraddham by tithi (R4).** Death on Ekadashi, Karkidakam. Default: the Ekadashi tithi in the same Malayalam month each year.

## Open questions for the owner

1. Is "second occurrence" (R1) the default you want for the app, or should `first` be the default?
2. R2: the previous-month default has no source. Confirm, or choose `nextMonth` or `skip`.
3. R3: confirm the sunrise anchor and the 6 nazhika reading (S3 vs S4).
4. R4: is a Kerala shraddham by tithi computed in the Malayalam (solar) month or the lunar month?
5. Malayalam-date anniversaries on day 31 or 30 in a short month: confirm the last-day rule.
6. R4: does a Kerala shraddham use the day with more of the afternoon (S8, the default), or the Karkidaka Vavu reading (the tithi at the end of the afternoon, first such day)? They differ when a tithi touches two afternoons, as Amavasya did on 3–4 August 2024.

## Next steps

- Verify R1 and R3 against two printed almanacs (Malayalam panchangam) for at least three stars and a year of data. Record the results in `packages/kollavarsham/test/fixtures/`.
- Ask a native Kerala Jyotishi to review R2 and R4.
