# Appwrite Backend Architecture & Setup

This document defines the production backend architecture for the Daily Dozen app and provides reproducible command-style steps.

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
- OAuth providers:
  - Google
  - Apple

Flutter client uses:
- `account.create(...)` for signup
- `account.createEmailPasswordSession(...)` for login
- `account.getSession(sessionId: 'current')` for session restore
- `account.deleteSession(sessionId: 'current')` for logout
- `account.createOAuth2Session(...)` for OAuth

## 3) Database Plan

Database ID: `daily_dozen_db`

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

## 7) Reproducible CLI-style Setup Steps

> Replace placeholders with real values:
> - `<ENDPOINT>`
> - `<PROJECT_ID>`
> - `<API_KEY>`

```bash
# Authenticate CLI context
appwrite client --endpoint "<ENDPOINT>" --project-id "<PROJECT_ID>" --key "<API_KEY>"

# Create database
appwrite databases create --database-id "daily_dozen_db" --name "Daily Dozen DB"

# Create collections
appwrite databases create-collection --database-id "daily_dozen_db" --collection-id "users" --name "Users"
appwrite databases create-collection --database-id "daily_dozen_db" --collection-id "category_definitions" --name "Category Definitions"
appwrite databases create-collection --database-id "daily_dozen_db" --collection-id "daily_logs" --name "Daily Logs"
appwrite databases create-collection --database-id "daily_dozen_db" --collection-id "daily_log_items" --name "Daily Log Items"
appwrite databases create-collection --database-id "daily_dozen_db" --collection-id "subscriptions" --name "Subscriptions"
appwrite databases create-collection --database-id "daily_dozen_db" --collection-id "analytics_events" --name "Analytics Events"
appwrite databases create-collection --database-id "daily_dozen_db" --collection-id "educational_content" --name "Educational Content"
```

Use the Appwrite console (or equivalent CLI commands for attributes/indexes) to apply the field schema and indexes exactly as specified above.

## 8) OAuth Platform Callback Notes

Android:
- Add callback activity with scheme: `appwrite-callback-<PROJECT_ID>`

iOS:
- Add URL scheme in `Info.plist`: `appwrite-callback-<PROJECT_ID>`

Both are already prepared in this repository and should be updated with the actual project id per environment.

