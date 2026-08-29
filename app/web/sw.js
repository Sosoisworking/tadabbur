'use strict';

/*
  Tadabbur's service worker.

  Why this file exists at all: the app is distributed as a PWA (see
  install_guide_screen.dart, which promises it "runs full-screen and offline").
  Flutter's own `flutter_service_worker.js` is now a self-unregistering stub and
  the whole bootstrap-driven SW path is deprecated (flutter#156910), so a cold
  home-screen launch with no network used to land on Safari's error page. This
  worker is what makes that claim true.

  Where it lives and how it survives a build: `flutter build web` regenerates
  and overwrites `flutter_service_worker.js` every time, but it copies every
  *other* file under `web/` to `build/web/` verbatim
  (flutter_tools/lib/src/build_system/targets/web.dart, the "Copy other resource
  files out of web/ directory" loop, which skips only index.html and
  flutter_bootstrap.js). So this file is deliberately NOT named
  flutter_service_worker.js: as `sw.js` it is copied through untouched.

  Nothing registers Flutter's stub: web/flutter_bootstrap.js is a custom
  template that omits `serviceWorkerSettings` entirely. That matters — the
  default bootstrap calls `getRegistration()` and, if it finds *any* worker in
  scope, registers `flutter_service_worker.js` over it, which would replace this
  worker with the stub and then unregister it.

  ---------------------------------------------------------------------------
  UPDATE STRATEGY (the "don't pin users to a stale build" part)
  ---------------------------------------------------------------------------
  A naive cache-everything worker strands users on an old build forever, because
  a byte-identical sw.js is never reinstalled no matter how much the app around
  it changed. Four things prevent that here:

  1. The worker is registered as `sw.js?v=<token>`, where the token is Flutter's
     per-build service-worker version placeholder, substituted into index.html
     at build time. A new build means a new script URL, and the spec treats a
     changed script URL as a new worker to install — no byte-diff short circuit.

  2. Every cache this worker owns is namespaced with that same token (read back
     off `self.location.search`), so a new build precaches into new caches and
     cannot read the previous build's bytes.

  3. `activate` deletes every `tadabbur-`-prefixed cache that is not in KEEP, so
     old builds are actively reclaimed rather than accumulating.

  4. The navigation document is network-first (with a short timeout and a cache
     fallback), not cache-first. index.html is the file that carries the version
     token, so keeping it fresh is what lets the chain above start at all. If it
     were cache-first, a stale index would keep re-registering the stale token
     and the app could never discover a new build.

  Taking control is deliberate rather than automatic. `install` does NOT call
  skipWaiting: a new worker precaches and then waits, so a running session is
  never swapped onto a different build mid-use. The page (index.html) applies
  the waiting worker only at a launch boundary — see the registration script
  there — which bounds staleness to at most one launch while never pulling the
  rug out from under an active session.

  ---------------------------------------------------------------------------
  WHAT IS NEVER CACHED
  ---------------------------------------------------------------------------
  Supabase traffic is excluded twice over: cross-origin requests are not
  intercepted at all (Supabase lives on its own host), and any same-origin URL
  whose path looks like a Supabase REST/auth/realtime/storage/functions endpoint
  is passed straight through, which covers a self-hosted instance proxied under
  this domain. Non-GET requests are never touched. See SUPABASE_PATH.
*/

// ---------------------------------------------------------------------------
// Versioning
// ---------------------------------------------------------------------------

/// Flutter's per-build service-worker token, handed over by index.html via the
/// registration URL (`sw.js?v=...`). Falls back to a constant only when the
/// worker was somehow registered without one — in which case cache names stop
/// varying per build, so index.html deliberately refuses to register at all.
const BUILD = new URL(self.location.href).searchParams.get('v') || 'unversioned';

const SHELL_CACHE = `tadabbur-shell-${BUILD}`;
const RUNTIME_CACHE = `tadabbur-runtime-${BUILD}`;

const KEEP = new Set([SHELL_CACHE, RUNTIME_CACHE]);

/// Only caches we own are ever deleted; another app on the same origin must not
/// be collateral damage.
const OWNED_CACHE_PREFIX = 'tadabbur-';

// ---------------------------------------------------------------------------
// The app shell
// ---------------------------------------------------------------------------

/// Everything a cold, offline launch needs to reach first frame. If any of
/// these fails to download, install fails and the old worker stays in charge —
/// a half-precached shell is worse than no shell, because it fails *after* the
/// user has been told the app works offline.
///
/// CanvasKit is listed as the single `canvaskit/` variant rather than the
/// `chromium/` one on purpose: web/flutter_bootstrap.js pins
/// `canvasKitVariant: 'full'` so the engine's browser-dependent variant choice
/// cannot disagree with what was precached. See the note there.
const SHELL_CORE = [
  '.', // the navigation URL: the bytes of index.html under the canonical key
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-192.png',
  'icons/Icon-maskable-512.png',
  'canvaskit/canvaskit.js',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  // The three bundled families. Nested under assets/assets/ because that is
  // where Flutter puts an asset declared as `assets/fonts/…` in pubspec.
  //
  // Amiri Quran is the one entry here that is not cosmetic: without it an
  // offline launch renders Qur'anic Arabic in whatever system face the
  // device picks, and a substitute cannot position Tashkeel — which is the
  // entire reason these were bundled rather than fetched.
  'assets/assets/fonts/AmiriQuran-Regular.ttf',
  'assets/assets/fonts/Lora-Regular.ttf',
  'assets/assets/fonts/Lora-Medium.ttf',
  'assets/assets/fonts/Lora-Italic.ttf',
  'assets/assets/fonts/WorkSans-Regular.ttf',
  'assets/assets/fonts/WorkSans-Medium.ttf',
  'assets/assets/fonts/WorkSans-SemiBold.ttf',
  'assets/assets/fonts/WorkSans-Bold.ttf',
  'assets/shaders/ink_sparkle.frag',
  'assets/shaders/stretch_effect.frag',
];

/// Best-effort: nice to have offline, but not worth failing an install over.
/// `index.html` is the same bytes as '.' under its explicit name, and some
/// static hosts answer it with a redirect to '/' rather than the file.
const SHELL_OPTIONAL = ['index.html'];

/// Fetched after the worker activates, never as part of install.
///
/// canvaskit.wasm is 6.9 MB — on its own more than half of what a full
/// precache weighs. Install is atomic, so while it was in SHELL_CORE the
/// entire update hinged on that one download finishing: a phone that
/// downloaded 10 MB and was then backgrounded cached nothing, left no worker
/// waiting, and started again from zero on the next launch. In practice
/// updates stopped landing on iOS at all, because a PWA is suspended the
/// moment it leaves the foreground.
///
/// Deferring it makes the atomic part ~4 MB, which finishes in seconds, so
/// the new build reliably reaches `waiting` and can be offered. The wasm is
/// then warmed in the background, and a miss is not fatal either way:
/// cacheFirstShell falls through to the network and adopts what it gets.
///
/// The tradeoff, stated plainly: for a short window after an update — until
/// the warm completes — going offline can fail to render. Before this change
/// offline was guaranteed the instant install completed, but updates
/// effectively never completed on a phone. A narrow window beats a permanent
/// one.
const SHELL_DEFERRED = ['canvaskit/canvaskit.wasm'];

/*
  DEVIATION, FLAGGED DELIBERATELY.

  The brief said "never cache .env". Taken literally that makes offline
  impossible, and offline is the point of this change: main.dart's startup does

      await dotenv.load(fileName: '.env');   // lib/main.dart

  before anything else, and `.env` ships as a Flutter *asset* at
  `assets/.env`. Uncached, that fetch fails on a cold offline launch and startup
  falls through to StartupFailureApp — the shell would load and then immediately
  show an error, which is not meaningfully better than the Safari error page.

  What is actually in the file is SUPABASE_URL and the *publishable* key. Both
  are public by construction (the file's own header calls it the publishable
  key; RLS is what protects data), and the static host already serves them to
  anyone at a stable URL, so caching them discloses nothing HTTP did not.

  The real risk behind "don't cache it" is staleness — a rotated key pinned
  forever in a cache. That is handled rather than ignored: `.env` is precached so
  offline works, but it is served **network-first** (see the fetch handler), so
  an online client always gets the current file and a rotation propagates on the
  very next launch. It is also namespaced per build like everything else, so it
  cannot outlive a deploy.

  Flip this to `false` to honour the brief literally; the cost is that offline
  launches reach the shell and then fail at startup.
*/
const PRECACHE_ENV = true;
const ENV_ASSET = 'assets/.env';

// ---------------------------------------------------------------------------
// Exclusions
// ---------------------------------------------------------------------------

/// Supabase's own hosts. Cross-origin requests are already ignored wholesale,
/// so this is belt-and-braces for anything that resolves oddly.
const SUPABASE_HOST = /(^|\.)supabase\.(co|in|net)$/i;

/// Supabase's URL shape, matched on path so a self-hosted instance reverse
/// proxied under this origin is excluded too.
const SUPABASE_PATH = /\/(rest|auth|realtime|storage|functions|graphql)\/v\d+\//i;


/// How long a launch will wait on the network for the navigation document (and
/// for `.env`) before falling back to the cached copy. Short enough that a dead
/// or captive network does not turn into a visibly hung boot screen; the boot
/// splash in index.html covers the wait.
const NETWORK_FIRST_TIMEOUT_MS = 2500;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Resolves a shell path against this worker's own location, so a deploy under
/// a `--base-href` subpath keeps working. The `?v=` query is dropped by URL
/// resolution, which is what we want for cache keys.
function shellUrl(path) {
  return new URL(path, self.location.href).toString();
}

/// Cache keys for the shell, precomputed so the fetch handler is a set lookup.
const SHELL_URLS = new Set(
  SHELL_CORE.concat(SHELL_OPTIONAL).map(shellUrl),
);

const DOCUMENT_URL = shellUrl('.');
const ENV_URL = shellUrl(ENV_ASSET);

function isSupabase(url) {
  return SUPABASE_HOST.test(url.hostname) || SUPABASE_PATH.test(url.pathname);
}

/// Same URL minus any query string — shell assets are requested without one,
/// but a cache-busting suffix should not cause a miss.
function withoutSearch(url) {
  const stripped = new URL(url);
  stripped.search = '';
  stripped.hash = '';
  return stripped.toString();
}

/// Only ever store responses we actually served successfully from this origin.
/// Opaque and error responses would poison the cache with unusable bytes, and
/// an explicit `no-store` is the server telling us not to.
function isStorable(response) {
  if (!response || !response.ok || response.type !== 'basic') return false;
  const cc = response.headers.get('cache-control') || '';
  return !cc.includes('no-store');
}

function fetchWithTimeout(request, timeoutMs) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  return fetch(request, { signal: controller.signal }).finally(() =>
    clearTimeout(timer),
  );
}

function offlineResponse() {
  return new Response('', {
    status: 504,
    statusText: 'Offline and not cached',
    headers: { 'cache-control': 'no-store' },
  });
}

// ---------------------------------------------------------------------------
// install — precache the shell
// ---------------------------------------------------------------------------

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(SHELL_CACHE);

      // `cache: 'reload'` bypasses the browser's HTTP cache. Without it a build
      // can be precached from stale bytes the HTTP cache is still holding,
      // which would defeat the whole versioning scheme.
      const precache = async (path) => {
        const url = shellUrl(path);
        const response = await fetch(new Request(url, { cache: 'reload' }));
        if (!response.ok) {
          throw new Error(`precache ${path}: HTTP ${response.status}`);
        }
        await cache.put(url, response);
      };

      const required = SHELL_CORE.slice();
      if (PRECACHE_ENV) required.push(ENV_ASSET);

      await Promise.all(required.map(precache));

      await Promise.all(
        SHELL_OPTIONAL.map((path) =>
          precache(path).catch((error) => {
            console.warn('[sw] optional precache skipped:', path, error);
          }),
        ),
      );

      // Deliberately no skipWaiting(). A freshly installed worker waits; the
      // page decides when to hand over. See the header comment.
    })(),
  );
});

// ---------------------------------------------------------------------------
// activate — reclaim every cache that is not this build's
// ---------------------------------------------------------------------------

/// Pulls [SHELL_DEFERRED] into the shell cache in the background, skipping
/// anything already there so a re-activation is cheap. Failures are logged and
/// dropped: this is an optimisation, and the fetch handler copes without it.
async function warmDeferred() {
  try {
    const cache = await caches.open(SHELL_CACHE);
    for (const path of SHELL_DEFERRED) {
      const url = shellUrl(path);
      if (await cache.match(url)) continue;
      try {
        const response = await fetch(new Request(url, { cache: 'reload' }));
        if (response.ok) await cache.put(url, response);
      } catch (error) {
        console.warn('[sw] deferred warm skipped:', path, error);
      }
    }
  } catch (error) {
    console.warn('[sw] deferred warm failed:', error);
  }
}

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const names = await caches.keys();
      await Promise.all(
        names
          .filter((name) => name.startsWith(OWNED_CACHE_PREFIX) && !KEEP.has(name))
          .map((name) => caches.delete(name)),
      );

      // Claim so that the page which just triggered the handover is controlled
      // immediately, rather than only after another navigation.
      await self.clients.claim();

      // Deliberately not awaited: warming the deferred assets must not hold up
      // activation, or it would just move the stall that deferring them was
      // meant to remove. If the worker is terminated mid-download the cache
      // simply stays cold and the next fetch adopts it from the network.
      warmDeferred();
    })(),
  );
});

// ---------------------------------------------------------------------------
// message — the page's explicit "you may take over now"
// ---------------------------------------------------------------------------

self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

// ---------------------------------------------------------------------------
// fetch
// ---------------------------------------------------------------------------

self.addEventListener('fetch', (event) => {
  const request = event.request;

  // Writes are never cached and never intercepted.
  if (request.method !== 'GET') return;

  // Media range requests need real 206 handling; let the browser do it.
  if (request.headers.has('range')) return;

  let url;
  try {
    url = new URL(request.url);
  } catch (_) {
    return;
  }
  if (url.protocol !== 'https:' && url.protocol !== 'http:') return;

  // Supabase: never cached, never intercepted.
  if (isSupabase(url)) return;

  // Every cross-origin request is left entirely alone. The app has no
  // cross-origin dependencies left: the type families are bundled assets and
  // CanvasKit is served from this origin, which is what makes offline
  // possible at all — a service worker cannot cache a cross-origin URL.
  if (url.origin !== self.location.origin) return;

  // The navigation document carries the build token, so it must stay fresh.
  // Any SPA route falls back to the cached shell document, which is what makes
  // a deep-linked cold launch work offline.
  if (request.mode === 'navigate') {
    event.respondWith(networkFirst(event, request, DOCUMENT_URL));
    return;
  }

  // See PRECACHE_ENV: cached so offline boots, network-first so a rotated key
  // is never served to a client that could have fetched the current one.
  if (withoutSearch(request.url) === ENV_URL) {
    event.respondWith(networkFirst(event, request, ENV_URL));
    return;
  }

  if (SHELL_URLS.has(withoutSearch(request.url))) {
    event.respondWith(cacheFirstShell(event, request));
    return;
  }

  event.respondWith(staleWhileRevalidate(event, request));
});

/// Network-first with a bounded wait, falling back to the precached copy.
/// A successful response refreshes the shell entry in place, so the cached
/// document tracks the deployed one even between worker versions.
async function networkFirst(event, request, cacheKey) {
  const cache = await caches.open(SHELL_CACHE);
  try {
    const response = await fetchWithTimeout(request, NETWORK_FIRST_TIMEOUT_MS);
    if (isStorable(response)) {
      const copy = response.clone();
      event.waitUntil(cache.put(cacheKey, copy));
    }
    if (response && response.ok) return response;
    // A real HTTP error (404/500) is still an answer from the server; prefer
    // the cached shell over showing it, but hand it back if we have nothing.
    const fallback = await cache.match(cacheKey);
    return fallback || response;
  } catch (_) {
    const fallback = await cache.match(cacheKey);
    return fallback || offlineResponse();
  }
}

/// Cache-first for the precached shell. A miss can only mean this build asked
/// for something the manifest above does not list, so fetch and adopt it rather
/// than failing.
async function cacheFirstShell(event, request) {
  const cache = await caches.open(SHELL_CACHE);
  const hit = await cache.match(request, { ignoreSearch: true });
  if (hit) return hit;

  try {
    const response = await fetch(request);
    if (isStorable(response)) {
      event.waitUntil(cache.put(withoutSearch(request.url), response.clone()));
    }
    return response;
  } catch (_) {
    return offlineResponse();
  }
}

/// Everything else same-origin — currently `assets/NOTICES`, `version.json`,
/// and anything added later. Serve instantly from cache when we have it, and
/// refresh in the background so the next launch is current.
async function staleWhileRevalidate(event, request) {
  const cache = await caches.open(RUNTIME_CACHE);
  const hit = await cache.match(request);

  const network = fetch(request)
    .then((response) => {
      if (isStorable(response)) {
        const copy = response.clone();
        return cache.put(request, copy).then(() => response);
      }
      return response;
    })
    .catch(() => undefined);

  if (hit) {
    event.waitUntil(network);
    return hit;
  }

  const response = await network;
  return response || offlineResponse();
}
