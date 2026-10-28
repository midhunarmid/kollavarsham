# Contributing

Thanks for helping make the Malayalam calendar in Dart accurate and useful.

## Reporting a wrong date

Calendar correctness is this project's top priority. If a date, month start or festival differs from a Kerala almanac, please [open a "Wrong date" issue](https://github.com/midhunarmid/kollavarsham/issues/new?template=wrong_date.yml) and include:

- the Gregorian date and what the package returns;
- what you expected;
- **the source**: the almanac or calendar (for example Mathrubhumi, Manorama or the Kerala Government calendar) and year, or a news report;
- the location, if you used a calendar other than the default.

Confirmed month starts go into `KollavarshamCalendar.verifiedMonthStarts` with their source in `packages/kollavarsham/test/fixtures/borderline_months.csv`. See [docs/accuracy.md](docs/accuracy.md) for how dates are computed.

## Development

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces) with two packages:

- `packages/kollavarsham`: pure Dart core
- `packages/kollavarsham_flutter`: Flutter widgets and the web example

```
flutter pub get                      # at the repository root

cd packages/kollavarsham
dart test                            # VM
dart test -p chrome                  # web
dart analyze --fatal-infos

cd ../kollavarsham_flutter
flutter test
flutter analyze

dart format packages                 # before committing
```

To see the example: `cd packages/kollavarsham_flutter/example && flutter run -d chrome`.

### Generated files

| File | Regenerate with |
|---|---|
| `packages/kollavarsham/lib/src/data/month_starts.dart` | `dart run tool/generate_table.dart` (in `packages/kollavarsham`) |
| `packages/kollavarsham/test/fixtures/borderline_months.csv` | `dart run tool/borderline_audit.dart` |
| `packages/kollavarsham/test/fixtures/sankranti_1900_2100.csv`, `lib/src/astro/delta_t_table.dart` | `python tool/generate_reference.py` (repository root; needs `pip install pyswisseph`) |

Regenerate the month-start table whenever you change the astronomy or add a verified month start; `table_test.dart` fails until you do.

### Guidelines

- Every public member needs a doc comment (the `public_member_api_docs` lint is on).
- Festival rules need at least five years of published dates in the tests.
- Keep the core package free of Flutter and other heavy dependencies.

## Releasing

1. Update `CHANGELOG.md` and the `version` in each package's `pubspec.yaml`. Release `kollavarsham` before `kollavarsham_flutter`.
2. Push a tag `kollavarsham-vX.Y.Z` (and then `kollavarsham_flutter-vX.Y.Z`); the publish workflow uploads to pub.dev.
