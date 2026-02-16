-- name: GetAuthIdentityUserID :one
SELECT user_id
FROM auth_identities
WHERE provider = $1
  AND provider_subject = $2
LIMIT 1;

-- name: CreateAuthIdentity :one
INSERT INTO auth_identities (user_id, provider, provider_subject)
VALUES ($1, $2, $3)
RETURNING *;

