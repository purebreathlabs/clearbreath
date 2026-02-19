# ClearBreath

Pranayama and breathing exercise platform.

## Structure

```
server/          Go API (Chi + pgx + Redis)
apps/mobile/     Flutter mobile app (iOS + Android)
apps/web/        Astro landing page (clearbreath.life)
docs/            Product requirements and architecture
```

## Prerequisites

- Go 1.25+
- Flutter 3.38+ (at `~/sdk/flutter/bin/flutter` if not in PATH)
- Bun 1.3+
- PostgreSQL 17
- Redis 7+
- Docker (optional, for containerized dev)

## Setup

Create the database:

```
make db-create
```

Copy environment files:

```
cp .env.example server/.env
```

Install all dependencies:

```
make setup
```

## Running

All commands are available as both `make` targets and `bun run` shortcuts.

| Task | Make | Bun |
|------|------|-----|
| Go API | `make server-dev` | `bun run server` |
| Flutter app | `make mobile-run` | `bun run mobile` |
| Astro dev server | `make web-dev` | `bun run web` |
| Docker up | `make docker-up` | `bun run docker:up` |
| Docker down | `make docker-down` | `bun run docker:down` |
| Setup | `make setup` | `bun run setup` |
| Clean | `make clean` | `bun run clean` |

`bun run dev` is an alias for `bun run server`.

### Server

```
bun run server
```

Starts the Go API on http://localhost:8080. Test with:

```
curl http://localhost:8080/health
```

### Mobile

```
bun run mobile:get
bun run mobile
```

### Web

```
bun run web
```

Starts the Astro dev server on http://localhost:4321.

### Docker (Postgres + Redis)

For containerized databases instead of local brew services:

```
bun run docker:up
```

Update `server/.env` to use ports 5433 (postgres) and 6380 (redis).

Stop with:

```
bun run docker:down
```

## Build

| Target | Make | Bun |
|--------|------|-----|
| Go binary (`server/bin/api`) | `make server-build` | `bun run server:build` |
| Android APK | `make mobile-build` | `bun run mobile:build` |
| Static site (`apps/web/dist/`) | `make web-build` | `bun run web:build` |

## Lint & Test

```
bun run server:lint     # golangci-lint
bun run server:test     # go test
bun run mobile:analyze  # flutter analyze
```
