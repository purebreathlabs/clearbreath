-- name: UpsertUserProgress :one
INSERT INTO user_progress (user_id, total_xp, current_level, curve_version)
VALUES ($1, $2, $3, $4)
ON CONFLICT (user_id) DO UPDATE SET
  total_xp = $2, current_level = $3, curve_version = $4, updated_at = now()
RETURNING *;

-- name: GetUserProgress :one
SELECT * FROM user_progress WHERE user_id = $1;

-- name: InsertXPEvent :one
INSERT INTO xp_events (user_id, source, amount, multiplier, base_amount, session_id, local_day, curve_version)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING *;

-- name: GetDailyPracticeXP :one
SELECT COALESCE(SUM(amount), 0)::int AS daily_practice_xp
FROM xp_events
WHERE user_id = $1 AND local_day = $2 AND source = 'session';

-- name: HasDailyOpenXP :one
SELECT EXISTS(
  SELECT 1 FROM xp_events WHERE user_id = $1 AND local_day = $2 AND source = 'daily_open'
) AS has_daily_open_xp;

-- name: GetTotalXP :one
SELECT COALESCE(SUM(amount), 0)::bigint AS total_xp FROM xp_events WHERE user_id = $1;

-- name: GetDailyXPHistory :many
SELECT local_day,
       SUM(amount)::int AS total_xp,
       SUM(CASE WHEN source = 'session' THEN amount ELSE 0 END)::int AS practice_xp,
       SUM(CASE WHEN source = 'daily_open' THEN amount ELSE 0 END)::int AS login_xp
FROM xp_events
WHERE user_id = $1 AND local_day >= $2
GROUP BY local_day
ORDER BY local_day DESC;

-- name: DeleteXPEventsByUser :exec
DELETE FROM xp_events WHERE user_id = $1;

-- name: DeleteUserProgress :exec
DELETE FROM user_progress WHERE user_id = $1;
