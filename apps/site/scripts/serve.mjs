// A plain static server for dist/, shared by the offline check and
// Lighthouse CI (which starts it as `node scripts/serve.mjs 8790`).
//
//   node scripts/serve.mjs [port]
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import zlib from 'node:zlib';

const types = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png',
  '.otf': 'font/otf', '.ttf': 'font/ttf', '.woff': 'font/woff', '.woff2': 'font/woff2',
  '.svg': 'image/svg+xml', '.css': 'text/css', '.xml': 'application/xml',
  '.txt': 'text/plain', '.ics': 'text/calendar; charset=utf-8',
};

/** An HTTP server for the files under `dist` (directories serve index.html). */
export function staticServer(dist) {
  return http.createServer((req, res) => {
    let file = path.join(dist, decodeURIComponent(new URL(req.url, 'http://x').pathname));
    if (!file.startsWith(dist)) { res.writeHead(403); res.end(); return; }
    if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
    if (!fs.existsSync(file)) {
      const missing = path.join(dist, '404.html');
      res.writeHead(404, { 'content-type': types['.html'] });
      if (fs.existsSync(missing)) fs.createReadStream(missing).pipe(res); else res.end();
      return;
    }
    const type = types[path.extname(file)] ?? 'application/octet-stream';
    // Compress text as GitHub Pages does, so Lighthouse sees real sizes.
    const gzip = /text|javascript|json|xml|svg|calendar|wasm/.test(type) &&
      /\bgzip\b/.test(req.headers['accept-encoding'] ?? '');
    res.writeHead(200, { 'content-type': type, ...(gzip ? { 'content-encoding': 'gzip' } : {}) });
    const body = fs.createReadStream(file);
    if (gzip) body.pipe(zlib.createGzip()).pipe(res); else body.pipe(res);
  });
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const port = Number(process.argv[2] ?? 8790);
  staticServer(path.resolve('dist')).listen(port, () => {
    console.log(`Serving dist/ at http://localhost:${port}/`);
  });
}
