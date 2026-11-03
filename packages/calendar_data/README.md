# calendar_data

Not published. Festival and holiday data shared by the Malayalam Calendar app (`apps/calendar`) and the site generator (`apps/site_data`):

- `HolidayData`, `HolidayEntry`: the Kerala holiday lists in `data/holidays/` (format: `data/holidays/schema.md`).
- `festivalDaysBetween`: the engine's computed festivals (Kerala, Christian, tentative Muslim) merged with those lists. A listed holiday that names a computed festival marks it as a holiday; an announced Muslim date replaces the tabular one.
- `festivalInfo`: what each festival is and how its date is found, in Malayalam and English.

```bash
dart test
```
