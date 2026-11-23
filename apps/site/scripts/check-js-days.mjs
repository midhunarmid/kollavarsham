// Checks that the compiled engine (public/kollavarsham.js) computes the same
// panchangam in JavaScript as the site data written by the Dart generator,
// for every day of the first full year the data holds, at
// Thiruvananthapuram. Place-specific times on the site come from this JS,
// so a dart2js difference would show up here.
//
//   node scripts/check-js-days.mjs
import fs from 'node:fs';
import vm from 'node:vm';

globalThis.self ??= globalThis;
vm.runInThisContext(fs.readFileSync('public/kollavarsham.js', 'utf-8'));
const k = globalThis.kollavarsham;
if (!k?.dayOf) throw new Error('kollavarsham.js has no dayOf');

const meta = JSON.parse(fs.readFileSync('src/data/meta.json', 'utf-8'));
const year = meta.from + 2;
const days = JSON.parse(fs.readFileSync(`src/data/days/${year}.json`, 'utf-8'));
const { latitude, longitude, utcOffsetMinutes } = meta.location;

const pick = (d) => ({
  stars: d.stars.map((s) => [String(s.id), s.until]),
  tithis: d.tithis.map((s) => [Number(s.id), s.until]),
  paksha: d.paksha,
  sunrise: d.sunrise, sunset: d.sunset, moonrise: d.moonrise, moonset: d.moonset,
  kalams: d.kalams,
});

let differences = 0;
for (const day of days) {
  const js = k.dayOf(day.date, latitude, longitude, utcOffsetMinutes);
  const a = JSON.stringify(pick(js));
  const b = JSON.stringify(pick(day));
  if (a !== b) {
    differences++;
    if (differences <= 5) console.error(`${day.date}\n  js:   ${a}\n  data: ${b}`);
  }
}
if (differences) {
  console.error(`${differences} of ${days.length} days differ between kollavarsham.js and the site data.`);
  process.exit(1);
}
console.log(`kollavarsham.js matches the site data on all ${days.length} days of ${year}`);
