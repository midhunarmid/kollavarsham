// Per-page social preview images: festival pages and Malayalam month pages
// of the featured years (last year to next year), in both languages. The
// build lists them at /og-manifest.json; scripts/og-pages.mjs renders each
// to /og/<lang>/<page path>.png and removes the manifest. Other pages keep
// the shared /og.png.
import { completeMonths, dayOf, featureYears, festivals, festivalSlug, type Lang } from './data';
import { gregorianDate, langs, malayalamDate, nameOf, t, weekdayOf } from './i18n';

export interface OgEntry {
  /** Site path of the image. */
  image: string;
  lang: Lang;
  /** Small line above the title. */
  kicker: string;
  title: string;
  subtitle: string;
}

const entries = new Map<string, OgEntry>();
const add = (lang: Lang, path: string, entry: Omit<OgEntry, 'image' | 'lang'>) =>
  entries.set(`${lang}${path}`, { image: `/og/${lang}${path.replace(/\/$/, '')}.png`, lang, ...entry });

for (const lang of langs) {
  for (const f of festivals) {
    for (const year of featureYears) {
      const date = f.dates.find((d) => d.date.startsWith(`${year}-`));
      if (!date) continue;
      const day = dayOf(date.date);
      add(lang, `/festival/${festivalSlug(f.id)}/${year}/`, {
        kicker: t(lang, 'festivals'),
        title: `${f[lang]} ${year}`,
        subtitle: `${day ? `${weekdayOf(lang, day.weekday)}, ` : ''}${gregorianDate(lang, date.date)} · ${malayalamDate(lang, date.ml)}`,
      });
    }
  }
  for (const m of completeMonths) {
    if (!featureYears.includes(Number(m.start.slice(0, 4)))) continue;
    const last = new Date(Date.parse(`${m.start}T00:00:00Z`) + (m.days - 1) * 86400000).toISOString().slice(0, 10);
    add(lang, `/month/${m.ml.y}/${m.ml.m}/`, {
      kicker: t(lang, 'months'),
      title: `${nameOf('months', m.ml.m, lang)} ${m.ml.y}`,
      subtitle: `${gregorianDate(lang, m.start)} – ${gregorianDate(lang, last)}`,
    });
  }
}

/** Every page image to render. */
export const ogEntries = [...entries.values()];

/** The preview image of the page at `path` in `lang`. */
export const ogImageFor = (lang: Lang, path: string) => entries.get(`${lang}${path}`)?.image ?? '/og.png';
