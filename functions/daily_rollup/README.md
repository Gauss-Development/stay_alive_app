# Daily Rollup Appwrite Function

Server-side companion for client gamification reconcile. Intended to run on a
daily cron schedule and denormalize streak counters into `gamification_profiles`.

## Responsibilities

1. Load users with activity in the last 48 hours.
2. Recompute streak counters from `daily_logs`.
3. Upsert `gamification_profiles` (`current_streak`, `best_streak`, `completed_days`).
4. Optionally emit rollup events into `gamification_events`.

## Deployment

This repository ships the function contract only. Deploy with Appwrite CLI once
your project is provisioned via `scripts/appwrite_provision.py`.

Suggested schedule: `30 0 * * *` UTC.

## Client contract

- Intraday XP and challenge progress remain client-authoritative via
  `reconcileTodayOverview`.
- Full `reconcileOverview` on app launch and pull-to-refresh remains the
  correctness backstop.
- Nightly rollup reduces cold-start drift for long-inactive users.
