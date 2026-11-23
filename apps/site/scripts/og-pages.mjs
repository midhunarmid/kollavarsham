// Renders the per-page preview images listed in dist/og-manifest.json
// (src/lib/og.ts) into dist/og/, with headless Chrome over the DevTools
// protocol and scripts/og-page.html as the template, then removes the
// manifest so it isn't published.
//
//   node scripts/og-pages.mjs [path-to-chrome]
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const dist = path.resolve('dist');
const manifestPath = path.join(dist, 'og-manifest.json');
if (!fs.existsSync(manifestPath)) throw new Error('dist/og-manifest.json is missing: build the site first.');
const entries = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));

const chrome = [
  process.argv[2],
  process.env.CHROME,
  process.env.CHROME_PATH,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
].find((p) => p && fs.existsSync(p));
if (!chrome) throw new Error('No Chrome found; pass its path.');

const port = 9341;
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'og-pages-'));
const browser = spawn(chrome, [
  '--headless=new', '--disable-gpu', '--hide-scrollbars', '--allow-file-access-from-files',
  `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`, '--window-size=1200,630', 'about:blank',
], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

let target;
for (let i = 0; i < 50 && !target; i++) {
  await sleep(200);
  try {
    target = (await (await fetch(`http://127.0.0.1:${port}/json/list`)).json()).find((t) => t.type === 'page');
  } catch { /* not up yet */ }
}
if (!target) throw new Error('Chrome did not start.');
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => ws.addEventListener('open', r));
let id = 0;
const pending = new Map();
ws.addEventListener('message', (e) => {
  const msg = JSON.parse(e.data);
  if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); }
});
const send = (method, params = {}) => new Promise((resolve, reject) => {
  pending.set(++id, (msg) => (msg.error ? reject(new Error(msg.error.message)) : resolve(msg.result)));
  ws.send(JSON.stringify({ id, method, params }));
});

let written = 0;
const started = Date.now();
try {
  await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', { width: 1200, height: 630, deviceScaleFactor: 1, mobile: false });
  await send('Page.navigate', { url: pathToFileURL(path.resolve('scripts/og-page.html')).href });
  for (let i = 0; i < 50; i++) {
    const ready = await send('Runtime.evaluate', { expression: 'typeof window.render === "function"', returnByValue: true });
    if (ready.result.value) break;
    await sleep(100);
  }
  for (const entry of entries) {
    const result = await send('Runtime.evaluate', {
      expression: `window.render(${JSON.stringify(entry)}).then(() => new Promise((r) => requestAnimationFrame(() => r(true))))`,
      awaitPromise: true,
      returnByValue: true,
    });
    if (result.exceptionDetails) throw new Error(`render failed for ${entry.image}`);
    const shot = await send('Page.captureScreenshot', {
      format: 'png', clip: { x: 0, y: 0, width: 1200, height: 630, scale: 1 },
    });
    const file = path.join(dist, entry.image);
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, Buffer.from(shot.data, 'base64'));
    written++;
  }
} finally {
  ws.close();
  browser.kill();
}
fs.rmSync(manifestPath);
console.log(`Wrote ${written} preview images in ${((Date.now() - started) / 1000).toFixed(1)} s`);
