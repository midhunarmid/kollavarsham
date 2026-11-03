# Apps

What is built on the `kollavarsham` packages. Plan and progress: [docs/app-roadmap.md](../docs/app-roadmap.md) and [docs/progress.md](../docs/progress.md).

| App | What it is | Run |
|---|---|---|
| [`calendar`](calendar) | The Malayalam Calendar app for Android (`in.armid.calendar`) and the web (`calendar.armid.in/app/`): Today, month and year views, panchangam, festivals and holidays, people with pirannal, nakshatram, birthday and shraddham reminders, tools, widgets, backup and `.ics` export. Flutter. | `cd calendar && flutter run` |
| [`site`](site) | The `calendar.armid.in` website: a page per day, Malayalam month, year, and festival, in English and Malayalam. Astro, static. | `cd site && npm run prepare-data && npm ci && npm run dev` |
| [`site_data`](site_data) | Writes the site's JSON (days, months, festivals) and prints the accuracy checklist. Dart CLI. | `cd site_data && dart run site_data` |
| [`converter_js`](converter_js) | The engine compiled to JavaScript: the site's converter, star finder and "today". | `dart compile js -O2 -o build/kollavarsham.js web/converter.dart` |

Shared festival and holiday logic lives in [`packages/calendar_data`](../packages/calendar_data); the holiday lists in [`data/holidays`](../data/holidays).

Deploy: every push to `main` publishes the site at `/` and the web app at `/app/` (`.github/workflows/deploy-web.yml`). Android releases: [docs/release.md](../docs/release.md). Yearly upkeep: [docs/runbook.md](../docs/runbook.md).
