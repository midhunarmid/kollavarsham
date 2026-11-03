# Accuracy checklist, 2026–2027

The app's values for every month start, festival and pirannal edge case in 2026 and 2027, with an empty **Almanac** column to fill from a printed Malayalam almanac (Needs you, see `progress.md`). Where the almanac differs, note its name and year beside the value and open an issue; small, known differences (a month within minutes of the cut-off) are expected and explained in `accuracy.md`.

Everything below the line is generated; refresh it after engine or data changes:

```bash
cd apps/site_data
dart run site_data:accuracy_checklist --from 2026 --to 2027
```

Paste the output below the line, keeping the filled-in Almanac cells. All values are for Thiruvananthapuram (IST), Chingam year start.

**Found and fixed on Day 23:** the holiday list has Vishu on 15 April 2026 but the app said 14 April (Medam 1). Vishu is kept at the first sunrise after the Mesha sankranti, which was at 09:39 on 14 April; the engine now follows that rule (checked against 2021–2026).

---

## Month starts

Margin: minutes from the sankranti to the cut-off of its day (three-fifths of the daytime); positive means the month starts that day. ⚠ marks months within 30 minutes, where almanacs may differ.

| Month | App: day 1 | Sankranti (IST) | Margin (min) | Almanac |
|---|---|---|---|---|
| Makaram 1201 | 2026-01-15 Thu | 2026-01-14 15:13 | -91 |  |
| Kumbham 1201 | 2026-02-13 Fri | 2026-02-13 04:14 | 572 |  |
| Meenam 1201 | 2026-03-15 Sun | 2026-03-15 01:08 | 754 |  |
| Medam 1201 | 2026-04-14 Tue | 2026-04-14 09:39 | 237 |  |
| Edavam 1201 | 2026-05-15 Fri | 2026-05-15 06:28 | 424 |  |
| Mithunam 1201 | 2026-06-15 Mon | 2026-06-15 12:59 | 39 |  |
| Karkidakam 1201 | 2026-07-17 Fri | 2026-07-16 23:44 | -601 |  |
| Chingam 1202 | 2026-08-17 Mon | 2026-08-17 08:03 | 336 |  |
| Kanni 1202 | 2026-09-17 Thu | 2026-09-17 07:58 | 331 |  |
| Thulam 1202 | 2026-10-18 Sun | 2026-10-17 19:57 | -397 |  |
| Vrischikam 1202 | 2026-11-17 Tue | 2026-11-16 19:48 | -390 |  |
| Dhanu 1202 | 2026-12-16 Wed | 2026-12-16 10:29 | 177 |  |
| Makaram 1202 | 2027-01-15 Fri | 2027-01-14 21:14 | -453 |  |
| Kumbham 1202 | 2027-02-13 Sat | 2027-02-13 10:12 | 214 |  |
| Meenam 1202 | 2027-03-15 Mon | 2027-03-15 07:04 | 399 |  |
| Medam 1202 | 2027-04-15 Thu | 2027-04-14 15:32 | -116 |  |
| Edavam 1202 | 2027-05-15 Sat | 2027-05-15 12:24 | 69 |  |
| Mithunam 1202 | 2027-06-16 Wed | 2027-06-15 19:00 | -321 |  |
| Karkidakam 1202 | 2027-07-17 Sat | 2027-07-17 05:52 | 471 |  |
| Chingam 1203 | 2027-08-18 Wed | 2027-08-17 14:16 | -36 |  |
| Kanni 1203 | 2027-09-18 Sat | 2027-09-17 14:14 | -44 |  |
| Thulam 1203 | 2027-10-18 Mon | 2027-10-18 02:12 | 666 |  |
| Vrischikam 1203 | 2027-11-17 Wed | 2027-11-17 02:02 | 675 |  |
| Dhanu 1203 | 2027-12-17 Fri | 2027-12-16 16:41 | -194 |  |

## Festivals

"Listed" is the Kerala holiday list's kind for that day, where the list names the festival. Muslim dates are tentative until announced.

| Festival | App date | Malayalam date | Listed | Almanac |
|---|---|---|---|---|
| New Year's Day | 2026-01-01 Thu | 17 Dhanu 1201 |  |  |
| Makaravilakku | 2026-01-15 Thu | 1 Makaram 1201 |  |  |
| Thaipooyam | 2026-02-01 Sun | 18 Makaram 1201 |  |  |
| Sivaratri | 2026-02-15 Sun | 3 Kumbham 1201 | public |  |
| Ramadan begins | 2026-02-18 Wed | 6 Kumbham 1201 | tentative |  |
| Attukal Pongala | 2026-03-03 Tue | 19 Kumbham 1201 |  |  |
| Eid ul-Fitr | 2026-03-20 Fri | 6 Meenam 1201 | public, tentative |  |
| Palm Sunday | 2026-03-29 Sun | 15 Meenam 1201 |  |  |
| Maundy Thursday | 2026-04-02 Thu | 19 Meenam 1201 | public |  |
| Good Friday | 2026-04-03 Fri | 20 Meenam 1201 | public |  |
| Easter | 2026-04-05 Sun | 22 Meenam 1201 | public |  |
| Vishu | 2026-04-15 Wed | 2 Medam 1201 | public |  |
| Thrissur Pooram | 2026-04-26 Sun | 13 Medam 1201 |  |  |
| Bakrid | 2026-05-27 Wed | 13 Edavam 1201 | public, tentative |  |
| Muharram | 2026-06-25 Thu | 11 Mithunam 1201 | public, tentative |  |
| Ramayana Masam begins | 2026-07-17 Fri | 1 Karkidakam 1201 |  |  |
| Karkidaka Vavu | 2026-08-12 Wed | 27 Karkidakam 1201 | public |  |
| Malayalam New Year | 2026-08-17 Mon | 1 Chingam 1202 |  |  |
| Atham | 2026-08-17 Mon | 1 Chingam 1202 |  |  |
| First Onam | 2026-08-25 Tue | 9 Chingam 1202 | public |  |
| Milad-i-Sherif | 2026-08-25 Tue | 9 Chingam 1202 | public, tentative |  |
| Thiruvonam | 2026-08-26 Wed | 10 Chingam 1202 | public |  |
| Third Onam | 2026-08-27 Thu | 11 Chingam 1202 | public |  |
| Fourth Onam | 2026-08-28 Fri | 12 Chingam 1202 | public |  |
| Avani Avittom | 2026-08-28 Fri | 12 Chingam 1202 | restricted |  |
| Ashtami Rohini | 2026-09-04 Fri | 19 Chingam 1202 | public |  |
| Vinayaka Chathurthi | 2026-09-14 Mon | 29 Chingam 1202 |  |  |
| Vishwakarma Day | 2026-09-17 Thu | 1 Kanni 1202 | restricted |  |
| Durgashtami | 2026-10-19 Mon | 2 Thulam 1202 |  |  |
| Mahanavami | 2026-10-20 Tue | 3 Thulam 1202 | public |  |
| Vijayadasami | 2026-10-21 Wed | 4 Thulam 1202 | public |  |
| Deepavali | 2026-11-08 Sun | 22 Thulam 1202 | public |  |
| Mandala Kalam begins | 2026-11-17 Tue | 1 Vrischikam 1202 |  |  |
| Guruvayur Ekadashi | 2026-11-21 Sat | 5 Vrischikam 1202 |  |  |
| Christmas | 2026-12-25 Fri | 10 Dhanu 1202 | public |  |
| Mandala Pooja | 2026-12-27 Sun | 12 Dhanu 1202 |  |  |
| New Year's Day | 2027-01-01 Fri | 17 Dhanu 1202 |  |  |
| Makaravilakku | 2027-01-15 Fri | 1 Makaram 1202 |  |  |
| Thaipooyam | 2027-01-22 Fri | 8 Makaram 1202 |  |  |
| Ramadan begins | 2027-02-08 Mon | 25 Makaram 1202 | tentative |  |
| Attukal Pongala | 2027-02-21 Sun | 9 Kumbham 1202 |  |  |
| Sivaratri | 2027-03-06 Sat | 22 Kumbham 1202 | public |  |
| Eid ul-Fitr | 2027-03-10 Wed | 26 Kumbham 1202 | public, tentative |  |
| Palm Sunday | 2027-03-21 Sun | 7 Meenam 1202 |  |  |
| Maundy Thursday | 2027-03-25 Thu | 11 Meenam 1202 | public |  |
| Good Friday | 2027-03-26 Fri | 12 Meenam 1202 | public |  |
| Easter | 2027-03-28 Sun | 14 Meenam 1202 |  |  |
| Vishu | 2027-04-15 Thu | 1 Medam 1202 | public |  |
| Thrissur Pooram | 2027-05-14 Fri | 30 Medam 1202 |  |  |
| Bakrid | 2027-05-17 Mon | 3 Edavam 1202 | public, tentative |  |
| Muharram | 2027-06-15 Tue | 32 Edavam 1202 | tentative |  |
| Ramayana Masam begins | 2027-07-17 Sat | 1 Karkidakam 1202 |  |  |
| Karkidaka Vavu | 2027-08-02 Mon | 17 Karkidakam 1202 |  |  |
| Milad-i-Sherif | 2027-08-15 Sun | 30 Karkidakam 1202 | tentative |  |
| Malayalam New Year | 2027-08-18 Wed | 1 Chingam 1203 |  |  |
| Ashtami Rohini | 2027-08-24 Tue | 7 Chingam 1203 | public |  |
| Atham | 2027-09-03 Fri | 17 Chingam 1203 |  |  |
| Vinayaka Chathurthi | 2027-09-04 Sat | 18 Chingam 1203 |  |  |
| Thiruvonam | 2027-09-12 Sun | 26 Chingam 1203 |  |  |
| Durgashtami | 2027-10-08 Fri | 21 Kanni 1203 |  |  |
| Mahanavami | 2027-10-09 Sat | 22 Kanni 1203 |  |  |
| Vijayadasami | 2027-10-10 Sun | 23 Kanni 1203 |  |  |
| Deepavali | 2027-10-28 Thu | 11 Thulam 1203 | public |  |
| Mandala Kalam begins | 2027-11-17 Wed | 1 Vrischikam 1203 |  |  |
| Guruvayur Ekadashi | 2027-12-09 Thu | 23 Vrischikam 1203 |  |  |
| Christmas | 2027-12-25 Sat | 9 Dhanu 1203 | public |  |
| Mandala Pooja | 2027-12-27 Mon | 11 Dhanu 1203 |  |  |

## Holiday list against the computed festivals

Entries of `data/holidays/` that name a computed festival but fall on another day. Muslim festivals are left out: the list replaces their tentative dates by design.

None: every listed festival falls on its computed day.

## Pirannal

Stars are read at sunrise + 6 nazhika (R3). Worked example 1 (`docs/pirannal-rules.md`): Pooradam in Dhanu.

| Pirannal | App date | Almanac |
|---|---|---|
| Pooradam in Dhanu 1202 | 2027-01-08 (24 Dhanu) |  |
| Pooradam in Dhanu 1203 | 2027-12-28 (12 Dhanu) |  |

Every star that falls on two days of a month (R1, worked example 2) or on none (R2, example 4) in these years, with the day the app chooses:

| Star and month | Days read with the star | Rule | App pirannal | Almanac |
|---|---|---|---|---|
| Rohini in Makaram 1201 | none (R2) | previous month | 2026-01-01 (17 Dhanu) |  |
| Anizham in Makaram 1201 | 2026-02-10, 2026-02-11 | second day (R1) | 2026-02-11 (28 Makaram) |  |
| Thrikketta in Makaram 1201 | 2026-01-15, 2026-02-12 | second day (R1) | 2026-02-12 (29 Makaram) |  |
| Pooradam in Makaram 1201 | 2026-01-17, 2026-01-18 | second day (R1) | 2026-01-18 (4 Makaram) |  |
| Pooyam in Kumbham 1201 | none (R2) | previous month | 2026-02-01 (18 Makaram) |  |
| Atham in Kumbham 1201 | 2026-03-05, 2026-03-06 | second day (R1) | 2026-03-06 (22 Kumbham) |  |
| Moolam in Kumbham 1201 | 2026-02-13, 2026-03-12 | second day (R1) | 2026-03-12 (28 Kumbham) |  |
| Pooradam in Kumbham 1201 | 2026-02-14, 2026-03-13 | second day (R1) | 2026-03-13 (29 Kumbham) |  |
| Uthradam in Kumbham 1201 | 2026-02-15, 2026-03-14 | second day (R1) | 2026-03-14 (30 Kumbham) |  |
| Moolam in Meenam 1201 | 2026-04-08, 2026-04-09 | second day (R1) | 2026-04-09 (26 Meenam) |  |
| Thiruvonam in Meenam 1201 | 2026-03-15, 2026-04-12 | second day (R1) | 2026-04-12 (29 Meenam) |  |
| Avittam in Meenam 1201 | 2026-03-16, 2026-04-13 | second day (R1) | 2026-04-13 (30 Meenam) |  |
| Bharani in Medam 1201 | none (R2) | previous month | 2026-03-22 (8 Meenam) |  |
| Anizham in Medam 1201 | 2026-05-03, 2026-05-04 | second day (R1) | 2026-05-04 (21 Medam) |  |
| Chathayam in Medam 1201 | 2026-04-14, 2026-05-11 | second day (R1) | 2026-05-11 (28 Medam) |  |
| Pooruruttathi in Medam 1201 | 2026-04-15, 2026-05-12 | second day (R1) | 2026-05-12 (29 Medam) |  |
| Uthrattathi in Medam 1201 | 2026-04-16, 2026-05-13 | second day (R1) | 2026-05-13 (30 Medam) |  |
| Revathi in Medam 1201 | 2026-04-17, 2026-05-14 | second day (R1) | 2026-05-14 (31 Medam) |  |
| Ashwathi in Edavam 1201 | 2026-05-15, 2026-06-11 | second day (R1) | 2026-06-11 (28 Edavam) |  |
| Bharani in Edavam 1201 | 2026-05-16, 2026-06-12 | second day (R1) | 2026-06-12 (29 Edavam) |  |
| Karthika in Edavam 1201 | 2026-05-17, 2026-06-13 | second day (R1) | 2026-06-13 (30 Edavam) |  |
| Rohini in Edavam 1201 | 2026-05-18, 2026-06-14 | second day (R1) | 2026-06-14 (31 Edavam) |  |
| Thiruvathira in Edavam 1201 | none (R2) | previous month | 2026-04-22 (9 Medam) |  |
| Chothi in Edavam 1201 | 2026-05-28, 2026-05-29 | second day (R1) | 2026-05-29 (15 Edavam) |  |
| Chathayam in Edavam 1201 | 2026-06-07, 2026-06-08 | second day (R1) | 2026-06-08 (25 Edavam) |  |
| Revathi in Edavam 1201 | none (R2) | previous month | 2026-05-14 (31 Medam) |  |
| Rohini in Mithunam 1201 | none (R2) | previous month | 2026-06-14 (31 Edavam) |  |
| Makayiram in Mithunam 1201 | 2026-06-15, 2026-07-12 | second day (R1) | 2026-07-12 (28 Mithunam) |  |
| Thiruvathira in Mithunam 1201 | 2026-06-16, 2026-07-13 | second day (R1) | 2026-07-13 (29 Mithunam) |  |
| Punartham in Mithunam 1201 | 2026-06-17, 2026-07-14 | second day (R1) | 2026-07-14 (30 Mithunam) |  |
| Pooyam in Mithunam 1201 | 2026-06-18, 2026-07-15 | second day (R1) | 2026-07-15 (31 Mithunam) |  |
| Ayilyam in Mithunam 1201 | 2026-06-19, 2026-07-16 | second day (R1) | 2026-07-16 (32 Mithunam) |  |
| Uthradam in Mithunam 1201 | 2026-07-01, 2026-07-02 | second day (R1) | 2026-07-02 (18 Mithunam) |  |
| Pooyam in Karkidakam 1201 | none (R2) | previous month | 2026-07-15 (31 Mithunam) |  |
| Makam in Karkidakam 1201 | 2026-07-17, 2026-08-13 | second day (R1) | 2026-08-13 (28 Karkidakam) |  |
| Pooram in Karkidakam 1201 | 2026-07-18, 2026-08-14 | second day (R1) | 2026-08-14 (29 Karkidakam) |  |
| Uthram in Karkidakam 1201 | 2026-07-19, 2026-08-15 | second day (R1) | 2026-08-15 (30 Karkidakam) |  |
| Atham in Karkidakam 1201 | 2026-07-20, 2026-08-16 | second day (R1) | 2026-08-16 (31 Karkidakam) |  |
| Moolam in Karkidakam 1201 | 2026-07-26, 2026-07-27 | second day (R1) | 2026-07-27 (11 Karkidakam) |  |
| Chithira in Chingam 1202 | 2026-08-17, 2026-09-14 | second day (R1) | 2026-09-14 (29 Chingam) |  |
| Chothi in Chingam 1202 | 2026-08-18, 2026-09-15 | second day (R1) | 2026-09-15 (30 Chingam) |  |
| Vishakham in Chingam 1202 | 2026-08-19, 2026-08-20, 2026-09-16 | second day (R1) | 2026-09-16 (31 Chingam) |  |
| Bharani in Kanni 1202 | none (R2) | previous month | 2026-09-02 (17 Chingam) |  |
| Anizham in Kanni 1202 | 2026-09-17, 2026-10-14 | second day (R1) | 2026-10-14 (28 Kanni) |  |
| Thrikketta in Kanni 1202 | 2026-09-18, 2026-10-15 | second day (R1) | 2026-10-15 (29 Kanni) |  |
| Moolam in Kanni 1202 | 2026-09-19, 2026-10-16, 2026-10-17 | second day (R1) | 2026-10-17 (31 Kanni) |  |
| Thiruvonam in Kanni 1202 | 2026-09-22, 2026-09-23 | second day (R1) | 2026-09-23 (7 Kanni) |  |
| Thiruvathira in Thulam 1202 | none (R2) | previous month | 2026-10-03 (17 Kanni) |  |
| Vishakham in Thulam 1202 | 2026-11-09, 2026-11-10 | second day (R1) | 2026-11-10 (24 Thulam) |  |
| Pooradam in Thulam 1202 | 2026-10-18, 2026-11-14 | second day (R1) | 2026-11-14 (28 Thulam) |  |
| Uthradam in Thulam 1202 | 2026-10-19, 2026-11-15 | second day (R1) | 2026-11-15 (29 Thulam) |  |
| Thiruvonam in Thulam 1202 | 2026-10-20, 2026-11-16 | second day (R1) | 2026-11-16 (30 Thulam) |  |
| Thiruvonam in Vrischikam 1202 | 2026-12-13, 2026-12-14 | second day (R1) | 2026-12-14 (28 Vrischikam) |  |
| Avittam in Vrischikam 1202 | 2026-11-17, 2026-12-15 | second day (R1) | 2026-12-15 (29 Vrischikam) |  |
| Rohini in Dhanu 1202 | none (R2) | previous month | 2026-11-25 (9 Vrischikam) |  |
| Pooradam in Dhanu 1202 | 2027-01-07, 2027-01-08 | second day (R1) | 2027-01-08 (24 Dhanu) |  |
| Chathayam in Dhanu 1202 | 2026-12-16, 2027-01-12 | second day (R1) | 2027-01-12 (28 Dhanu) |  |
| Pooruruttathi in Dhanu 1202 | 2026-12-17, 2027-01-13 | second day (R1) | 2027-01-13 (29 Dhanu) |  |
| Uthrattathi in Dhanu 1202 | 2026-12-18, 2027-01-14 | second day (R1) | 2027-01-14 (30 Dhanu) |  |
| Ashwathi in Makaram 1202 | 2027-01-16, 2027-02-12 | second day (R1) | 2027-02-12 (29 Makaram) |  |
| Pooyam in Makaram 1202 | none (R2) | previous month | 2026-12-26 (11 Dhanu) |  |
| Thrikketta in Makaram 1202 | 2027-02-01, 2027-02-02 | second day (R1) | 2027-02-02 (19 Makaram) |  |
| Revathi in Makaram 1202 | 2027-01-15, 2027-02-11 | second day (R1) | 2027-02-11 (28 Makaram) |  |
| Bharani in Kumbham 1202 | 2027-02-13, 2027-03-13 | second day (R1) | 2027-03-13 (29 Kumbham) |  |
| Karthika in Kumbham 1202 | 2027-02-14, 2027-03-14 | second day (R1) | 2027-03-14 (30 Kumbham) |  |
| Pooruruttathi in Kumbham 1202 | 2027-03-08, 2027-03-09 | second day (R1) | 2027-03-09 (25 Kumbham) |  |
| Rohini in Meenam 1202 | 2027-03-15, 2027-04-11 | second day (R1) | 2027-04-11 (28 Meenam) |  |
| Thiruvathira in Meenam 1202 | 2027-03-16, 2027-04-13 | second day (R1) | 2027-04-13 (30 Meenam) |  |
| Punartham in Meenam 1202 | 2027-03-17, 2027-04-14 | second day (R1) | 2027-04-14 (31 Meenam) |  |
| Uthradam in Meenam 1202 | 2027-03-31, 2027-04-01 | second day (R1) | 2027-04-01 (18 Meenam) |  |
| Pooyam in Medam 1202 | 2027-04-15, 2027-05-12 | second day (R1) | 2027-05-12 (28 Medam) |  |
| Makam in Medam 1202 | 2027-04-16, 2027-05-14 | second day (R1) | 2027-05-14 (30 Medam) |  |
| Thrikketta in Medam 1202 | 2027-04-24, 2027-04-25 | second day (R1) | 2027-04-25 (11 Medam) |  |
| Rohini in Edavam 1202 | none (R2) | previous month | 2027-05-08 (24 Medam) |  |
| Pooram in Edavam 1202 | 2027-05-15, 2027-06-11 | second day (R1) | 2027-06-11 (28 Edavam) |  |
| Uthram in Edavam 1202 | 2027-05-16, 2027-06-12 | second day (R1) | 2027-06-12 (29 Edavam) |  |
| Atham in Edavam 1202 | 2027-05-17, 2027-06-13 | second day (R1) | 2027-06-13 (30 Edavam) |  |
| Chithira in Edavam 1202 | 2027-05-18, 2027-06-14 | second day (R1) | 2027-06-14 (31 Edavam) |  |
| Chothi in Edavam 1202 | 2027-05-19, 2027-06-15 | second day (R1) | 2027-06-15 (32 Edavam) |  |
| Chathayam in Edavam 1202 | 2027-05-28, 2027-05-29 | second day (R1) | 2027-05-29 (15 Edavam) |  |
| Pooyam in Mithunam 1202 | none (R2) | previous month | 2027-06-08 (25 Edavam) |  |
| Vishakham in Mithunam 1202 | 2027-06-16, 2027-07-13 | second day (R1) | 2027-07-13 (28 Mithunam) |  |
| Anizham in Mithunam 1202 | 2027-06-17, 2027-07-14 | second day (R1) | 2027-07-14 (29 Mithunam) |  |
| Thrikketta in Mithunam 1202 | 2027-06-18, 2027-07-15 | second day (R1) | 2027-07-15 (30 Mithunam) |  |
| Moolam in Mithunam 1202 | 2027-06-19, 2027-07-16 | second day (R1) | 2027-07-16 (31 Mithunam) |  |
| Thiruvonam in Mithunam 1202 | 2027-06-22, 2027-06-23 | second day (R1) | 2027-06-23 (8 Mithunam) |  |
| Uthram in Karkidakam 1202 | none (R2) | previous month | 2027-07-09 (24 Mithunam) |  |
| Anizham in Karkidakam 1202 | 2027-08-10, 2027-08-11 | second day (R1) | 2027-08-11 (26 Karkidakam) |  |
| Pooradam in Karkidakam 1202 | 2027-07-17, 2027-07-18, 2027-08-14 | second day (R1) | 2027-08-14 (29 Karkidakam) |  |
| Uthradam in Karkidakam 1202 | 2027-07-19, 2027-08-15 | second day (R1) | 2027-08-15 (30 Karkidakam) |  |
| Thiruvonam in Karkidakam 1202 | 2027-07-20, 2027-08-16 | second day (R1) | 2027-08-16 (31 Karkidakam) |  |
| Avittam in Karkidakam 1202 | 2027-07-21, 2027-08-17 | second day (R1) | 2027-08-17 (32 Karkidakam) |  |
| Thiruvathira in Chingam 1203 | none (R2) | previous month | 2027-07-31 (15 Karkidakam) |  |
| Avittam in Chingam 1203 | 2027-09-13, 2027-09-14 | second day (R1) | 2027-09-14 (28 Chingam) |  |
| Chathayam in Chingam 1203 | 2027-08-18, 2027-09-15 | second day (R1) | 2027-09-15 (29 Chingam) |  |
| Pooruruttathi in Chingam 1203 | 2027-08-19, 2027-09-16 | second day (R1) | 2027-09-16 (30 Chingam) |  |
| Uthrattathi in Chingam 1203 | 2027-08-20, 2027-08-21, 2027-09-17 | second day (R1) | 2027-09-17 (31 Chingam) |  |
| Ashwathi in Kanni 1203 | 2027-09-19, 2027-10-16 | second day (R1) | 2027-10-16 (29 Kanni) |  |
| Bharani in Kanni 1203 | 2027-09-20, 2027-10-17 | second day (R1) | 2027-10-17 (30 Kanni) |  |
| Makam in Kanni 1203 | none (R2) | previous month | 2027-08-31 (14 Chingam) |  |
| Uthradam in Kanni 1203 | 2027-10-08, 2027-10-09 | second day (R1) | 2027-10-09 (22 Kanni) |  |
| Revathi in Kanni 1203 | 2027-09-18, 2027-10-15 | second day (R1) | 2027-10-15 (28 Kanni) |  |
| Karthika in Thulam 1203 | 2027-10-18, 2027-11-14 | second day (R1) | 2027-11-14 (28 Thulam) |  |
| Rohini in Thulam 1203 | 2027-10-19, 2027-11-15 | second day (R1) | 2027-11-15 (29 Thulam) |  |
| Makayiram in Thulam 1203 | 2027-10-20, 2027-11-16 | second day (R1) | 2027-11-16 (30 Thulam) |  |
| Thiruvathira in Vrischikam 1203 | 2027-11-17, 2027-12-15 | second day (R1) | 2027-12-15 (29 Vrischikam) |  |
| Punartham in Vrischikam 1203 | 2027-11-18, 2027-12-16 | second day (R1) | 2027-12-16 (30 Vrischikam) |  |
| Chathayam in Vrischikam 1203 | 2027-12-05, 2027-12-06 | second day (R1) | 2027-12-06 (20 Vrischikam) |  |
| Ayilyam in Dhanu 1203 | 2027-12-17, 2028-01-14 | second day (R1) | 2028-01-14 (29 Dhanu) |  |
| Uthradam in Dhanu 1203 | 2027-12-29, 2027-12-30 | second day (R1) | 2027-12-30 (14 Dhanu) |  |

## Shraddham by tithi

Worked example 5: Ekadashi in Karkidakam, by the larger share of the afternoon (R4).

| Shraddham | App date | Almanac |
|---|---|---|
| Ekadashi (waxing), Karkidakam 1201 | 2026-07-24 (8 Karkidakam) |  |
| Ekadashi (waxing), Karkidakam 1202 | 2027-08-12 (27 Karkidakam) |  |
| Ekadashi (waning), Karkidakam 1201 | 2026-08-08 (23 Karkidakam) |  |
| Ekadashi (waning), Karkidakam 1202 | 2027-07-29 (13 Karkidakam) |  |
