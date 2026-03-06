-- name: UpsertInstallation :one
INSERT INTO notification_installations (
  device_id, user_id, platform, fcm_token, permission_status,
  reminder_enabled, reminder_time_minutes, streak_warning_enabled,
  timezone_iana, timezone_offset_minutes, app_version, build_number, locale,
  last_seen_at, updated_at
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, now(), now())
ON CONFLICT (device_id) DO UPDATE SET
  user_id = COALESCE(EXCLUDED.user_id, notification_installations.user_id),
  platform = EXCLUDED.platform,
  fcm_token = EXCLUDED.fcm_token,
  permission_status = EXCLUDED.permission_status,
  reminder_enabled = EXCLUDED.reminder_enabled,
  reminder_time_minutes = EXCLUDED.reminder_time_minutes,
  streak_warning_enabled = EXCLUDED.streak_warning_enabled,
  timezone_iana = EXCLUDED.timezone_iana,
  timezone_offset_minutes = EXCLUDED.timezone_offset_minutes,
  app_version = EXCLUDED.app_version,
  build_number = EXCLUDED.build_number,
  locale = EXCLUDED.locale,
  last_seen_at = now(),
  updated_at = now()
RETURNING *;

-- name: BindInstallationToUser :exec
UPDATE notification_installations SET user_id = $2, updated_at = now() WHERE device_id = $1;

-- name: UnbindInstallation :exec
UPDATE notification_installations
SET user_id = NULL, last_streak_sent_local_day = NULL, updated_at = now()
WHERE device_id = $1 AND user_id = $2;

-- name: GetInstallationByDeviceID :one
SELECT * FROM notification_installations WHERE device_id = $1;

-- name: GetInstallationsByUserID :many
SELECT * FROM notification_installations WHERE user_id = $1;

-- name: DeleteInstallationByDeviceID :exec
DELETE FROM notification_installations WHERE device_id = $1;

-- name: DeleteInstallationByFCMToken :exec
DELETE FROM notification_installations WHERE fcm_token = $1;

-- name: ListDistinctActiveTimezones :many
SELECT DISTINCT timezone_iana FROM notification_installations WHERE reminder_enabled = true;

-- name: GetDueDailyReminders :many
SELECT device_id, fcm_token, platform
FROM notification_installations
WHERE reminder_enabled = true
  AND permission_status = 'authorized'
  AND reminder_time_minutes = $1
  AND timezone_iana = $2
  AND (last_daily_sent_local_day IS NULL OR last_daily_sent_local_day < $3::date)
  AND (user_id IS NULL OR EXISTS (
    SELECT 1 FROM users u WHERE u.id = notification_installations.user_id AND u.deleted_at IS NULL
  ));

-- name: GetDueStreakWarnings :many
SELECT ni.device_id, ni.fcm_token, ni.platform
FROM notification_installations ni
JOIN users u ON u.id = ni.user_id AND u.deleted_at IS NULL
JOIN stats_snapshots ss ON ss.user_id = ni.user_id
WHERE ni.streak_warning_enabled = true
  AND ni.permission_status = 'authorized'
  AND ss.current_streak_days > 0
  AND ni.timezone_iana = $1
  AND (ni.last_streak_sent_local_day IS NULL OR ni.last_streak_sent_local_day < $2::date)
  AND NOT EXISTS (
    SELECT 1 FROM sessions s
    WHERE s.user_id = ni.user_id
      AND s.started_at_utc >= ($2::date - make_interval(secs => ni.timezone_offset_minutes * 60))
      AND s.started_at_utc < ($2::date + interval '1 day' - make_interval(secs => ni.timezone_offset_minutes * 60))
      AND s.duration_seconds_actual >= 120
  );

-- name: MarkDailyReminderSent :exec
UPDATE notification_installations
SET last_daily_sent_local_day = $2, last_send_error = NULL, updated_at = now()
WHERE device_id = $1;

-- name: MarkStreakWarningSent :exec
UPDATE notification_installations
SET last_streak_sent_local_day = $2, last_send_error = NULL, updated_at = now()
WHERE device_id = $1;

-- name: MarkSendError :exec
UPDATE notification_installations
SET last_send_error = $2, updated_at = now()
WHERE device_id = $1;

-- name: ListDistinctStreakTimezones :many
SELECT DISTINCT timezone_iana FROM notification_installations
WHERE streak_warning_enabled = true AND user_id IS NOT NULL;
