// Offline support for the web app at /app/.
//
// Pages (navigations) are fetched from the network first, falling back to
// the cached copy; everything else (the app's code, CanvasKit, fonts,
// including Google's font files Flutter fetches for missing glyphs) is
// served from the cache and refreshed in the background. After one online
// visit the app opens offline.
const CACHE = 'malayalam-calendar-app-v1';
const SHELL = ['./', 'index.html', 'browser.js', 'flutter_bootstrap.js', 'main.dart.js', 'manifest.json'];

// The app's code: when the background refresh brings a different copy,
// the open pages are told a reload will show the new version.
function isAppCode(url) {
  return url.origin === self.location.origin && /\/(main\.dart\.js|main\.dart\.wasm|main\.dart\.mjs)$/.test(url.pathname);
}

function sameVersion(a, b) {
  for (const header of ['etag', 'last-modified', 'content-length']) {
    const x = a.headers.get(header);
    const y = b.headers.get(header);
    if (x && y) return x === y;
  }
  return true; // Nothing to compare: don't claim an update.
}

async function announceUpdate() {
  const clients = await self.clients.matchAll({ type: 'window' });
  for (const client of clients) client.postMessage({ type: 'update-ready' });
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(SHELL)).then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim()),
  );
});

function cacheable(request) {
  if (request.method !== 'GET') return false;
  const url = new URL(request.url);
  if (url.origin === self.location.origin) return url.pathname.startsWith(new URL(self.registration.scope).pathname);
  return url.hostname === 'fonts.gstatic.com' || url.hostname === 'fonts.googleapis.com';
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (!cacheable(request)) return;

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put('index.html', copy));
          return response;
        })
        .catch(() => caches.match('index.html')),
    );
    return;
  }

  // Stale-while-revalidate: answer from the cache when possible, and keep
  // the worker alive until the refreshed copy is stored.
  const lookup = caches.open(CACHE).then(async (cache) => {
    const cached = await cache.match(request);
    const network = fetch(request)
      .then(async (response) => {
        if (response.ok || response.type === 'opaque') {
          const updated = cached && response.ok && isAppCode(new URL(request.url)) &&
            !sameVersion(cached, response);
          await cache.put(request, response.clone());
          if (updated) await announceUpdate();
        }
        return response;
      })
      .catch(() => cached);
    return { cached, network };
  });
  event.respondWith(lookup.then(({ cached, network }) => cached || network));
  event.waitUntil(lookup.then(({ network }) => network).catch(() => undefined));
});
