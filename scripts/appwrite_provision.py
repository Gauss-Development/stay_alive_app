#!/usr/bin/env python3
"""Idempotently provision the Stay Alive Appwrite backend.

The script intentionally uses only the Python standard library so it can run in
minimal CI/agent environments where the Appwrite CLI is not installed.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Any


APPWRITE_ENDPOINT = os.environ.get("APPWRITE_ENDPOINT", "https://sfo.cloud.appwrite.io/v1").rstrip("/")
APPWRITE_PROJECT_ID = os.environ.get("APPWRITE_PROJECT_ID", "69de16de001dfb5c1e5d")
APPWRITE_API_KEY = os.environ.get("APPWRITE_API_KEY", "")

DATABASE_ID = os.environ.get("APPWRITE_DATABASE_ID", "daily_dozen_db")

COLLECTION_IDS = {
    "users": os.environ.get("APPWRITE_USERS_COLLECTION_ID", "users"),
    "category_definitions": os.environ.get(
        "APPWRITE_CATEGORY_DEFINITIONS_COLLECTION_ID",
        "category_definitions",
    ),
    "daily_logs": os.environ.get("APPWRITE_DAILY_LOGS_COLLECTION_ID", "daily_logs"),
    "daily_log_items": os.environ.get(
        "APPWRITE_DAILY_LOG_ITEMS_COLLECTION_ID",
        "daily_log_items",
    ),
    "subscriptions": os.environ.get("APPWRITE_SUBSCRIPTIONS_COLLECTION_ID", "subscriptions"),
    "analytics_events": os.environ.get(
        "APPWRITE_ANALYTICS_EVENTS_COLLECTION_ID",
        "analytics_events",
    ),
    "educational_content": os.environ.get(
        "APPWRITE_EDUCATIONAL_CONTENT_COLLECTION_ID",
        "educational_content",
    ),
    "gamification_profiles": os.environ.get(
        "APPWRITE_GAMIFICATION_PROFILES_COLLECTION_ID",
        "gamification_profiles",
    ),
    "gamification_events": os.environ.get(
        "APPWRITE_GAMIFICATION_EVENTS_COLLECTION_ID",
        "gamification_events",
    ),
}

BUCKET_IDS = {
    "avatars": os.environ.get("APPWRITE_AVATARS_BUCKET_ID", "avatars"),
    "user_uploads": os.environ.get("APPWRITE_USER_UPLOADS_BUCKET_ID", "user_uploads"),
    "content_assets": os.environ.get("APPWRITE_CONTENT_ASSETS_BUCKET_ID", "content_assets"),
}

ROLE_ANY = 'read("any")'
ROLE_USERS_CREATE = 'create("users")'


class AppwriteRequestError(RuntimeError):
    def __init__(self, status: int, payload: dict[str, Any] | str) -> None:
        self.status = status
        self.payload = payload
        super().__init__(f"Appwrite request failed with {status}: {payload}")


@dataclass(frozen=True)
class AttributeSpec:
    collection: str
    kind: str
    key: str
    required: bool = False
    size: int | None = None
    default: Any = None
    array: bool = False


@dataclass(frozen=True)
class IndexSpec:
    collection: str
    key: str
    kind: str
    attributes: tuple[str, ...]
    orders: tuple[str, ...] | None = None


DEFAULT_CATEGORIES = [
    {
        "$id": "beans",
        "category_id": "beans",
        "title": "Beans / Legumes",
        "description": "Track servings of beans and legumes",
        "target_count": 3,
        "display_order": 1,
        "icon_key": "beans",
        "is_active": True,
    },
    {
        "$id": "berries",
        "category_id": "berries",
        "title": "Berries",
        "description": "Track servings of berries",
        "target_count": 1,
        "display_order": 2,
        "icon_key": "berries",
        "is_active": True,
    },
    {
        "$id": "fruits",
        "category_id": "fruits",
        "title": "Fruits",
        "description": "Track fruit servings",
        "target_count": 3,
        "display_order": 3,
        "icon_key": "fruits",
        "is_active": True,
    },
    {
        "$id": "cruciferous_vegetables",
        "category_id": "cruciferous_vegetables",
        "title": "Cruciferous Vegetables",
        "description": "Track cruciferous veggie servings",
        "target_count": 1,
        "display_order": 4,
        "icon_key": "cruciferous_vegetables",
        "is_active": True,
    },
    {
        "$id": "greens",
        "category_id": "greens",
        "title": "Greens",
        "description": "Track leafy greens servings",
        "target_count": 2,
        "display_order": 5,
        "icon_key": "greens",
        "is_active": True,
    },
    {
        "$id": "other_vegetables",
        "category_id": "other_vegetables",
        "title": "Other Vegetables",
        "description": "Track other vegetable servings",
        "target_count": 2,
        "display_order": 6,
        "icon_key": "other_vegetables",
        "is_active": True,
    },
    {
        "$id": "flaxseeds",
        "category_id": "flaxseeds",
        "title": "Flaxseeds",
        "description": "Track flaxseed servings",
        "target_count": 1,
        "display_order": 7,
        "icon_key": "flaxseeds",
        "is_active": True,
    },
    {
        "$id": "nuts",
        "category_id": "nuts",
        "title": "Nuts",
        "description": "Track nuts servings",
        "target_count": 1,
        "display_order": 8,
        "icon_key": "nuts",
        "is_active": True,
    },
    {
        "$id": "spices",
        "category_id": "spices",
        "title": "Spices",
        "description": "Track turmeric/spice servings",
        "target_count": 1,
        "display_order": 9,
        "icon_key": "spices",
        "is_active": True,
    },
    {
        "$id": "whole_grains",
        "category_id": "whole_grains",
        "title": "Whole Grains",
        "description": "Track whole grain servings",
        "target_count": 3,
        "display_order": 10,
        "icon_key": "whole_grains",
        "is_active": True,
    },
    {
        "$id": "beverages",
        "category_id": "beverages",
        "title": "Beverages",
        "description": "Track healthy beverage goals",
        "target_count": 5,
        "display_order": 11,
        "icon_key": "beverages",
        "is_active": True,
    },
    {
        "$id": "exercise",
        "category_id": "exercise",
        "title": "Exercise",
        "description": "Track exercise sessions",
        "target_count": 1,
        "display_order": 12,
        "icon_key": "exercise",
        "is_active": True,
    },
]


def main() -> int:
    if not APPWRITE_PROJECT_ID or not APPWRITE_API_KEY:
        print(
            "Missing required Appwrite credentials. Set APPWRITE_PROJECT_ID and APPWRITE_API_KEY.",
            file=sys.stderr,
        )
        return 2

    create_database()
    create_collections()
    create_attributes()
    wait_for_attributes()
    create_indexes()
    create_buckets()
    seed_categories()
    print("Appwrite provisioning complete.")
    return 0


def request(
    method: str,
    path: str,
    payload: dict[str, Any] | None = None,
    query: dict[str, str] | None = None,
) -> dict[str, Any]:
    url = f"{APPWRITE_ENDPOINT}{path}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method=method,
        headers={
            "Content-Type": "application/json",
            "X-Appwrite-Project": APPWRITE_PROJECT_ID,
            "X-Appwrite-Key": APPWRITE_API_KEY,
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            data = response.read().decode("utf-8")
            return json.loads(data) if data else {}
    except urllib.error.HTTPError as error:
        raw = error.read().decode("utf-8")
        try:
            payload_data: dict[str, Any] | str = json.loads(raw)
        except json.JSONDecodeError:
            payload_data = raw
        raise AppwriteRequestError(error.code, payload_data) from error


def create_database() -> None:
    create_or_skip(
        "database",
        DATABASE_ID,
        lambda: request(
            "POST",
            "/databases",
            {"databaseId": DATABASE_ID, "name": "Daily Dozen DB", "enabled": True},
        ),
    )


def create_collections() -> None:
    specs = [
        ("users", "Users", True, [ROLE_USERS_CREATE]),
        ("category_definitions", "Category Definitions", False, [ROLE_ANY]),
        ("daily_logs", "Daily Logs", True, [ROLE_USERS_CREATE]),
        ("daily_log_items", "Daily Log Items", True, [ROLE_USERS_CREATE]),
        ("gamification_profiles", "Gamification Profiles", True, [ROLE_USERS_CREATE]),
        ("gamification_events", "Gamification Events", True, [ROLE_USERS_CREATE]),
        ("subscriptions", "Subscriptions", True, []),
        ("analytics_events", "Analytics Events", True, [ROLE_USERS_CREATE]),
        ("educational_content", "Educational Content", False, [ROLE_ANY]),
    ]
    for key, name, document_security, permissions in specs:
        collection_id = COLLECTION_IDS[key]
        create_or_skip(
            "collection",
            collection_id,
            lambda collection_id=collection_id, name=name, document_security=document_security, permissions=permissions: request(
                "POST",
                f"/databases/{DATABASE_ID}/collections",
                {
                    "collectionId": collection_id,
                    "name": name,
                    "permissions": permissions,
                    "documentSecurity": document_security,
                    "enabled": True,
                },
            ),
        )


def create_attributes() -> None:
    for spec in attribute_specs():
        create_or_skip(
            f"{spec.collection} attribute",
            spec.key,
            lambda spec=spec: request(
                "POST",
                f"/databases/{DATABASE_ID}/collections/{COLLECTION_IDS[spec.collection]}/attributes/{spec.kind}",
                attribute_payload(spec),
            ),
        )


def attribute_payload(spec: AttributeSpec) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "key": spec.key,
        "required": spec.required,
        "array": spec.array,
    }
    if spec.size is not None:
        payload["size"] = spec.size
    if spec.default is not None:
        payload["default"] = spec.default
    return payload


def wait_for_attributes() -> None:
    for collection_key in COLLECTION_IDS:
        collection_id = COLLECTION_IDS[collection_key]
        wanted = {spec.key for spec in attribute_specs() if spec.collection == collection_key}
        if not wanted:
            continue
        for _ in range(30):
            response = request(
                "GET",
                f"/databases/{DATABASE_ID}/collections/{collection_id}/attributes",
            )
            attributes = response.get("attributes", [])
            available = {
                attr.get("key")
                for attr in attributes
                if attr.get("status") in ("available", "failed")
            }
            if wanted.issubset(available):
                break
            time.sleep(1)
        else:
            print(f"Timed out waiting for attributes in {collection_id}; continuing to indexes.")


def create_indexes() -> None:
    for spec in index_specs():
        payload: dict[str, Any] = {
            "key": spec.key,
            "type": spec.kind,
            "attributes": list(spec.attributes),
        }
        if spec.orders is not None:
            payload["orders"] = list(spec.orders)
        create_or_skip(
            f"{spec.collection} index",
            spec.key,
            lambda spec=spec, payload=payload: request(
                "POST",
                f"/databases/{DATABASE_ID}/collections/{COLLECTION_IDS[spec.collection]}/indexes",
                payload,
            ),
        )


def create_buckets() -> None:
    specs = [
        ("avatars", "Avatars", True, []),
        ("user_uploads", "User Uploads", True, []),
        ("content_assets", "Content Assets", False, [ROLE_ANY]),
    ]
    for key, name, file_security, permissions in specs:
        bucket_id = BUCKET_IDS[key]
        create_or_skip(
            "bucket",
            bucket_id,
            lambda bucket_id=bucket_id, name=name, file_security=file_security, permissions=permissions: request(
                "POST",
                "/storage/buckets",
                {
                    "bucketId": bucket_id,
                    "name": name,
                    "permissions": permissions,
                    "fileSecurity": file_security,
                    "enabled": True,
                    "maximumFileSize": 10_000_000,
                    "allowedFileExtensions": ["jpg", "jpeg", "png", "webp", "heic", "pdf"],
                },
            ),
        )


def seed_categories() -> None:
    collection_id = COLLECTION_IDS["category_definitions"]
    for category in DEFAULT_CATEGORIES:
        document_id = category["$id"]
        data = dict(category)
        data.pop("$id")
        now = iso_now()
        data["created_at"] = now
        data["updated_at"] = now
        create_or_skip(
            "category document",
            document_id,
            lambda document_id=document_id, data=data: request(
                "POST",
                f"/databases/{DATABASE_ID}/collections/{collection_id}/documents",
                {
                    "documentId": document_id,
                    "data": data,
                    "permissions": [f'read("any")'],
                },
            ),
        )


def create_or_skip(label: str, identifier: str, callback: Any) -> None:
    try:
        callback()
        print(f"created {label}: {identifier}")
    except AppwriteRequestError as error:
        if error.status == 409:
            print(f"skipped existing {label}: {identifier}")
            return
        raise


def attribute_specs() -> list[AttributeSpec]:
    s = AttributeSpec
    return [
        s("users", "string", "user_id", True, 64),
        s("users", "email", "email", True),
        s("users", "string", "display_name", True, 128),
        s("users", "url", "avatar_url", False),
        s("users", "boolean", "onboarding_completed", False, default=False),
        s("users", "string", "units_preference", False, 32, default="metric"),
        s("users", "string", "locale", False, 16, default="en"),
        s("users", "integer", "age"),
        s("users", "string", "gender", False, 32),
        s("users", "string", "preferred_diet", False, 64),
        s("users", "integer", "height_cm"),
        s("users", "float", "weight_kg"),
        s("users", "datetime", "created_at"),
        s("users", "datetime", "updated_at"),
        s("category_definitions", "string", "category_id", True, 64),
        s("category_definitions", "string", "title", True, 128),
        s("category_definitions", "string", "description", True, 512),
        s("category_definitions", "string", "icon_key", True, 64),
        s("category_definitions", "integer", "target_count", True),
        s("category_definitions", "integer", "display_order", True),
        s("category_definitions", "boolean", "is_active", False, default=True),
        s("category_definitions", "datetime", "created_at"),
        s("category_definitions", "datetime", "updated_at"),
        s("daily_logs", "string", "log_id", True, 96),
        s("daily_logs", "string", "user_id", True, 64),
        s("daily_logs", "string", "log_date", True, 16),
        s("daily_logs", "float", "completion_percentage", False, default=0),
        s("daily_logs", "integer", "total_completed", False, default=0),
        s("daily_logs", "integer", "total_target", False, default=0),
        s("daily_logs", "boolean", "is_fully_completed", False, default=False),
        s("daily_logs", "datetime", "created_at"),
        s("daily_logs", "datetime", "updated_at"),
        s("daily_log_items", "string", "item_id", True, 128),
        s("daily_log_items", "string", "log_id", True, 96),
        s("daily_log_items", "string", "user_id", True, 64),
        s("daily_log_items", "string", "category_id", True, 64),
        s("daily_log_items", "integer", "completed_count", False, default=0),
        s("daily_log_items", "integer", "target_count", False, default=0),
        s("daily_log_items", "datetime", "created_at"),
        s("daily_log_items", "datetime", "updated_at"),
        s("gamification_profiles", "string", "user_id", True, 64),
        s("gamification_profiles", "integer", "xp", False, default=0),
        s("gamification_profiles", "integer", "level", False, default=1),
        s("gamification_profiles", "integer", "current_streak", False, default=0),
        s("gamification_profiles", "integer", "best_streak", False, default=0),
        s("gamification_profiles", "integer", "completed_days", False, default=0),
        s("gamification_profiles", "string", "last_completed_date", False, 16),
        s("gamification_profiles", "string", "badges", False, 64, array=True),
        s("gamification_profiles", "integer", "activity_streak", False, default=0),
        s("gamification_profiles", "integer", "total_categories_completed", False, default=0),
        s("gamification_profiles", "integer", "streak_freezes_remaining", False, default=0),
        s("gamification_profiles", "string", "streak_freezes_used", False, 16, array=True),
        s("gamification_profiles", "string", "completed_dates_json", False, 16, array=True),
        s("gamification_profiles", "string", "early_log_dates_json", False, 16, array=True),
        s("gamification_profiles", "datetime", "created_at"),
        s("gamification_profiles", "datetime", "updated_at"),
        s("gamification_events", "string", "event_id", True, 128),
        s("gamification_events", "string", "user_id", True, 64),
        s("gamification_events", "string", "event_type", True, 64),
        s("gamification_events", "integer", "xp_delta", False, default=0),
        s("gamification_events", "string", "log_date", False, 16),
        s("gamification_events", "string", "metadata_json", False, 4096),
        s("gamification_events", "datetime", "created_at"),
        s("subscriptions", "string", "subscription_id", True, 96),
        s("subscriptions", "string", "user_id", True, 64),
        s("subscriptions", "string", "plan", True, 64),
        s("subscriptions", "string", "status", True, 64),
        s("subscriptions", "datetime", "expires_at"),
        s("subscriptions", "string", "provider", True, 64),
        s("subscriptions", "datetime", "created_at"),
        s("subscriptions", "datetime", "updated_at"),
        s("analytics_events", "string", "event_id", True, 128),
        s("analytics_events", "string", "user_id", False, 64),
        s("analytics_events", "string", "event_name", True, 128),
        s("analytics_events", "string", "screen_name", False, 128),
        s("analytics_events", "string", "metadata_json", False, 4096),
        s("analytics_events", "datetime", "created_at"),
        s("educational_content", "string", "content_id", True, 96),
        s("educational_content", "string", "category_id", True, 64),
        s("educational_content", "string", "title", True, 256),
        s("educational_content", "string", "short_description", True, 512),
        s("educational_content", "string", "body", True, 16384),
        s("educational_content", "string", "language_code", False, 16, default="en"),
        s("educational_content", "boolean", "is_published", False, default=False),
        s("educational_content", "datetime", "created_at"),
        s("educational_content", "datetime", "updated_at"),
    ]


def index_specs() -> list[IndexSpec]:
    i = IndexSpec
    return [
        i("users", "user_id_unique", "unique", ("user_id",)),
        i("users", "email_index", "key", ("email",)),
        i("category_definitions", "category_id_unique", "unique", ("category_id",)),
        i("category_definitions", "active_order_index", "key", ("is_active", "display_order")),
        i("daily_logs", "log_id_unique", "unique", ("log_id",)),
        i("daily_logs", "user_date_unique", "unique", ("user_id", "log_date")),
        i("daily_logs", "user_id_index", "key", ("user_id",)),
        i("daily_logs", "log_date_index", "key", ("log_date",)),
        i("daily_logs", "completed_index", "key", ("is_fully_completed",)),
        i("daily_log_items", "item_id_unique", "unique", ("item_id",)),
        i("daily_log_items", "log_category_unique", "unique", ("log_id", "category_id")),
        i("daily_log_items", "log_id_index", "key", ("log_id",)),
        i("daily_log_items", "user_id_index", "key", ("user_id",)),
        i("daily_log_items", "category_id_index", "key", ("category_id",)),
        i("gamification_profiles", "gamification_user_unique", "unique", ("user_id",)),
        i("gamification_events", "gamification_event_unique", "unique", ("event_id",)),
        i("gamification_events", "gamification_user_index", "key", ("user_id",)),
        i("gamification_events", "gamification_type_index", "key", ("event_type",)),
        i("gamification_events", "gamification_date_index", "key", ("log_date",)),
        i("subscriptions", "subscription_id_unique", "unique", ("subscription_id",)),
        i("subscriptions", "subscription_user_index", "key", ("user_id",)),
        i("analytics_events", "analytics_event_id_unique", "unique", ("event_id",)),
        i("analytics_events", "analytics_user_index", "key", ("user_id",)),
        i("analytics_events", "analytics_name_index", "key", ("event_name",)),
        i("analytics_events", "analytics_screen_index", "key", ("screen_name",)),
        i("analytics_events", "analytics_created_index", "key", ("created_at",)),
        i("educational_content", "content_id_unique", "unique", ("content_id",)),
        i("educational_content", "content_category_index", "key", ("category_id",)),
        i("educational_content", "content_language_index", "key", ("language_code",)),
    ]


def iso_now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%S.000+00:00", time.gmtime())


if __name__ == "__main__":
    raise SystemExit(main())
