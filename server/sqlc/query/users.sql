-- name: CreateUser :one
INSERT INTO users (username, name, avatar_seed, age_band, timezone_offset_minutes_latest)
VALUES ($1, $2, $3, $4, $5)
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

-- name: UpdateUsername :one
UPDATE users
SET username = $2
WHERE id = $1
  AND deleted_at IS NULL
RETURNING *;

-- name: UpdateUserName :one
UPDATE users
SET name = $2
WHERE id = $1
  AND deleted_at IS NULL
RETURNING *;

-- name: UpdateUserLeaderboardPrefs :one
UPDATE users
SET leaderboard_opt_in = $2
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
    username = $2,
    avatar_seed = $3
WHERE id = $1
  AND deleted_at IS NULL
RETURNING *;

-- name: CheckUsernameExists :one
SELECT EXISTS(SELECT 1 FROM users WHERE lower(username) = lower($1) AND deleted_at IS NULL);

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

