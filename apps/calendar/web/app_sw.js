// Offline support for the web app at /app/.
//
// Pages (navigations) are fetched from the network first, falling back to
// the cached copy; everything else (the app's code, CanvasKit, fonts,
// including Google's font files Flutter fetches for missing glyphs) is
// served from the cache and refreshed in the background. After one online
// visit the app opens offline.
const CACHE = 'malayalam-calendar-app-v1';
const SHELL = ['./', 'index.html', 'flutter_bootstrap.js', 'main.dart.js', 'manifest.json'];

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

  event.respondWith(
    caches.open(CACHE).then(async (cache) => {
      const cached = await cache.match(request);
      const network = fetch(request)
        .then((response) => {
          if (response.ok || response.type === 'opaque') cache.put(request, response.clone());
          return response;
        })
        .catch(() => cached);
      return cached || network;
    }),
  );
});
