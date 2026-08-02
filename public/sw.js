// Inkwell service worker
// Kept deliberately minimal: Inkwell's content (feed, chat, profiles) changes
// constantly, so this does NOT try to cache pages or API responses. Its only
// job is to satisfy the "installable PWA" requirement (required for TWA /
// Play Store packaging) and cache static assets like icons and CSS so the
// app shell loads instantly.

const CACHE_NAME = 'inkwell-static-v1';
const STATIC_ASSETS = [
  '/css/style.css',
  '/icons/icon-192.png',
  '/icons/icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const { request } = event;

  // Never intercept anything other than same-origin GET requests.
  // This leaves Socket.io's websocket/polling traffic, POST forms
  // (login, publish, comments, etc.) and cross-origin calls untouched.
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) {
    return;
  }

  // Only cache static assets; everything else (pages, feed, chat) always
  // goes to the network so users never see stale content.
  if (STATIC_ASSETS.some((path) => request.url.endsWith(path))) {
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request))
    );
  }
});
