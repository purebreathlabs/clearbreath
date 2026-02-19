# ClearBreath Backend Progress

Last updated: 2026-02-19

## Working Rules

- Work one checkbox group at a time.
- For each task: research → analysis → plan → implement → review → manual curl → automated tests → full test run.
- Update this file immediately after each task is completed.

## Phase 0: Research & Baseline

- [x] Read product docs: `docs/clearbreath-prd.md`, `docs/final_plan.md`, `docs/ClearBreath Tech Stack.md`
- [x] Read backend env/config: `.env.example`, `server/.env`, `server/.env.example`, `server/internal/config/config.go`
- [x] Read schema/migrations and sqlc queries: `server/migrations/*`, `server/sqlc/query/*`
- [x] Read router wiring + handlers + services for auth/sessions/stats/leaderboard
- [x] Create `BACKEND_CODEBASE_ANALYSIS.md`

## Week 2 (Backend)

### B2-W2-1: API contract freeze + mobile integration pack

- [x] Create contract doc (endpoints + request/response + error codes + rate limits)
- [x] Publish canonical IDs list (technique IDs + preset IDs) sourced from registry
- [x] Include payload examples for mobile local DB mirroring

### B2-W2-2: Resolve env var naming drift (docs vs code)

- [x] Decide single source of truth (keep code names) and update docs
- [x] Ensure `.env.example` matches docs and backend config

### B2-W2-3: Add missing risk tests (timezone/week boundary + ended_early plausibility)

- [x] Tests for local_day computation around midnight with timezone offsets
- [x] Tests for Monday-start week boundary correctness
- [x] Tests for ended_early min duration rule
- [x] Tests for breaths plausibility edge cases (including short durations)

### B2-W2-4: Leaderboard rank contiguity audit

- [x] Fix rank assignment to be contiguous after filtering
- [x] Add regression test for rank contiguity

## Week 3 (Backend)

### B7-W3-1: CI integration job with Postgres + Redis services

- [x] Add GitHub Actions job that runs integration tests with Postgres+Redis
- [x] Ensure job is deterministic and runs on PRs

### B7-W3-2: Leaderboard refresh failure-mode hardening plan

- [x] Document failure-mode behavior/runbook (transient Redis failure, partial refresh, empty dataset, recovery)
- [x] Add tests for write path failure modes where feasible

## Beyond Week 3 (Backend)

- [x] Audit remaining backend requirements from `docs/final_plan.md` (Weeks 4–7) and map to implemented code
- [x] Add HTTP integration tests covering all v1 endpoints
- [x] Publish manual curl smoke checklist doc
- [x] Close any missing backend features (implement + tests + CI)
- [x] Security audit (auth, rate limits, validation, data deletion, least privilege)
- [x] Performance audit (hot paths: sessions ingest, stats recompute, leaderboard refresh/list)
- [x] Code quality audit (lint, test coverage, consistency)
- [x] Run full manual curl checklist against running server

## Pending (Docs-required)

### P1: Safety warning acceptance sync (cross-device)

- [x] Add persistence model for per-technique warning acceptance (DB + queries)
- [x] Add authenticated endpoints to get/update warning acceptance
- [x] Add unit + integration tests for sync behavior
- [x] Update API contract doc with the new endpoints

### P2: Backend deploy pipeline + ops runbooks

- [x] Add CI job to build and publish Docker image
- [x] Add deploy workflow scaffold for Hetzner VPS (Docker + Caddy)
- [x] Add rollback and backup runbooks

## Final Production Readiness Verification

- [x] Re-run build, format check, and lint
- [x] Re-run unit tests (`make server-test-ci`)
- [x] Re-run integration tests with Postgres+Redis (`make server-test-integration`)
- [x] Re-run curl smoke flow (`docs/backend_curl_smoke.md`)
- [x] Sync audits/docs with current code state
