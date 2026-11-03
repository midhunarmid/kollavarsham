# Kollavarsham

The Malayalam calendar (Kollavarsham / Malayalam Era): Dart and Flutter packages, an Android and web app, and the website [calendar.armid.in](https://calendar.armid.in).

| Package | Description |
|---|---|
| [`kollavarsham`](packages/kollavarsham) | Pure Dart core: Gregorian ↔ Malayalam conversion, month and weekday names, nakshatra, tithi, yoga, karana, kalams, sun and moon times, festivals, vrats, star birthdays and other recurrences, formatting |
| [`kollavarsham_flutter`](packages/kollavarsham_flutter) | Flutter widgets: month view, date picker, date text |
| [`calendar_data`](packages/calendar_data) | Not published: festivals merged with the Kerala holiday lists, and festival descriptions, shared by the app and the site |

| App | Description |
|---|---|
| [`apps/calendar`](apps/calendar) | Malayalam Calendar for Android and the web (`/app/`): panchangam, festivals, pirannal reminders, widgets |
| [`apps/site`](apps/site) | calendar.armid.in: a page per day, month, year and festival, in English and Malayalam |
| [`apps/site_data`](apps/site_data), [`apps/converter_js`](apps/converter_js) | The site's data generator and its in-browser converter |

More in [apps/README.md](apps/README.md).

How dates are computed and how accurate they are: [docs/accuracy.md](docs/accuracy.md), with the yearly [accuracy checklist](docs/accuracy-checklist.md).

Found a date that differs from an almanac? Please [report it](https://github.com/midhunarmid/kollavarsham/issues/new?template=wrong_date.yml). See [CONTRIBUTING.md](CONTRIBUTING.md).

## Development

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces) that still resolves on Dart 3.6 / Flutter 3.27.4.

```bash
flutter pub get
cd packages/kollavarsham && dart test
cd packages/kollavarsham_flutter && flutter test
cd apps/calendar && flutter test
```

Everything else (the site, releases, yearly upkeep): [docs/runbook.md](docs/runbook.md), [docs/release.md](docs/release.md).
