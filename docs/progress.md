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

- [ ] Review `docs/pirannal-rules.md` (Day 2) and confirm the default rules, including the unsourced R2 (star absent in the month) default and the sunrise anchor for R3.
- [ ] Complete `data/holidays/2027.json`: it currently holds only the Negotiable Instruments Act list (G.O. (P) No. 20/2026/GAD). Add the state government list (Onam, Mahanavami, Vijayadasami, Karkidaka Vavu, Easter, Milad-i-Sherif, Independence Day, Kerala Piravi, restricted holidays) from the gazette.
- [ ] Settle the 2026 holiday conflicts noted in `data/holidays/2026.json`: the G.O. number (14 or 15/2025/GAD), Navaratri (20 Oct in the source vs a 19 Oct order reported by an aggregator), and whether Kerala Piravi (1 Nov) is a 2026 holiday.
- [ ] Review `docs/privacy.md` and `docs/design.md` open questions, and set the contact email in the privacy policy.
- [ ] Create the Google Play developer account; recruit 12 closed testers (needed by Day 18).
- [ ] Create a release keystore and add it as described in `docs/release.md` (Day 18).
- [x] Choose the website domain and DNS (Day 20): `calendar.armid.in`, a CNAME to `midhunarmid.github.io`.
- [ ] Check 2026–2027 dates against printed almanacs (Day 23).
- [ ] Malayalam copy review by a native editor (Day 24).

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

### Day 4: Sprint 1b, birth details and shraddham (status: todo)
- [ ] `BirthDetails.fromInstant(DateTime, {calendar})`: nakshatra with pada, rashi, Malayalam date, tithi; tests against known values.
- [ ] `TithiInMonth` (shraddham by tithi) and `TithiEveryPaksha` (e.g. every Ekadashi) recurrences, with tests.
- [ ] Export the new APIs; README section; CHANGELOG `1.1.0`; bump to 1.1.0 (no tag); update the dependents' constraints.

### Day 5: Sprint 2a, panchangam extras (status: todo)
- [ ] Yoga and karana (enums with Malayalam/English names, values at an instant and at sunrise, spans).
- [ ] Rahu kalam, Gulika kalam and Yamagandam from sunrise/sunset and the weekday; tests against published values.
- [ ] Moonrise/moonset; Chandrashtamam for a birth star.

### Day 6: Sprint 2b, festivals (status: todo)
- [ ] New festivals, each with ≥5 years of sourced dates (follow the existing rule in `festivals.dart`): Sivaratri, Ashtami Rohini, Vinayaka Chathurthi, Navaratri (Durgashtami, Mahanavami, Vijayadasami), Deepavali, Thaipooyam, Guruvayur Ekadashi, and Thiruvathira if the sources agree. Leave out any whose rule can't be verified, and note why.
- [ ] Vrat lists: Ekadashi, Pradosham, Shashti, Pournami, Amavasya for a year.
- [ ] Christian movable feasts (Easter computus) and fixed days; tentative Hijri festivals (tabular calendar).
- [ ] CHANGELOG `1.2.0`; bump the version (no tag).

### Day 7: Sprint 3a, app shell (status: todo)
- [ ] go_router navigation (bottom bar: Today, Calendar, People, Tools, Settings), theme with light/dark/system, ml/en l10n for every UI string.
- [ ] Settings storage (shared_preferences): language, script, Malayalam digits, location (Kerala cities + manual lat/long/time zone), year start, default calendar mode, theme.
- [ ] Onboarding flow: language, location, what notifications are for.

### Day 8: Sprint 3b, Today, Month and Day screens (status: todo)
- [ ] Today: both dates, nakshatra/tithi with times, sunrise/sunset, rahu kalam, gulika, yamagandam, today's festivals, next festival.
- [ ] Calendar tab: `MalayalamMonthView` in both modes with festival markers; tap a day for the Day detail screen.
- [ ] Day detail screen with the full panchangam and festivals.
- [ ] Golden tests for Today, Month and Day (ml/en, light/dark).

### Day 9: Sprint 4a, database and people (status: todo)
- [ ] drift database (native + web) with tables `people`, `events` (type, recurrence JSON, colour, notes), `reminders`, plus migrations and tests.
- [ ] Repositories and Riverpod providers.
- [ ] People list, person editor (name, relation, colour, optional photo) and person detail.

### Day 10: Sprint 4b, events and pirannal (status: todo)
- [ ] Event editor with presets: pirannal (star + Malayalam month), monthly nakshatram, Gregorian birthday, shraddham (tithi or star in a month), anniversary, custom (any recurrence); duplicate-rule picker with an explanation.
- [ ] "Find my star" flow (birth date, time, place → `BirthDetails`) that pre-fills a pirannal.
- [ ] Upcoming list with countdowns; person colours as markers on the calendar.
- [ ] Widget tests: create "Midhun: Pooradam, Dhanu" and check the next 5 pirannals and 12 nakshatram days.

### Day 11: Sprint 5a, reminder scheduler (status: todo)
- [ ] Pure-Dart scheduler: from events and reminder settings, compute the notifications for the next 60 days, with stable IDs per (event, date, offset). Unit tests with a fake clock.
- [ ] Message templates (ml/en) with `{name}`, `{star}`, `{month}`, `{age}`, e.g. "Midhun's pirannal (Pooradam)", "Midhun's nakshatram".
- [ ] Month and year start reminders ("Chingam 1 tomorrow: Malayalam New Year 1202").

### Day 12: Sprint 5b, Android notifications (status: todo)
- [ ] flutter_local_notifications + timezone: schedule and cancel from the scheduler output; `POST_NOTIFICATIONS` and exact-alarm permission flows with fallback.
- [ ] Reschedule on app start, on boot, on time/time-zone change, and in a daily workmanager job.
- [ ] Daily panchangam notification (optional); festival reminders by category; actions (Open, Snooze).
- [ ] Reminder settings screen.

### Day 13: Sprint 6a, holidays and agenda (status: todo)
- [ ] Holiday data loader for `data/holidays/*.json` (bundled as assets), merged with computed festivals.
- [ ] Category filters (Hindu, Christian, Muslim, national, government, bank), persisted.
- [ ] Agenda tab or section: upcoming festivals, holidays and personal events; search by name.

### Day 14: Sprint 6b, festival details and year view (status: todo)
- [ ] Festival detail screen: Malayalam and English description, rule, next 5 dates, share.
- [ ] Year view (12 mini-months with festival dots) in `kollavarsham_flutter` or the app.
- [ ] Descriptions content for all festivals (ml/en).

### Day 15: Sprint 7a, tools and sharing (status: todo)
- [ ] Tools tab: date converter (both directions), age calculator, days between dates, Kollavarsham year info.
- [ ] Share cards rendered as images: today's panchangam, pirannal greeting.

### Day 16: Sprint 7b, export and backup (status: todo)
- [ ] .ics export of selected events for N years (explicit dates).
- [ ] JSON backup/restore (versioned), file picker/share; Android Auto Backup rules; round-trip tests.

### Day 17: Sprint 8a, Android widgets and extras (status: todo)
- [ ] Home-screen widgets via `home_widget`: Today (date, star, festival) and Next pirannal; refreshed daily.
- [ ] App shortcuts; "Report a wrong date" (pre-filled GitHub issue URL); North Malabar year setting wired through.

### Day 18: Sprint 8b, release readiness (status: todo)
- [ ] Accessibility pass (semantics, large text, contrast) and performance (R8/minify, startup, size).
- [ ] Release signing config reading `key.properties` (not committed) and `docs/release.md`; mark the keystore as **Needs you**.
- [ ] `docs/store-listing.md`: Play listing text (ml/en), screenshot list, data-safety answers.

### Day 19: Sprint 9a, site data and converter (status: todo)
- [ ] `apps/site_data`: a Dart CLI writing JSON for the current year −2 to +10 (days, months, festivals, panchangam) into `apps/site/src/data/`.
- [ ] `apps/converter_js`: the engine compiled with `dart compile js`, exposing a converter and star finder for the site.

### Day 20: Sprint 9b, static site (status: todo)
- [ ] `apps/site` (Astro): home/today, day pages, month pages, festival-per-year pages, "nakshatra today", "Malayalam calendar YYYY"; ml/en with `hreflang`; structured data; sitemap; OG images.
- [x] GitHub Pages deployment workflow (`.github/workflows/deploy-web.yml`, domain `calendar.armid.in`).

### Day 21: Sprint 10a, Flutter web app (status: todo)
- [ ] Web build of `apps/calendar` served at `/app` of the site; drift on IndexedDB; web-specific reminder UI (upcoming list + .ics instead of notifications).

### Day 22: Sprint 10b, PWA and site pages (status: todo)
- [ ] PWA manifest and offline caching for `/app`; deep links from site pages to the app.
- [ ] Privacy, "how dates are computed" and contact pages; Play Store link placeholder.

### Day 23: Sprint 11a, accuracy campaign (status: todo)
- [ ] `docs/accuracy-checklist.md`: every 2026–2027 month start, festival and pirannal example with a column for the almanac value (filling it is **Needs you**); a script that prints the app's values.
- [ ] Fix anything found from sources available online.

### Day 24: Sprint 11b, launch preparation (status: todo)
- [ ] `docs/runbook.md`: yearly holiday data, almanac checks, dependency updates, release steps for the app, packages and site.
- [ ] Final polish: README for `apps/`, top-level README update, CHANGELOGs; all CI green.

## Log

| Date | Day | Result |
|---|---|---|
| 2026-10-29 | Day 1 | apps/calendar scaffold (in.armid.calendar), Riverpod/go_router/gen-l10n, Noto Sans Malayalam, M3 home screen with tests, CI app job (web + debug APK artifacts) green |
| 2026-10-30 | Day 2 | docs/pirannal-rules.md (draft defaults, sourced where possible, open questions), docs/design.md (IA, wireframes, colour/type), data/holidays schema plus 2026.json (complete per source) and 2027.json (partial: NI Act list only), docs/privacy.md draft; no code changes, so no test run |
| 2026-10-30 | Day 3 | Recurrence engine (NakshatraInMonth, NakshatraMonthly, MalayalamDateYearly/Monthly, GregorianYearly), DuplicateRule/AbsentRule, JSON; 37 new tests incl. Onam 2009–2025 cross-check and 1950–2100 property tests; all 146 core tests pass |
