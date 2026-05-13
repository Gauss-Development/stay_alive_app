#!/usr/bin/env bash
# Production release build wrapper.
#
# Reads secrets from scripts/release.env (gitignored) and feeds them to
# Flutter via --dart-define-from-file. EnvConfig prefers fromEnvironment
# over .env, so these values override anything in assets/env/app.prod.env.
#
# Usage:
#   ./scripts/build-prod.sh apk        # signed APK
#   ./scripts/build-prod.sh appbundle  # AAB for Play Store upload
#   ./scripts/build-prod.sh ipa        # iOS archive

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/release.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "error: ${ENV_FILE} not found." >&2
  echo "       Copy scripts/release.env.example to scripts/release.env and fill in real values." >&2
  exit 1
fi

TARGET="${1:-apk}"

case "${TARGET}" in
  apk|appbundle|ipa)
    ;;
  *)
    echo "error: unknown target '${TARGET}'. Expected apk | appbundle | ipa." >&2
    exit 1
    ;;
esac

cd "${SCRIPT_DIR}/.."

flutter build "${TARGET}" \
  --release \
  --flavor prod \
  -t lib/main_prod.dart \
  --dart-define-from-file="${ENV_FILE}"
