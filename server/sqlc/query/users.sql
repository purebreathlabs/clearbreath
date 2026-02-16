-- name: CreateUser :one
INSERT INTO users (display_name, avatar_seed, age_band, timezone_offset_minutes_latest)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetUserByID :one
SELECT *
FROM users
WHERE id = $1
  AND deleted_at IS NULL
LIMIT 1;

-- name: GetUserByIDAllowDeleted :one
SELECT *
FROM users
WHERE id = $1
LIMIT 1;

-- name: UpdateUserDisplayName :one
UPDATE users
SET display_name = $2
WHERE id = $1
  AND deleted_at IS NULL
RETURNING *;

-- name: UpdateUserLeaderboardPrefs :one
UPDATE users
SET leaderboard_opt_in = $2,
    leaderboard_initials_only = $3
WHERE id = $1
  AND deleted_at IS NULL
RETURNING *;

-- name: UpdateUserTimezoneOffset :one
UPDATE users
SET timezone_offset_minutes_latest = $2
WHERE id = $1
  AND deleted_at IS NULL
RETURNING *;

-- name: MarkUserDeleted :one
UPDATE users
SET deleted_at = now(),
    leaderboard_opt_in = false,
    leaderboard_initials_only = false,
    display_name = $2,
    avatar_seed = $3
WHERE id = $1
  AND deleted_at IS NULL
RETURNING *;

-- name: DeleteAuthIdentitiesByUserID :exec
DELETE FROM auth_identities
WHERE user_id = $1;

-- name: DeleteRefreshTokensByUserID :exec
DELETE FROM refresh_tokens
WHERE user_id = $1;

-- name: DeleteSessionsByUserID :exec
DELETE FROM sessions
WHERE user_id = $1;

-- name: DeleteStatsSnapshotByUserID :exec
DELETE FROM stats_snapshots
WHERE user_id = $1;

