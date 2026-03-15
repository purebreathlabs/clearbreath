.PHONY: server-dev server-build server-docker-build server-lint server-test server-test-ci server-test-integration server-coverage server-fmt-check server-sqlc server-smoke db-wipe \
       mobile-run mobile-build apk apk-arm64 mobile-analyze mobile-get mobile-pub-add mobile-gen mobile-icons mobile-fmt mobile-fmt-check mobile-test \
       fmt-check \
       web-dev web-build \
       docker-up docker-down \
       db-create db-migrate db-migrate-status db-migrate-new sqlc-generate setup clean \
       version version-sync version-bump-patch version-bump-minor version-bump-major

FLUTTER ?= flutter
DART ?= $(shell if command -v dart >/dev/null 2>&1; then echo dart; else FLUTTER_PATH="$$(command -v $(FLUTTER) 2>/dev/null || echo $(FLUTTER))"; echo "$$(dirname "$$FLUTTER_PATH")/dart"; fi)
MOBILE_RUN_ARGS ?=
API_BASE_URL ?= https://api.clearbreath.life
GOOGLE_WEB_CLIENT_ID ?=
GOOGLE_IOS_CLIENT_ID ?=
MOBILE_DART_DEFINES ?= --dart-define=API_BASE_URL=$(API_BASE_URL) --dart-define=GOOGLE_WEB_CLIENT_ID=$(GOOGLE_WEB_CLIENT_ID) --dart-define=GOOGLE_IOS_CLIENT_ID=$(GOOGLE_IOS_CLIENT_ID)
GOLANGCI_LINT ?= $(shell command -v golangci-lint 2>/dev/null || echo $(HOME)/go/bin/golangci-lint)
SQLC ?= $(shell command -v sqlc 2>/dev/null || echo $(HOME)/go/bin/sqlc)
GOOSE ?= $(shell command -v goose 2>/dev/null || echo $(HOME)/go/bin/goose)
PSQL ?= $(shell command -v psql 2>/dev/null || echo /opt/homebrew/opt/postgresql@17/bin/psql)
VERSION := $(shell cat VERSION 2>/dev/null || echo 0.0.0)
BUILD := $(shell git rev-list --count HEAD 2>/dev/null || echo 1)

server-dev:
	cd server && go run ./cmd/api

server-build:
	cd server && go build -ldflags="-X main.version=$(VERSION)" -o bin/api ./cmd/api

server-docker-build:
	DOCKER_BUILDKIT=0 docker build -t clearbreath-api:local --build-arg VERSION=$(VERSION)+$(BUILD) -f server/Dockerfile server

server-lint:
	cd server && $(GOLANGCI_LINT) run

server-test:
	cd server && go test ./...

server-test-ci:
	cd server && go test -race -count=1 ./...

server-test-integration:
	cd server && CLEARBREATH_INTEGRATION=1 go test ./...

server-coverage:
	cd server && CLEARBREATH_INTEGRATION=1 go test -count=1 -coverpkg=./... -coverprofile=coverage.out ./...
	cd server && go tool cover -func=coverage.out | tail -n 1

server-fmt-check:
	cd server && test -z "$$(gofmt -l .)"

server-sqlc:
	cd server && $(SQLC) generate -f sqlc/sqlc.yaml

server-smoke:
	bash scripts/backend_api_smoke.sh

mobile-run:
	cd apps/mobile && $(FLUTTER) run $(MOBILE_RUN_ARGS) $(MOBILE_DART_DEFINES)

mobile-build:
	cd apps/mobile && $(FLUTTER) build apk --release $(MOBILE_DART_DEFINES)

apk:
	cd apps/mobile && $(FLUTTER) build apk --release --split-per-abi $(MOBILE_DART_DEFINES)

apk-arm64:
	cd apps/mobile && $(FLUTTER) build apk --release --split-per-abi --target-platform android-arm64 $(MOBILE_DART_DEFINES)

mobile-analyze:
	cd apps/mobile && $(FLUTTER) analyze

mobile-get:
	cd apps/mobile && $(FLUTTER) pub get

mobile-pub-add:
	if [ -z "$(PKG)" ]; then echo "PKG is required"; exit 1; fi
	cd apps/mobile && $(FLUTTER) pub add $(PKG)

mobile-gen:
	cd apps/mobile && $(FLUTTER) pub run build_runner build --delete-conflicting-outputs

mobile-icons:
	cd apps/mobile && $(DART) run flutter_launcher_icons

mobile-fmt:
	cd apps/mobile && $(DART) format lib/ test/

mobile-fmt-check:
	cd apps/mobile && $(DART) format --set-exit-if-changed --output=none lib/

mobile-test:
	cd apps/mobile && $(FLUTTER) test

fmt-check: server-fmt-check mobile-fmt-check

web-dev:
	cd apps/web && bun run dev

web-build:
	cd apps/web && bun run build

docker-up:
	docker compose -f docker-compose.dev.yml up -d

docker-down:
	docker compose -f docker-compose.dev.yml down

db-create:
	$(PSQL) -c "CREATE DATABASE clearbreath;" 2>/dev/null || true

db-migrate:
	if [ -z "$$DATABASE_URL" ]; then echo "DATABASE_URL is required"; exit 1; fi
	$(GOOSE) -dir server/migrations postgres "$$DATABASE_URL" up

db-migrate-status:
	if [ -z "$$DATABASE_URL" ]; then echo "DATABASE_URL is required"; exit 1; fi
	$(GOOSE) -dir server/migrations postgres "$$DATABASE_URL" status

db-migrate-new:
	if [ -z "$$NAME" ]; then echo "NAME is required"; exit 1; fi
	$(GOOSE) -dir server/migrations create "$$NAME" sql

db-wipe:
	@echo "Wiping all data (development only)..."
	PGPASSWORD=clearbreath $(PSQL) -h localhost -p 5433 -U clearbreath -d clearbreath \
		-c "TRUNCATE users, auth_identities, refresh_tokens, sessions, stats_snapshots, safety_acknowledgements, xp_events, user_progress, request_logs, event_logs CASCADE;"
	@echo "Done."

sqlc-generate: server-sqlc

setup:
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
	go install github.com/pressly/goose/v3/cmd/goose@latest
	cd server && go mod download
	cd apps/mobile && $(FLUTTER) pub get
	cd apps/web && bun install

clean:
	rm -rf server/bin
	cd apps/web && rm -rf dist .astro

version:
	@echo $(VERSION)+$(BUILD)

version-sync:
	@bash scripts/version-sync.sh

version-bump-patch:
	@bash scripts/version-bump.sh patch

version-bump-minor:
	@bash scripts/version-bump.sh minor

version-bump-major:
	@bash scripts/version-bump.sh major
