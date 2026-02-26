-- +goose Up
ALTER TABLE users ADD COLUMN username text;
ALTER TABLE users ADD COLUMN name text;
UPDATE users SET username = display_name WHERE username IS NULL;
ALTER TABLE users ALTER COLUMN username SET NOT NULL;
CREATE UNIQUE INDEX users_username_lower_uniq ON users (lower(username)) WHERE deleted_at IS NULL;
ALTER TABLE users DROP COLUMN display_name;
ALTER TABLE users DROP COLUMN leaderboard_initials_only;

-- +goose Down
ALTER TABLE users ADD COLUMN leaderboard_initials_only boolean NOT NULL DEFAULT false;
ALTER TABLE users ADD COLUMN display_name text;
UPDATE users SET display_name = username WHERE display_name IS NULL;
ALTER TABLE users ALTER COLUMN display_name SET NOT NULL;
DROP INDEX IF EXISTS users_username_lower_uniq;
ALTER TABLE users DROP COLUMN name;
ALTER TABLE users DROP COLUMN username;
