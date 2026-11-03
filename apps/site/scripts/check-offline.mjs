// Checks that the web app at /app/ opens offline after two online visits.
//
//   node scripts/check-offline.mjs [path-to-chrome]
//
// Serves dist/ (with dist/app from the Flutter web build) on a local port,
// drives headless Chrome over the DevTools protocol in a fresh profile:
// visit /app/ (the service worker installs), visit again (it caches what
// the app loads), stop the server, reload, and check that Flutter renders.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import http from 'node:http';
import os from 'node:os';
import path from 'node:path';

const dist = path.resolve('dist');
if (!fs.existsSync(path.join(dist, 'app', 'index.html'))) {
  throw new Error('dist/app is missing: copy the Flutter web build there first.');
}
const chrome = [
  process.argv[2],
  process.env.CHROME,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
].find((p) => p && fs.existsSync(p));
if (!chrome) throw new Error('No Chrome found; pass its path.');

const types = {
  '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.png': 'image/png', '.otf': 'font/otf',
  '.ttf': 'font/ttf', '.svg': 'image/svg+xml', '.css': 'text/css',
};
const server = http.createServer((req, res) => {
  let file = path.join(dist, decodeURIComponent(new URL(req.url, 'http://x').pathname));
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
  if (!fs.existsSync(file)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'content-type': types[path.extname(file)] ?? 'application/octet-stream' });
  fs.createReadStream(file).pipe(res);
});
await new Promise((r) => server.listen(8791, r));

const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'offline-check-'));
const browser = spawn(chrome, [
  '--headless=new', '--disable-gpu', '--remote-debugging-port=9339',
  `--user-data-dir=${profile}`, 'about:blank',
], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

let target;
for (let i = 0; i < 50 && !target; i++) {
  await sleep(200);
  try {
    const list = await (await fetch('http://127.0.0.1:9339/json/list')).json();
    target = list.find((t) => t.type === 'page');
  } catch { /* not up yet */ }
}
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => ws.addEventListener('open', r));
let id = 0;
const pending = new Map();
ws.addEventListener('message', (e) => {
  const msg = JSON.parse(e.data);
  if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); }
});
const send = (method, params = {}) => new Promise((resolve) => {
  pending.set(++id, resolve);
  ws.send(JSON.stringify({ id, method, params }));
});
const evaluate = async (expression) =>
  (await send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true })).result?.result?.value;

const url = 'http://localhost:8791/app/';
let ok = false;
try {
  await send('Page.enable');
  await send('Page.navigate', { url });
  await sleep(12000);
  await send('Page.navigate', { url });
  await sleep(12000);
  const cached = await evaluate(`caches.keys().then(async (k) => (await (await caches.open(k[0])).keys()).length)`);
  console.log(`Online: ${cached} files cached`);
  server.close();
  server.closeAllConnections?.();
  await send('Page.reload', { ignoreCache: false });
  await sleep(10000);
  const rendered = await evaluate(`!!document.querySelector('flutter-view, flt-glass-pane')`);
  const href = await evaluate('location.href');
  console.log(`Offline: ${rendered ? 'the app rendered' : 'the app did not render'} at ${href}`);
  ok = rendered === true;
} finally {
  ws.close();
  browser.kill();
  server.close();
}
process.exit(ok ? 0 : 1);
