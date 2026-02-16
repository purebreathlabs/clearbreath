-- name: GetLeaderboardStreakMetrics :many
SELECT u.id AS user_id,
       COALESCE(ss.current_streak_days, 0)::bigint AS metric_value
FROM users u
LEFT JOIN stats_snapshots ss ON ss.user_id = u.id
WHERE u.deleted_at IS NULL
  AND u.leaderboard_opt_in = true
  AND u.shadow_banned = false;

-- name: GetLeaderboardAllTimeMinutesMetrics :many
WITH per_day AS (
  SELECT user_id,
         local_day,
         LEAST((SUM(duration_seconds_actual)::int) / 60, $1)::bigint AS capped_minutes
  FROM sessions
  GROUP BY user_id, local_day
)
SELECT u.id AS user_id,
       COALESCE(SUM(per_day.capped_minutes), 0)::bigint AS metric_value
FROM users u
LEFT JOIN per_day ON per_day.user_id = u.id
WHERE u.deleted_at IS NULL
  AND u.leaderboard_opt_in = true
  AND u.shadow_banned = false
GROUP BY u.id;

-- name: GetLeaderboardWeeklyMinutesMetrics :many
WITH eligible AS (
  SELECT id AS user_id,
         (($1::timestamptz + (timezone_offset_minutes_latest * interval '1 minute'))::date) AS local_today
  FROM users
  WHERE deleted_at IS NULL
    AND leaderboard_opt_in = true
    AND shadow_banned = false
),
week_bounds AS (
  SELECT user_id,
         (local_today - (extract(isodow from local_today)::int - 1))::date AS week_start
  FROM eligible
),
per_day AS (
  SELECT user_id,
         local_day,
         LEAST((SUM(duration_seconds_actual)::int) / 60, $2)::bigint AS capped_minutes
  FROM sessions
  GROUP BY user_id, local_day
)
SELECT wb.user_id AS user_id,
       COALESCE(SUM(pd.capped_minutes), 0)::bigint AS metric_value
FROM week_bounds wb
LEFT JOIN per_day pd
  ON pd.user_id = wb.user_id
 AND pd.local_day >= wb.week_start
 AND pd.local_day < wb.week_start + 7
GROUP BY wb.user_id;

-- name: GetUsersByIDs :many
SELECT id, display_name, avatar_seed, leaderboard_initials_only
FROM users
WHERE id = ANY($1::uuid[])
  AND deleted_at IS NULL
  AND leaderboard_opt_in = true
  AND shadow_banned = false;

