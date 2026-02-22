# ClearBreath Backend Codebase Analysis (Go)

Last updated: 2026-02-22

## Scope

This document covers the Go backend in `server/` plus repo-level infrastructure that affects backend execution (Make targets, Docker, CI workflows, env vars, and backend-related product docs).

## High-level Architecture

- Entry point: `server/cmd/api/main.go`
- Router: Chi v5
- Database: PostgreSQL (pgx/v5 + pgxpool)
- Cache/rate limiting/leaderboard: Redis (go-redis/v9)
- Migrations: goose (SQL files in `server/migrations/`)
- Query layer: sqlc (queries in `server/sqlc/query/*.sql`, generated in `server/internal/repository/sqlcgen/`)
- Logging: `log/slog` JSON default logger (`server/cmd/api/main.go:41`)

## Dependencies (Go)

From `server/go.mod`:

- `github.com/go-chi/chi/v5 v5.2.5`
- `github.com/jackc/pgx/v5 v5.8.0`
- `github.com/redis/go-redis/v9 v9.17.3`
- `github.com/pressly/goose/v3 v3.25.0`
- `github.com/sqlc-dev/sqlc` is installed via `make setup` (not in `go.mod`)

## Runtime Configuration (Environment Variables)

Source of truth for current dev config:

- `server/.env`
- `server/.env.example`
- `.env.example`

Variables currently used by `server/internal/config/config.go`:

- `PORT` (default `8080`) (`server/internal/config/config.go:71`)
- `DATABASE_URL` (`server/internal/config/config.go:72`)
- `REDIS_ADDR` (`server/internal/config/config.go:73`)
- `REDIS_PASSWORD` (`server/internal/config/config.go:74`)
- `CORS_ORIGINS` (CSV) (`server/internal/config/config.go:75`)
- `ENV` (default `development`) (`server/internal/config/config.go:38`)
- `TECHNIQUE_REGISTRY_PATH` (default `registry/techniques.json`) (`server/internal/config/config.go:77`)
- `JWT_ACCESS_SECRET` (`server/internal/config/config.go:78`)
- `JWT_REFRESH_SECRET` (`server/internal/config/config.go:79`)
- `JWT_ACCESS_TTL_MINUTES` (default `15`) (`server/internal/config/config.go:40`)
- `JWT_REFRESH_TTL_MINUTES` (default `43200`) (`server/internal/config/config.go:44`)
- `GOOGLE_OAUTH_CLIENT_ID` (required if `ENV != development`) (`server/internal/config/config.go:82`, `server/internal/config/config.go:203`)
- `APPLE_OAUTH_AUDIENCE` (required if `ENV != development`) (`server/internal/config/config.go:83`, `server/internal/config/config.go:206`)
- `RATE_LIMIT_AUTH_PER_HOUR` (default `30`) (`server/internal/config/config.go:48`)
- `RATE_LIMIT_AUTH_BURST_PER_MIN` (default `10`) (`server/internal/config/config.go:52`)
- `RATE_LIMIT_SESSION_WRITES_PER_DAY` (default `500`) (`server/internal/config/config.go:56`)
- `RATE_LIMIT_LEADERBOARD_READS_PER_MIN` (default `120`) (`server/internal/config/config.go:60`)
- `DEV_AUTH_ENABLED` (default `true` when `ENV=development`) (`server/internal/config/config.go:64`)
- `DEV_AUTH_SECRET` (required when `DEV_AUTH_ENABLED=true`) (`server/internal/config/config.go:89`, `server/internal/config/config.go:199`)
- `LEADERBOARD_DAILY_CAP_MINUTES` (default `60`) (`server/internal/config/config.go:65`)

Doc mismatch resolved:

- `docs/final_plan.md` documents `ENV`, `REDIS_ADDR`, `REDIS_PASSWORD`, `CORS_ORIGINS` to match `server/internal/config/config.go`.

## Database Schema

Migration files:

- `server/migrations/00001_init.sql`
- `server/migrations/00002_safety_acknowledgements.sql`

Tables:

- `users` (includes leaderboard prefs, shadow ban, `age_band`, `timezone_offset_minutes_latest`, soft delete via `deleted_at`)
- `auth_identities` (provider + subject -> user mapping)
- `refresh_tokens` (hashed refresh tokens, single-use rotation via `replaced_by`, revoke via `revoked_at`)
- `safety_acknowledgements` (per-technique safety warning acceptance for cross-device sync)
- `sessions` (unique `client_session_id` for idempotent ingest, `local_day` derived from `started_at_utc + timezone_offset_minutes`)
- `stats_snapshots` (authoritative aggregates cached per user)

Primary session/stats indexes:

- `sessions_user_day_idx` on `(user_id, local_day)`
- `sessions_user_started_idx` on `(user_id, started_at_utc)`

## Technique Registry and Canonical IDs

Registry file:

- `server/registry/techniques.json`

Technique IDs (canonical):

- `hrv_resonance`
- `ultra_slow`
- `diaphragmatic`
- `box`
- `four_seven_eight`
- `yogic_three_part`
- `anulom_vilom`
- `ujjayi`
- `bhramari`
- `kapalbhati`
- `bhastrika`

Preset IDs (canonical, per technique):

- `beginner`
- `intermediate`
- `advanced`

Validation:

- Backend validates `(technique_id, preset_id)` against the registry at ingest time (`server/internal/service/session/service.go:114`).

## HTTP Routes and Middleware

Router wiring: `server/cmd/api/main.go`.

Global middleware chain:

- Request ID (`server/cmd/api/main.go:130`, `server/internal/middleware/requestid.go`)
- Structured logging (`server/cmd/api/main.go:131`, `server/internal/middleware/logging.go`)
- Panic recovery (`server/cmd/api/main.go:132`, `server/internal/middleware/panic.go`)
- CORS allowlist (`server/cmd/api/main.go:133`, `server/internal/middleware/cors.go`)

Health endpoints:

- `GET /health` (`server/cmd/api/main.go:137`)
- `GET /ready` (`server/cmd/api/main.go:138`)

Auth endpoints (rate-limited per IP):

- `POST /v1/auth/provider_sign_in` (`server/cmd/api/main.go:144`)
- `POST /v1/auth/refresh` (`server/cmd/api/main.go:145`)
- `POST /v1/auth/logout` (JWT required) (`server/cmd/api/main.go:146`)

User endpoints (JWT required):

- `GET /v1/me` (`server/cmd/api/main.go:157`)
- `PATCH /v1/me` (`server/cmd/api/main.go:158`)
- `DELETE /v1/me` (allows deleted user lookup for idempotency) (`server/cmd/api/main.go:159`)
- `GET /v1/me/safety_acknowledgements` (`server/cmd/api/main.go:162`)
- `POST /v1/me/safety_acknowledgements` (`server/cmd/api/main.go:163`)

Session endpoints (JWT required, rate-limited per user/day):

- `POST /v1/sessions/submit` (`server/cmd/api/main.go:167`)
- `POST /v1/sessions/sync` (`server/cmd/api/main.go:168`)

Stats endpoint (JWT required):

- `GET /v1/stats/snapshot` (`server/cmd/api/main.go:171`)

Leaderboard endpoints:

- `GET /v1/leaderboard` (rate-limited per IP/min) (`server/cmd/api/main.go:175`)
- `GET /v1/leaderboard/self` (JWT required + same IP/min limit) (`server/cmd/api/main.go:176`)

## Response and Error Format

All JSON responses are written via `server/internal/httpx/httpx.go:16`.

Errors use a uniform envelope:

```json
{ "error": "message", "code": "validation", "request_id": "..." }
```

Source:

- `server/internal/httpx/httpx.go:10`
- `server/internal/httpx/httpx.go:22`

JSON decoding:

- Disallows unknown fields (`server/internal/httpx/httpx.go:33`)
- Rejects trailing JSON (`server/internal/httpx/httpx.go:42`)

## Auth Model

- Access tokens: JWT (HS256), subject is `user_id` (`server/internal/auth/access.go:35`)
- Access token expiry: `JWT_ACCESS_TTL_MINUTES`
- Refresh tokens:
  - Random 32 bytes base64url (`server/internal/auth/refresh.go:11`)
  - Stored as HMAC-SHA256 hash in DB (`server/internal/auth/refresh.go:20`)
  - Rotated single-use; replaced tokens return 409 `refresh_replay` (`server/internal/service/auth/service.go:207`)
  - Revoked (logout) tokens return 401 `unauthorized` (`server/internal/service/auth/service.go:210`)
- Provider verification:
  - `dev` provider supported when `DEV_AUTH_ENABLED=true` and header `X-Dev-Auth` matches `DEV_AUTH_SECRET` (`server/internal/service/auth/service.go:360`)
  - `google`/`apple` use OIDC verifier and return 401 `invalid_provider_token` on verification failure (`server/internal/service/auth/service.go:441`)

## Session Ingest and Plausibility Rules

Endpoint payload source:

- `server/internal/handler/sessions.go:24`

Core normalization and validation:

- Valid UUID required for `client_session_id` (`server/internal/service/session/service.go:195`)
- `timezone_offset_minutes` must be within `[-840, 840]` minutes (`server/internal/service/session/service.go:212`)
- `ended_at_utc >= started_at_utc` and duration must be positive (`server/internal/service/session/service.go:222`)
- Duration max enforced by preset (`server/internal/service/session/service.go:239`)
- Duration min enforced by preset only when `ended_early=false` (`server/internal/service/session/service.go:247`)
- When `ended_early=true`, duration must be at least 10 seconds (`server/internal/service/session/service.go:255`)
- Breaths estimate:
  - Negative is rejected (`server/internal/service/session/service.go:263`)
  - For longer sessions, estimate must be plausible vs preset bpm bounds; clamped into bounds (`server/internal/service/session/service.go:297`)
- `local_day` derived from `started_at_utc + timezone_offset_minutes` and stored as a UTC date-only timestamp (`server/internal/service/session/service.go:280`)

## Stats Semantics

- Streak qualifying threshold: total seconds in a local day must be `>= 120` (`server/internal/service/stats/service.go:122`)
- Week definition: ISO week start Monday (`server/internal/service/stats/service.go:81`, `server/internal/service/stats/service.go:195`)
- Minute rounding: integer division `seconds / 60` (`server/internal/service/stats/service.go:107`, `server/internal/service/stats/service.go:132`, `server/internal/service/stats/service.go:133`)

## Leaderboard Mechanics

Refresh job:

- Runs once at boot + every 5 minutes (`server/cmd/api/main.go:167`, `server/cmd/api/main.go:171`)

Redis write strategy:

- Writes to `key:tmp` then `RENAME` to final key (`server/internal/service/leaderboard/service.go:115`)
- Empty dataset deletes final key (`server/internal/service/leaderboard/service.go:144`)

Ranking views:

- `streak` key `lb:streak`
- `weekly` key `lb:weekly`
- `all_time` key `lb:all_time`

Leaderboard list limit:

- Enforced in service: `limit <= 0 || limit > 50 => 50` (`server/internal/service/leaderboard/service.go:170`)

Rank contiguity:

- Ranks are assigned contiguously after DB filtering (verified in `server/internal/integration/leaderboard_rank_test.go`).

## Testing Inventory

Unit tests exist for:

- Access token issuance/parse (`server/internal/auth/access_test.go`)
- Refresh token hashing (`server/internal/auth/refresh_test.go`)
- Age band calculation (`server/internal/service/auth/service_test.go`)
- Display name canonicalization (`server/internal/service/user/validate_test.go`)
- Session normalization basics (`server/internal/service/session/service_test.go`)
- Stats streak computation (`server/internal/service/stats/streak_test.go`)
- Leaderboard initials (`server/internal/service/leaderboard/initials_test.go`)

Integration test exists (gated):

- `server/internal/integration/integration_test.go` (requires `CLEARBREATH_INTEGRATION=1`)

Gaps closed (Week-2/3 backend tasks):

- Timezone local-day boundary and Monday-start week boundary tests added.
- `ended_early` min duration and short-session breaths plausibility tests added.
- CI integration job runs with Postgres+Redis services (`.github/workflows/server.yml`).
