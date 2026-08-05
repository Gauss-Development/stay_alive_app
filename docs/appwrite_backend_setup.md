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
export APPWRITE_ENDPOINT="https://nyc.cloud.appwrite.io/v1"
export APPWRITE_PROJECT_ID="6a53570100147968d1f6"
export APPWRITE_API_KEY="<API_KEY_WITH_PROJECT_WRITE_SCOPE>"
python3 scripts/appwrite_auth_setup.py
```

The script enables `email-password` and `anonymous` auth, registers Android/iOS
platforms for `com.gaussdev.stayalive` and `com.gaussdev.stayalivedev`, and
prints Google/Apple OAuth status. OAuth credentials must still be added in the
Appwrite Console (Auth → Settings) — enabling OAuth via API requires valid
client credentials.

### Appwrite MCP (Cursor)

Project-level config: [`.cursor/mcp.json`](.cursor/mcp.json) uses hosted OAuth:

```json
{
  "mcpServers": {
    "appwrite": {
      "url": "https://mcp.appwrite.io/mcp"
    }
  }
}
```

Alternatively, use stdio + API key in **Cursor Settings → MCP** (remove legacy `--users` flag):

- `APPWRITE_ENDPOINT=https://nyc.cloud.appwrite.io/v1`
- `APPWRITE_PROJECT_ID=6a53570100147968d1f6`
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

Database ID: `stay_alive_v1` (canonical Stay Alive database in project `6a53570100147968d1f6`)

Design: document id is the natural key where possible; row-level permissions enforce ownership (no redundant `user_id` on user-owned collections).

Collections:

1. `users` — document id = Auth user id
   - `email` (string, required, indexed)
   - `name` (string, required)
   - `avatar_url` (string, optional)
   - `onboarding_completed` (bool, default false)
   - `units_preference` (string, default `metric`)
   - `locale` (string, default `en`)
   - profile fields (`age`, `gender`, `preferred_diet`, `height_cm`, `weight_kg`)
   - `created_at`, `updated_at` (datetime)

2. `category_definitions` — document id = category slug
   - `category_id`, `title`, `description`, `icon_key`, `target_count`, `display_order`, `is_active`, timestamps

3. `daily_logs` — document id = `{userId}_{yyyy-MM-dd}`
   - `log_date` (string `yyyy-MM-dd`, indexed)
   - `completion_percentage`, `total_completed`, `total_target`, `is_fully_completed`
   - `created_at`, `updated_at`

4. `daily_log_items` — document id = `{logDocId}_{categoryId}`
   - `category_id`, `category_title`, `description`, `icon_key`, `target_count`, `display_order`, `is_active`
   - `completed_count`, `created_at`, `updated_at`

5. `subscriptions` — document id = subscription id
   - `plan`, `status`, `expires_at`, `provider`, timestamps

6. `analytics_events` — document id = auto-generated
   - `event_name`, `screen_name`, `metadata_json`, `created_at`

7. `educational_content` — document id = content id
   - `content_id`, `category_id`, `title`, `short_description`, `body`, `language_code`, `is_published`, timestamps

8. `gamification_profiles` — document id = user id
   - `xp`, `level`, streak/badge fields, `created_at`, `updated_at`

9. `gamification_events` — document id = auto-generated
   - `event_type`, `xp_delta`, `log_date`, `metadata_json`, `created_at`

10. `ai_interactions` — document id = auto-generated (AI coach audit)
   - `user_id`, `mode`, `from_fallback`, `created_at`

Legacy database `69de1ac5002830be7040` is deprecated; do not point the app at it.

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
- `ai_coach` for LLM coach proxy (`functions/ai_coach`) — set `APPWRITE_AI_COACH_FUNCTION_ID` and optional `OPENAI_API_KEY`

## 7) Reproducible Setup Script

The repository includes an idempotent provisioning script that uses the Appwrite REST API directly. The Appwrite CLI is not required.

```bash
export APPWRITE_ENDPOINT="https://nyc.cloud.appwrite.io/v1"
export APPWRITE_PROJECT_ID="6a53570100147968d1f6"
export APPWRITE_DATABASE_ID="stay_alive_v1"
export APPWRITE_API_KEY="<API_KEY_WITH_DATABASE_AND_STORAGE_SCOPES>"
./scripts/provision_fresh_db.sh
python3 scripts/appwrite_verify.py
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

