# Backend Performance Audit

Last updated: 2026-02-19

## Hot paths

### Session ingest (`/v1/sessions/submit`, `/v1/sessions/sync`)

- Max payload is bounded (submit 200, sync 500).
- Each session is normalized in-process, then inserted with `ON CONFLICT DO NOTHING` for idempotency.
- Stats snapshot is recomputed and upserted after ingest within the same transaction.

DB indexes supporting ingest/stats:

- `sessions_user_day_idx (user_id, local_day)`
- `sessions_user_started_idx (user_id, started_at_utc)`

### Stats snapshot (`/v1/stats/snapshot`)

- Reads the cached row from `stats_snapshots`.
- If missing, recomputes from `sessions` aggregates and upserts.

### Leaderboard refresh job

- Runs every 5 minutes.
- Executes three bounded DB queries and rewrites three Redis sorted sets via tmp+rename.

### Leaderboard reads

- Reads from Redis sorted sets and fetches user rows by id from Postgres for display fields.

### Safety acknowledgements (`/v1/me/safety_acknowledgements`)

- Single-table lookups keyed by `(user_id, technique_id)` with primary key index.

## Observations

- The current design is safe for MVP scale due to strict request bounds and simple queries.
- Leaderboard refresh is isolated and should not block request handling; refresh failures keep serving cached data.

## Follow-ups (if needed later)

- Add basic timing metrics around ingest/stats/refresh for p95 visibility.
- Consider incremental stats updates if recompute becomes expensive at large session volumes.
