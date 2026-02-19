# Backend Code Quality Audit

Last updated: 2026-02-19

## Formatting

- `make server-fmt-check` passes (gofmt clean).
- CI runs format check in `.github/workflows/server.yml`.

## Lint

- `make server-lint` passes (golangci-lint).
- CI runs lint in `.github/workflows/server.yml`.

## Tests

- Unit test suite: `make server-test-ci`
- Integration test suite (requires Postgres + Redis): `make server-test-integration`
- CI runs integration tests with Postgres + Redis services in `.github/workflows/server.yml`.

## Coverage notes

- Unit tests cover core validation helpers (auth token logic, display name validation, session normalization, streak/week computations).
- Integration tests cover end-to-end service flows and HTTP endpoint contract smoke.

Measured combined coverage (instrumenting all packages, running all tests with integration enabled):

- Total statements covered: 80.4%
- Command used: `make server-coverage` (runs `CLEARBREATH_INTEGRATION=1 go test -count=1 -coverpkg=./... -coverprofile=coverage.out ./...`)

Main sources of uncovered statements:

- `cmd/api` entrypoint wiring
- sqlc generated query wrappers (thin wrappers over DB calls)
- OIDC verifier network paths (Apple/Google) without real provider tokens
