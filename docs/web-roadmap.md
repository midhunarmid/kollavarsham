# Web roadmap: calendar.armid.in after Day 24

## Context

The 24-day plan in [app-roadmap.md](app-roadmap.md) is done, and both web pieces are live at `calendar.armid.in`:

- **The site** (`apps/site`, Astro): 10,707 static pages in English (`/`) and Malayalam (`/ml/`). There is a page per day, per complete Malayalam month, per Gregorian year and per festival-year, plus "nakshatra today", the converter, and the privacy, how-dates-are-computed and contact pages. Home, nakshatra-today and the converter compute in the browser with `kollavarsham.js` (115 KB). Every other page is fixed at build time for **Thiruvananthapuram**.
- **The web app** (`apps/calendar`, Flutter web at `/app/`): the full app with its data in `localStorage`, an offline service worker (`web/app_sw.js`), deep links from the site, and a reminder list plus `.ics` export in place of notifications.

This roadmap covers the next stage of the web: fix what the launch left open, then grow the site's reach and make the web app safe to rely on. The founding decisions stay: **no backend, no accounts, no analytics, no ads, free static hosting.** Every item below has to work within them.

The roadmap has four parts: the **gaps** found in the current build, **six milestones** of about two weeks each with "done when" criteria, the **owner actions**, and the **risks**.

---

## 1. Gaps in the current build

Found by reading the code and docs on 17 November 2026.

| # | Gap | Where | Effect |
|---|---|---|---|
| W1 | **The site only rebuilds on a push to `main`.** There's no scheduled build. | `.github/workflows/deploy-web.yml` | Each upcoming-festival list, the nav's "Calendar YEAR" link (`new Date().getFullYear()` in `Base.astro`) and the data range (`year −2 … +10`) are frozen at the last push. The runbook says the range "moves forward by itself on the first build of each year". That's only true if someone pushes in January. |
| W2 | **Fonts load from Google Fonts** on every page. | `apps/site/src/layouts/Base.astro` | Each visit sends a request to a third party, which sits awkwardly with "no tracking". The site's Malayalam text also breaks offline, and the fonts block first paint. The app already bundles Noto Sans Malayalam. |
| W3 | **No Lighthouse CI or performance budget.** The Sprint 9 check (≥95 performance and SEO) and the Sprint 10 check (`/app/` under 3 s on 4G) were never automated or measured. | `ci.yml`, `deploy-web.yml` | The site and app can regress without anyone noticing. Nobody knows how big `/app/` is: CanvasKit plus main.dart.js is likely several MB. |
| W4 | **Site pages are for one city only.** | `i18n.ts` (`timesNote`), day and month pages | Sunrise, kalams and star end times are wrong for Kozhikode, the Gulf and the diaspora. The app handles this, but the site, where most visitors land, doesn't. |
| W5 | **Web app data sits in `localStorage` with no persistence request.** | `lib/data/database.dart` (shared_preferences on the web) | Safari can evict script-written storage after seven days without a visit (installed PWAs are exempt), and any browser can clear it under storage pressure. People could lose their pirannals without warning, and the app has no reminder to make a backup. |
| W6 | **Day pages have no "Report a wrong date" link and no "almanacs may differ" note.** | `day/[date].astro` | The app has both (Day 8, Day 17). The site sends people to a general contact page instead. |
| W7 | **One shared OG image.** | `public/og.png` | Shared festival and day links all show the same picture. |
| W8 | **No site search, and no print styles.** | `site.css` | You can't find "Karkidaka Vavu 2027" without browsing, and there's no printable month (A8 in the app roadmap). |
| W9 | **The web app still has Flutter's default icons.** | `apps/calendar/web/icons/`, `favicon.png` | Installing it shows the Flutter logo. This is the same open owner item as the Android icon. |
| W10 | **The Play link is a placeholder.** | `index.astro` `#play-link` | Expected: it waits on the Play listing. |
| W11 | **No uptime or deploy-health check.** | | A broken DNS record or a failed Pages deploy would go unnoticed. |

---

## 2. Milestones

Each milestone takes about two weeks and has a "done when". M1 comes first because it fixes correctness and privacy. After it, M2–M4 can run in any order, and M5–M6 build on M2 and M4.

### M1: Launch hardening (W1, W2, W3, W6, W9, W11)

- **Daily scheduled deploy.** Add `schedule: - cron: '30 19 * * *'` to `deploy-web.yml`. That's 01:00 IST, so the build happens after Kerala's midnight. It keeps the build-day lists, the nav year and the data range current, and the January rollover happens on its own.
  - Make `buildDay` and the nav year explicit IST dates. Today `new Date()` on the runner is UTC, which is 5½ hours behind Kerala.
  - Keep the client-side fixes on home (it hides festivals that have passed). They cover the hours between builds.
- **Self-host the fonts.** Subset Noto Sans Malayalam and Noto Sans to WOFF2 (Latin + Malayalam, weights 400/600/700) in `public/fonts/` with `font-display: swap`, and preload the regular weight. Remove the Google Fonts `<link>`s, and the font rule in `app_sw.js` if the app stops using them too. The privacy page can then say the site contacts no third parties, GitHub Pages aside.
- **Lighthouse CI.** Run `@lhci/cli` in the CI site job against a local `astro preview` for home, one day page, one festival page and the converter, in both languages.
  - Budgets: performance ≥95, SEO 100, accessibility ≥95, best practices ≥95, total page weight under 150 KB before JS.
  - For `/app/`: record transfer size and time-to-interactive on simulated 4G. Fail the run if either grows by more than 10% over a committed baseline (`apps/site/lighthouse-baseline.json`).
- **Day page extras.** Add a "Report a wrong date" link that opens the GitHub `wrong_date.yml` template, pre-filled with the date, Malayalam date, star, tithi and "site, Thiruvananthapuram". Reuse the app's report fields from `lib/app/report.dart`. Show the "almanacs may differ" note when the month starts within 10 minutes of the cut-off. `site_data` already has the sankranti time and can write a `borderline` flag.
- **Icons.** Once the owner supplies the icon, generate the web favicon, the 192/512 icons and the maskable icons from it, and the site's `favicon.svg`.
- **Uptime check.** A small scheduled workflow (daily) that fetches `/`, `/ml/`, `/app/`, `/kollavarsham.js` and `/sitemap-index.xml` and opens an issue if any fail. That's enough without a monitoring service.
- **Done when:**
  - a deploy runs every day with no push;
  - the site makes no request to any host except `calendar.armid.in` (checked in the browser's network log);
  - Lighthouse CI is green on 8 URLs, with the `/app/` baseline recorded;
  - day pages carry the report link and the borderline note.

### M2: Your place on the site (W4)

The aim is to keep the static pages for search engines (Thiruvananthapuram) and let visitors switch to their own place in the browser, without a server.

- **Location picker** in the header: the app's 14 district headquarters, plus Gulf and diaspora cities (Dubai, Abu Dhabi, Doha, Muscat, Riyadh, Kuwait, Bahrain, Singapore, London, New York, Toronto, Sydney). Share one city list with the app by moving `lib/app/locations.dart` into `calendar_data`. The choice is saved in `localStorage`. It's a per-visitor convenience, and losing it only means falling back to the default city.
- **Extend `converter_js`** with a `dayOf(iso, lat, lon, utcOffset)` returning what `site_data` writes for a day: star and tithi spans, sun and moon times, kalams. The engine already computes all of it. Check that the JS output matches `site_data` for every day of 2026 at Thiruvananthapuram. That's a unit test in `apps/converter_js/test`.
- **Day, month, nakshatra-today and home pages:** when a city other than the default is chosen, recompute the times in place and change the note to "Times for Dubai (GST)". The static HTML stays as it is, for crawlers and for visitors without JavaScript.
- **Time zones:** Gulf visitors usually want Kerala's dates with local clock times. Show times in the chosen city's zone. Dates still follow the Kerala year start, which is the app's behaviour (G2).
- **Done when:**
  - choosing Kozhikode or Dubai changes sunrise, kalams and star end times on every day page without a reload;
  - the JS output equals `site_data` for 365 days;
  - the static HTML is byte-identical with and without the feature;
  - `kollavarsham.js` stays under 150 KB.

### M3: Web app you can trust with your data (W5)

- **Ask for persistent storage.** Call `navigator.storage.persist()` after the first person is saved, through a small JS interop in `apps/calendar/lib/app/`, and show the result in Settings → Backup ("Saved in this browser · protected from automatic clearing", or a warning when it isn't).
- **Move the web data to IndexedDB.** It holds more, can be asked to persist, and is less likely to be cleared than `localStorage`. Keep the versioned JSON document format from `database.dart`. Only the storage changes: one IndexedDB key holding the same document, with a one-time migration from `localStorage`. This also answers the open "drift or not" owner question for the web: no drift and no `sqlite3.wasm` are needed.
- **Backup nudges.** Track when the last backup was made. On the web, show a banner on Today when there are events and no backup in 30 days: "Your data lives only in this browser. Save a backup." Offer to make a backup right after the first pirannal is added.
- **Update flow.** When `app_sw.js` finds a new version, show a "New version: reload" snackbar, so users aren't left on an old build until a second visit.
- **Install prompt.** Catch `beforeinstallprompt` and offer "Install" in Settings and once on Today, which can be dismissed. On iOS, show the Share → Add to Home Screen steps, since installing also exempts the app from Safari's seven-day clearing.
- **No Google font requests from the app.** Flutter web fetches Roboto from `fonts.gstatic.com` for Latin text, since Noto Sans Malayalam has no Latin letters. Bundle a Latin font as an app asset and use it as the fallback. Then the privacy page can drop its `/app` caveat, and `app_sw.js` can stop caching Google's font files.
- **Load time.** Using the M1 baseline:
  - try `--wasm` (skwasm) with the CanvasKit fallback;
  - defer rarely used screens (Find my star, backup, share cards) with Dart deferred imports;
  - show a light HTML splash in `index.html` with today's date (from `kollavarsham.js`) while Flutter boots.
- **Done when:**
  - Chrome reports `persisted: true` after install;
  - data survives clearing `localStorage` (it lives in IndexedDB);
  - a test covers the `localStorage` → IndexedDB migration;
  - a new deploy shows the reload prompt;
  - `/app/` is interactive in under 3 s on Lighthouse's simulated 4G, or the measured gap and its cause are written down.

### M4: Calendar feeds and print, still without a server (W8)

- **Public subscription feeds.** `site_data` writes static `.ics` files: `/ics/en/all.ics`, `/ics/en/hindu.ics`, `christian.ics`, `muslim.ics`, `holidays.ics` and `bank.ics`, plus Malayalam versions under `/ics/ml/`. Each holds every date in the data range. Reuse the app's RFC 5545 writer (`lib/backup/ics.dart`) by moving it into `calendar_data`. A festivals page section offers "Subscribe in Google Calendar / Apple Calendar" (`webcal://` and the Google `cid=` link). The daily deploy from M1 keeps the feeds current, and calendar apps poll them on their own. This is the closest thing to push reminders a static site can offer.
- **Personal events stay in the app.** Feeds are public files, so pirannals never go into them. The app's own `.ics` export is unchanged.
- **Printable calendars.** Add an `@media print` stylesheet for month and year pages: an A4 wall-calendar grid with Malayalam dates, the star for each day and festivals, with no nav or footer. Add a "Print / Save as PDF" button. This is A8 without a PDF library.
- **Site search.** Add Pagefind, which indexes at build time and needs no server, for festival pages, month pages and the festival index (not the 9,500 day pages, to keep the index small). Fix the search terms people type, such as "vishu 2027" and "onam date", plus Malayalam names and common English spellings (Thiruvonam/Thiruonam).
- **Done when:**
  - Google Calendar and Apple Calendar subscribe to `hindu.ics` and show 2026–2027 Onam on the right days;
  - the feeds pass an RFC 5545 validator;
  - a printed Chingam 1202 fits one A4 page in both languages;
  - searching "Karkidaka Vavu" finds the 2027 page.

### M5: Growing the site's reach (W7)

Search is how most people will find the calendar. New pages must come from computed data, never hand-written per date.

- **New page families**, each computed by `site_data`, with ml/en and hreflang:
  - **Nakshatra pages**: `/nakshatra/pooradam/2027/`, every Pooradam day of the year, with a "find your pirannal" form.
  - **Vrat pages**: `/ekadashi/2027/`, `/pradosham/2027/`, `/shashti/2027/`, `/pournami/2027/`, `/amavasya/2027/`, from `vratDays`. They keep the caveat from `docs/accuracy.md`: no Kerala vrat list has been checked yet.
  - **Rahu kalam today**: `/rahu-kalam-today/`, computed in the browser (with M2 it follows the visitor's city), listing the week ahead.
  - **Pirannal finder** as a public tool page: enter a star and a Malayalam month, get the next ten dates. It runs in the browser with a recurrence function added to `converter_js`, and links into the app to save the result.
- **Per-page OG images.** Make them only for festival-year pages and month pages (a few hundred, not 10,000), at build time, with `og_image.mjs` and headless Chrome. The festival name and date go in both scripts. Cache by content hash so builds stay fast.
- **Structured data:**
  - `Event` gains `eventAttendanceMode` and a Kerala `location`;
  - add `BreadcrumbList` on day, month and festival pages;
  - add `FAQPage` on how-dates-are-computed;
  - check them in Google's Rich Results Test and keep the warnings under 5.
- **Content.** Longer festival descriptions (history, how the date is computed, where in Kerala it's celebrated) and a glossary page (nakshatra, tithi, njattuvela, nazhika). Malayalam text goes through the same native-editor review as the app.
- **Measuring without analytics.** Use Google Search Console and Bing Webmaster Tools (both owner-side and cookie-free for visitors). They give impressions, queries and indexing errors. Nothing goes on the page.
- **Done when:**
  - the new families build and pass the link check;
  - the sitemap holds them;
  - OG images render for 2026–2027 festivals;
  - the build still finishes in under 60 s in CI;
  - Search Console shows the new pages indexed.

### M6: Openness and reuse

- **Static JSON API.** Publish the files `site_data` already writes under `/api/v1/` (`days/2027.json`, `festivals.json`, `months.json`), with a short documentation page and a stability promise for v1. It's free to host and helps other Malayalam sites and apps use correct dates instead of copying them by hand.
- **Embeddable widget.** A `<script src="https://calendar.armid.in/embed.js" data-lang="ml">` that draws today's Malayalam date and star in a shadow DOM, built from `kollavarsham.js`, with no tracking. It suits temple and community websites. Each embed links back.
- **Engine in npm.** Optional: publish `converter_js` as a small npm package (`kollavarsham-js`) for JS developers, versioned with the Dart package.
- **Done when:** the API docs page is live, the embed works on a plain HTML test page in Chrome, Firefox and Safari, and it adds no request beyond its own script.

### Backlog

- Tamil calendar mode on the site, alongside the app's backlog item.
- Temple festival pages (C8) once a curated, sourced list exists.
- Muhurtham pages (B8): only with a reliable almanac source.
- Year-start choice (Chingam or Kanni) on the site, next to the city picker.
- Web Periodic Background Sync, for installed Chrome PWAs only, to show festival notifications without a server. It's too narrowly supported to promise today; revisit yearly.
- A share-target manifest entry so a backup file can be "shared to" the installed web app.

---

## 3. Owner actions

- [ ] Supply the app icon (also on the app roadmap's list); M1 builds the web icons from it.
- [ ] Verify `calendar.armid.in` in **Google Search Console** and **Bing Webmaster Tools**, and submit `sitemap-index.xml` (M5 depends on it).
- [ ] Replace the Play placeholder (`#play-link`) once the listing is public.
- [ ] Review the privacy page after M1. Remove "draft", set the contact email, and add the no-third-party-fonts line.
- [ ] Decide on M6: whether to promise a stable public JSON API and an npm package. Both are commitments to maintain.
- [ ] Malayalam review of the new M5 content, together with the app's copy review.

---

## 4. Risks and open questions

- **Storage eviction** (M3) can't be ruled out on the web, even with IndexedDB and `persist()`. The real protection is backups, so the nudges matter more than the storage change. Say this plainly on the privacy and backup pages.
- **Build time and repo limits.** GitHub Pages sites have a 1 GB limit and a soft bandwidth limit of 100 GB a month. Today's ~10,700 pages are fine. M5 roughly doubles the page count, and OG images add weight. Track `dist/` size in CI (fail above 500 MB) and move to Cloudflare Pages if it's needed. The app roadmap allows either.
- **Daily cron deploys.** GitHub disables scheduled workflows in repositories with no activity for 60 days. The uptime check from M1 should alert when the last deploy is more than two days old.
- **City-specific numbers on the site** (M2) can't be checked against almanacs for every city. Check Kozhikode and Dubai on 30 days against a published panchangam, the way Day 5 checked Thiruvananthapuram. Record the results in `docs/accuracy.md`.
- **Feeds and the "tentative" Muslim dates** (M4). Feed events must carry "(tentative)" until the holiday data confirms them. Each UID must stay stable when a date moves, so subscribers' calendars update rather than duplicate.
- **SEO thin-content risk** (M5). Pages that differ only in their dates, such as the 27 nakshatra pages × 13 years, can be treated as thin content. Give each family real explanatory text, and start with 3 years per family, not 13.

## 5. Progress

| Milestone | Status | Notes |
|---|---|---|
| M1 | done (2026-11-23) | Daily 01:00 IST deploy; IST build day in `site_data` and the site; fonts bundled with the site (no third-party requests, checked in the browser); Lighthouse CI in the deploy (all 8 site pages scored 100 in every category locally, 98–160 KB); "Report a wrong date" and the borderline note on day pages (2 days in 2024–2036); `uptime.yml`. Measured `/app/` baseline: **7.2 MB, interactive at 37.7 s** on simulated slow 4G, far from the 3 s target, which is M3's job. Web icons are still waiting on the owner's icon. |
| M2 | done (2026-11-23) | A header place picker (14 Kerala district headquarters, 4 Indian cities, 7 Gulf and 5 other cities, in `calendar_data`'s `places`; the app's tests check the Kerala ones match its city list). The choice is kept in `localStorage` and the list is one cached `/places.json`. Day pages (panchangam card and star/tithi chips), home's star and tithi, and nakshatra-today recompute in the browser, with each date's UTC offset from its IANA zone (so London and New York follow daylight saving). Malayalam dates stay Kerala's. The day panchangam is now one shared function (`panchangamJson`) for `site_data` and `kollavarsham.dayOf`. `npm run check` checks that the compiled JS equals the site data on all 365 days of a year. `kollavarsham.js` is 125 KB, and Lighthouse still passes. Not done: month pages keep Thiruvananthapuram's star per day, and Kozhikode and Dubai haven't been compared with a published panchangam (needs a source that loads without a CAPTCHA). |
| M3 | done (2026-11-23) | The web database is in IndexedDB (`web/browser.js` + `lib/web/`), read into memory at start, with a one-time move from `localStorage` (checked in the browser). The first person or event asks for persistent storage, and Settings → Backup shows the result and the last backup date. Today has a backup reminder (events and no backup in 30 days; "Not now" hides it for 7 days) and an install card (the browser's prompt, or Safari's steps on iOS). A "new version, reload" snackbar comes from `app_sw.js` noticing a changed `main.dart.js`. Roboto is bundled as a Latin subset (about 70 KB per weight), so the app makes no request outside the site. An HTML splash shows while Flutter starts. Measured `/app/`: **3.8 MB, interactive at 13.6 s**, first paint 0.75 s, against 7.2 MB and 37.7 s (that baseline was measured without gzip, which GitHub Pages applies to `.wasm`). `--wasm` was tried: 3.3 MB but interactive at 14.7 s, so the JS build stays. The 3 s target isn't reachable with CanvasKit (2.2 MB gzipped on its own); deferred loading of rarely used screens was not tried. |

## 6. Verification (every milestone)

- `npm run build && npm run check` (links, canonical, hreflang) and Lighthouse CI in CI.
- `flutter test` for app changes. A web build plus `check-offline.mjs` for anything that touches `/app/`.
- A consistency test between `site_data` and `converter_js` whenever either changes.
- A manual check in the browser pane at the end of each milestone, at 390 px and desktop width and in both languages, with screenshots of the new pages.
