#!/usr/bin/env bash
# Creates (idempotently) the QA account used by integration_test/screens_test.dart
# on the LOCAL Supabase stack and seeds it with 20 days of tracker data:
#
#   today      — partially logged (~60% of each category)
#   yesterday  — 10 consecutive perfect days (24/24), so streaks and badges fire
#   older      — half-completed days, so the history charts are not flat
#
# Gamification is fully recomputed from daily_logs, so seeding logs is enough:
# XP, level, streaks, badges and category mastery all follow.
#
# Usage: supabase start && ./tool/seed_qa_account.sh
set -euo pipefail

EMAIL="qa@stayalive.test"
PASSWORD="qa-password-123"
API="http://127.0.0.1:54321"
DB_CONTAINER="supabase_db_stay_alive"

ANON=$(supabase status -o json | python3 -c 'import sys,json; print(json.load(sys.stdin)["ANON_KEY"])')

echo "→ creating $EMAIL (ignored if it already exists)"
curl -s -X POST "$API/auth/v1/signup" \
  -H "apikey: $ANON" -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"data\":{\"name\":\"QA Росток\",\"onboardingCompleted\":true}}" \
  >/dev/null || true

USER_ID=$(docker exec "$DB_CONTAINER" psql -U postgres -d postgres -tAc \
  "select id from auth.users where email = '$EMAIL'")
if [ -z "$USER_ID" ]; then
  echo "could not resolve a user id for $EMAIL" >&2
  exit 1
fi
echo "→ user id: $USER_ID"

TODAY=$(date +%Y-%m-%d)
echo "→ seeding 20 days up to $TODAY"

docker exec -i "$DB_CONTAINER" psql -U postgres -d postgres <<SQL >/dev/null
do \$\$
declare
  v_uid uuid := '$USER_ID';
  v_today date := date '$TODAY';
  d int; v_log_id uuid; v_date date; v_mode text;
begin
  for d in 0..19 loop
    v_date := v_today - d;
    v_mode := case when d = 0 then 'today'
                   when d between 1 and 10 then 'perfect'
                   else 'partial' end;

    insert into public.daily_logs (user_id, log_date)
    values (v_uid, v_date)
    on conflict (user_id, log_date) do update set updated_at = now()
    returning id into v_log_id;

    insert into public.daily_log_items (
      log_id, user_id, category_id, category_title, description, icon_key,
      target_count, display_order, is_active, completed_count)
    select v_log_id, v_uid, c.category_id, c.title, c.description, c.icon_key,
           c.target_count, c.display_order, c.is_active,
           case v_mode
             when 'perfect' then c.target_count
             when 'today'   then greatest(0, floor(c.target_count * 0.6))::int
             else                greatest(0, floor(c.target_count * 0.5))::int
           end
    from public.category_definitions c
    where c.is_active
    on conflict (log_id, category_id) do update set completed_count = excluded.completed_count;

    update public.daily_logs l
    set total_completed = s.completed,
        total_target = s.target,
        completion_percentage = case when s.target > 0
              then s.completed::double precision / s.target * 100 else 0 end,
        is_fully_completed = (s.target > 0 and s.completed >= s.target),
        created_at = v_date::timestamptz
    from (select coalesce(sum(completed_count),0) completed,
                 coalesce(sum(target_count),0) target
          from public.daily_log_items where log_id = v_log_id) s
    where l.id = v_log_id;
  end loop;
end \$\$;
SQL

echo "→ done. Log in as $EMAIL / $PASSWORD"
