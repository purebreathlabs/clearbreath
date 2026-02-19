# Backend Weeks Audit (Weeks 4–7)

Last updated: 2026-02-19

This maps the backend deliverables in `docs/final_plan.md` Week 4–Week 7 to the current Go backend implementation.

## Week 4 (Auth, age gate, cloud sync foundations)

- Provider sign-in backend + app flow
  - Implemented: `POST /v1/auth/provider_sign_in` (`server/cmd/api/main.go`)
  - Providers: `dev`, `google`, `apple` (`server/internal/service/auth/service.go`)
- Birth-year age gate
  - Implemented: `birth_year` required; under-13 blocked with `403 age_restricted` (`server/internal/service/auth/service.go`)
- Token lifecycle (access + rotating refresh)
  - Implemented: JWT access tokens + refresh rotation + replay detection (`server/internal/service/auth/service.go`)
  - Revoked refresh token returns `401 unauthorized` (`server/internal/service/auth/service.go`)
- Guest-to-account session merge and dedupe
  - Implemented:
    - `POST /v1/sessions/sync` (`server/cmd/api/main.go`)
    - Dedupe by `client_session_id` (`server/sqlc/query/sessions.sql`)

## Week 5 (Leaderboard production)

- Three ranking views
  - Implemented: `streak`, `weekly`, `all_time` (`server/internal/service/leaderboard/service.go`)
- Opt-in visibility and initials-only behavior
  - Implemented in DB queries and response shaping (`server/sqlc/query/leaderboard.sql`, `server/internal/service/leaderboard/service.go`)
  - Update via `PATCH /v1/me` (`server/internal/handler/me.go`, `server/internal/service/user/service.go`)
- 5-minute refresh and Redis ranking sets
  - Implemented at boot + ticker (`server/cmd/api/main.go`)
- Anti-cheat baseline and profanity filtering
  - Session plausibility validation implemented (`server/internal/service/session/service.go`)
  - Display name profanity filtering implemented (`server/internal/service/user/service.go`, `server/internal/profanity/filter.go`)

## Week 6 (Hardening and CI)

- Input validation hardening
  - JSON unknown fields rejected (`server/internal/httpx/httpx.go`)
  - Session plausibility validation and clamping (`server/internal/service/session/service.go`)
- Rate limiting hardening
  - Auth: per-IP burst/min + per-IP/hour (`server/cmd/api/main.go`, `server/internal/middleware/ratelimit.go`)
  - Sessions: per-user/day (`server/cmd/api/main.go`, `server/internal/middleware/ratelimit.go`)
  - Leaderboard reads: per-IP/min (`server/cmd/api/main.go`, `server/internal/middleware/ratelimit.go`)
- CI regression coverage
  - Unit tests run in CI (`.github/workflows/server.yml`)
  - Integration tests run in CI with Postgres+Redis services (`.github/workflows/server.yml`)

## Week 7 (Release candidate stabilization)

- Release stabilization is ongoing and requires:
  - Manual API smoke using curl (`docs/backend_curl_smoke.md`)
  - Integration tests green in CI (`.github/workflows/server.yml`)
  - Security/performance/code-quality audits tracked in `BACKEND_PROGRESS.md`

## Docs-required follow-ups (completed)

- Safety warning acceptance sync (cross-device)
  - Required by PRD and plan:
    - PRD: per-technique warning acceptance is synced after sign-in so it stays one-time across devices (`docs/clearbreath-prd.md:541`)
    - Plan: warnings are persisted locally per technique and synced if signed in (`docs/final_plan.md:271`)
  - Implemented:
    - DB table: `safety_acknowledgements` (`server/migrations/00002_safety_acknowledgements.sql`)
    - API: `GET /v1/me/safety_acknowledgements`, `POST /v1/me/safety_acknowledgements` (`server/cmd/api/main.go`)
    - Contract: `docs/backend_api_contract.md`

- Deployment pipeline and operational runbooks
  - Required by PRD and plan:
    - Plan: CI deploy to Hetzner VPS with Docker and Caddy (`docs/final_plan.md:115`)
    - Plan: main branch deploy pipeline for backend with rollback runbook (`docs/final_plan.md:939`)
    - Plan: backup and rollback procedures documented (`docs/final_plan.md:949`)
  - Implemented:
    - Image publish workflow: `.github/workflows/server-image.yml`
    - Deploy workflow scaffold: `.github/workflows/server-deploy.yml`
    - Prod compose + Caddy config: `deploy/docker-compose.prod.yml`, `deploy/Caddyfile`, `deploy/.env.example`
    - Runbooks: `docs/backend_deploy_runbook.md`, `docs/backend_backup_runbook.md`
