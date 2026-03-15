# AGENTS.md - Go Backend

## Commands
- Dev: `make server-dev` (from root)
- Test: `make server-test`
- Lint: `make server-lint`
- Build: `make server-build`

## Stack
- Router: Chi v5
- Database: pgx/v5 with pgxpool
- Cache: go-redis/v9
- Migrations: goose
- SQL codegen: sqlc
- Config: godotenv + internal/config
- Logging: log/slog (structured JSON)

## Code style
- Never write comments in code. Not a single line.
- Errors: always wrap with `fmt.Errorf("context: %w", err)`.
- Naming: camelCase unexported, PascalCase exported.
- Imports: stdlib, blank line, third-party, blank line, internal packages.
- Use table-driven tests. Name test cases clearly.
- Prefer interfaces for testable boundaries (see handler/health.go Pinger pattern).
- Keep handlers thin - business logic goes in service layer, data access in repository layer.
- All new endpoints need tests before merge.

## Project structure
- `cmd/api/` - entry point, router wiring, graceful shutdown
- `internal/config/` - env-based configuration
- `internal/handler/` - HTTP handlers (thin, delegate to services)
- `internal/middleware/` - request ID, logging, CORS, panic recovery
- `internal/service/` - business logic
- `internal/repository/` - database queries (sqlc-generated + custom)
- `internal/model/` - domain types
- `migrations/` - goose SQL migration files
- `sqlc/` - sqlc config and generated code
