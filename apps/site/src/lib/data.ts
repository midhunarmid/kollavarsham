// Reads the JSON written by apps/site_data (`npm run data`).
import fs from 'node:fs';
import path from 'node:path';

const dir = path.resolve('src/data');
const read = (file: string) =>
  JSON.parse(fs.readFileSync(path.join(dir, file), 'utf-8'));

export type Lang = 'en' | 'ml';
export type Names = { ml: string; en: string };
export type MlDate = { y: number; m: string; d: number };
export type Span = { id: string | number; until: string };

export interface Day {
  date: string;
  weekday: string;
  ml: MlDate;
  stars: Span[];
  tithis: Span[];
  paksha: string;
  sunrise: string | null;
  sunset: string | null;
  moonrise: string | null;
  moonset: string | null;
  kalams: Record<string, [string, string]>;
  festivals: string[];
}

export interface Month {
  ml: MlDate;
  start: string;
  days: number;
  sankranti: string;
}

export interface FestivalDate {
  date: string;
  ml: MlDate;
  holiday?: 'public' | 'restricted' | 'bank';
  tentative?: boolean;
  source?: string;
}

export interface Festival {
  id: string;
  category: string;
  ml: string;
  en: string;
  about: Names;
  rule: Names;
  dates: FestivalDate[];
}

export const meta: { from: number; to: number } = read('meta.json');
export const names: {
  months: Record<string, Names>;
  weekdays: Record<string, Names & { gregorian: string }>;
  stars: Record<string, Names>;
  tithis: Record<string, Names>;
  pakshas: Record<string, Names>;
  kalams: Record<string, Names>;
} = read('names.json');
export const months: Month[] = read('months.json');
export const festivals: Festival[] = read('festivals.json');

/** Years with day data, oldest first. */
export const years: number[] = Array.from(
  { length: meta.to - meta.from + 1 },
  (_, i) => meta.from + i,
);

const dayCache = new Map<number, Day[]>();

/** The days of a Gregorian year. */
export function daysOf(year: number): Day[] {
  if (!dayCache.has(year)) dayCache.set(year, read(`days/${year}.json`));
  return dayCache.get(year)!;
}

/** Every day with data, in order. */
export function allDays(): Day[] {
  return years.flatMap(daysOf);
}

/** The day with ISO date `iso`, if there is data for it. */
export function dayOf(iso: string): Day | undefined {
  const year = Number(iso.slice(0, 4));
  if (!years.includes(year)) return undefined;
  return daysOf(year).find((d) => d.date === iso);
}

/** URL slug of a festival: its English name, lower case. */
function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

const slugs = new Map<string, string>();
const taken = new Set<string>();
for (const f of festivals) {
  let slug = slugify(f.en) || slugify(f.id);
  if (taken.has(slug)) slug = slugify(f.id);
  taken.add(slug);
  slugs.set(f.id, slug);
}

/** The slug of the festival with `id`. */
export const festivalSlug = (id: string) => slugs.get(id)!;

/** The festival with `id`. */
export const festivalById = new Map(festivals.map((f) => [f.id, f]));

const addDays = (iso: string, n: number) =>
  new Date(Date.parse(`${iso}T00:00:00Z`) + n * 86400000).toISOString().slice(0, 10);

/** Malayalam months whose every day has data: the ones with a page. */
export const completeMonths: Month[] = months.filter(
  (m) => dayOf(m.start) && dayOf(addDays(m.start, m.days - 1)),
);

const monthPages = new Set(completeMonths.map((m) => `${m.ml.y}/${m.ml.m}`));

/** Whether the Malayalam month of `ml` has a page. */
export const hasMonthPage = (ml: MlDate) => monthPages.has(`${ml.y}/${ml.m}`);
