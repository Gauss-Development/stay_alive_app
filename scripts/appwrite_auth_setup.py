#!/usr/bin/env python3
"""Configure Stay Alive Appwrite auth settings for project 69de16de001dfb5c1e5d.

Idempotently enables auth methods, registers mobile platforms, and reports OAuth
provider status. Uses the Appwrite REST API (stdlib only).

Required env:
  APPWRITE_ENDPOINT   (default: https://sfo.cloud.appwrite.io/v1)
  APPWRITE_PROJECT_ID (default: 69de16de001dfb5c1e5d)
  APPWRITE_API_KEY    (project API key with project.write scope)

Example:
  APPWRITE_API_KEY=... python3 scripts/appwrite_auth_setup.py
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any

APPWRITE_ENDPOINT = os.environ.get(
    "APPWRITE_ENDPOINT", "https://sfo.cloud.appwrite.io/v1"
).rstrip("/")
APPWRITE_PROJECT_ID = os.environ.get("APPWRITE_PROJECT_ID", "69de16de001dfb5c1e5d")
APPWRITE_API_KEY = os.environ.get("APPWRITE_API_KEY", "")

AUTH_METHODS_TO_ENABLE = (
    "email-password",
    "anonymous",
)

ANDROID_PLATFORMS = (
    ("stayalive-android-prod", "Stay Alive Android", "com.gaussdev.stayalive"),
    ("stayalive-android-dev", "Stay Alive Android Dev", "com.gaussdev.stayalivedev"),
)

APPLE_PLATFORMS = (
    ("stayalive-ios-prod", "Stay Alive iOS", "com.gaussdev.stayalive"),
    ("stayalive-ios-dev", "Stay Alive iOS Dev", "com.gaussdev.stayalivedev"),
)


class AppwriteRequestError(RuntimeError):
    def __init__(self, status: int, payload: dict[str, Any] | str) -> None:
        self.status = status
        self.payload = payload
        super().__init__(f"Appwrite request failed with {status}: {payload}")


def main() -> int:
    if not APPWRITE_PROJECT_ID or not APPWRITE_API_KEY:
        print(
            "Missing credentials. Set APPWRITE_PROJECT_ID and APPWRITE_API_KEY.",
            file=sys.stderr,
        )
        return 2

    print(f"Configuring auth for project {APPWRITE_PROJECT_ID} at {APPWRITE_ENDPOINT}")

    project = get_project()
    print(f"Project name: {project.get('name', '(unknown)')}")

    for method_id in AUTH_METHODS_TO_ENABLE:
        enable_auth_method(method_id)

    for platform_id, name, application_id in ANDROID_PLATFORMS:
        ensure_android_platform(platform_id, name, application_id)

    for platform_id, name, bundle_id in APPLE_PLATFORMS:
        ensure_apple_platform(platform_id, name, bundle_id)

    report_oauth_providers()
    print("Auth setup complete.")
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


def get_project() -> dict[str, Any]:
    return request("GET", "/project")


def enable_auth_method(method_id: str) -> None:
    try:
        request(
            "PATCH",
            f"/project/auth-methods/{method_id}",
            {"enabled": True},
        )
        print(f"enabled auth method: {method_id}")
    except AppwriteRequestError as error:
        if error.status == 409:
            print(f"skipped auth method (already configured): {method_id}")
            return
        raise


def list_platforms() -> list[dict[str, Any]]:
    response = request("GET", "/project/platforms")
    return response.get("platforms", [])


def ensure_android_platform(
    platform_id: str,
    name: str,
    application_id: str,
) -> None:
    existing = _find_platform(list_platforms(), application_id=application_id, type="android")
    if existing is not None:
        print(f"skipped existing android platform: {application_id}")
        return
    create_or_skip(
        "android platform",
        application_id,
        lambda: request(
            "POST",
            "/project/platforms/android",
            {
                "platformId": platform_id,
                "name": name,
                "applicationId": application_id,
            },
        ),
    )


def ensure_apple_platform(
    platform_id: str,
    name: str,
    bundle_identifier: str,
) -> None:
    existing = _find_platform(
        list_platforms(),
        bundle_identifier=bundle_identifier,
        type="apple",
    )
    if existing is not None:
        print(f"skipped existing apple platform: {bundle_identifier}")
        return
    create_or_skip(
        "apple platform",
        bundle_identifier,
        lambda: request(
            "POST",
            "/project/platforms/apple",
            {
                "platformId": platform_id,
                "name": name,
                "bundleIdentifier": bundle_identifier,
            },
        ),
    )


def _find_platform(
    platforms: list[dict[str, Any]],
    *,
    application_id: str | None = None,
    bundle_identifier: str | None = None,
    type: str | None = None,
) -> dict[str, Any] | None:
    for platform in platforms:
        if type is not None and platform.get("type") != type:
            continue
        if application_id is not None and platform.get("applicationId") == application_id:
            return platform
        if (
            bundle_identifier is not None
            and platform.get("bundleIdentifier") == bundle_identifier
        ):
            return platform
    return None


def report_oauth_providers() -> None:
    response = request("GET", "/project/oauth2")
    providers = response.get("providers", [])
    tracked = {"google", "apple"}
    print("OAuth provider status:")
    for provider in providers:
        provider_id = provider.get("key") or provider.get("$id") or provider.get("provider")
        if provider_id not in tracked:
            continue
        enabled = provider.get("enabled", False)
        print(f"  - {provider_id}: {'enabled' if enabled else 'disabled'}")
        if not enabled:
            print(
                f"    Configure credentials in Appwrite Console → Auth → {provider_id.title()}",
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


if __name__ == "__main__":
    raise SystemExit(main())
