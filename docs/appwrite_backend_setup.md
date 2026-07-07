# Appwrite Backend Architecture & Setup

This document defines the production backend architecture for the Stay Alive app and provides reproducible setup steps.

## 1) Environment Strategy

- Use separate Appwrite projects for isolation:
  - `daily-dozen-dev`
  - `daily-dozen-prod`
- Keep app/client configuration in environment variables:
  - `APPWRITE_ENDPOINT`
  - `APPWRITE_PROJECT_ID`
  - `APPWRITE_DATABASE_ID`
  - Collection IDs and bucket IDs

## 2) Authentication Setup

Enable:
- Email/Password auth
- Anonymous auth (dev mock login)
- OAuth providers:
  - Google
  - Apple

### Automated auth configuration

Run the idempotent auth setup script after creating a project API key with
`project.write` scope:

```bash
export APPWRITE_ENDPOINT="https://sfo.cloud.appwrite.io/v1"
export APPWRITE_PROJECT_ID="69de16de001dfb5c1e5d"
export APPWRITE_API_KEY="<API_KEY_WITH_PROJECT_WRITE_SCOPE>"
python3 scripts/appwrite_auth_setup.py
```

The script enables `email-password` and `anonymous` auth, registers Android/iOS
platforms for `com.gaussdev.stayalive` and `com.gaussdev.stayalivedev`, and
prints Google/Apple OAuth status. OAuth credentials must still be added in the
Appwrite Console (Auth → Settings) — enabling OAuth via API requires valid
client credentials.

### Appwrite MCP (Cursor)

To use the Appwrite API MCP server in Cursor, configure these env vars in
**Cursor Settings → MCP → appwrite-api** (not the placeholder defaults):

- `APPWRITE_ENDPOINT=https://sfo.cloud.appwrite.io/v1`
- `APPWRITE_PROJECT_ID=69de16de001dfb5c1e5d`
- `APPWRITE_API_KEY=<your project API key>`

Flutter client uses:
- `account.create(...)` for signup
- `account.createEmailPasswordSession(...)` for login
- `account.getSession(sessionId: 'current')` for session restore
- `account.deleteSession(sessionId: 'current')` for logout
- `account.createOAuth2Session(...)` for OAuth

After every signup/login/OAuth restore, the app ensures a matching document exists in the `users` collection using the Appwrite Auth user id as the document id.

## 2.1) RevenueCat Subscription Setup

Stay Alive uses RevenueCat for mobile subscription purchase state. Configure
RevenueCat dashboard products with these intended prices:

- Weekly plan: `$3`
- Monthly plan: `$15`
- Annual plan: `$100`

Create an entitlement named `premium` (or override with
`REVENUECAT_ENTITLEMENT_ID`) and attach the weekly, monthly, and annual
subscription products to the app offering (`REVENUECAT_OFFERING_ID`, default
`default`). The app reads platform API keys from:

- `REVENUECAT_ANDROID_API_KEY`
- `REVENUECAT_IOS_API_KEY`

Daily checklist tracking remains free. Full historical statistics are gated in
the app and require an active RevenueCat `premium` entitlement.

## 3) Database Plan

Database ID: `69de1ac5002830be7040` (Stay Alive project default)

Collections:

1. `users`
   - `user_id` (string, required, unique)
   - `email` (string, required, indexed)
   - `display_name` (string, required)
   - `avatar_url` (string, optional)
   - `onboarding_completed` (bool, required, default false)
   - `units_preference` (string, required, default `metric`)
   - `locale` (string, required, default `en`)
   - `created_at` (datetime)
   - `updated_at` (datetime)

2. `category_definitions`
   - `category_id` (string, required, unique)
   - `title` (string)
   - `description` (string)
   - `icon_key` (string)
   - `target_count` (int)
   - `display_order` (int)
   - `is_active` (bool)
   - `created_at` (datetime)
   - `updated_at` (datetime)

3. `daily_logs`
   - `log_id` (string, required, unique)
   - `user_id` (string, indexed)
   - `log_date` (string `yyyy-MM-dd`, indexed)
   - `completion_percentage` (double)
   - `total_completed` (int)
   - `total_target` (int)
   - `is_fully_completed` (bool)
   - `created_at` (datetime)
   - `updated_at` (datetime)

4. `daily_log_items`
   - `item_id` (string, required, unique)
   - `log_id` (string, indexed)
   - `user_id` (string, indexed)
   - `category_id` (string, indexed)
   - `completed_count` (int)
   - `target_count` (int)
   - `created_at` (datetime)
   - `updated_at` (datetime)

5. `subscriptions`
   - `subscription_id` (string, required, unique)
   - `user_id` (string, indexed)
   - `plan` (string)
   - `status` (string)
   - `expires_at` (datetime, optional)
   - `provider` (string)
   - `created_at` (datetime)
   - `updated_at` (datetime)

6. `analytics_events`
   - `event_id` (string, required, unique)
   - `user_id` (string, optional/indexed)
   - `event_name` (string, indexed)
   - `screen_name` (string, optional/indexed)
   - `metadata_json` (string/text)
   - `created_at` (datetime, indexed)

7. `educational_content`
   - `content_id` (string, required, unique)
   - `category_id` (string, indexed)
   - `title` (string)
   - `short_description` (string)
   - `body` (text)
   - `language_code` (string, default `en`)
   - `is_published` (bool)
   - `created_at` (datetime)
   - `updated_at` (datetime)

8. `gamification_profiles`
   - `user_id` (string, required, unique)
   - `xp` (int)
   - `level` (int)
   - `current_streak` (int)
   - `best_streak` (int)
   - `completed_days` (int)
   - `last_completed_date` (string, optional)
   - `badges` (string array)
   - `created_at` (datetime)
   - `updated_at` (datetime)

9. `gamification_events`
   - `event_id` (string, required, unique)
   - `user_id` (string, indexed)
   - `event_type` (string, indexed)
   - `xp_delta` (int)
   - `log_date` (string, optional/indexed)
   - `metadata_json` (string/text)
   - `created_at` (datetime, indexed)

## 4) Permissions Plan

- `users`, `daily_logs`, `daily_log_items`:
  - Row-level owner-only read/update/delete.
- `category_definitions`:
  - Public read (`Role.any()`), admin/server write.
- `educational_content`:
  - Public read only for published content, admin/server write.
- `subscriptions`:
  - Read own rows, writes only via server function.
- `analytics_events`:
  - Create by authenticated users or function pipeline; reads restricted.

## 5) Storage Buckets

- `avatars`: user-owned images
- `user_uploads`: private user files
- `content_assets`: public read, server write

## 6) Appwrite Functions (Recommended)

- `subscription_sync` for provider webhook handling
- `analytics_normalizer` for event normalization/enrichment
- `daily_rollup` for streak/summary denormalization

## 7) Reproducible Setup Script

The repository includes an idempotent provisioning script that uses the Appwrite REST API directly. The Appwrite CLI is not required.

```bash
export APPWRITE_ENDPOINT="https://sfo.cloud.appwrite.io/v1"
export APPWRITE_PROJECT_ID="69de16de001dfb5c1e5d"
export APPWRITE_API_KEY="<API_KEY_WITH_DATABASE_AND_STORAGE_SCOPES>"
python3 scripts/appwrite_provision.py
python3 scripts/appwrite_auth_setup.py
```

Run the script a second time to verify idempotency:

```bash
python3 scripts/appwrite_provision.py
```

The script creates the database, collections, attributes, indexes, storage buckets, and seeded food categories. It treats existing resources as successful skips.

Required API key scopes:

- Databases read/write
- Collections read/write
- Attributes read/write
- Indexes read/write
- Documents read/write for category seeding
- Buckets read/write

## 8) OAuth Platform Callback Notes

Android:
- Add callback activity with scheme: `appwrite-callback-<PROJECT_ID>`

iOS:
- Add URL scheme in `Info.plist`: `appwrite-callback-<PROJECT_ID>`

Both are already prepared in this repository and should be updated with the actual project id per environment.

## 9) Native Widgets

Android includes `DailyGoalWidgetProvider`, XML layout resources, and a manifest receiver. iOS includes a WidgetKit extension target named `DailyGoalWidgetExtension`.

The Flutter app writes widget data through `home_widget` using:

- `daily_goal_completed`
- `daily_goal_target`
- `daily_goal_percentage`
- `daily_goal_date`
- `daily_goal_streak`
- `daily_goal_level`

iOS widgets require the App Group configured in `DAILY_GOAL_WIDGET_APP_GROUP_ID` (default `group.com.example.stayAlive`) to be created in Apple Developer and enabled for both Runner and the widget extension.

