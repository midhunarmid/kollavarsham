// Checks the built site in dist/: every internal link resolves, every page
// has a canonical URL and (except 404) en/ml alternates, and the sitemap
// exists. Links into /app/ (the Flutter app, added at deploy) are skipped.
import fs from 'node:fs';
import path from 'node:path';

const dist = path.resolve('dist');
const pages = [];
(function walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (e.name.endsWith('.html')) pages.push(p);
  }
})(dist);

const exists = (url) => {
  const clean = decodeURI(url.split(/[?#]/)[0]);
  const p = path.join(dist, clean);
  return fs.existsSync(p) && (fs.statSync(p).isFile() || fs.existsSync(path.join(p, 'index.html')));
};

const problems = [];
let links = 0;
for (const file of pages) {
  const html = fs.readFileSync(file, 'utf-8');
  const rel = path.relative(dist, file);
  if (!html.includes('rel="canonical"')) problems.push(`${rel}: no canonical link`);
  if (!rel.startsWith('404') && !(html.includes('hreflang="en-IN"') && html.includes('hreflang="ml-IN"'))) {
    problems.push(`${rel}: missing hreflang alternates`);
  }
  for (const [, href] of html.matchAll(/href="(\/[^"]*)"/g)) {
    if (href.startsWith('/app/') || href.startsWith('//')) continue;
    links++;
    if (!exists(href)) problems.push(`${rel}: broken link ${href}`);
  }
}
if (!fs.existsSync(path.join(dist, 'sitemap-index.xml'))) problems.push('no sitemap-index.xml');

console.log(`${pages.length} pages, ${links} internal links checked`);
if (problems.length) {
  console.error([...new Set(problems)].slice(0, 50).join('\n'));
  console.error(`${problems.length} problem(s)`);
  process.exit(1);
}
