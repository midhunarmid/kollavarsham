# Design: information architecture, wireframes, colour and type

Scope: the Android app and the web app in `apps/calendar` (see [app-roadmap.md](app-roadmap.md)). The colour and type values below match the current theme in `apps/calendar/lib/app/theme.dart` and `fonts.dart`, so this document describes what is built plus what is planned.

## 1. Principles

- **Malayalam first, English on request.** Every screen works in ml and en (G1). Malayalam dates are the primary date on the home screen; Gregorian is shown beside them.
- **Star first for personal dates.** The pirannal and nakshatram are the core use case (D2, D3), so they appear on Today and in the People list, not buried under settings.
- **No surprises from a sunrise rule.** Where a date depends on sunrise or a cut-off, the Day screen shows the rule used (for example, "6 nazhika after sunrise") in one line.
- **Offline and local.** No screen asks for an account. Nothing shows a spinner for network data.

## 2. Information architecture

Bottom navigation (five tabs, from Day 7):

```
Today ─┬─ Today (home)          A3
       └─ Panchangam detail      (from Today, opens Day screen)

Calendar ─┬─ Month               A1 (Malayalam / Gregorian mode)
          ├─ Day detail          A2 (opened from Month, Today, Agenda)
          ├─ Year view           A4 (P1)
          └─ Agenda              A5 (upcoming festivals, holidays, events)

People ───┬─ People list          D1
          ├─ Person detail       D2–D5, D10 (events for one person)
          └─ Event editor        D2–D9 (presets: pirannal, nakshatram, birthday,
                                        shraddham, anniversary, custom)
                └─ Find my star  D4 (birth date, time, place → BirthDetails)

Tools ────┬─ Date converter      F1
          ├─ Age and days        F2
          ├─ Find my star        F3 (shortcut to D4)
          └─ Share card          F4 (P1)

Settings ─┬─ Language and script G1
          ├─ Location            G2
          ├─ Year convention     G3 (P1)
          ├─ Display (theme, week start, default mode)  G4
          ├─ Reminders           E1–E3, G5
          ├─ Backup and export   F5, F6
          └─ About, how dates are computed, report a wrong date   G6
```

Rules:

- Festivals and holidays are shown as markers on Month and Day, and as rows in Agenda. They are not a separate tab.
- Reminders are configured per event (in the Event editor) and globally (Settings → Reminders). There is no separate Reminders tab.
- The first run goes through onboarding (Day 7): language → location → what notifications are for → Today.

## 3. Text wireframes

Each block is one screen on a phone (about 360 × 740 dp). `[ ]` is a tappable control.

### 3.1 Today (home)

```
┌──────────────────────────────────┐
│ തുലാം 14 · 1202        [ ] ⚙    │   Malayalam date (large), Gregorian beside
│ Friday, 30 Oct 2026              │
├──────────────────────────────────┤
│ Pooradam · Dhanu 12 (sample)     │   nakshatra with end time, tithi with end time
│ Nakshatra ends 14:20 · Tithi …   │
│ Sunrise 06:12 · Sunset 17:48     │
│ Rahu kalam 13:30–15:00           │   from Day 5; Gulika, Yamagandam below fold
├──────────────────────────────────┤
│ Today's festivals                │
│  No festival today               │   empty state
├──────────────────────────────────┤
│ Pirannal and nakshatram          │
│  Midhun · Pooradam   in 3 days   │   countdown, person colour bar
│  Ajay · Atham        in 12 days  │
├──────────────────────────────────┤
│ Next festival: Deepavali         │   tap → festival detail (Day 14)
├──────────────────────────────────┤
│  [Today] [Calendar] [People]     │
│          [Tools]    [Settings]   │
└──────────────────────────────────┘
```

### 3.2 Calendar, Month

```
┌──────────────────────────────────┐
│ ‹  Thulam 1202  ·  Oct 2026  ›   │   swipe ⇄ months; tap title → jump
│ [Malayalam] [Gregorian]  [Today] │   mode toggle, Today button
├──────────────────────────────────┤
│ Sun Mon Tue Wed Thu Fri Sat      │
│  ..  ..  ..  ..  ..  ..  ..      │   day cells: Malayalam date small,
│  ..  ..  ..  ..  ..  ..  ..      │   Gregorian large (or swapped in mode)
│ [ ] markers: festival (orange),  │   person colour dots, holiday (red)
│     person colour dots           │
├──────────────────────────────────┤
│ Legend: ● Festival ● Holiday     │
│         ● Midhun ● Ajay          │   tap a legend item → filter (P1)
└──────────────────────────────────┘
```

### 3.3 Day detail

```
┌──────────────────────────────────┐
│ ‹             Friday             │
│ 30 October 2026                  │
│ 14 Thulam 1202 · Pooradam        │   large Malayalam date
├──────────────────────────────────┤
│ Panchangam                       │
│  Nakshatra   Pooradam  → 14:20   │   start/end times
│  Tithi       Navami    → 09:10   │
│  Paksha      Shukla             │
│  Yoga, Karana (B4, P1)           │
│  Sunrise 06:12   Sunset 17:48    │
│  Rahu kalam   13:30–15:00        │
│  Gulika       09:00–10:30        │
│  Yamagandam   … (below fold)     │
│  Rule: month start, 6 nazhika    │   one-line note; "almanacs may differ" if
│        (see How dates are made)  │   monthStartMargin < 10 min
├──────────────────────────────────┤
│ Festivals and holidays           │
│  • Mahanavami  (Hindu)           │
│ Your events                      │
│  • Midhun's nakshatram           │   tap → event detail
│  [+ Add event on this day]       │
└──────────────────────────────────┘
```

### 3.4 People list

```
┌──────────────────────────────────┐
│ People                       [+] │
├──────────────────────────────────┤
│ ● Midhun (self)                  │   person colour dot, relation
│    Pirannal: Pooradam, Dhanu     │   next date: 12 Nov 2026
│ ● Amma (family)                  │
│    Birthday: 3 Mar · age 62      │
│ ● Ajay (friend)                  │
│    Nakshatram: Atham             │
└──────────────────────────────────┘
```

### 3.5 Person detail

```
┌──────────────────────────────────┐
│ ‹  Midhun            [photo] [⋮] │
├──────────────────────────────────┤
│ Upcoming                         │
│  12 Nov  Pirannal (Pooradam)     │   countdowns (D10)
│  28 Nov  Nakshatram (Pooradam)   │
│  …                               │
├──────────────────────────────────┤
│ Events for Midhun                │
│  Pirannal         Dhanu · 2nd    │   rule shown: "second occurrence"
│  Nakshatram       monthly        │
│  Birthday         3 Mar          │
│  [+ Add event]                   │
└──────────────────────────────────┘
```

### 3.6 Event editor

```
┌──────────────────────────────────┐
│ ✕  New event                Save │
├──────────────────────────────────┤
│ Person        [ Midhun      ▾ ]  │
│ Type          [ Pirannal    ▾ ]  │   presets: pirannal, monthly nakshatram,
│ Star          [ Pooradam    ▾ ]  │   Gregorian birthday, shraddham,
│ Month         [ Dhanu       ▾ ]  │   anniversary, custom
│ Find my star  →                  │   D4 flow
├──────────────────────────────────┤
│ When two dates in the month      │
│  (•) Second occurrence           │   duplicate-rule picker (D9)
│  ( ) First occurrence            │
│  Explanation: "Janma nakshatram │   sourced in pirannal-rules.md
│  counts the later day in the …"  │
├──────────────────────────────────┤
│ Reminders                        │
│  Same day at 07:00    [x]        │
│  1 day before at 20:00 [ ]       │   E1
│  [+ Add reminder]                │
├──────────────────────────────────┤
│ Colour  ● ● ● ● ●                │
│ Notes                    (P2)    │
│ [ Delete event ]                 │   confirm dialog, soft delete first
└──────────────────────────────────┘
```

### 3.7 Reminders (Settings → Reminders)

```
┌──────────────────────────────────┐
│ ‹  Reminders                     │
├──────────────────────────────────┤
│ Default time             07:00   │
│ Notify for                       │
│  [x] Pirannal   [x] Nakshatram   │
│  [x] Shraddham  [x] Birthdays    │
│  [ ] Festivals (P1)              │
│  [x] Month start (Chingam 1 …)   │   E3
│ Exact alarms        [Allow]      │   permission hint, fallback note
│ Battery optimisation   [Help]    │
└──────────────────────────────────┘
```

### 3.8 Tools

```
┌──────────────────────────────────┐
│ Tools                            │
├──────────────────────────────────┤
│ Date converter                 › │   Gregorian ⇄ Malayalam
│ Age calculator                 › │
│ Days between dates             › │
│ Find my star                   › │   D4 flow
│ Kollavarsham year info         › │   A7 (P1)
└──────────────────────────────────┘
```

### 3.9 Settings

```
┌──────────────────────────────────┐
│ Settings                         │
├──────────────────────────────────┤
│ Language       മലയാളം / English  │
│ Digits         Malayalam / 0–9   │
│ Name script    Malayalam / Latin │
│ Location       Kochi ▾ / manual  │
│ Year start     Chingam ▾         │
│ Theme          System ▾          │
│ Week starts    Sunday ▾          │
│ Reminders                      › │
│ Backup and export              › │
│ About and how dates are made   › │
└──────────────────────────────────┘
```

## 4. Colour

Source of truth: `apps/calendar/lib/app/theme.dart`. The app uses Material 3 with one seed colour, so light and dark schemes are generated from it.

| Role | Value | Notes |
|---|---|---|
| Seed (primary) | `#00796B` (teal 700) | `appSeedColor`; Material 3 `ColorScheme.fromSeed` |
| Holiday | `#D84315` (deep orange 800) | `KollavarshamCalendarTheme(holidayColor:)` |
| Festival marker | Orange 500 (`#FF9800`) | planned, Day 8 |
| Person colours | 8 fixed colours from the palette below | user picks one per person |
| Error | M3 generated | reminders failing, validation |

Person colours (planned; contrast against the surface in both themes to be checked on Day 8): teal `#00796B`, indigo `#3949AB`, purple `#8E24AA`, pink `#D81B60`, brown `#6D4C41`, green `#558B2F`, blue `#1E88E5`, grey `#546E7A`.

Rules:

- Colour is never the only signal. Holidays also use a dot shape and the word in the day detail; festivals use a star-shaped marker.
- Dark mode uses the M3 dark scheme generated from the same seed. Check contrast of the holiday and person colours in dark mode with the golden tests (Day 8).

## 5. Typography

- **Font:** Noto Sans Malayalam, bundled (OFL licence in the app, `fonts.dart`). It covers Malayalam and Latin, so one family is used for both languages. `appFontFamily = 'NotoSansMalayalam'`.
- **Scale:** Material 3 text styles, with the family set in the theme. Sizes:

| Style | Size / line height | Use |
|---|---|---|
| Display (Malayalam date on Today) | 40 / 48 | the date on home |
| Headline | 28 / 36 | screen titles |
| Title | 20 / 28 | section titles, month name |
| Body | 16 / 24 | rows, descriptions |
| Label | 12 / 16 | day-cell numbers, markers, legend |

- Malayalam text needs more line height than Latin. Use at least 1.4 for body text in Malayalam, so conjuncts are not clipped.
- Support large text (200% system font scale, Day 18). No fixed-height rows for text.
- Digits: Malayalam digits (൦–൯) or Latin digits, from Settings.

## 6. Layout and interaction

- **Touch targets:** at least 48 × 48 dp. Day cells in Month are 44 dp minimum with the tap area covering the full cell.
- **Gutter:** 16 dp on phones.
- **Motion:** M3 standard transitions. Month swipe is a horizontal pager.
- **Empty states:** every list has a one-line message and one action (for example, "No people yet. Add someone to see their pirannal.").
- **Accessibility:** every marker has a semantics label ("Festival: Mahanavami"). Screen readers read the Malayalam date in the chosen script.
- **Web:** the same screens. Background reminders are replaced by an "Upcoming" panel and `.ics` export (E8).

## 7. Open design questions

1. Should the Today screen show Gregorian first in English mode? (Proposed: Malayalam first in both modes, Gregorian beside.)
2. Is a separate Agenda tab needed, or is Agenda a section of Calendar (current plan: a sub-screen of Calendar)?
3. Person photos: store on the device only (current plan) and show a coloured initial when none is set.
4. Exact wording of the explanation text for pirannal rules: wait for the owner's review of [pirannal-rules.md](pirannal-rules.md).
