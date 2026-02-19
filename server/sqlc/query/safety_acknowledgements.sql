-- name: ListSafetyAcknowledgementsByUserID :many
SELECT technique_id
FROM safety_acknowledgements
WHERE user_id = $1
ORDER BY technique_id;

-- name: AddSafetyAcknowledgement :exec
INSERT INTO safety_acknowledgements (user_id, technique_id)
VALUES ($1, $2)
ON CONFLICT (user_id, technique_id) DO NOTHING;

-- name: DeleteSafetyAcknowledgementsByUserID :exec
DELETE FROM safety_acknowledgements
WHERE user_id = $1;

