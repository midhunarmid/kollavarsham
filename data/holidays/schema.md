# Holiday data format

Curated holiday lists for Kerala, one JSON file per year: `data/holidays/YYYY.json`. The app loads these from its bundled assets (Day 13) and merges them with the computed festivals. The site build (Day 19) reads the same files.

Every entry must have a **source URL**. If an entry cannot be sourced, it is not added.

## File layout

```json
{
  "schemaVersion": 1,
  "year": 2026,
  "region": "Kerala, India",
  "status": "partial | complete",
  "scope": "Government of Kerala public holidays (GAD order)",
  "generatedFrom": ["https://…"],
  "notes": ["Free text: conflicts, unverified items, what is missing."],
  "holidays": [ { ... } ]
}
```

## Entry fields

| Field | Type | Required | Meaning |
|---|---|---|---|
| `date` | `YYYY-MM-DD` (Gregorian, Kerala local date) | yes | the holiday date |
| `name` | string (English) | yes | name as the source gives it |
| `category` | `hindu`, `christian`, `muslim`, `national`, `government`, `bank` | yes | used by the category filters (C6) |
| `kind` | `public`, `restricted`, `bank` | yes | `public` = listed as a public holiday; `restricted` = optional holiday chosen by employees; `bank` = bank-only closure |
| `tentative` | boolean | yes | `true` when the date depends on the moon's appearance or an estimate |
| `source` | URL | yes | the page the entry was taken from |
| `sourceNote` | string | no | e.g. which GO number, or a date conflict |
| `community` | string | no | for restricted holidays, the community named by the source |

Malayalam names (`name_ml`) are not in these files yet. They are added with the festival descriptions (Day 14).

## Rules

1. **Muslim festivals are `tentative: true`** until the government order or an announced date confirms them (C3). Moon-dependent dates are always tentative.
2. **Holidays that fall on a Sunday** are kept in the file with `kind: public` and `sourceNote: "falls on Sunday"`. The source's own "omit" list is not used to drop them. The app decides how to show them.
3. **Restricted holidays** are kept, with `kind: restricted` and the `community` the source names.
4. **Bank-only closures** (for example, "annual closing of accounts") use `kind: bank`. They are not government holidays.
5. **Dates must match the source exactly.** Do not move a date to fit another list. Put the conflict in `sourceNote` or in the file's `notes`.
6. **Order numbers** (for example, a G.O. number) go in `sourceNote` only when the source gives one.
7. Sorted by `date`, then `name`. One file per calendar year.

## Owner checks

Each file's entries are checked against a printed almanac or the official gazette (Needs you: "Check 2026–2027 dates against printed almanacs", Day 23). Entries listed in the file `notes` are the ones with known conflicts.
