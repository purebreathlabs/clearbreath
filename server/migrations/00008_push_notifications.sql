-- +goose Up

CREATE TABLE notification_installations (
  device_id                    text PRIMARY KEY,
  user_id                      uuid REFERENCES users(id) ON DELETE CASCADE,
  platform                     text NOT NULL CHECK (platform IN ('android', 'ios')),
  fcm_token                    text NOT NULL,
  permission_status            text NOT NULL DEFAULT 'not_determined',
  reminder_enabled             boolean NOT NULL DEFAULT true,
  reminder_time_minutes        int NOT NULL DEFAULT 480,
  streak_warning_enabled       boolean NOT NULL DEFAULT true,
  timezone_iana                text NOT NULL DEFAULT 'UTC',
  timezone_offset_minutes      int NOT NULL DEFAULT 0,
  app_version                  text NOT NULL DEFAULT '',
  build_number                 text NOT NULL DEFAULT '',
  locale                       text NOT NULL DEFAULT 'en',
  last_seen_at                 timestamptz NOT NULL DEFAULT now(),
  last_daily_sent_local_day    date,
  last_streak_sent_local_day   date,
  last_send_error              text,
  created_at                   timestamptz NOT NULL DEFAULT now(),
  updated_at                   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX notif_inst_user_id_idx ON notification_installations(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX notif_inst_fcm_token_idx ON notification_installations(fcm_token);
CREATE INDEX notif_inst_reminder_idx ON notification_installations(timezone_iana, reminder_time_minutes)
  WHERE reminder_enabled = true;

-- +goose Down
DROP TABLE IF EXISTS notification_installations;
