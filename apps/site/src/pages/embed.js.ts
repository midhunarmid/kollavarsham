// /embed.js: a "today" card for other websites (temples, associations).
//
//   <script src="https://calendar.armid.in/embed.js" data-lang="ml" async></script>
//
// It draws today's Malayalam date, star, tithi and festivals in a shadow
// root next to the script tag, linking back to the day's page. The next
// 400 days are inside the script (rebuilt daily), so it makes no other
// request, sets no cookies and tracks nothing.
import { allDays, festivalById, keralaToday, names } from '../lib/data';

export function GET() {
  const from = keralaToday();
  const days = allDays().filter((d) => d.date >= from).slice(0, 400);
  const monthIds = Object.keys(names.months);
  const starIds = Object.keys(names.stars);
  const festivalIds = [...new Set(days.flatMap((d) => d.festivals))];
  const data = {
    months: monthIds.map((id) => [names.months[id].en, names.months[id].ml]),
    stars: starIds.map((id) => [names.stars[id].en, names.stars[id].ml]),
    tithis: Array.from({ length: 30 }, (_, i) => [names.tithis[String(i + 1)].en, names.tithis[String(i + 1)].ml]),
    festivals: festivalIds.map((id) => [festivalById.get(id)!.en, festivalById.get(id)!.ml]),
    // [date, Malayalam day, month index, Malayalam year, star index, tithi, festival indexes]
    days: days.map((d) => [
      d.date, d.ml.d, monthIds.indexOf(d.ml.m), d.ml.y,
      starIds.indexOf(String(d.stars[0].id)), Number(d.tithis[0].id),
      d.festivals.map((f) => festivalIds.indexOf(f)),
    ]),
  };
  const script = `/*! Malayalam Calendar embed · https://calendar.armid.in/api/ · no tracking */
(function () {
  'use strict';
  var D = ${JSON.stringify(data)};
  var script = document.currentScript;
  if (!script) return;
  var ml = script.getAttribute('data-lang') === 'ml';
  var L = ml ? 1 : 0;
  var host = document.createElement('div');
  host.className = 'malayalam-calendar-embed';
  script.parentNode.insertBefore(host, script.nextSibling);
  var root = host.attachShadow ? host.attachShadow({ mode: 'open' }) : host;
  var today = new Date(Date.now() + 330 * 60000).toISOString().slice(0, 10);
  var day = null;
  for (var i = 0; i < D.days.length; i++) if (D.days[i][0] === today) { day = D.days[i]; break; }
  var gm = ml
    ? ['ജനുവരി','ഫെബ്രുവരി','മാർച്ച്','ഏപ്രിൽ','മേയ്','ജൂൺ','ജൂലൈ','ഓഗസ്റ്റ്','സെപ്റ്റംബർ','ഒക്ടോബർ','നവംബർ','ഡിസംബർ']
    : ['January','February','March','April','May','June','July','August','September','October','November','December'];
  var site = 'https://calendar.armid.in' + (ml ? '/ml' : '');
  var style = '<style>:host{all:initial;display:block}' +
    '.c{font:15px/1.45 system-ui,-apple-system,"Segoe UI",Roboto,"Noto Sans","Noto Sans Malayalam",sans-serif;' +
    'border:1px solid #cfe0dc;border-radius:12px;padding:12px 14px;background:#fff;color:#17201e;max-width:360px}' +
    '.k{font-size:12px;color:#55615e;margin:0}.d{font-size:20px;font-weight:700;margin:2px 0}.s{margin:0;color:#33403d}' +
    '.f{margin:6px 0 0;color:#bf360c;font-weight:600}a{color:#00695c;font-size:13px;text-decoration:none}a:hover{text-decoration:underline}' +
    '@media (prefers-color-scheme:dark){.c{background:#182120;color:#e6eeec;border-color:#2c3b38}.k,.s{color:#a9b8b4}.f{color:#ff8a65}a{color:#80cbc4}}</style>';
  function esc(t) { return String(t).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  var g = today.split('-');
  var gregorian = Number(g[2]) + ' ' + gm[Number(g[1]) - 1] + ' ' + g[0];
  var html;
  if (day) {
    var fest = day[6].map(function (f) { return D.festivals[f][L]; }).join(', ');
    html = '<div class="c"><p class="k">' + esc(gregorian) + '</p>' +
      '<p class="d">' + esc(day[1] + ' ' + D.months[day[2]][L] + ' ' + day[3]) + '</p>' +
      '<p class="s">' + esc((ml ? 'നക്ഷത്രം: ' : 'Star: ') + D.stars[day[4]][L] + ' · ' + (ml ? 'തിഥി: ' : 'Tithi: ') + D.tithis[day[5] - 1][L]) + '</p>' +
      (fest ? '<p class="f">' + esc(fest) + '</p>' : '') +
      '<a href="' + site + '/day/' + today + '/" target="_blank" rel="noopener">' + (ml ? 'മലയാളം കലണ്ടർ' : 'Malayalam Calendar') + ' →</a></div>';
  } else {
    html = '<div class="c"><a href="' + site + '/" target="_blank" rel="noopener">' + (ml ? 'മലയാളം കലണ്ടർ' : 'Malayalam Calendar') + ' →</a></div>';
  }
  root.innerHTML = style + html;
})();
`;
  return new Response(script, { headers: { 'content-type': 'text/javascript' } });
}
