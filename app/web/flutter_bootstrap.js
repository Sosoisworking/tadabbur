// Custom Flutter bootstrap. `flutter build web` uses this file as a template
// when it exists and expands the two placeholders near the bottom
// (flutter_tools/lib/src/build_system/targets/web.dart), otherwise it generates
// the default one. It exists here for two reasons, both required for the app to
// actually work offline.
//
// CAUTION: substitution is a blind string replace over the whole file, comments
// included. Never write a placeholder name in double braces anywhere in here
// except where you actually want it expanded — doing so in a `//` comment
// splices the entire minified flutter.js into that line, and because that file
// contains newlines the tail of it escapes the comment and becomes stray
// top-level code. Refer to the placeholders in prose instead.
//
// 1. NO serviceWorkerSettings.
//    The default bootstrap passes one, which makes flutter.js call
//    `navigator.serviceWorker.getRegistration()` and — if it finds any worker in
//    scope — register `flutter_service_worker.js` over it. That file is now a
//    self-unregistering stub (Flutter's SW support is deprecated,
//    flutter#156910), so the default path would replace web/sw.js with the stub
//    and then tear the registration down on every load. Omitting the settings
//    means flutter.js never touches the service worker at all; index.html
//    registers sw.js itself.
//
// 2. canvasKitBaseUrl / canvasKitVariant.
//    By default a release build loads CanvasKit from
//    https://www.gstatic.com/flutter-canvaskit/<engine-revision>/ — a CDN. That
//    alone makes an offline launch impossible no matter what the service worker
//    precaches, because the renderer never comes from this origin. Pointing
//    canvasKitBaseUrl at the local `canvaskit/` directory (the same thing
//    `--no-web-resources-cdn` does, but without depending on a build flag) makes
//    the renderer a same-origin asset the worker can cache.
//
//    Pinning `canvasKitVariant: 'full'` on top of that is what makes the
//    precache *provable*. Left on 'auto', flutter.js picks
//    canvaskit/chromium/canvaskit.{js,wasm} on Chromium and
//    canvaskit/canvaskit.{js,wasm} elsewhere, based on runtime feature probes —
//    so a worker would have to guess which pair to precache, and a wrong guess
//    is a white screen on the first offline launch. 'full' is the variant that
//    works in every browser, so there is exactly one pair to precache and no
//    guess to get wrong. The cost is that Chromium users download the 7.2MB
//    build instead of the 5.8MB one, once per deploy, and then never again
//    because sw.js serves it from cache.

{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: 'canvaskit/',
    canvasKitVariant: 'full',
  },
});
