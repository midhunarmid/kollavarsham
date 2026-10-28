# Kollavarsham

Malayalam calendar (Kollavarsham / Malayalam Era) utilities for Dart and Flutter.

| Package | Description |
|---|---|
| [`kollavarsham`](packages/kollavarsham) | Pure Dart core: Gregorian ↔ Malayalam conversion, month and weekday names, nakshatra, tithi, festivals, formatting |
| [`kollavarsham_flutter`](packages/kollavarsham_flutter) | Flutter widgets: month view, date picker, date text |

How dates are computed and how accurate they are: [docs/accuracy.md](docs/accuracy.md).

Found a date that differs from an almanac? Please [report it](https://github.com/midhunarmid/kollavarsham/issues/new?template=wrong_date.yml). See [CONTRIBUTING.md](CONTRIBUTING.md).

## Development

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces).

```
flutter pub get
cd packages/kollavarsham && dart test
cd packages/kollavarsham_flutter && flutter test
```
