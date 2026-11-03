// Site strings and formatting in English and Malayalam.
import { names, type Lang, type MlDate } from './data';

export const langs: Lang[] = ['en', 'ml'];

/** Path prefix of a language: '' for English, '/ml' for Malayalam. */
export const prefix = (lang: Lang) => (lang === 'ml' ? '/ml' : '');

/** `path` (starting with '/') in `lang`. */
export const href = (lang: Lang, path: string) => `${prefix(lang)}${path}`;

const strings = {
  siteName: { en: 'Malayalam Calendar', ml: 'മലയാളം കലണ്ടർ' },
  tagline: {
    en: 'Kollavarsham dates, panchangam and Kerala festivals',
    ml: 'കൊല്ലവർഷ തീയതി, പഞ്ചാംഗം, കേരളത്തിലെ വിശേഷങ്ങൾ',
  },
  today: { en: 'Today', ml: 'ഇന്ന്' },
  calendar: { en: 'Calendar', ml: 'കലണ്ടർ' },
  festivals: { en: 'Festivals', ml: 'വിശേഷങ്ങൾ' },
  converter: { en: 'Date converter', ml: 'തീയതി മാറ്റൽ' },
  nakshatraToday: { en: 'Nakshatra today', ml: 'ഇന്നത്തെ നക്ഷത്രം' },
  openApp: { en: 'Open the app', ml: 'ആപ്പ് തുറക്കുക' },
  star: { en: 'Star', ml: 'നക്ഷത്രം' },
  tithi: { en: 'Tithi', ml: 'തിഥി' },
  paksha: { en: 'Paksha', ml: 'പക്ഷം' },
  sunrise: { en: 'Sunrise', ml: 'സൂര്യോദയം' },
  sunset: { en: 'Sunset', ml: 'സൂര്യാസ്തമയം' },
  moonrise: { en: 'Moonrise', ml: 'ചന്ദ്രോദയം' },
  moonset: { en: 'Moonset', ml: 'ചന്ദ്രാസ്തമയം' },
  until: { en: 'until', ml: 'വരെ' },
  nextDay: { en: 'next day', ml: 'പിറ്റേന്ന്' },
  none: { en: 'None', ml: 'ഇല്ല' },
  panchangam: { en: 'Panchangam', ml: 'പഞ്ചാംഗം' },
  noFestival: { en: 'No festival on this day', ml: 'ഈ ദിവസം വിശേഷങ്ങളില്ല' },
  previousDay: { en: 'Previous day', ml: 'മുൻ ദിവസം' },
  nextDayLink: { en: 'Next day', ml: 'അടുത്ത ദിവസം' },
  timesNote: {
    en: 'Times are for Thiruvananthapuram (IST). The app computes them for your own place.',
    ml: 'സമയങ്ങൾ തിരുവനന്തപുരത്തേതാണ് (IST). ആപ്പിൽ നിങ്ങളുടെ സ്ഥലത്തേതു കാണാം.',
  },
  about: { en: 'About', ml: 'വിവരണം' },
  rule: { en: 'How the date is found', ml: 'തീയതി കണ്ടെത്തുന്ന വിധം' },
  otherYears: { en: 'Other years', ml: 'മറ്റു വർഷങ്ങൾ' },
  publicHoliday: { en: 'Public holiday', ml: 'പൊതു അവധി' },
  restrictedHoliday: { en: 'Restricted holiday', ml: 'നിയന്ത്രിത അവധി' },
  bankHoliday: { en: 'Bank holiday', ml: 'ബാങ്ക് അവധി' },
  tentative: { en: 'Date may change', ml: 'തീയതി മാറിയേക്കാം' },
  source: { en: 'Source', ml: 'ഉറവിടം' },
  malayalamCalendarYear: { en: 'Malayalam Calendar {year}', ml: 'മലയാളം കലണ്ടർ {year}' },
  upcomingFestivals: { en: 'Upcoming festivals', ml: 'വരാനിരിക്കുന്ന വിശേഷങ്ങൾ' },
  allFestivals: { en: 'All festivals', ml: 'എല്ലാ വിശേഷങ്ങളും' },
  months: { en: 'Months', ml: 'മാസങ്ങൾ' },
  date: { en: 'Date', ml: 'തീയതി' },
  day: { en: 'Day', ml: 'ദിവസം' },
  malayalamDate: { en: 'Malayalam date', ml: 'മലയാള തീയതി' },
  englishDate: { en: 'English date', ml: 'ഇംഗ്ലീഷ് തീയതി' },
  needsJs: {
    en: 'Turn on JavaScript to see today’s date here.',
    ml: 'ഇന്നത്തെ തീയതി കാണാൻ JavaScript ഓണാക്കുക.',
  },
  language: { en: 'മലയാളം', ml: 'English' },
  findStar: { en: 'Find my star', ml: 'എന്റെ നക്ഷത്രം കണ്ടെത്തുക' },
  birthDateTime: { en: 'Date and time of birth', ml: 'ജനന തീയതിയും സമയവും' },
  convert: { en: 'Convert', ml: 'മാറ്റുക' },
  find: { en: 'Find', ml: 'കണ്ടെത്തുക' },
  pada: { en: 'pada', ml: 'പാദം' },
  rashi: { en: 'rashi', ml: 'രാശി' },
  year: { en: 'Year', ml: 'വർഷം' },
  month: { en: 'Month', ml: 'മാസം' },
  invalid: { en: 'There is no such date.', ml: 'അങ്ങനെയൊരു തീയതിയില്ല.' },
  placeNote: {
    en: 'Computed in your browser for Thiruvananthapuram.',
    ml: 'തിരുവനന്തപുരത്തേക്ക് നിങ്ങളുടെ ബ്രൗസറിൽ കണക്കാക്കിയത്.',
  },
  notFound: { en: 'Page not found', ml: 'പേജ് കണ്ടെത്തിയില്ല' },
  kalams: { en: 'Kalams', ml: 'കാലങ്ങൾ' },
  footer: {
    en: 'Free, no ads, no tracking. Dates are computed; almanacs can differ by a day.',
    ml: 'സൗജന്യം, പരസ്യമില്ല, നിരീക്ഷണമില്ല. തീയതികൾ കണക്കാക്കുന്നതാണ്; പഞ്ചാംഗങ്ങളുമായി ഒരു ദിവസം വ്യത്യാസം വരാം.',
  },
} as const;

export type Key = keyof typeof strings;

/** The string `key` in `lang`, with `{name}` placeholders filled. */
export function t(lang: Lang, key: Key, values: Record<string, string | number> = {}): string {
  let text: string = strings[key][lang];
  for (const [k, v] of Object.entries(values)) text = text.replace(`{${k}}`, String(v));
  return text;
}

/** The name `id` from a names table, in `lang`. */
export function nameOf(table: keyof typeof names, id: string | number, lang: Lang): string {
  const entry = (names[table] as Record<string, { ml: string; en: string }>)[String(id)];
  return entry ? entry[lang] : String(id);
}

const gregorianMonths = {
  en: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  ml: ['ജനുവരി', 'ഫെബ്രുവരി', 'മാർച്ച്', 'ഏപ്രിൽ', 'മേയ്', 'ജൂൺ', 'ജൂലൈ', 'ഓഗസ്റ്റ്', 'സെപ്റ്റംബർ', 'ഒക്ടോബർ', 'നവംബർ', 'ഡിസംബർ'],
};

/** A Gregorian month name. */
export const gregorianMonth = (lang: Lang, month: number) => gregorianMonths[lang][month - 1];

/** `2026-11-02` as "2 November 2026". */
export function gregorianDate(lang: Lang, iso: string): string {
  const [y, m, d] = iso.split('-').map(Number);
  return `${d} ${gregorianMonth(lang, m)} ${y}`;
}

/** A Malayalam date as "17 Thulam 1202". */
export function malayalamDate(lang: Lang, ml: MlDate): string {
  return `${ml.d} ${nameOf('months', ml.m, lang)} ${ml.y}`;
}

/** The weekday of a day in `lang`: Malayalam name, or Gregorian in English. */
export function weekdayOf(lang: Lang, id: string): string {
  const w = names.weekdays[id];
  return lang === 'ml' ? w.ml : w.gregorian;
}

/**
 * The clock time of local `yyyy-mm-ddThh:mm`, marked when it falls after
 * the day `iso`.
 */
export function timeOf(lang: Lang, local: string | null, iso: string): string {
  if (!local) return t(lang, 'none');
  const time = local.slice(11, 16);
  return local.slice(0, 10) === iso ? time : `${time} (${t(lang, 'nextDay')})`;
}

/** The holiday label of a festival date. */
export function holidayLabel(lang: Lang, kind?: string): string | undefined {
  if (kind === 'public') return t(lang, 'publicHoliday');
  if (kind === 'restricted') return t(lang, 'restrictedHoliday');
  if (kind === 'bank') return t(lang, 'bankHoliday');
  return undefined;
}

/** The `lang` param value for getStaticPaths: undefined for English. */
export const langParam = (lang: Lang) => (lang === 'ml' ? 'ml' : undefined);

/** The language of a `lang` route param. */
export const langOf = (param: string | undefined): Lang => (param === 'ml' ? 'ml' : 'en');

/** "Pooradam until 14:20" / "പൂരാടം 14:20 വരെ". */
export function spanText(lang: Lang, name: string, until: string, iso: string): string {
  const time = timeOf(lang, until, iso);
  return lang === 'ml' ? `${name} ${time} ${t(lang, 'until')}` : `${name} ${t(lang, 'until')} ${time}`;
}
