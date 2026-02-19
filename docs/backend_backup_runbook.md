# Backend Backup and Restore Runbook

Last updated: 2026-02-19

ClearBreath backend state lives in PostgreSQL. Redis is treated as a rebuildable cache (leaderboards) and transient counters (rate limits).

## Postgres backup

Recommended baseline:

- Automated daily logical backups using `pg_dump`.
- Store backups in a secure bucket (team-chosen storage) with retention.
- Verify restore regularly.

Example:

```bash
export DATABASE_URL="postgres://..."
pg_dump "$DATABASE_URL" --format=custom --file "clearbreath_$(date -u +%Y%m%dT%H%M%SZ).dump"
```

## Postgres restore

Example:

```bash
export DATABASE_URL="postgres://..."
pg_restore --clean --if-exists --no-owner --dbname "$DATABASE_URL" "clearbreath_YYYYMMDDTHHMMSSZ.dump"
```

## Redis backup

Redis can be rebuilt from Postgres:

- Leaderboard sets are recomputed on refresh.
- Rate-limit keys are transient.

If Redis is lost:

- Restart the API and let refresh rebuild leaderboards.
- If needed, force a refresh by restarting the API process.

