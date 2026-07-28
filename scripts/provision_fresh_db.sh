#!/usr/bin/env bash
set -euo pipefail

: "${APPWRITE_ENDPOINT:=https://sfo.cloud.appwrite.io/v1}"
: "${APPWRITE_PROJECT_ID:=69de16de001dfb5c1e5d}"
: "${APPWRITE_DATABASE_ID:=stay_alive_v1}"

if [[ -z "${APPWRITE_API_KEY:-}" ]]; then
  echo "Set APPWRITE_API_KEY before running." >&2
  exit 2
fi

case "${APPWRITE_API_KEY}" in
  *"<"* | *">"* | "<your-api-key>" | "your-api-key" | "<server-api-key>")
    echo "APPWRITE_API_KEY looks like a documentation placeholder." >&2
    echo 'Use a real key from Appwrite Console → Settings → API Keys (no angle brackets).' >&2
    exit 2
    ;;
esac

export APPWRITE_ENDPOINT APPWRITE_PROJECT_ID APPWRITE_DATABASE_ID

echo "Provisioning database ${APPWRITE_DATABASE_ID} in project ${APPWRITE_PROJECT_ID}..."
python3 "$(dirname "$0")/appwrite_provision.py"
python3 "$(dirname "$0")/appwrite_auth_setup.py"
echo "Done."
