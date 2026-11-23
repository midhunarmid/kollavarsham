// Day pages: when the visitor has picked a place other than
// Thiruvananthapuram, recompute the panchangam card and the star and tithi
// chips there; picking the default again restores the page as built.
import { dayAt, offsetLabel, offsetMinutes, onPlace, type EngineDay, type Place } from './place';

const kalamOrder = ['rahu', 'gulika', 'yamagandam'];

export function showDayAtPlace() {
  const card = document.getElementById('panchangam');
  const rows = card?.querySelector('dl.rows');
  const note = document.getElementById('times-note');
  const chipStar = document.getElementById('chip-star');
  const chipTithi = document.getElementById('chip-tithi');
  if (!card || !rows || !note) return;
  const iso = card.dataset.iso!;
  const lang = card.dataset.lang === 'ml' ? 'ml' : 'en';
  const s: Record<string, string> = JSON.parse(card.dataset.strings!);
  const built = {
    rows: rows.innerHTML,
    note: note.textContent,
    star: chipStar?.textContent,
    tithi: chipTithi?.textContent,
  };

  const time = (local: string | null) => {
    if (!local) return s.none;
    const t = local.slice(11, 16);
    return local.slice(0, 10) === iso ? t : `${t} (${s.nextDay})`;
  };
  const span = (name: string, until: string) =>
    lang === 'ml' ? `${name} ${time(until)} ${s.until}` : `${name} ${s.until} ${time(until)}`;

  function render(day: EngineDay, place: Place) {
    const out: [string, string[]][] = [
      [s.star, day.stars.map((x) => span(x[lang], x.until))],
      [s.tithi, day.tithis.map((x) => span(x[lang], x.until))],
      [s.paksha, [lang === 'ml' ? day.pakshaMl : day.pakshaEn]],
      [s.sunrise, [time(day.sunrise)]],
      [s.sunset, [time(day.sunset)]],
      [s.moonrise, [time(day.moonrise)]],
      [s.moonset, [time(day.moonset)]],
      ...kalamOrder
        .filter((k) => day.kalams[k])
        .map((k): [string, string[]] => [
          day.kalamNames[k][lang],
          [`${time(day.kalams[k][0])}–${time(day.kalams[k][1])}`],
        ]),
    ];
    rows!.replaceChildren(
      ...out.flatMap(([label, lines]) => {
        const dt = document.createElement('dt');
        dt.textContent = label;
        const dd = document.createElement('dd');
        if (lines.length === 1) dd.textContent = lines[0];
        else for (const line of lines) dd.appendChild(Object.assign(document.createElement('div'), { textContent: line }));
        return [dt, dd];
      }),
    );
    note!.textContent = s.timesFor
      .replace('{place}', place[lang])
      .replace('{offset}', offsetLabel(offsetMinutes(place.tz, iso)));
    if (chipStar) chipStar.textContent = `${s.star}: ${day.stars[0][lang]}`;
    if (chipTithi) chipTithi.textContent = `${s.tithi}: ${day.tithis[0][lang]}`;
  }

  let latest = 0;
  onPlace(async (place) => {
    const request = ++latest;
    if (!place) {
      rows.innerHTML = built.rows;
      note.textContent = built.note;
      if (chipStar && built.star) chipStar.textContent = built.star;
      if (chipTithi && built.tithi) chipTithi.textContent = built.tithi;
      return;
    }
    try {
      const day = await dayAt(iso, place);
      if (day && request === latest) render(day, place);
    } catch {
      // The engine could not load (offline): keep the page as built.
    }
  });
}
