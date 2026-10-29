# Malayalam Calendar app (Android + web): feature list and sprint plan

## Context

`kollavarsham` and `kollavarsham_flutter` (1.0.0, in this repo) provide an accurate Malayalam calendar engine and calendar widgets. The next step is a consumer product built on them: a complete Malayalam calendar for **Android** and the **web**. Its distinguishing feature is **star-based birthdays (pirannal)**. Example: "my pirannal is Pooradam in Dhanu". The app then reminds you every year ("Midhun's pirannal") and, if you choose, every month when that star returns ("Midhun's nakshatram").

Decisions taken:
- **Local-only data.** No accounts, no backend, no analytics. Backup is a file export.
- **Web:** a static, SEO-friendly site (a page for every day, month and festival) plus the Flutter app at `/app`.
- **Code** lives in this monorepo under `apps/`.
- **Free, no ads**, with free hosting.

The plan has three parts: a complete **feature catalogue**, the **architecture**, and **12 two-week sprints** (Sprint 0–11, about 24 weeks), each with tasks and "done when" criteria.

---

## 1. Feature catalogue

Priority: **P0** is the MVP, needed for the Play Store launch. **P1** is in the launch version if the sprints allow. **P2** is backlog.

### A. Calendar views
| # | Feature | Pri |
|---|---|---|
| A1 | Month view: Malayalam months (Chingam…) or Gregorian months with Malayalam dates (wall-calendar style), swipe, jump to month/year | P0 |
| A2 | Day detail: Malayalam date, weekday, nakshatra and tithi with start/end times, paksha, sunrise/sunset, festivals, holidays, your events | P0 |
| A3 | Today screen (home): today's date in both calendars, panchangam summary, today's and upcoming pirannals and events, next festival | P0 |
| A4 | Year view: 12 mini-months with festival dots; tap a month to open it | P1 |
| A5 | Agenda/list view: upcoming festivals, holidays and events | P0 |
| A6 | Go to date and "Today" button; search by festival or date | P1 |
| A7 | Kollavarsham year info: year number, start/end dates, month lengths | P1 |
| A8 | Printable or PDF month calendar (web) | P2 |

### B. Panchangam (daily almanac)
| # | Feature | Pri |
|---|---|---|
| B1 | Nakshatra (with times), tithi (with times), paksha | P0 |
| B2 | Sunrise and sunset for the chosen location | P0 |
| B3 | Rahu kalam, Gulika kalam, Yamagandam | P0 |
| B4 | Yoga and Karana (the remaining two of the five panchanga elements) | P1 |
| B5 | Moonrise/moonset, Chandrashtamam for your birth star | P1 |
| B6 | Auspicious time helpers: Abhijit muhurtham, good/bad days by weekday and star | P2 |
| B7 | Ekadashi, Pradosham, Shashti, Pournami and Amavasya lists for the year (vrat days) | P1 |
| B8 | Muhurtham (wedding and housewarming dates). This needs almanac data, so it's backlog unless a reliable source is found | P2 |

### C. Festivals and holidays
| # | Feature | Pri |
|---|---|---|
| C1 | Computed Hindu festivals: Onam with the Atham–Thiruvonam days, Vishu, Thiruvathira, Sivaratri, Ashtami Rohini, Vinayaka Chathurthi, Navaratri (Durgashtami, Mahanavami, Vijayadasami), Deepavali, Karkidaka Vavu, Mandala/Makaravilakku, Attukal Pongala, Thrissur Pooram, Thaipooyam, Guruvayur Ekadashi | P0 (from the existing package) / P1 (new ones) |
| C2 | Christian: Easter, Good Friday, Maundy Thursday, Palm Sunday (computed), Christmas, New Year | P1 |
| C3 | Muslim: Ramadan start, Eid ul-Fitr, Bakrid, Muharram, Milad-un-Nabi, from the tabular Hijri calendar. Shown as **tentative** and replaced by announced dates from the holiday data | P1 |
| C4 | National days: Republic Day, Independence Day, Gandhi Jayanthi, May Day, Kerala Piravi | P0 |
| C5 | Kerala Government public holidays and bank holidays for each year, from a curated data file (per year, with source links) | P0 |
| C6 | Filters by category (Hindu, Christian, Muslim, national, government, bank); only show the ones I choose | P1 |
| C7 | Festival detail: description in Malayalam and English, date rule, the next five years' dates, share | P1 |
| C8 | Major temple festivals (Guruvayur, Sabarimala and others), as a curated list | P2 |

### D. Pirannal and personal events (the core feature)
| # | Feature | Pri |
|---|---|---|
| D1 | **People:** name, relation (self, family, friend), optional photo, colour | P0 |
| D2 | **Star birthday (pirannal):** birth nakshatra + birth Malayalam month → one date each year | P0 |
| D3 | **Monthly nakshatram:** every day the birth star recurs (~27.3 days), e.g. "Midhun's nakshatram" | P0 |
| D4 | **"Find my star":** enter birth date, time and place to get the nakshatra, Malayalam month, rashi and Kollavarsham date, then create the pirannal from it | P0 |
| D5 | Gregorian birthday (with age) alongside the star birthday | P0 |
| D6 | **Shraddham / death anniversary (Aandu):** yearly by nakshatra or by tithi in a Malayalam month, as Kerala families observe it | P0 |
| D7 | Wedding and other anniversaries: by Gregorian date or by Malayalam date (e.g. "Thulam 12") | P1 |
| D8 | Custom recurring events: by Malayalam date each year or month, by nakshatra (monthly or yearly), by tithi (e.g. every Ekadashi), or by Gregorian date | P1 |
| D9 | Handling the rare cases: the star occurring twice in the month, or not at all (rule picker with a sensible default and an explanation) | P0 |
| D10 | Upcoming list: next occurrences for everyone, with countdowns ("in 3 days") | P0 |
| D11 | Calendar markers and colours per person on the month view | P0 |
| D12 | Notes and checklists per event (e.g. temple offering, sadhya) | P2 |
| D13 | Import Gregorian birthdays from phone contacts (Android) | P2 |

### E. Reminders and notifications
| # | Feature | Pri |
|---|---|---|
| E1 | Per-event reminders: same day at a chosen time, 1 day before, N days before; several per event | P0 |
| E2 | Configurable message templates per event type, in Malayalam or English: "{name}'s pirannal (Pooradam)", "{name}'s nakshatram" | P0 |
| E3 | **Start reminders** for months and years: "Chingam 1 tomorrow: Malayalam New Year 1202", "Thulam month begins" | P0 |
| E4 | Daily morning panchangam notification (date, star, rahu kalam), optional | P1 |
| E5 | Festival and holiday reminders, per category or per festival | P1 |
| E6 | Notification actions: "Open", "Snooze 1 hour", "Mark done" | P1 |
| E7 | Reliable delivery: exact alarms, rescheduling after reboot and time-zone or clock changes, the Android 13+ permission flow, battery-optimisation guidance | P0 |
| E8 | Web: no background push without a server, so the web app offers **.ics export** (Google or other calendar import) and in-app "upcoming" lists instead | P0 |

### F. Tools
| # | Feature | Pri |
|---|---|---|
| F1 | Date converter: Gregorian ↔ Malayalam, both directions | P0 |
| F2 | Age calculator, plus days between two dates | P1 |
| F3 | Birth star finder (= D4) | P0 |
| F4 | Share as image: today's panchangam card, pirannal greeting card ("ജന്മദിനാശംസകൾ") | P1 |
| F5 | Export events to .ics with explicit dates for the next N years (calendar apps can't express star recurrences) | P0 |
| F6 | Backup and restore: export/import a JSON file, plus Android Auto Backup (the device's own backup, no server of ours) | P0 |

### G. Settings and personalisation
| # | Feature | Pri |
|---|---|---|
| G1 | Interface language: Malayalam / English; names in Malayalam script or transliteration; Malayalam digits | P0 |
| G2 | Location for sunrise and month starts: Kerala cities, current location (optional permission) or manual; time zone, so the Gulf and other countries can still use Kerala dates | P0 |
| G3 | Year convention: Chingam (default) or Kanni (North Malabar) | P1 |
| G4 | Week start, default view (Malayalam or Gregorian mode), theme (light, dark, system), accent colour | P0 |
| G5 | Notification defaults (time of day, which categories) | P0 |
| G6 | "How dates are computed" page and "Report a wrong date" (opens a pre-filled GitHub issue or email) | P1 |

### H. Android platform
| # | Feature | Pri |
|---|---|---|
| H1 | Home-screen widgets: today (Malayalam date, star, festival), plus next pirannal and upcoming events | P1 |
| H2 | App shortcuts: add pirannal, today, converter | P2 |
| H3 | Fully offline; app under ~15 MB; cold start under 1.5 s on mid-range phones | P0 |
| H4 | Accessibility: TalkBack labels, large text, contrast | P0 |
| H5 | Bundled Malayalam font (Noto Sans Malayalam / Manjari) for consistent rendering | P0 |
| H6 | Wear OS tile, Android Auto, iOS | P2 |

### I. Website
| # | Feature | Pri |
|---|---|---|
| I1 | Static SEO site: home (today), a page per **day** (`/2026/10/29`), **month** (`/2026/10`, `/thulam-1202`), **festival per year** (`/onam/2027`), "nakshatra today" and "Malayalam calendar 2027" pages | P0 |
| I2 | Malayalam and English versions with `hreflang`, structured data (Event, Date), sitemaps, Open Graph images | P0 |
| I3 | Interactive date converter and "find my star" on the site, using the Dart engine compiled to JS | P1 |
| I4 | Flutter web app at `/app`: the full app with local storage in the browser (IndexedDB) and .ics export | P1 |
| I5 | PWA install for `/app` | P2 |
| I6 | Privacy page, "how dates are computed", Play Store link, contact | P0 |

### J. Quality, privacy and operations
| # | Feature | Pri |
|---|---|---|
| J1 | No accounts, no tracking, no network at runtime (Play "no data collected") | P0 |
| J2 | Accuracy campaign: compare 2026–2027 against printed almanacs; feed corrections into `verifiedMonthStarts` | P0 |
| J3 | Automated tests: engine, recurrence, notification scheduling, widget and golden tests, integration tests on emulator | P0 |
| J4 | CI builds of the APK/AAB and the website; release via Play internal testing | P0 |
| J5 | Yearly maintenance: holiday data for the next year, almanac checks | P0 |

---

## 2. Architecture

```
apps/
  calendar/            Flutter app (Android + web), in the pub workspace
    lib/
      app/             routing (go_router), theme, l10n (ARB: ml, en)
      features/        today/ month/ day/ people/ events/ reminders/
                       festivals/ tools/ settings/ backup/
      data/            drift database, repositories
      services/        notifications, widgets, ics, share
  site/                Astro static website (SEO pages)
  site_data/           Dart CLI: generates the site's JSON from the engine
  converter_js/        Dart → JS bundle for the site's interactive tools
packages/
  kollavarsham/        + recurrence, birth-star, panchangam extras, more festivals
  kollavarsham_flutter/ + year view, day cells with person colours
data/
  holidays/2026.json   curated Kerala Government / bank holidays, with sources
```

**Key choices**

| Concern | Choice | Why |
|---|---|---|
| State | Riverpod | Testable, no context plumbing |
| Database | drift (SQLite; on the web, SQLite WASM in IndexedDB) | One schema for Android and web, migrations, reactive queries |
| Notifications | flutter_local_notifications + timezone | Exact scheduled notifications on Android |
| Background refresh | workmanager (daily) | Tops up the rolling reminder window |
| Home widgets | home_widget + Kotlin/Glance layouts | Native Android widgets fed from Dart |
| i18n | Flutter gen-l10n with ARB files | Malayalam and English UI |
| Website | Astro | Static HTML, fast and SEO-friendly; consumes JSON from `site_data` |
| Hosting | Cloudflare Pages or GitHub Pages | Free, CDN, custom domain |

**Reminder scheduling.** Android allows only a limited number of pending alarms (~500), and star recurrences can't be expressed as repeating alarms. So:
1. Compute each event's occurrences with the engine.
2. Schedule only those in the next 60 days.
3. A daily workmanager job, app start, boot (`RECEIVE_BOOT_COMPLETED`) and time-zone or clock change broadcasts all re-run the scheduler, which is idempotent: notification IDs are derived from (event, date, offset).
4. Calendar apps qualify for `USE_EXACT_ALARM`. Fall back to inexact alarms if denied, and show a hint.

**Engine additions** (go into `packages/kollavarsham`, which is public API and reusable):
- **Recurrence:** `Recurrence` types:
  - `NakshatraInMonth` (yearly pirannal)
  - `NakshatraMonthly`
  - `TithiInMonth` (shraddham)
  - `MalayalamDateYearly` / `MalayalamDateMonthly`
  - `GregorianYearly`
  - `TithiEveryPaksha` (e.g. Ekadashi)

  Each has `occurrencesBetween(from, to)` and `next(after)`, plus a configurable `DuplicateRule` (first / second / sunrise + 6 nazhika). This reuses `daysWithNakshatra`, `tithiOn`, `nakshatraSpanAt` and `MalayalamDate` arithmetic in `lib/src/calendar.dart` and `lib/src/malayalam_date.dart`.
- **Birth details:** `BirthDetails.fromInstant(dateTime, location)`, returning the nakshatra (with pada), rashi, Malayalam date and tithi. Uses `moonSiderealLongitude` (`lib/src/astro/moon.dart`).
- **Panchangam extras:** yoga, karana, rahu/gulika/yamagandam (from `sunrise`/`sunset` and the weekday), moonrise/moonset.
- **More festivals:** extend `KeralaFestival` (`lib/src/festivals.dart`). Each needs ≥5 years of sourced dates, the existing rule.
- **Christian and Hijri calendars:** Easter computus; tabular Hijri marked tentative.

---

## 3. Sprints (2 weeks each)

### Sprint 0: Foundations and research
- Set up `apps/calendar` (Flutter, Android + web) in the pub workspace; CI builds APK, web and tests.
- Design: information architecture, wireframes for Today, Month, Day, People, Event editor, Reminders and Settings; colour and type system; a Malayalam font licence check.
- **Research spike (blocking D2/D6/D9):** pirannal rules when the star falls twice in a month, the "6 nazhika after sunrise" convention, and shraddham by tithi versus nakshatra. Collect the rules from at least two almanac publishers or astrologers; write `docs/pirannal-rules.md` with sourced examples.
- Holiday data format and the 2026–2027 Kerala Government holiday list, with sources.
- Privacy policy draft; Play Console account; app name, icon and package ID.
- **Done when:** the app runs "Hello Kollavarsham" on Android and web from CI artifacts, and the rules document is reviewed.

### Sprint 1: Engine: recurrences and birth star
- `Recurrence` API and `DuplicateRule`, with tests against sourced pirannal examples.
- `BirthDetails.fromInstant` (nakshatra + pada, rashi, Malayalam date), tested against known horoscopes or drikpanchang values.
- Monthly nakshatra recurrence; tithi-in-month for shraddham; Malayalam-date anniversaries.
- Publish `kollavarsham` 1.1.0.
- **Done when:** for 20 sourced examples the computed pirannal and shraddham dates match, and all occurrences 1900–2100 are monotonic with no gaps (property tests).

### Sprint 2: Engine: panchangam extras and festivals
- Yoga and karana; rahu kalam, gulika and yamagandam; moonrise/moonset; Chandrashtamam.
- New festivals, each with ≥5 years of sourced dates: Thiruvathira, Sivaratri, Ashtami Rohini, Vinayaka Chathurthi, Navaratri days, Deepavali, Thaipooyam, Guruvayur Ekadashi; vrat lists (Ekadashi, Pradosham, Shashti).
- Christian movable feasts (Easter computus); tentative Hijri festivals.
- `kollavarsham` 1.2.0.
- **Done when:** rahu kalam matches a published panchangam within 2 minutes for 30 days, and every festival has a passing test table.

### Sprint 3: App shell, Today and Month
- Routing, theme (light/dark), l10n (ml/en), bundled font, settings storage.
- Onboarding: language, location, notification permission explained.
- Today screen (A3/B1–B3), Month view in both modes (A1, from `MalayalamMonthView`), Day detail (A2).
- Settings G1, G2, G4.
- **Done when:** golden tests pass for Today, Month and Day in ml/en and light/dark; it runs on Android 8–15 emulators and in Chrome.

### Sprint 4: People and events
- drift schema: `people`, `events` (type, recurrence JSON, colour), `reminders`, `settings`; migrations from the start.
- Screens:
  - People list and person editor.
  - Event editor with type presets: pirannal, monthly nakshatram, Gregorian birthday, shraddham, anniversary, custom (D1–D9).
  - "Find my star" flow (D4) that pre-fills a pirannal.
- Upcoming list with countdowns (D10); person colours and markers on the month view (D11).
- **Done when:** you can create "Midhun: Pooradam, Dhanu" and see the next five pirannals and the next twelve nakshatram days, all matching the engine.

### Sprint 5: Reminder engine
- Scheduler service: a rolling 60-day window, idempotent IDs, rescheduling on boot, time change, app start and the daily workmanager job (E7).
- Reminder offsets and times per event (E1); message templates in ml/en with `{name}`, `{star}`, `{month}`, `{age}` (E2).
- Month and year start reminders (E3); daily panchangam notification (E4); festival reminders (E5); actions (E6).
- Permission flows: `POST_NOTIFICATIONS`, exact alarms, battery-optimisation hint.
- **Done when:** integration tests on an emulator with a fake clock deliver the expected notifications across a reboot and a time-zone change, and a 12-month simulated schedule never exceeds 400 pending alarms.

### Sprint 6: Festivals and holidays content
- Holiday data loader (bundled JSON per year, plus a newer bundled version on each app update).
- Category filters (C6); festival detail pages with descriptions and the next five dates (C7); year view (A4); agenda (A5); search (A6).
- Malayalam and English festival descriptions (content task).
- **Done when:** every 2026–2027 Kerala Government holiday appears on the right date with its source, and filters persist.

### Sprint 7: Tools, sharing and backup
- Converter (F1), age and days-between (F2), year info (A7).
- Share cards rendered to an image (F4).
- .ics export of chosen events for N years (F5/E8).
- JSON backup/restore with versioning and conflict handling; Android Auto Backup rules (F6).
- **Done when:** an .ics export imports correctly into Google Calendar and backup → reinstall → restore reproduces all data and reminders.

### Sprint 8: Android polish and Play Store readiness
- Home-screen widgets (H1); app shortcuts (H2).
- Accessibility audit (H4); performance (H3: size, startup, jank); R8/minify; crash-free runs.
- "Report a wrong date" (G6); North Malabar setting (G3).
- Store listing in ml/en, screenshots, feature graphic, data-safety form ("no data collected"), privacy policy URL.
- **Closed test:** new personal developer accounts must run a closed test with **at least 12 testers for 14 days** before production. Start it at the end of this sprint.
- **Done when:** the AAB is uploaded to closed testing, Play pre-launch report is clean, and there are no accessibility scanner errors.

### Sprint 9: Website I: SEO static site
- `apps/site_data`: a Dart CLI that writes JSON for a configurable year range (e.g. the current year −2 to +10): days, months, festivals, panchangam.
- `apps/site` (Astro): home/today, day, month and festival-per-year pages, "nakshatra today", "Malayalam calendar YYYY"; ml/en with `hreflang`; structured data; sitemaps; OG images.
- `apps/converter_js`: compile the engine with `dart compile js` for the interactive converter and star finder (I3).
- Deploy to Cloudflare Pages or GitHub Pages; custom domain.
- **Done when:** Lighthouse scores ≥95 for performance and SEO on the day and festival pages, the sitemap validates, and page dates match the app for a sampled 100 days.

### Sprint 10: Website II: Flutter web app
- Build the app for the web at `/app`: drift on IndexedDB, no notifications, an "upcoming" panel, .ics export (I4/E8).
- PWA manifest and offline caching (I5); deep links from site pages into the app.
- Privacy, "how dates are computed" and contact pages (I6).
- **Done when:** data persists across browser restarts, the .ics export works, and `/app` loads in under 3 s on a mid-range phone over 4G.

### Sprint 11: Beta, accuracy campaign and launch
- Accuracy campaign (J2): compare every 2026–2027 month start, festival and pirannal example against two printed almanacs; fix or add overrides.
- Beta feedback triage from the closed test; bug fixes; Malayalam copy review by a native editor.
- Production release on Play; website launch; announce.
- Maintenance runbook (J5): yearly holiday data, almanac checks, dependency updates.
- **Done when:** the production rollout reaches 100% with a crash-free rate ≥99.5%, the website is live, and the runbook is committed.

### Backlog (after launch)
Muhurtham (B8), temple festivals (C8), PDF calendars (A8), contacts import (D13), event notes (D12), Wear OS, iOS, family sharing via shared export files, jathakam (lagna and planetary positions), a Tamil calendar mode.

---

## 4. Risks and open questions

- **Pirannal edge rules** (D9) vary by family and almanac. Sprint 0 research picks a default and makes it configurable, with an explanation in the app.
- **Shraddham rule** (tithi or nakshatra; which time of day counts) needs the same research.
- **Muslim festival dates** depend on moon sighting. Show them as tentative until the yearly holiday data confirms them.
- **Exact alarms** need the Play declaration (calendar apps qualify for `USE_EXACT_ALARM`); fall back gracefully if denied.
- **No backend** means no cross-device sync and no web push. The mitigations are file export/import and .ics.
- **Borderline month starts:** the app shows a small "almanacs may differ" note on days where `monthStartMargin` is under 10 minutes.

## 5. Verification (applies to every sprint)

- `dart test` / `flutter test` across packages and apps in CI, plus `dart test -p chrome` for the engine.
- Golden tests for key screens in ml/en and light/dark.
- Android integration tests (`integration_test`) on emulators for API 26, 33 and 35: onboarding, creating a pirannal, receiving a notification with a fake clock, reboot rescheduling.
- Website: a build that fails on broken links, Lighthouse CI, and a date-consistency check between `site_data` output and the engine.
- Manual check at each sprint end: run the app on a device and the site in the browser pane, with screenshots of the new screens.
