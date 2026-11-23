# Runbook

Recurring work to keep the calendar right and the app, packages and site current. Each section says when, what, and how to check it.

## Every year: holiday data (October–December)

Kerala publishes the next year's public holiday list (a GAD government order) late in the year.

1. Create `data/holidays/YYYY.json` per `data/holidays/schema.md`: every entry with a source URL, `name_ml`, Muslim festivals `tentative: true`.
2. Copy into the app: `cd apps/calendar && dart run tool/sync_holidays.dart`. `test/holidays_test.dart` fails until the copies match.
3. Run the accuracy check for the new year (below). Its "Holiday list against the computed festivals" section must say "None"; if a listed festival falls on another day, find out which is right before changing either.
4. When a Muslim festival's date is announced, set its entry's date and leave `tentative: true` only if it may still move.
5. Push: the site rebuilds with the new year's holidays, and the app picks them up in its next release.

The site's data range is "two years back to ten ahead" of the build date in Kerala (IST). The deploy runs every day at 01:00 IST, so the range moves forward by itself on 1 January.

## Every year: almanac check (before Chingam, and before Medam)

1. `cd apps/site_data && dart run site_data:accuracy_checklist --from YEAR --to YEAR+1`.
2. Paste it below the line in `docs/accuracy-checklist.md`, keeping filled-in cells.
3. Fill the Almanac column from at least one printed Malayalam almanac (Manorama or Mathrubhumi panchangam). Months marked ⚠ are within 30 minutes of the cut-off: almanacs may differ there by design; record what the almanac says.
4. For a confirmed difference, add the month to `KollavarshamCalendar.verifiedMonthStarts` (month starts) or fix the festival rule, with a test citing the source, and note it in `docs/accuracy.md`.

## Wrong-date reports

Issues come from the issue template and the app's "Report a wrong date" (label `accuracy`). For each: reproduce with the checklist generator or `dart run` in `packages/kollavarsham`, compare with the reporter's source, then fix with a test or answer with the rule and its source.

## Dependencies (every quarter)

The workspace still resolves on **Dart 3.6 / Flutter 3.27.4**, the packages' minimum (CI tests both). That pins several app dependencies below their latest versions; `docs/progress.md` (Days 7–17) records each choice.

1. `flutter pub outdated` at the root.
2. Raise a constraint only when the new version resolves on Dart 3.6, or when the owner decides to raise the packages' minimum SDK (then update `environment` in every pubspec, the CI matrix and the CHANGELOGs).
3. Watch for: `workmanager` dropping the Kotlin Gradle Plugin; Flutter enabling built-in Kotlin in the template (then remove the Kotlin hook in `apps/calendar/android/build.gradle.kts`); Astro minor releases (`apps/site/package.json` pins exact versions; update both `astro` and `@astrojs/sitemap`, run `npm run build && npm run check`).
4. Run everything: tests below, a release APK build, and the site build.

## Tests and checks

```bash
flutter pub get
cd packages/kollavarsham && dart test
cd packages/kollavarsham_flutter && flutter test
cd packages/calendar_data && dart test
cd apps/site_data && dart test
cd apps/converter_js && dart test
cd apps/calendar && flutter test          # goldens run on Windows only
cd apps/site && npm run prepare-data && npm ci && npm run build && npm run check
```

Golden images (`apps/calendar/test/goldens/`) are made on Windows; refresh with `flutter test --update-goldens test/golden_test.dart` and look at every changed image before committing.

## Releases

- **Android app:** `docs/release.md` (version in `pubspec.yaml` and `lib/app/version.dart`, signing, R8, Play tracks).
- **Packages (`kollavarsham`, `kollavarsham_flutter`):** move the CHANGELOG's Unreleased section under a version, bump `version` in the pubspec and the dependents' constraints, then push a tag `kollavarsham-vX.Y.Z` (or `kollavarsham_flutter-vX.Y.Z`): `.github/workflows/publish.yml` publishes to pub.dev. Only the owner creates these tags.
- **Site and web app:** every push to `main`, and a schedule every day at 01:00 IST, deploy both (`.github/workflows/deploy-web.yml`): site data, the JS converter, the Astro build and link check, the Flutter web build at `/app/`, the offline check and Lighthouse CI. Watch the run; a failed check stops the deploy and the previous version stays up.
  - Lighthouse (`apps/site/lighthouserc.cjs`): eight site pages must score at least 95 (SEO 100) and stay under 250 KB; `/app/` may not grow more than 10% over `apps/site/lighthouse-baseline.json` in bytes or time to interactive. After a deliberate change to the app's size, run it locally (`npm run build`, copy the Flutter build to `dist/app`, then `npx @lhci/cli@0.16.0 autorun`) and update the baseline from the `/app/` report. The reports are kept as the run's `lighthouse` artifact.
  - The build also writes the public `.ics` feeds (`site_data` → `public/ics/<lang>/<feed>.ics`: all, hindu, christian, muslim, holidays; from last year on) and the Pagefind search index (`pagefind --site dist`, festival and month pages only, marked with `data-pagefind-body`). Feed UIDs are the festival id and year, so a moved tentative date updates subscribers' calendars instead of duplicating.
  - `.github/workflows/uptime.yml` checks the live site every morning (06:30 IST) and opens or comments on an issue labelled `uptime` when a page fails or the last deploy is more than 48 hours old. GitHub pauses scheduled workflows after 60 days without a commit; re-enable them from the Actions tab.

## When something breaks

| Symptom | Where to look |
|---|---|
| A festival on the wrong day | `docs/accuracy.md` (its rule and evidence), `packages/kollavarsham/lib/src/festivals.dart` |
| A month starts a day off | the checklist margin; `verifiedMonthStarts` in `calendar.dart` |
| Notifications missing on a phone | Settings → Reminders (exact alarms, permission); `docs/release.md` smoke test |
| Lighthouse fails in the deploy | the run's `lighthouse` artifact (open the HTML report for the failing URL); `apps/site/lighthouserc.cjs` |
| An `uptime` issue opened | the failing URL or the Deploy web run history; GitHub Pages settings (custom domain, DNS) |
| The web app doesn't open offline | `apps/site/scripts/check-offline.mjs`; `apps/calendar/web/app_sw.js` and `flutter_bootstrap.js` |
| Site build fails on data | `npm run prepare-data` output; a malformed holiday file is reported by name |
