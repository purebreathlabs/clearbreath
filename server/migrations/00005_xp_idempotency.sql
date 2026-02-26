-- +goose Up

CREATE UNIQUE INDEX xp_events_daily_open_uniq
  ON xp_events(user_id, local_day)
  WHERE source = 'daily_open';

CREATE UNIQUE INDEX xp_events_session_uniq
  ON xp_events(session_id)
  WHERE source = 'session' AND session_id IS NOT NULL;

-- +goose Down

DROP INDEX IF EXISTS xp_events_session_uniq;
DROP INDEX IF EXISTS xp_events_daily_open_uniq;
