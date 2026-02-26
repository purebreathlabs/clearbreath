-- +goose Up

ALTER TABLE stats_snapshots
  ADD COLUMN practice_days_all_time int NOT NULL DEFAULT 0;

WITH qualifying_days AS (
  SELECT user_id, local_day
  FROM sessions
  GROUP BY user_id, local_day
  HAVING SUM(duration_seconds_actual) >= 120
),
counts AS (
  SELECT user_id, COUNT(*)::int AS practice_days_all_time
  FROM qualifying_days
  GROUP BY user_id
)
UPDATE stats_snapshots s
SET practice_days_all_time = c.practice_days_all_time
FROM counts c
WHERE s.user_id = c.user_id;

-- +goose Down

ALTER TABLE stats_snapshots
  DROP COLUMN IF EXISTS practice_days_all_time;
