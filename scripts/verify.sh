#!/usr/bin/env bash
#
# Full verification loop for Tadabbur.
#
# Run this after any change. It is the closest thing to a device that this
# repo can run on its own: every check here catches a class of failure that
# `flutter test` alone does not.
#
# Each check reports PASS, FAIL, or SKIP. SKIP is used only when a tool is
# genuinely absent (e.g. Xcode) — never to paper over a check that could
# have run. The script exits non-zero if anything FAILed.
#
# Usage:
#   ./scripts/verify.sh          # everything available on this machine
#   ./scripts/verify.sh --quick  # skip the release build (much faster)
#
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/app"
QUICK=0
[[ "${1:-}" == "--quick" ]] && QUICK=1

FAILED=0
declare -a RESULTS=()

pass() { RESULTS+=("PASS  $1"); }
fail() { RESULTS+=("FAIL  $1"); FAILED=1; }
skip() { RESULTS+=("SKIP  $1"); }

step() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

cd "$APP_DIR"

# .env is gitignored, so a fresh clone or a git worktree has none — and its
# absence fails the asset bundle rather than any test, which reads as an
# unrelated error. Supply the example so checks can run.
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "note: created app/.env from .env.example (placeholders, gitignored)"
fi

# ---------------------------------------------------------------------------
step "Static analysis"
if flutter analyze 2>&1 | tail -3 | grep -q "No issues found"; then
  pass "flutter analyze"
else
  flutter analyze 2>&1 | grep -E "error|warning" | head -20
  fail "flutter analyze"
fi

# ---------------------------------------------------------------------------
step "Tests"
TEST_OUT="$(flutter test 2>&1 | tail -3)"
if grep -q "All tests passed" <<<"$TEST_OUT"; then
  pass "flutter test ($(grep -oE '\+[0-9]+' <<<"$TEST_OUT" | tail -1 | tr -d '+') tests)"
else
  echo "$TEST_OUT"
  fail "flutter test"
fi

# ---------------------------------------------------------------------------
# Fonts are bundled rather than fetched, and a family-name typo does NOT
# throw — Flutter silently substitutes a system face. For Arabic that means
# Tashkeel stops being positioned correctly, which is invisible to every
# other check here. So verify the declared families match the code.
step "Font declarations match the code"
FONT_MISMATCH=0
for family in "Lora" "Work Sans" "Amiri Quran"; do
  if ! grep -q "family: $family" pubspec.yaml; then
    echo "  pubspec.yaml is missing 'family: $family'"
    FONT_MISMATCH=1
  fi
  if ! grep -q "'$family'" lib/core/theme/app_typography.dart; then
    echo "  app_typography.dart no longer references '$family'"
    FONT_MISMATCH=1
  fi
done
for ttf in $(grep -oE "assets/fonts/[A-Za-z-]+\.ttf" pubspec.yaml | sort -u); do
  [[ -f "$ttf" ]] || { echo "  declared but missing on disk: $ttf"; FONT_MISMATCH=1; }
done
[[ $FONT_MISMATCH -eq 0 ]] && pass "font families and files" || fail "font families and files"

# ---------------------------------------------------------------------------
# The app is shipped as a PWA, so iOS behaviour is governed by Info.plist and
# the web config rather than by anything Dart. These are the settings whose
# absence only shows up on a real handset.
step "iOS / display configuration"
IOS_ISSUES=0
plist_get() { python3 -c "
import plistlib,sys
d=plistlib.load(open('ios/Runner/Info.plist','rb'))
v=d.get('$1')
print('' if v is None else v)
" 2>/dev/null; }

[[ -n "$(plist_get NSLocationWhenInUseUsageDescription)" ]] \
  || { echo "  Info.plist: NSLocationWhenInUseUsageDescription missing — geolocator will crash the app on first permission request"; IOS_ISSUES=1; }

# A dark app with no explicit light status bar gets dark status-bar content
# on a near-black ground: an invisible clock, battery and signal.
grep -rq "SystemUiOverlayStyle" lib/ \
  || { echo "  no SystemUiOverlayStyle anywhere in lib/ — status bar icons will be dark on the dark ground"; IOS_ISSUES=1; }

grep -q "apple-mobile-web-app-capable" web/index.html \
  || { echo "  index.html: apple-mobile-web-app-capable missing — iOS ignores manifest.json display mode"; IOS_ISSUES=1; }

# The dark ground must be declared on the document too, or the page is white
# until CanvasKit paints — which on a cold home-screen launch reads as broken.
grep -q "0D1815" web/index.html && grep -q "0D1815" web/manifest.json \
  || { echo "  web theme colour is not the app's dark ground (#0D1815) in both index.html and manifest.json"; IOS_ISSUES=1; }

[[ $IOS_ISSUES -eq 0 ]] && pass "iOS / display configuration" || fail "iOS / display configuration"

# ---------------------------------------------------------------------------
step "Release web build"
if [[ $QUICK -eq 1 ]]; then
  skip "release build (--quick)"
else
  if flutter build web --release --no-web-resources-cdn >/dev/null 2>&1; then
    pass "flutter build web --release"

    # The flag is not a size optimisation — CanvasKit ships either way. What
    # it changes is whether the renderer is fetched from Google's CDN, which
    # both leaks every user's IP and makes offline impossible, since a
    # service worker cannot cache a cross-origin URL.
    if grep -q '"useLocalCanvasKit":true' build/web/flutter_bootstrap.js; then
      pass "CanvasKit served from this origin"
    else
      fail "CanvasKit would load from gstatic.com"
    fi

    # A single missing entry fails the service worker's install atomically,
    # so the app silently stops working offline while still claiming to.
    node -e "
      const fs=require('fs');
      const sw=fs.readFileSync('build/web/sw.js','utf8');
      const body=sw.match(/const SHELL_CORE = \[([\s\S]*?)\n\];/)[1];
      const list=body.split('\n').map(l=>l.trim())
        .filter(l=>l.startsWith(\"'\")).map(l=>l.match(/'([^']+)'/)[1]);
      const missing=list.filter(e=>!fs.existsSync('build/web/'+(e==='.'?'index.html':e)));
      if(missing.length){console.error('  missing from build: '+missing.join(', '));process.exit(1);}
      const fonts=list.filter(e=>/assets\/assets\/fonts\/.*\.ttf\$/.test(e));
      if(fonts.length<8){console.error('  only '+fonts.length+' bundled fonts precached; Arabic will fall back offline');process.exit(1);}
      console.log('  '+list.length+' precache entries, all present, '+fonts.length+' fonts');
    " && pass "service worker precache integrity" || fail "service worker precache integrity"

    node --check build/web/sw.js 2>/dev/null && pass "sw.js parses" || fail "sw.js parses"
    grep -q '{{' build/web/index.html && fail "unsubstituted {{placeholders}} in index.html" || pass "no template placeholders left"
  else
    fail "flutter build web --release"
  fi
fi

# ---------------------------------------------------------------------------
step "iOS build"
if xcodebuild -version >/dev/null 2>&1; then
  if flutter build ios --release --no-codesign >/dev/null 2>&1; then
    pass "flutter build ios --release"
  else
    fail "flutter build ios --release"
  fi
else
  skip "iOS build — Xcode not installed (only Command Line Tools)"
fi

# ---------------------------------------------------------------------------
printf '\n\033[1m── Results ──\033[0m\n'
for r in "${RESULTS[@]}"; do
  case "$r" in
    PASS*) printf '\033[32m%s\033[0m\n' "$r" ;;
    FAIL*) printf '\033[31m%s\033[0m\n' "$r" ;;
    *)     printf '\033[33m%s\033[0m\n' "$r" ;;
  esac
done

if [[ $FAILED -eq 1 ]]; then
  printf '\n\033[31mVerification failed.\033[0m\n'
  exit 1
fi
printf '\n\033[32mAll available checks passed.\033[0m\n'
