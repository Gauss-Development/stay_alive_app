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

  if grep -qE '^APPWRITE_DELETE_USER_FUNCTION_ID=.+' "${ENV_FILE}"; then
    pass "Account-deletion function id set"
  else
    fail "Account-deletion function id empty" \
         "Apple requires server-side account deletion. Deploy functions/delete_user and set the id."
  fi
fi

# --- Appwrite environment separation ------------------------------------
# docs/architecture_overview.md requires separate dev and prod projects; the
# OAuth callback scheme is the visible tell when they have been left equal.
DEV_SCHEME=$(grep -A 8 'create("dev")' android/app/build.gradle.kts | grep -o 'appwrite-callback-[a-z0-9]*' | head -1)
PROD_SCHEME=$(grep -A 8 'create("prod")' android/app/build.gradle.kts | grep -o 'appwrite-callback-[a-z0-9]*' | head -1)
if [[ -n "${PROD_SCHEME}" && "${DEV_SCHEME}" == "${PROD_SCHEME}" ]]; then
  fail "dev and prod share one Appwrite project" \
       "Both flavors use ${PROD_SCHEME}. Point prod at its own project and update AndroidManifest + Info.plist."
else
  pass "dev and prod use separate Appwrite projects"
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
