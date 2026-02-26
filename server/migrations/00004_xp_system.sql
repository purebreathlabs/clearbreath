-- +goose Up

-- Dedicated progress table (source of truth for XP/level)
CREATE TABLE user_progress (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_xp bigint NOT NULL DEFAULT 0,
  current_level int NOT NULL DEFAULT 0,
  curve_version int NOT NULL DEFAULT 1,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Audit trail for all XP events
CREATE TABLE xp_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  source text NOT NULL,
  amount int NOT NULL,
  multiplier numeric(4,2) NOT NULL DEFAULT 1.00,
  base_amount int NOT NULL,
  session_id uuid NULL REFERENCES sessions(id) ON DELETE SET NULL,
  local_day date NOT NULL,
  curve_version int NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX xp_events_user_day_idx ON xp_events(user_id, local_day);
CREATE INDEX xp_events_user_created_idx ON xp_events(user_id, created_at);
CREATE INDEX xp_events_session_idx ON xp_events(session_id);

-- +goose Down
DROP TABLE IF EXISTS xp_events;
DROP TABLE IF EXISTS user_progress;
