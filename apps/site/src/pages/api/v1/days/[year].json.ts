// /api/v1/days/<year>.json: every day of a Gregorian year with its
// Malayalam date and panchangam (see /api/).
import fs from 'node:fs';
import path from 'node:path';
import { years } from '../../../../lib/data';

export function getStaticPaths() {
  return years.map((year) => ({ params: { year: String(year) } }));
}

export function GET({ params }: { params: { year: string } }) {
  const text = fs.readFileSync(path.resolve('src/data/days', `${params.year}.json`), 'utf-8');
  return new Response(text, { headers: { 'content-type': 'application/json' } });
}
