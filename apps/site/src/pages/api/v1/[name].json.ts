// /api/v1/<name>.json: the site's data, published as static files for
// other sites and apps (documented at /api/). The same JSON the pages are
// built from; GitHub Pages serves it with Access-Control-Allow-Origin: *.
import fs from 'node:fs';
import path from 'node:path';

/** Files published under /api/v1/ (days are per year, in days/). */
const apiFiles = [
  'meta', 'names', 'months', 'festivals', 'places', 'vrats', 'nakshatra_days',
] as const;

export function getStaticPaths() {
  return apiFiles.map((name) => ({ params: { name } }));
}

export function GET({ params }: { params: { name: string } }) {
  const text = fs.readFileSync(path.resolve('src/data', `${params.name}.json`), 'utf-8');
  return new Response(text, { headers: { 'content-type': 'application/json' } });
}
