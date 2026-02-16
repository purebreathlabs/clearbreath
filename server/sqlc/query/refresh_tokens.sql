-- name: CreateRefreshToken :one
INSERT INTO refresh_tokens (user_id, device_id, token_hash, expires_at)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetRefreshTokenByHashForUpdate :one
SELECT *
FROM refresh_tokens
WHERE token_hash = $1
LIMIT 1
FOR UPDATE;

-- name: RevokeRefreshToken :exec
UPDATE refresh_tokens
SET revoked_at = now()
WHERE id = $1
  AND revoked_at IS NULL;

-- name: ReplaceRefreshToken :exec
UPDATE refresh_tokens
SET revoked_at = now(),
    replaced_by = $2
WHERE id = $1
  AND revoked_at IS NULL;

-- name: RevokeAllUserRefreshTokens :exec
UPDATE refresh_tokens
SET revoked_at = now()
WHERE user_id = $1
  AND revoked_at IS NULL;

-- name: RevokeUserDeviceRefreshTokens :exec
UPDATE refresh_tokens
SET revoked_at = now()
WHERE user_id = $1
  AND device_id = $2
  AND revoked_at IS NULL;

