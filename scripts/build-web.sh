#!/usr/bin/env bash
#
# Production web build for Tadabbur.
#
# Always build releases with this script. A plain `flutter build web --release`
# produces a bundle that fetches ~2.8 MB of CanvasKit from
# https://www.gstatic.com/flutter-canvaskit/ on every cold start — putting a
# Google CDN on the critical path and disclosing every user's IP address to
# Google. See README.md ("Production web build") for the full rationale.
#
# Usage:
#   ./scripts/build-web.sh          # build into app/build/web
#   ./scripts/build-web.sh --wasm   # extra flags are passed through to Flutter
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/app"
ENV_FILE="$APP_DIR/.env"

# ---------------------------------------------------------------------------
# Preflight: .env must exist and be filled in.
#
# `.env` is declared as a bundled asset in app/pubspec.yaml, so its contents are
# compiled INTO the output. It is read at build time, not at runtime — the
# deployed site has no way to pick up credentials later, and changing them means
# rebuilding. A missing .env fails the Flutter build with an opaque asset error,
# so check it here and say something useful instead.
# ---------------------------------------------------------------------------
if [[ ! -f "$ENV_FILE" ]]; then
  echo "error: $ENV_FILE not found." >&2
  echo "       cp app/.env.example app/.env and fill in your Supabase values." >&2
  exit 1
fi

for key in SUPABASE_URL SUPABASE_PUBLISHABLE_KEY; do
  if ! grep -qE "^${key}=.+" "$ENV_FILE"; then
    echo "error: $key is missing or empty in app/.env" >&2
    exit 1
  fi
done

# Refuse to ship the example placeholders.
if grep -qE '^SUPABASE_URL=https://your-project-ref\.supabase\.co' "$ENV_FILE" \
  || grep -qE '^SUPABASE_PUBLISHABLE_KEY=your-publishable-key-here' "$ENV_FILE"; then
  echo "error: app/.env still contains the .env.example placeholder values." >&2
  echo "       Fill in the real Supabase URL and publishable key before building." >&2
  exit 1
fi

cd "$APP_DIR"

echo "==> flutter pub get"
flutter pub get

# ---------------------------------------------------------------------------
# The actual build.
#
# --no-web-resources-cdn sets "useLocalCanvasKit": true in the generated
# flutter_bootstrap.js. The CanvasKit files are copied into build/web/canvaskit/
# either way; this flag is what makes the bootstrap load them from that local
# copy instead of from gstatic.com.
# ---------------------------------------------------------------------------
echo "==> flutter build web --release --no-web-resources-cdn ${*:-}"
flutter build web --release --no-web-resources-cdn "$@"

# ---------------------------------------------------------------------------
# Postflight: prove the CDN was actually cut out.
#
# This is the whole point of the script, so verify it rather than trusting that
# the flag kept working across Flutter upgrades.
# ---------------------------------------------------------------------------
BOOTSTRAP="build/web/flutter_bootstrap.js"

if ! grep -q '"useLocalCanvasKit":true' "$BOOTSTRAP"; then
  echo "error: useLocalCanvasKit is not set in $BOOTSTRAP." >&2
  echo "       This build would fetch CanvasKit from gstatic.com. Not shippable." >&2
  exit 1
fi

if [[ ! -f "build/web/canvaskit/canvaskit.wasm" ]]; then
  echo "error: build/web/canvaskit/canvaskit.wasm is missing." >&2
  echo "       The bootstrap expects a local copy; the app would fail to render." >&2
  exit 1
fi

VERSION="$(sed -E 's/.*"version":"([^"]*)".*/\1/' build/web/version.json)"
BUILD_NUMBER="$(sed -E 's/.*"build_number":"([^"]*)".*/\1/' build/web/version.json)"

echo
echo "Build OK — CanvasKit is served locally (no gstatic.com on the critical path)."
echo "  output:  app/build/web"
echo "  version: ${VERSION}+${BUILD_NUMBER}  (from app/pubspec.yaml, served at /version.json)"
echo
echo "Deploy the CONTENTS of app/build/web. Serve it with compression enabled —"
echo "canvaskit.wasm is 7.2 MB raw but ~2.8 MB gzipped."
