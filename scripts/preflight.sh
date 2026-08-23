#!/usr/bin/env bash
# Go-live preflight: fails if any store-submission blocker is still a placeholder.
#
# Every check here maps to something that ships broken rather than failing
# loudly — a 404 privacy URL, a debug-signed bundle, an unset crash DSN. Run
# before ./scripts/build-prod.sh, and in CI before any release build.
#
# Usage:
#   ./scripts/preflight.sh          # all checks
#   ./scripts/preflight.sh --ci     # skip checks needing local secret files

set -uo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

CI_MODE=0
[[ "${1:-}" == "--ci" ]] && CI_MODE=1

FAILED=0
PASSED=0

pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; PASSED=$((PASSED + 1)); }
fail() { printf '  \033[31m✗\033[0m %s\n     \033[2m%s\033[0m\n' "$1" "$2"; FAILED=$((FAILED + 1)); }
skip() { printf '  \033[2m-\033[0m %s \033[2m(skipped: %s)\033[0m\n' "$1" "$2"; }

echo
echo "Stay Alive — release preflight"
echo

# --- Legal URLs (GAU-315) -----------------------------------------------
# Both stores reject a Privacy Policy URL that does not resolve.
if grep -q 'stay-alive.app' lib/core/constants/legal_urls.dart; then
  fail "Legal URLs are still placeholders" \
       "lib/core/constants/legal_urls.dart points at stay-alive.app, which 404s. Host docs/legal/*.md and replace."
else
  pass "Legal URLs point at a real host"
fi

# --- Legal document content (GAU-315) -----------------------------------
# Hosting is pointless while the text still has unfilled placeholders — a
# published policy reading "Оператор: {{COMPANY}}" is worse than none.
if grep -rq '{{' docs/legal/; then
  UNFILLED=$(grep -rhoE '\{\{[A-Z_]+\}\}' docs/legal/ | sort -u | tr '\n' ' ')
  fail "Legal documents still contain placeholders" \
       "docs/legal/ has unfilled: ${UNFILLED}— and both drafts are marked as needing legal review."
else
  pass "Legal documents have no unfilled placeholders"
fi

# --- Android signing (GAU-305) ------------------------------------------
# Without key.properties the release build silently falls back to the debug
# keystore, producing an artifact the Play Console will reject.
if [[ "${CI_MODE}" -eq 1 ]]; then
  skip "Android release keystore" "--ci, keystore is injected by the runner"
elif [[ ! -f android/key.properties ]]; then
  fail "Android release keystore missing" \
       "android/key.properties absent — release builds fall back to debug signing. Copy android/key.properties.example."
elif grep -q 'CHANGE_ME' android/key.properties; then
  fail "Android keystore has placeholder passwords" \
       "android/key.properties still contains CHANGE_ME."
else
  pass "Android release keystore configured"
fi

# --- Release secrets (GAU-309, GAU-310) ---------------------------------
ENV_FILE=scripts/release.env
if [[ "${CI_MODE}" -eq 1 ]]; then
  skip "Release secrets file" "--ci, values come from --dart-define"
elif [[ ! -f "${ENV_FILE}" ]]; then
  fail "Release secrets missing" \
       "${ENV_FILE} absent. Copy scripts/release.env.example and fill it in."
else
  if grep -q 'REPLACE_ME' "${ENV_FILE}"; then
    fail "RevenueCat keys are placeholders" \
         "${ENV_FILE} still contains REPLACE_ME — purchases will fail at runtime."
  else
    pass "RevenueCat keys set"
  fi

  if grep -qE '^SENTRY_DSN=.+' "${ENV_FILE}"; then
    pass "Sentry DSN set"
  else
    fail "Sentry DSN empty" \
         "Crash reporting is inert without SENTRY_DSN (bootstrap.dart skips init)."
  fi

  if grep -qE '^SUPABASE_URL=https://.+' "${ENV_FILE}"; then
    pass "Production Supabase URL set"
  else
    fail "Production Supabase URL missing" \
         "SUPABASE_URL in scripts/release.env must point at the hosted project (https://<ref>.supabase.co). Local/empty values make prod bootstrap throw."
  fi

  if grep -qE '^SUPABASE_ANON_KEY=.+' "${ENV_FILE}"; then
    pass "Production Supabase anon key set"
  else
    fail "Production Supabase anon key missing" \
         "Set SUPABASE_ANON_KEY (publishable key) in scripts/release.env."
  fi
fi

# --- Supabase OAuth deep link ---------------------------------------------
# signInWithOAuth returns through stayalive://login-callback; both platforms
# must register the scheme or Google/Apple sign-in never completes.
if grep -q 'android:scheme="stayalive"' android/app/src/main/AndroidManifest.xml \
   && grep -q '<string>stayalive</string>' ios/Runner/Info.plist; then
  pass "OAuth deep-link scheme registered on both platforms"
else
  fail "OAuth deep-link scheme missing" \
       "Register the stayalive:// scheme in AndroidManifest.xml and ios/Runner/Info.plist."
fi

# --- Network permission (GAU-378) ---------------------------------------
# Flutter injects INTERNET into the debug and profile manifests only. If it is
# missing from main/, debug builds work and the release build has no network.
if grep -q 'android.permission.INTERNET' android/app/src/main/AndroidManifest.xml; then
  pass "INTERNET permission declared for release builds"
else
  fail "Release builds have no INTERNET permission" \
       "android/app/src/main/AndroidManifest.xml lacks uses-permission INTERNET — Supabase, RevenueCat and Sentry all fail in release while debug works."
fi

# --- Date locale ---------------------------------------------------------
# The UI is Russian; an uninitialised intl locale renders English month names.
if grep -q "initializeDateFormatting" lib/bootstrap.dart; then
  pass "Date formatting locale initialised"
else
  fail "Date locale not initialised" \
       "lib/bootstrap.dart does not call initializeDateFormatting — DateFormat falls back to en_US inside the Russian UI."
fi

# --- Splash art (GAU-313) -----------------------------------------------
if grep -q 'Placeholder logo' pubspec.yaml; then
  fail "Splash logo is still the placeholder" \
       "pubspec.yaml flags assets/splash/logo.png as placeholder art. Swap it and re-run flutter_native_splash:create."
else
  pass "Splash logo replaced"
fi

# --- Static checks -------------------------------------------------------
if flutter analyze --no-pub >/dev/null 2>&1; then
  pass "flutter analyze clean"
else
  fail "flutter analyze reported issues" "Run: flutter analyze"
fi

if flutter test --no-pub >/dev/null 2>&1; then
  pass "flutter test suite passing"
else
  fail "flutter test suite failing" "Run: flutter test"
fi

echo
if [[ "${FAILED}" -gt 0 ]]; then
  printf '\033[31m%d blocker(s)\033[0m, %d passed — not ready to ship.\n\n' "${FAILED}" "${PASSED}"
  exit 1
fi
printf '\033[32mAll %d checks passed\033[0m — clear for release build.\n\n' "${PASSED}"
