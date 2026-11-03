// Renders public/og.png (1200x630) from scripts/og.html with headless
// Chrome or Edge, which shape Malayalam text properly.
//   node scripts/og_image.mjs [path-to-browser]
import { execFileSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const candidates = [
  process.argv[2],
  process.env.CHROME,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
].filter(Boolean);
const browser = candidates.find((p) => existsSync(p));
if (!browser) throw new Error('No Chrome or Edge found; pass its path.');

execFileSync(browser, [
  '--headless=new',
  '--disable-gpu',
  '--hide-scrollbars',
  '--allow-file-access-from-files',
  `--screenshot=${path.resolve('public/og.png')}`,
  '--window-size=1200,630',
  pathToFileURL(path.resolve('scripts/og.html')).href,
], { stdio: 'inherit' });
console.log('Wrote public/og.png');
