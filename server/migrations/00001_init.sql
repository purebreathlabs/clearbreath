-- +goose Up
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name text NOT NULL,
  avatar_seed text NOT NULL,
  leaderboard_opt_in boolean NOT NULL DEFAULT true,
  leaderboard_initials_only boolean NOT NULL DEFAULT false,
  shadow_banned boolean NOT NULL DEFAULT false,
  age_band text NOT NULL DEFAULT 'unknown',
  timezone_offset_minutes_latest int NOT NULL DEFAULT 0,
  deleted_at timestamptz NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE auth_identities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider text NOT NULL,
  provider_subject text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, provider_subject)
);

CREATE INDEX auth_identities_user_id_idx ON auth_identities(user_id);

CREATE TABLE refresh_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id text NOT NULL,
  token_hash bytea NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz NULL,
  replaced_by uuid NULL REFERENCES refresh_tokens(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX refresh_tokens_user_id_idx ON refresh_tokens(user_id);

CREATE TABLE sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  client_session_id uuid NOT NULL UNIQUE,
  technique_id text NOT NULL,
  preset_id text NOT NULL,
  started_at_utc timestamptz NOT NULL,
  ended_at_utc timestamptz NOT NULL,
  timezone_offset_minutes int NOT NULL,
  local_day date NOT NULL,
  duration_seconds_actual int NOT NULL,
  breaths_completed_estimated int NOT NULL,
  ended_early boolean NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX sessions_user_day_idx ON sessions(user_id, local_day);
CREATE INDEX sessions_user_started_idx ON sessions(user_id, started_at_utc);

CREATE TABLE stats_snapshots (
  user_id uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  current_streak_days int NOT NULL,
  longest_streak_days int NOT NULL,
  minutes_this_week int NOT NULL,
  minutes_all_time int NOT NULL,
  sessions_all_time int NOT NULL,
  minutes_by_technique jsonb NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE IF EXISTS stats_snapshots;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS auth_identities;
DROP TABLE IF EXISTS users;
