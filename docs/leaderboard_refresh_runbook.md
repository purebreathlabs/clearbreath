# Leaderboard Refresh Runbook

Last updated: 2026-02-19

## What runs the refresh

- On boot: refresh is attempted once.
- During runtime: refresh runs every 5 minutes.

Source: `server/cmd/api/main.go` and `server/internal/service/leaderboard/service.go`.

## Redis keys

- `lb:streak`
- `lb:weekly`
- `lb:all_time`

## Write strategy (per key)

For each leaderboard key:

1. Delete `key:tmp`
2. Write the new sorted-set to `key:tmp`
3. `RENAME key:tmp key` (atomic swap)

If the computed dataset is empty:

- Delete `key` (leaderboard view becomes empty)

## Failure modes and expected behavior

### Redis transient failure during refresh

Examples:

- `DEL key:tmp` fails
- `ZADD key:tmp …` fails
- `RENAME key:tmp key` fails

Expected behavior:

- Refresh returns an error and is logged by the server.
- The existing `key` remains unchanged when failure happens before `RENAME`.
- `key:tmp` may remain if failure occurs after `ZADD` but before `RENAME`.
- The next refresh attempt deletes `key:tmp` first and retries, allowing recovery.

### Partial refresh across ranking views

Refresh updates the ranking views sequentially.

Expected behavior:

- A failure while updating one view does not roll back already-updated views.
- Each view is independently consistent because each key swap is atomic.

### Empty dataset

This occurs when there are no eligible users (deleted, opted out, or shadow banned).

Expected behavior:

- Refresh deletes the final leaderboard key for that view.
- List responses return an empty `top` list for that view.
- Self-rank responses return `rank=null` and `metric_value` may be `0`.

### Recovery behavior

- Automatic: refresh retries every 5 minutes.
- Manual: restart the API process to force an on-boot refresh attempt.

## Debug checklist (local/staging)

1. Confirm refresh is running (logs for success or `leaderboard refresh failed`).
2. Inspect Redis keys:

```bash
redis-cli -h localhost -p 6380 ZREVRANGE lb:streak 0 10 WITHSCORES
redis-cli -h localhost -p 6380 ZREVRANGE lb:weekly 0 10 WITHSCORES
redis-cli -h localhost -p 6380 ZREVRANGE lb:all_time 0 10 WITHSCORES
redis-cli -h localhost -p 6380 KEYS "lb:*:tmp"
```

3. Inspect Postgres eligibility rules:

```bash
psql "$DATABASE_URL" -c "select id, deleted_at, leaderboard_opt_in, shadow_banned from users order by created_at desc limit 20;"
psql "$DATABASE_URL" -c "select user_id, current_streak_days from stats_snapshots order by updated_at desc limit 20;"
```

4. If `lb:*:tmp` keys persist, it indicates refresh failures after writing tmp but before rename.
