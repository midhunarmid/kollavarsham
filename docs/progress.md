# Build progress: Malayalam Calendar app and website

This file drives the daily automated build of the plan in [app-roadmap.md](app-roadmap.md). Each sprint takes **2 days**, and each day is **one run**. A run takes the **first day whose status is not `done`**, works through its tasks, commits after each finished task, and updates this file.

- App: `apps/calendar`, Android application ID **`in.armid.calendar`** (+ web).
- Status values: `todo`, `in progress`, `done`, `blocked: <reason>`.
- Task boxes: `[ ]` open, `[x]` done, `[-]` skipped or needs the owner (see "Needs you").

## Rules for every run

1. `git pull --rebase` on `main` first, then read this file and the roadmap.
2. Work only on the current day's tasks. If they finish early, stop; don't start the next day.
3. After each finished task:
   - format with `dart format`;
   - analyze the touched packages;
   - run the tests of the touched packages;
   - commit to `main` with a descriptive message ending in `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, and push.
4. Never commit failing tests or analyzer errors. If something can't be fixed in this run, revert it, mark the task `blocked: <reason>` or leave it open with a note, and move on.
5. Do not:
   - force-push or rewrite history;
   - change commit dates;
   - create git tags (tags trigger the pub.dev publish workflow);
   - publish to pub.dev or Play;
   - commit secrets or keystores.
6. Steps needing the owner (accounts, keys, almanac checks, reviews) go under **Needs you**; continue with the rest.
7. At the end, update this file (task boxes, the day's status, a one-line log entry) and commit it.

## Needs you (owner actions)

- [ ] Review `docs/pirannal-rules.md` (Day 2) and confirm the default rules, including the unsourced R2 (star absent in the month) default, the sunrise anchor for R3, and the R4 shraddham day (question 6: the rule follows the larger share of the afternoon and gives 4 August 2024 where Karkidaka Vavu was observed on 3 August).
- [ ] Complete `data/holidays/2027.json`: it currently holds only the Negotiable Instruments Act list (G.O. (P) No. 20/2026/GAD). Add the state government list (Onam, Mahanavami, Vijayadasami, Karkidaka Vavu, Easter, Milad-i-Sherif, Independence Day, Kerala Piravi, restricted holidays) from the gazette.
- [ ] Settle the 2026 holiday conflicts noted in `data/holidays/2026.json`: the G.O. number (14 or 15/2025/GAD), and whether Kerala Piravi (1 Nov) is a 2026 holiday. For Navaratri, Onmanorama (16 Oct 2026) says the 19 Oct order is for Durgashtami, so Mahanavami stays on 20 Oct; add the 19 Oct holiday if the gazette confirms it.
- [ ] Review `docs/privacy.md` and `docs/design.md` open questions, and set the contact email in the privacy policy.
- [ ] Create the Google Play developer account; recruit 12 closed testers (needed by Day 18).
- [ ] Create a release keystore and add it as described in `docs/release.md` (Day 18).
- [x] Choose the website domain and DNS (Day 20): `calendar.armid.in`, a CNAME to `midhunarmid.github.io`.
- [ ] Check 2026–2027 dates against printed almanacs (Day 23). Include the Day 6 rules with the weakest evidence: Ashtami Rohini, Thaipooyam, Vinayaka Chathurthi and the vrat reading times, none of which has a Kerala almanac behind it.
- [ ] Malayalam copy review by a native editor (Day 24).
- [ ] Design the app icon (launcher, 512 px Play icon) and feature graphic; the app still has Flutter's default icon (Day 18, `docs/store-listing.md`).
- [ ] Create a `wrong-date` label in the GitHub repository, used by the app's "Report a wrong date" link (Day 17).
- [ ] Confirm the Day 9 storage choice: a versioned JSON document in shared_preferences instead of drift (drift now needs Dart 3.10, and a sqlite3.wasm download for the web). Moving to drift later means a one-time import of that document.

## Days

### Day 1: Sprint 0a, app scaffold (status: done)
- [x] Create `apps/calendar` with `flutter create --platforms=android,web --org in.armid --project-name calendar`; set the SDK constraint to `^3.6.0`, `resolution: workspace`, and add it to the root `pubspec.yaml` workspace. The Android `applicationId` must be `in.armid.calendar`.
- [x] Dependencies: `kollavarsham_flutter`, `flutter_riverpod`, `go_router`, `flutter_localizations` + `intl` (gen-l10n with `app_en.arb` / `app_ml.arb`).
- [x] Bundle the Noto Sans Malayalam font (OFL licence file included) and use it as the app font.
- [x] Minimal app: a Material 3 theme (light/dark), a home screen showing today's Malayalam date via `MalayalamDateText` and a `MalayalamMonthView`, and a widget test.
- [x] CI (`.github/workflows/ci.yml`): analyze and test `apps/calendar`; build the web app and a debug APK; upload them as artifacts.
  - The web app deploys to GitHub Pages on every push to `main` (`.github/workflows/deploy-web.yml`), at `https://calendar.armid.in/`.
  - Note: `flutter_riverpod` ^2.6.1 and `go_router` ^14.8.1, the newest releases that resolve on the workspace Dart 3.6 floor (riverpod 3 / go_router 18 need Dart 3.12).

### Day 2: Sprint 0b, research and design docs (status: done)
- [x] `docs/pirannal-rules.md`: rules for star birthdays when the star falls twice or not at all in the birth month, the "6 nazhika after sunrise" convention, monthly nakshatram, and shraddham by tithi or nakshatra. Use web research with **cited sources** and worked examples; pick defaults; list open questions for the owner.
- [x] `docs/design.md`: information architecture, navigation, and text wireframes for Today, Month, Day, People, Event editor, Reminders, Tools and Settings; colour and type system.
- [x] `data/holidays/` format (`schema.md`) plus `2026.json` and `2027.json` for Kerala Government public holidays and national days, each entry with a source URL. Mark Muslim festivals `tentative` until confirmed. (2027 is partial, see Needs you.)
- [x] `docs/privacy.md`: privacy policy (no data collected, everything stays on the device).

### Day 3: Sprint 1a, recurrence engine (status: done)
- [x] `packages/kollavarsham/lib/src/recurrence.dart`: `Recurrence` with `occurrencesBetween(from, to)` and `next(after)`; implementations `NakshatraInMonth` (yearly pirannal), `NakshatraMonthly`, `MalayalamDateYearly`, `MalayalamDateMonthly`, `GregorianYearly`; a `DuplicateRule` per `docs/pirannal-rules.md`. Reuse `daysWithNakshatra` and `MalayalamDate`.
  - Stars are read at sunrise + 6 nazhika (R3 default), so the code uses `nakshatraAt` and `sunrise` rather than `daysWithNakshatra` (which reads at sunrise). R2 is `AbsentRule`. The other R3 options (`firstOccurrence`, `dharmaSindhu`) wait for the owner's review.
  - Monthly nakshatram: when the star falls wholly between two days' readings, the earlier day counts (S3), so every lunar cycle has a day.
- [x] Tests with the sourced examples from the rules doc, plus property tests (sorted, no duplicates, no gaps over 1950–2100).
  - The rules doc has no almanac-verified pirannal dates yet (Day 23). As a sourced stand-in, the default pirannal rule reproduces the published Onam dates for 2009–2025 (16 years, two with Thiruvonam twice).
- [x] JSON (de)serialisation of recurrences, used later by the app database.

### Day 4: Sprint 1b, birth details and shraddham (status: done)
- [x] `BirthDetails.fromInstant(DateTime, {calendar})`: nakshatra with pada, rashi, Malayalam date, tithi; tests against known values.
  - Also added `BirthDetails.fromLocalTime` (a clock time at the calendar's location, for "Find my star" on Day 10) and a `Rashi` enum.
  - Known values: two published charts with a birth time, plus a Chithira/Deepavali birth date. All come from web sources, not almanacs.
- [x] `TithiInMonth` (shraddham by tithi) and `TithiEveryPaksha` (e.g. every Ekadashi) recurrences, with tests.
  - `TithiInMonth` uses the larger share of the afternoon (R4, sourced). It matches 3 published New Delhi shraddha days and 10 of 11 Karkidaka Vavu years; the 2024 difference is pinned in a test and listed under Needs you. Only 3 of the planned drikpanchang pages could be read (the others returned a CAPTCHA).
  - `TithiEveryPaksha` has property tests only (1950–2100); no published Ekadashi dates were checked.
- [x] Export the new APIs; README section; CHANGELOG `1.1.0`; bump to 1.1.0 (no tag); update the dependents' constraints.

### Day 5: Sprint 2a, panchangam extras (status: done)
- [x] Yoga and karana (enums with Malayalam/English names, values at an instant and at sunrise, spans).
  - All 30 sampled days of drikpanchang (Thiruvananthapuram, 2025–2026) match by name. End times run 30–96 s later than published, within the 2-minute tolerance; see `docs/accuracy.md`.
- [x] Rahu kalam, Gulika kalam and Yamagandam from sunrise/sunset and the weekday; tests against published values.
  - `Kalam` and `kalamOn`, within 2 minutes on the same 30 days, which meets the sprint's check.
- [x] Moonrise/moonset; Chandrashtamam for a birth star.
  - Moonrise uses the Moon's centre on the true horizon without refraction, found by fitting drikpanchang (within 30 s on 30 days). No printed almanac was compared.
  - `chandrashtamam` takes a `Rashi`, because 9 stars straddle two rashis; `Nakshatra.rashiOf(pada)` gives it. The app must ask for the pada for those stars (Day 8/10). It matches the 13 published Mesha periods of 2026. The star-level window is left out: sources disagree (16th or 17th star).
  - The CHANGELOG has an `Unreleased` section for Day 6's 1.2.0. Malayalam yoga and karana names await the Day 24 copy review.

### Day 6: Sprint 2b, festivals (status: done)
- [x] New festivals, each with ≥5 years of sourced dates (follow the existing rule in `festivals.dart`): Sivaratri, Ashtami Rohini, Vinayaka Chathurthi, Navaratri (Durgashtami, Mahanavami, Vijayadasami), Deepavali, Thaipooyam, Guruvayur Ekadashi, and Thiruvathira if the sources agree. Leave out any whose rule can't be verified, and note why.
  - Dhanu Thiruvathira is left out: sources disagree for 2021, 2023 and 2026, and only three years have a Kerala date.
  - Vinayaka Chathurthi and Thaipooyam rest on non-Kerala lists. Thaipooyam misses 2017 (pinned in a test), and Mahanavami and Durgashtami leave out 2020, where the Kerala list and the tithi differ. See `docs/accuracy.md`.
  - A 1900–2100 sweep showed `festivalsIn` threw for some years (a star between two readings), so Onam, Attukal Pongala and Thrissur Pooram gained fallbacks. Those fallback days aren't checked against published dates.
- [x] Vrat lists: Ekadashi, Pradosham, Shashti, Pournami, Amavasya for a year.
  - `Vrat` and `vratDays`. Reading times were fitted to drikpanchang's 2025 New Delhi lists, which all match except one Ekadashi. A 2026 Tamil Nadu Pradosham list matches 23 of 25 at Thiruvananthapuram. No Kerala vrat list was found.
- [x] Christian movable feasts (Easter computus) and fixed days; tentative Hijri festivals (tabular calendar).
  - Hijri dates are within two days of Kerala's lists. They take a Gregorian year and return `DateTime`, so the Day 13 loader merges them with the announced dates.
- [x] CHANGELOG `1.2.0`; bump the version (no tag).
  - The new Malayalam festival, vrat, feast and Hijri names await the Day 24 copy review.

### Day 7: Sprint 3a, app shell (status: done)
- [x] go_router navigation (bottom bar: Today, Calendar, People, Tools, Settings), theme with light/dark/system, ml/en l10n for every UI string.
  - A `StatefulShellRoute` keeps each tab's state. People and Tools are placeholders until Days 9 and 15. A test checks that `app_en.arb` and `app_ml.arb` have the same keys and that every English string has a description.
- [x] Settings storage (shared_preferences): language, script, Malayalam digits, location (Kerala cities + manual lat/long/time zone), year start, default calendar mode, theme.
  - Locations: the 14 district headquarters (approximate city-centre coordinates; Thiruvananthapuram, Kochi and Kozhikode reuse the engine's values) or a manual latitude, longitude and UTC offset. `calendarProvider` builds the `KollavarshamCalendar` from the location and year start.
  - `shared_preferences: ^2.5.3`, because the CI job on Flutter 3.27.4 resolves the whole workspace and newer releases need Flutter 3.41.
  - Week start (design.md §3.9) is left out: `MalayalamMonthView` has no week-start option yet.
- [x] Onboarding flow: language, location, what notifications are for.
  - Three steps; the router sends a first run to `/onboarding` until it is finished. The notification permission is not asked here; Day 12 asks for it with the first reminder.
  - Checked by widget tests and `flutter build web`; the app wasn't opened in a browser in this run. The new Malayalam strings await the Day 24 copy review.

### Day 8: Sprint 3b, Today, Month and Day screens (status: done)
- [x] Today: both dates, nakshatra/tithi with times, sunrise/sunset, rahu kalam, gulika, yamagandam, today's festivals, next festival.
  - Times are wall-clock times at the chosen location, in the locale's 12- or 24-hour format, marked "(next day)" after midnight. "Today" comes from a `clockProvider`, so tests fix the day. The pirannal section waits for Day 10.
- [x] Calendar tab: `MalayalamMonthView` in both modes with festival markers; tap a day for the Day detail screen.
- [x] Day detail screen with the full panchangam and festivals.
  - Route `/day/yyyy-mm-dd` over the tabs, with previous/next day buttons. Lists every star, tithi, yoga and karana from sunrise to the next sunrise, moonrise and moonset, and the "almanacs may differ" note when a month starts within 10 minutes of the cut-off.
- [x] Golden tests for Today, Month and Day (ml/en, light/dark).
  - Twelve goldens at 25 August 2026, run on Windows only (`@TestOn('windows')`), since text rendering differs on the Linux CI. The theme gained a Roboto fallback: Noto Sans Malayalam has no Latin letters.

### Day 9: Sprint 4a, database and people (status: done)
- [x] drift database (native + web) with tables `people`, `events` (type, recurrence JSON, colour, notes), `reminders`, plus migrations and tests.
  - Not drift: the tables are one versioned JSON document in shared_preferences (`lib/data/database.dart`), a file on Android and `localStorage` on the web. drift ≥2.33 and sqlite3 ≥3.0 need Dart 3.10, the workspace still resolves on Dart 3.6, and drift on the web needs a downloaded `sqlite3.wasm`. With a few hundred rows at most, rewriting the document per change is cheap. Migrations are numbered steps; a newer schema is refused rather than overwritten. See Needs you.
- [x] Repositories and Riverpod providers.
  - `Repository` (a Notifier) assigns ids and cascades deletes (person → events → reminders); providers for the sorted people list, a person, a person's events and an event's reminders.
- [x] People list, person editor (name, relation, colour, optional photo) and person detail.
  - The photo is left out: it needs `image_picker` and file storage, and adds little to a list of initials in colour. Events on the detail screen are listed only by type until Day 10's editor.

### Day 10: Sprint 4b, events and pirannal (status: done)
- [x] Event editor with presets: pirannal (star + Malayalam month), monthly nakshatram, Gregorian birthday, shraddham (tithi or star in a month), anniversary, custom (any recurrence); duplicate-rule picker with an explanation.
  - Custom offers Malayalam date (yearly or monthly), English date (yearly) and tithi every paksha. Shraddham by star defaults to the first day (rules doc, R4 section); the rest to the second. A preview shows the next three dates. New events get a same-day 07:00 reminder; the reminder editor is Day 12. The absent-star rule (R2) keeps its default and has no picker.
- [x] "Find my star" flow (birth date, time, place → `BirthDetails`) that pre-fills a pirannal.
  - The place is the location in Settings; the screen says so. It fills the star, Malayalam month and birth year.
- [x] Upcoming list with countdowns; person colours as markers on the calendar.
  - Today lists the next 30 days of events; the person detail lists each event's next date. An `EventIndex` computes event days a Gregorian year at a time.
- [x] Widget tests: create "Midhun: Pooradam, Dhanu" and check the next 5 pirannals and 12 nakshatram days.
  - The checks are structural (each date in Dhanu of successive years, each a Pooradam day at sunrise + 6 nazhika, monthly gaps), not almanac values. The monthly rule gives both days when the star is read on two days running, so "12 nakshatram days" can be fewer than 12 lunar months.

### Day 11: Sprint 5a, reminder scheduler (status: done)
- [x] Pure-Dart scheduler: from events and reminder settings, compute the notifications for the next 60 days, with stable IDs per (event, date, offset). Unit tests with a fake clock.
  - `lib/reminders/scheduler.dart`. It uses no plugins and no BuildContext (templates come from `lookupAppLocalizations`), so Day 12's background job can run it. Ids are FNV-1a hashes in 31 bits.
- [x] Message templates (ml/en) with `{name}`, `{star}`, `{month}`, `{age}`, e.g. "Midhun's pirannal (Pooradam)", "Midhun's nakshatram".
  - Malayalam titles use "{name} – പിറന്നാൾ" rather than a genitive suffix, which depends on how the name ends. Ages are shown for birthdays and anniversaries with a year; a pirannal's age waits for a birth Malayalam year in the data.
- [x] Month and year start reminders ("Chingam 1 tomorrow: Malayalam New Year 1202").
  - The evening before at 20:00, with the sankranti time. `ReminderOptions` (year start on, months off by default) is persisted with the Day 12 reminder settings screen.

### Day 12: Sprint 5b, Android notifications (status: done)
- [x] flutter_local_notifications + timezone: schedule and cancel from the scheduler output; `POST_NOTIFICATIONS` and exact-alarm permission flows with fallback.
  - `flutter_local_notifications ^19.5.0`, `timezone ^0.10.1` and `workmanager ^0.7.0`: the newest that resolve on Dart 3.6 / Flutter 3.27. The plugin needs core library desugaring (`desugar_jdk_libs` 2.1.4). Without exact alarms, notifications use `inexactAllowWhileIdle`. The permission is asked when the first event is saved, and from Settings → Reminders.
  - Not run on a device: the emulator couldn't start in this environment (Windows hypervisor access denied). Scheduling, settings, permission requests and notification taps are covered by tests with a fake sink; delivery on a phone is unverified.
- [x] Reschedule on app start, on boot, on time/time-zone change, and in a daily workmanager job.
  - Boot and app updates: the plugin's `ScheduledNotificationBootReceiver`. Times are absolute instants at the chosen location, so a device time-zone change doesn't move them and needs no handler. `workmanager` 0.7 still applies the Kotlin Gradle Plugin, which Flutter warns will stop building in a future release.
- [x] Daily panchangam notification (optional); festival reminders by category; actions (Open, Snooze).
  - Festival categories are Hindu (the engine's Kerala festivals), Christian and Muslim (tentative); Day 13 adds holidays and filters. Snooze is "Remind in 1 hour".
- [x] Reminder settings screen.

### Day 13: Sprint 6a, holidays and agenda (status: done)
- [x] Holiday data loader for `data/holidays/*.json` (bundled as assets), merged with computed festivals.
  - Flutter assets can't point outside the package, so `apps/calendar/assets/holidays/` holds copies made by `dart run tool/sync_holidays.dart`; `test/holidays_test.dart` fails while they differ. They load before the first frame.
  - Merging: an entry whose name matches a computed festival (an alias table, e.g. "Sreekrishna Jayanthi" → Ashtami Rohini) on the same day marks it as a holiday; an announced Muslim date replaces the tabular one for that festival and year; all other entries are their own items. Data entries have English names only until Day 14.
- [x] Category filters (Hindu, Christian, Muslim, national, government, bank), persisted.
  - In `AppSettings.categories`; they apply to the calendar markers, Today, Day detail and the agenda. Festival reminders have their own category choice in Settings → Reminders.
- [x] Agenda tab or section: upcoming festivals, holidays and personal events; search by name.
  - Calendar → Agenda (`/calendar/agenda`): the next 366 days, filter chips, search over Malayalam and English names, people and event titles.

### Day 14: Sprint 6b, festival details and year view (status: done)
- [x] Festival detail screen: Malayalam and English description, rule, next 5 dates, share.
  - `/festival/<id>` (ids like `hindu.onam`, `christian.easter`, `muslim.bakrid`, `holiday.gandhijayanthi`). List-only holidays have dates only in years with a holiday file. Sharing goes through `share_plus ^12.0.2` (the newest on Dart 3.6).
- [x] Year view (12 mini-months with festival dots) in `kollavarsham_flutter` or the app.
  - In the app (Calendar → Year), in the tab's mode; tapping a month opens it in the month view.
- [x] Descriptions content for all festivals (ml/en).
  - `lib/data/festival_info.dart`; the holiday files gained `name_ml` (schema updated). The Malayalam text joins the Day 24 copy review.
  - The bottom bar's Malayalam labels wrap on narrow phones (seen in the goldens); left for the Day 18 accessibility pass.

### Day 15: Sprint 7a, tools and sharing (status: done)
- [x] Tools tab: date converter (both directions), age calculator, days between dates, Kollavarsham year info.
  - Find my star is listed there too. The converter's Malayalam direction uses `showMalayalamDatePicker` from `kollavarsham_flutter`.
- [x] Share cards rendered as images: today's panchangam, pirannal greeting.
  - A preview dialog renders the card in a `RepaintBoundary` and shares a 3× PNG (Today → share; a person's pirannal or birthday → gift icon). File names go through `fileNameOverrides`, since `XFile.fromData` ignores the name on Android.

### Day 16: Sprint 7b, export and backup (status: done)
- [x] .ics export of selected events for N years (explicit dates).
  - Settings → Backup and export: pick events and 1, 2, 5 or 10 years. All-day events with a stable UID per occurrence, RFC 5545 escaping and 75-octet line folding; the description carries the Malayalam date, star and notes.
- [x] JSON backup/restore (versioned), file picker/share; Android Auto Backup rules; round-trip tests.
  - `lib/backup/backup.dart`: `backupVersion` 1 with the database document, settings and reminder options. Restore refuses other files and newer versions and migrates older database schemas. Saving goes through the share sheet; restoring uses `file_picker ^11.0.3` (newest on Dart 3.6).
  - file_picker 11 relies on AGP 9's built-in Kotlin, which the Flutter template disables (`android.builtInKotlin=false`), so `android/build.gradle.kts` applies the Kotlin plugin (JVM 17) to that subproject. Revisit when Flutter moves the template to built-in Kotlin.
  - `backup_rules.xml` (Android 6–11) and `data_extraction_rules.xml` (12+) include `FlutterSharedPreferences.xml`, which holds all the data. Not tested with `adb shell bmgr`: no emulator in this environment.

### Day 17: Sprint 8a, Android widgets and extras (status: done)
- [x] Home-screen widgets via `home_widget`: Today (date, star, festival) and Next pirannal; refreshed daily.
  - `home_widget ^0.9.2` (newest on Dart 3.6), with the same AGP 9 Kotlin hook as file_picker. Dart writes a week of widget text ahead, keyed `today.<date>.*` / `next.<date>.*`, on every app sync and in the daily workmanager job; the Kotlin providers read the device's date, and `updatePeriodMillis` redraws them hourly. Debug APK builds; the widgets haven't been seen on a device (no emulator here).
- [x] App shortcuts; "Report a wrong date" (pre-filled GitHub issue URL); North Malabar year setting wired through.
  - Shortcuts are static (`res/xml/shortcuts.xml`, Today / Add event / Date converter) and open routes through Flutter deep linking (`kollavarsham://app/<route>`), so no plugin. Widget taps use the same.
  - The report opens `github.com/midhunarmid/kollavarsham/issues/new` (url_launcher) with the date, the app's Malayalam date, star, tithi, festivals, city and year start. A manual location is reported only as "manual" with its UTC offset. Needs you: create the `wrong-date` label on GitHub.
  - North Malabar (Kanni 1) was already a setting; tests now check year info, the year view and the new-year reminder with it.

### Day 18: Sprint 8b, release readiness (status: done)
- [x] Accessibility pass (semantics, large text, contrast) and performance (R8/minify, startup, size).
  - `test/a11y_test.dart` checks 15 screens (light and dark) against the tap-target, label and text-contrast guidelines, and 200% text in English and Malayalam; `test/nav_bar_test.dart` checks the bottom-bar labels at 320 dp with real fonts. Fixed: holiday colour contrast (#BF360C light, #FF8A65 dark), year-view semantics and overflow, and bottom-bar labels wrapping (one line, shorter Malayalam ടൂളുകൾ and സെറ്റിങ്സ്).
  - Release builds use R8 and resource shrinking (`proguard-rules.pro` keeps the notification plugin's Gson types and the widget providers). arm64 APK: 19.9 MB, mostly the Flutter engine (11.3 MB) and Dart code (7.5 MB). Startup does two small reads before the first frame (preferences, holiday files); not measured on a device.
- [x] Release signing config reading `key.properties` (not committed) and `docs/release.md`; mark the keystore as **Needs you**.
  - Without `key.properties` the release build falls back to the debug key with a warning. The launcher label is now "Malayalam Calendar" / "മലയാളം കലണ്ടർ".
- [x] `docs/store-listing.md`: Play listing text (ml/en), screenshot list, data-safety answers.
  - Release builds declare no INTERNET permission. `docs/privacy.md` was corrected to match the app (no photos, no device location). The launcher icon is still Flutter's default: Needs you.

### Day 19: Sprint 9a, site data and converter (status: done)
- [x] `apps/site_data`: a Dart CLI writing JSON for the current year −2 to +10 (days, months, festivals, panchangam) into `apps/site/src/data/`.
  - `dart run site_data` (from `apps/site_data`): `meta.json`, `names.json` (ids → Malayalam/English), `months.json` (start, length, sankranti), `festivals.json` (names, description, rule, every date with holiday kind, tentative flag and source) and `days/YYYY.json` (every star and tithi to the next sunrise with end times, paksha, sun and moon times, kalams, festival ids). Thiruvananthapuram, local times. 13 years: 3.5 s, 2.8 MB; generated at site build time, not committed.
  - To share the festival/holiday merge and descriptions with the app, they moved into a new pure-Dart package, `packages/calendar_data`; the app re-exports it.
- [x] `apps/converter_js`: the engine compiled with `dart compile js`, exposing a converter and star finder for the site.
  - `globalThis.kollavarsham.toMalayalam(iso)`, `.toGregorian(year, monthId, day)`, `.findStar(localDateTime)`, each with an optional latitude, longitude and UTC offset. 115 KB with `-O2`; checked from Node. The logic is plain Dart (`lib/converter.dart`) with VM tests; CI also compiles it.

### Day 20: Sprint 9b, static site (status: done)
- [x] `apps/site` (Astro): home/today, day pages, month pages, festival-per-year pages, "nakshatra today", "Malayalam calendar YYYY"; ml/en with `hreflang`; structured data; sitemap; OG images.
  - Astro 7.3.8 (the newest release over two weeks old), English at `/`, Malayalam at `/ml/`, 10,701 pages built in about 10 s: a page per day (13 years), per complete Malayalam month, per Gregorian year, per festival and year, plus a festival index, home, "nakshatra today" and a converter. Home, nakshatra-today and the converter compute in the browser with `kollavarsham.js` (Day 19), so they're right on any day, not only the build day.
  - `hreflang` alternates (en-IN, ml-IN, x-default) and canonical links on every page, JSON-LD (`WebSite`, `WebPage`, `Event` for festival pages), `@astrojs/sitemap` with i18n, `robots.txt`. One shared OG image (`public/og.png`, rendered by headless Chrome from `scripts/og.html` because Pillow here can't shape Malayalam); per-page images are left for later.
  - `npm run check` checks that all internal links resolve (158,886) and every page has canonical and hreflang links. Checked in the browser at desktop and 390 px widths (no horizontal scroll on any page type), and the converter and nakshatra-today scripts.
  - Site data and `kollavarsham.js` are generated at build time (`npm run prepare-data`), not committed. CI builds and checks the site on every push.
- [x] GitHub Pages deployment workflow (`.github/workflows/deploy-web.yml`, domain `calendar.armid.in`).
  - Now deploys the site at the root and the Flutter web app at `/app/` (`--base-href /app/`; hash URLs, so no rewrites). Checked locally: the app loads at `/app/` with no failed requests.

### Day 21: Sprint 10a, Flutter web app (status: done)
- [x] Web build of `apps/calendar` served at `/app` of the site; drift on IndexedDB; web-specific reminder UI (upcoming list + .ics instead of notifications).
  - Served at `/app/` by the Day 20 deploy (`--base-href /app/`, hash URLs); checked locally that it loads and opens onboarding with no failed requests.
  - Not drift (see Day 9): the data is in shared_preferences, which is `localStorage` on the web. That's per browser and origin; the backup file moves it between browsers and phones.
  - Without system notifications (the web), Settings → Reminders lists the next 15 reminders the app would send and links to the `.ics` export, so a calendar app can do the reminding. Sharing files on the web goes through `share_plus`'s Web Share, or a download where that's unsupported.

### Day 22: Sprint 10b, PWA and site pages (status: done)
- [x] PWA manifest and offline caching for `/app`; deep links from site pages to the app.
  - Flutter's service worker is now a self-unregistering stub, so the app has its own (`web/app_sw.js`: network-first for the page, stale-while-revalidate for app files and Google font files) and a custom `web/flutter_bootstrap.js` that doesn't register Flutter's. Built with `--no-web-resources-cdn` so CanvasKit is local. `apps/site/scripts/check-offline.mjs` checks, in headless Chrome, that the app renders with the server stopped after two online visits; it passes locally and runs in the deploy workflow.
  - Day, festival and converter pages link into the app (`/app/#/day/…`, `/app/#/festival/<id>?date=…`, `/app/#/tools/converter`). A first visit keeps the link through onboarding and opens it afterwards (only in-app paths).
- [x] Privacy, "how dates are computed" and contact pages; Play Store link placeholder.
  - `/privacy/`, `/how-dates-are-computed/`, `/contact/` in both languages, linked from every page's footer. The home page has an "Android app" card with "Google Play: coming soon" (`#play-link`) to replace with the listing URL. The privacy page mirrors `docs/privacy.md` and is still marked draft (Needs you: review, contact email).

### Day 23: Sprint 11a, accuracy campaign (status: done)
- [x] `docs/accuracy-checklist.md`: every 2026–2027 month start, festival and pirannal example with a column for the almanac value (filling it is **Needs you**); a script that prints the app's values.
  - `dart run site_data:accuracy_checklist --from 2026 --to 2027` (in `apps/site_data`) prints all of it: 24 month starts with the sankranti time and its margin to the cut-off (⚠ under 30 minutes), every Hindu, Christian and Muslim festival with its holiday-list kind, the rules doc's worked examples (Pooradam in Dhanu, Ekadashi shraddham in Karkidakam), and every star that falls on two days of a month (94, R1) or none (16, R2) with the day the app picks. Tested in `apps/site_data/test/accuracy_test.dart`.
- [x] Fix anything found from sources available online.
  - The checklist compares the Kerala holiday lists with the computed festivals. One difference: Vishu, listed on 15 April 2026, computed 14 April (Medam 1). Vishu is the first sunrise after the Mesha sankranti (09:39 on 14 April 2026); the engine now follows that, checked against six published years (2021–2026). `kollavarsham` CHANGELOG has it under Unreleased. After the fix, every listed festival falls on its computed day.
  - Almanac columns stay empty: no printed almanac or Kerala panchangam with minute-level month starts was reachable online.

### Day 24: Sprint 11b, launch preparation (status: todo)
- [ ] `docs/runbook.md`: yearly holiday data, almanac checks, dependency updates, release steps for the app, packages and site.
- [ ] Final polish: README for `apps/`, top-level README update, CHANGELOGs; all CI green.

## Log

| Date | Day | Result |
|---|---|---|
| 2026-10-29 | Day 1 | apps/calendar scaffold (in.armid.calendar), Riverpod/go_router/gen-l10n, Noto Sans Malayalam, M3 home screen with tests, CI app job (web + debug APK artifacts) green |
| 2026-10-30 | Day 2 | docs/pirannal-rules.md (draft defaults, sourced where possible, open questions), docs/design.md (IA, wireframes, colour/type), data/holidays schema plus 2026.json (complete per source) and 2027.json (partial: NI Act list only), docs/privacy.md draft; no code changes, so no test run |
| 2026-10-30 | Day 3 | Recurrence engine (NakshatraInMonth, NakshatraMonthly, MalayalamDateYearly/Monthly, GregorianYearly), DuplicateRule/AbsentRule, JSON; 37 new tests incl. Onam 2009–2025 cross-check and 1950–2100 property tests; all 146 core tests pass |
| 2026-10-30 | Day 4 | BirthDetails (pada, rashi, tithi, Malayalam date), Rashi, TithiInMonth (shraddham, afternoon rule) and TithiEveryPaksha, kollavarsham 1.1.0 (no tag); 171 core, 21 widget and 4 app tests pass; R4 differs from Karkidaka Vavu in 2024, sent to owner review |
| 2026-10-30 | Day 5 | Yoga, Karana, Kalam (Rahu, Gulika, Yamagandam), moonrise/moonset and Chandrashtamam, checked against 30 days of drikpanchang for Thiruvananthapuram and 13 published Mesha periods; 397 core, 21 widget and 4 app tests pass |
| 2026-11-01 | Day 6 | Nine festivals (Dhanu Thiruvathira left out: sources disagree), vrat lists, Easter and Christian feasts, tentative Hijri festivals, festivalsIn crash fixed, kollavarsham 1.2.0 (no tag); 436 core, 21 widget and 4 app tests pass |
| 2026-11-02 | Day 7 | Five-tab go_router shell, persisted settings (language, name script, digits, 14 Kerala cities or manual location, year start, calendar mode, theme), three-step onboarding, ml/en strings with a parity test; 21 app tests pass, web build OK |
| 2026-11-02 | Day 8 | Today panchangam summary and next festival, Day detail screen (/day/yyyy-mm-dd) with every span to the next sunrise, Calendar tab opens days, 12 Windows-only goldens; 44 app tests pass, web build OK |
| 2026-11-02 | Day 9 | Versioned JSON database in shared_preferences (people, events, reminders; migrations; drift deferred, see Needs you), Riverpod repository with cascading deletes, People list, editor and detail; 57 app tests pass |
| 2026-11-02 | Day 10 | Event editor with six presets and duplicate-rule picker, Find my star, upcoming events on Today and person detail, person-colour calendar markers; Midhun/Pooradam/Dhanu test; 63 app tests pass |
| 2026-11-02 | Day 11 | Pure-Dart ReminderScheduler (60 days, stable ids, fake-clock tests), ml/en notification templates, month and year start reminders; 72 app tests pass |
| 2026-11-02 | Day 12 | flutter_local_notifications scheduling with exact/inexact fallback, Open/Snooze actions, daily workmanager job, boot receiver, Settings → Reminders (types, month/year starts, festival categories, daily panchangam); 84 app tests pass, debug APK and web build OK; not run on a device |
| 2026-11-02 | Day 13 | Bundled holiday data merged with computed festivals (alias matching, announced Muslim dates), six persisted category filters, Agenda with search; 93 app tests pass, web build OK |
| 2026-11-02 | Day 14 | Festival detail (description, rule, source, next 5 dates, share), year view, ml/en descriptions for every festival and holiday, name_ml in the holiday files; 101 app tests pass, web build OK |
| 2026-11-02 | Day 15 | Tools tab (converter, Find my star, age, days between, year info), panchangam and greeting share cards as PNG; 109 app tests pass, web build OK |
| 2026-11-02 | Day 16 | .ics export (explicit dates, N years), versioned JSON backup and restore with file_picker, Auto Backup rules; 116 app tests pass, debug APK and web build OK |
| 2026-11-02 | Day 17 | Today and Next pirannal home-screen widgets (week of text ahead), static launcher shortcuts via deep links, Report a wrong date, North Malabar checks; 124 app tests pass, debug APK and web build OK |
| 2026-11-02 | Day 18 (part) | Accessibility pass: guideline tests on 15 screens, holiday colour contrast, year-view semantics and large-text fixes; 156 app tests pass. Stopped here at the owner's request |
| 2026-11-03 | Day 18 | Bottom-bar labels on one line, R8 release build (arm64 19.9 MB), key.properties signing, docs/release.md and docs/store-listing.md, privacy draft corrected |
| 2026-11-03 | Day 19 | calendar_data package (shared festival/holiday model), site_data CLI (13 years of days, months, festivals as JSON), converter_js (115 KB JS converter and star finder, checked in Node) |
| 2026-11-03 | Day 20 | Astro site (10,701 pages, en/ml with hreflang, JSON-LD, sitemap, OG image, browser-side today/star/converter), link checker, CI site job, deploy of site at / and app at /app/ |
| 2026-11-03 | Day 21 | Flutter web app at /app/ (verified locally), web reminder list with .ics export link; 159 app tests pass |
| 2026-11-03 | Day 22 | Offline PWA at /app/ (own service worker, local CanvasKit, headless-Chrome offline check), site→app deep links surviving onboarding, privacy/how-computed/contact pages, Play placeholder; 161 app tests pass, 10,707 site pages with all links resolving |
| 2026-11-03 | Day 23 | Accuracy checklist generator and docs/accuracy-checklist.md (24 month starts, festivals, 110 pirannal edge cases, shraddham), holiday list vs computed check; fixed Vishu (first sunrise after the Mesha sankranti; 2026 is 15 April); 437 core, 161 app tests pass |
