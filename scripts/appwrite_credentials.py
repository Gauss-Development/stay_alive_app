"""Shared Appwrite credential validation for provisioning scripts."""

from __future__ import annotations

import os
import sys

PLACEHOLDER_API_KEYS = frozenset(
    {
        "<your-api-key>",
        "<api-key>",
        "<server-api-key>",
        "your-api-key",
        "your_api_key",
        "changeme",
        "replace-me",
    }
)

REQUIRED_PROVISION_SCOPES = (
    "databases.read",
    "databases.write",
    "collections.read",
    "collections.write",
    "attributes.read",
    "attributes.write",
    "indexes.read",
    "indexes.write",
    "documents.read",
    "documents.write",
    "buckets.read",
    "buckets.write",
)


def load_api_key() -> str:
    return os.environ.get("APPWRITE_API_KEY", "").strip()


def validate_api_key(api_key: str) -> str | None:
    """Return an error message when the key is missing or looks like a placeholder."""
    if not api_key:
        return "APPWRITE_API_KEY is not set."
    lowered = api_key.lower()
    if lowered in PLACEHOLDER_API_KEYS or "<" in api_key or ">" in api_key:
        return (
            "APPWRITE_API_KEY looks like a documentation placeholder. "
            "Create a project API key in Appwrite Console and paste the real value."
        )
    if len(api_key) < 20:
        return "APPWRITE_API_KEY is too short to be a valid Appwrite project API key."
    return None


def unauthorized_help(status: int) -> str:
    if status != 401:
        return ""
    return (
        "\n401 Unauthorized — common causes:\n"
        "  1. You exported the docs placeholder instead of a real key "
        '(do not use "<your-api-key>").\n'
        "  2. The key belongs to a different Appwrite project.\n"
        "  3. The key is missing scopes. For provisioning, enable at least:\n"
        f"     {', '.join(REQUIRED_PROVISION_SCOPES)}\n"
        "  4. For auth setup, also enable projects.write.\n"
        "\nCreate a key: Appwrite Console → Project 69de16de001dfb5c1e5d "
        "→ Settings → API Keys → Create API Key."
    )


def require_api_key() -> str:
    api_key = load_api_key()
    error = validate_api_key(api_key)
    if error:
        print(error, file=sys.stderr)
        print(
            "\nExample:\n"
            '  export APPWRITE_API_KEY="standard_abc123..."  # no angle brackets\n'
            "  ./scripts/provision_fresh_db.sh",
            file=sys.stderr,
        )
        raise SystemExit(2)
    return api_key
