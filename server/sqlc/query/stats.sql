-- name: UpsertStatsSnapshot :one
INSERT INTO stats_snapshots (
  user_id,
  current_streak_days,
  longest_streak_days,
  practice_days_all_time,
  minutes_this_week,
  minutes_all_time,
  sessions_all_time,
  minutes_by_technique,
  updated_at
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now())
ON CONFLICT (user_id)
DO UPDATE SET
  current_streak_days = EXCLUDED.current_streak_days,
  longest_streak_days = EXCLUDED.longest_streak_days,
  practice_days_all_time = EXCLUDED.practice_days_all_time,
  minutes_this_week = EXCLUDED.minutes_this_week,
  minutes_all_time = EXCLUDED.minutes_all_time,
  sessions_all_time = EXCLUDED.sessions_all_time,
  minutes_by_technique = EXCLUDED.minutes_by_technique,
  updated_at = now()
RETURNING *;

-- name: GetStatsSnapshot :one
SELECT *
FROM stats_snapshots
WHERE user_id = $1;
