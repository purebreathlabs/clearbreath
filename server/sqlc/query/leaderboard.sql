-- name: GetLeaderboardXPMetrics :many
SELECT u.id AS user_id, COALESCE(up.total_xp, 0)::bigint AS total_xp
FROM users u LEFT JOIN user_progress up ON up.user_id = u.id
WHERE u.deleted_at IS NULL AND u.leaderboard_opt_in = true AND u.shadow_banned = false;

-- name: GetUsersByIDs :many
SELECT id, display_name, avatar_seed, leaderboard_initials_only
FROM users
WHERE id = ANY($1::uuid[])
  AND deleted_at IS NULL
  AND leaderboard_opt_in = true
  AND shadow_banned = false;
