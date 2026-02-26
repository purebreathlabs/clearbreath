-- name: InsertSession :execrows
INSERT INTO sessions (
  user_id,
  client_session_id,
  technique_id,
  preset_id,
  started_at_utc,
  ended_at_utc,
  timezone_offset_minutes,
  local_day,
  duration_seconds_actual,
  breaths_completed_estimated,
  ended_early
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
ON CONFLICT (client_session_id) DO NOTHING;

-- name: GetSessionDayTotals :many
SELECT local_day, COALESCE(SUM(duration_seconds_actual), 0)::bigint AS total_seconds
FROM sessions
WHERE user_id = $1
GROUP BY local_day
ORDER BY local_day;

-- name: GetSessionCount :one
SELECT COUNT(*)::bigint AS session_count
FROM sessions
WHERE user_id = $1;

-- name: GetTotalSessionSeconds :one
SELECT COALESCE(SUM(duration_seconds_actual), 0)::bigint AS total_seconds
FROM sessions
WHERE user_id = $1;

-- name: GetTechniqueTotals :many
SELECT technique_id, COALESCE(SUM(duration_seconds_actual), 0)::bigint AS total_seconds
FROM sessions
WHERE user_id = $1
GROUP BY technique_id;

-- name: GetSessionSecondsInRange :one
SELECT COALESCE(SUM(duration_seconds_actual), 0)::bigint AS total_seconds
FROM sessions
WHERE user_id = $1
  AND local_day >= $2
  AND local_day < $3;

-- name: GetSessionByClientID :one
SELECT id, duration_seconds_actual, ended_early, local_day FROM sessions WHERE client_session_id = $1;

