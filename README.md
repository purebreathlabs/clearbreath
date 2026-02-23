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

#### Local backend testing (Android emulator)

Start dependencies and server first, then run mobile with dart-define flags:

```bash
make docker-up
make server-dev

make mobile-run MOBILE_RUN_ARGS="--dart-define=API_BASE_URL=http://10.0.2.2:8080 --dart-define=DEV_AUTH_ENABLED=true"
```

`10.0.2.2` is the Android emulator alias for the host machine's `localhost`.

#### Local backend testing (physical Android on same WiFi)

Find your machine's local IP (`ip -4 addr show | grep 192.168`) and use it:

```bash
make mobile-run MOBILE_RUN_ARGS="--dart-define=API_BASE_URL=http://192.168.x.x:8080 --dart-define=DEV_AUTH_ENABLED=true"
```

#### Release APK for local testing

```bash
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL=http://192.168.x.x:8080 \
  --dart-define=DEV_AUTH_ENABLED=true \
  --dart-define=DEV_AUTH_SECRET=dev_secret_change_me
```

The arm64-v8a APK is at `apps/mobile/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

#### Google Sign-In (local dev)

Google Sign-In works on debug builds if the debug keystore SHA-1 is registered in the
Google Cloud Console Android OAuth client. The `serverClientId` (Web client ID) is
configured in `sign_in_screen.dart` and the backend reads `GOOGLE_OAUTH_CLIENT_ID` from
`server/.env`. No additional URL or redirect configuration is needed for native Android
sign-in.

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
