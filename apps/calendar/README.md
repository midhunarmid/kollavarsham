# Malayalam Calendar app

The Malayalam calendar for Android (`in.armid.calendar`) and the web (`calendar.armid.in/app/`), built on `kollavarsham` and `kollavarsham_flutter`.

- **Today, Calendar, Day:** both dates, star and tithi with end times, sunrise and sunset, Rahu kalam, Gulika and Yamagandam, festivals and Kerala holidays; month and year views; an agenda with search and category filters.
- **People:** pirannal (star in a Malayalam month), monthly nakshatram, birthday, shraddham (tithi or star), anniversary and custom events, with "Find my star".
- **Reminders:** local notifications on Android (exact when allowed), a daily panchangam, festival and month-start reminders; on the web, a list and `.ics` export.
- **Tools:** date converter, age, days between dates, Kollavarsham year; share cards.
- **Android extras:** two home-screen widgets, launcher shortcuts, Auto Backup.
- **Private:** everything stays on the device (shared_preferences; `localStorage` on the web). JSON backup and restore.

```bash
flutter run                      # a phone or emulator
flutter run -d chrome            # the web app
flutter test                     # goldens run on Windows only
```

Layout: `lib/app` (router, settings, theme), `lib/data` (database, events index, festivals), `lib/features/*` (screens), `lib/reminders` (scheduler, notifications, widgets), `lib/backup`. Holiday lists are copies of `data/holidays/` (`dart run tool/sync_holidays.dart`).

Release: [docs/release.md](../../docs/release.md). Design: [docs/design.md](../../docs/design.md). Privacy: [docs/privacy.md](../../docs/privacy.md).
