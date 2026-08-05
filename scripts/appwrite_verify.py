#!/usr/bin/env python3
"""Verify Stay Alive Appwrite backend provisioning for stay_alive_v1."""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

from appwrite_credentials import require_api_key, unauthorized_help

APPWRITE_ENDPOINT = os.environ.get(
    "APPWRITE_ENDPOINT", "https://nyc.cloud.appwrite.io/v1"
).rstrip("/")
APPWRITE_PROJECT_ID = os.environ.get("APPWRITE_PROJECT_ID", "6a53570100147968d1f6")
APPWRITE_API_KEY = os.environ.get("APPWRITE_API_KEY", "")
DATABASE_ID = os.environ.get("APPWRITE_DATABASE_ID", "stay_alive_v1")

REQUIRED_COLLECTIONS = (
    "users",
    "category_definitions",
    "daily_logs",
    "daily_log_items",
    "gamification_profiles",
    "gamification_events",
    "subscriptions",
    "analytics_events",
    "educational_content",
)

REQUIRED_DAILY_LOG_ATTRIBUTES = {
    "log_date",
    "completion_percentage",
    "total_completed",
    "total_target",
    "is_fully_completed",
}

REQUIRED_DAILY_LOG_ITEM_ATTRIBUTES = {
    "log_document_id",
    "category_id",
    "completed_count",
}


def main() -> int:
    require_api_key()

    try:
        request("GET", f"/databases/{DATABASE_ID}")
    except urllib.error.HTTPError as error:
        if error.code == 401:
            print(
                "Appwrite rejected the API key (401 Unauthorized)."
                + unauthorized_help(401),
                file=sys.stderr,
            )
            return 1
        print(f"Database {DATABASE_ID} not found ({error.code}).", file=sys.stderr)
        return 1

    collections = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections",
        query={"queries[]": 'limit(100)'},
    ).get("collections", [])
    collection_ids = {item.get("$id") for item in collections}
    missing_collections = [
        name for name in REQUIRED_COLLECTIONS if name not in collection_ids
    ]
    if missing_collections:
        print(f"Missing collections: {', '.join(missing_collections)}", file=sys.stderr)
        return 1

    daily_log_attrs = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/daily_logs/attributes",
    ).get("attributes", [])
    available = {
        attr.get("key")
        for attr in daily_log_attrs
        if attr.get("status") == "available"
    }
    missing_log_attrs = REQUIRED_DAILY_LOG_ATTRIBUTES - available
    if missing_log_attrs:
        print(
            f"daily_logs missing attributes: {', '.join(sorted(missing_log_attrs))}",
            file=sys.stderr,
        )
        return 1

    daily_log_item_attrs = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/daily_log_items/attributes",
    ).get("attributes", [])
    item_available = {
        attr.get("key")
        for attr in daily_log_item_attrs
        if attr.get("status") == "available"
    }
    missing_item_attrs = REQUIRED_DAILY_LOG_ITEM_ATTRIBUTES - item_available
    if missing_item_attrs:
        print(
            "daily_log_items missing attributes: "
            f"{', '.join(sorted(missing_item_attrs))}",
            file=sys.stderr,
        )
        return 1

    categories = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/category_definitions/documents",
        query={"queries[]": 'limit(1)'},
    ).get("total", 0)
    if categories < 1:
        print("category_definitions has no seed documents.", file=sys.stderr)
        return 1

    print(
        f"OK: project={APPWRITE_PROJECT_ID} database={DATABASE_ID} "
        f"collections={len(collection_ids)} categories={categories}"
    )
    return 0


def request(
    method: str,
    path: str,
    query: dict[str, str] | None = None,
) -> dict:
    url = f"{APPWRITE_ENDPOINT}{path}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    req = urllib.request.Request(
        url,
        method=method,
        headers={
            "Content-Type": "application/json",
            "X-Appwrite-Project": APPWRITE_PROJECT_ID,
            "X-Appwrite-Key": APPWRITE_API_KEY,
        },
    )
    with urllib.request.urlopen(req, timeout=30) as response:
        raw = response.read().decode("utf-8")
        return json.loads(raw) if raw else {}


if __name__ == "__main__":
    raise SystemExit(main())
