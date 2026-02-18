.PHONY: server-dev server-build server-lint server-test server-test-ci server-test-integration server-fmt-check server-sqlc \
       mobile-run mobile-build mobile-analyze mobile-get mobile-gen mobile-fmt mobile-fmt-check mobile-test \
       fmt-check \
       web-dev web-build \
       docker-up docker-down \
       db-create db-migrate db-migrate-status db-migrate-new sqlc-generate setup clean \
       version version-sync version-bump-patch version-bump-minor version-bump-major

FLUTTER := /Users/rahul/sdk/flutter/bin/flutter
GOLANGCI_LINT := $(HOME)/go/bin/golangci-lint
SQLC := $(HOME)/go/bin/sqlc
GOOSE := $(HOME)/go/bin/goose
PSQL := /opt/homebrew/opt/postgresql@17/bin/psql
VERSION := $(shell cat VERSION 2>/dev/null || echo 0.0.0)
BUILD := $(shell git rev-list --count HEAD 2>/dev/null || echo 1)

server-dev:
	cd server && go run ./cmd/api

server-build:
	cd server && go build -ldflags="-X main.version=$(VERSION)" -o bin/api ./cmd/api

server-lint:
	cd server && $(GOLANGCI_LINT) run

server-test:
	cd server && go test ./...

server-test-ci:
	cd server && go test -race -count=1 ./...

server-test-integration:
	cd server && CLEARBREATH_INTEGRATION=1 go test ./...

server-fmt-check:
	cd server && test -z "$$(gofmt -l .)"

server-sqlc:
	cd server && $(SQLC) generate -f sqlc/sqlc.yaml

mobile-run:
	cd apps/mobile && $(FLUTTER) run

mobile-build:
	cd apps/mobile && $(FLUTTER) build apk --release

mobile-analyze:
	cd apps/mobile && $(FLUTTER) analyze

mobile-get:
	cd apps/mobile && $(FLUTTER) pub get

mobile-gen:
	cd apps/mobile && dart run build_runner build --delete-conflicting-outputs

mobile-fmt:
	cd apps/mobile && dart format lib/ test/

mobile-fmt-check:
	cd apps/mobile && dart format --set-exit-if-changed --output=none lib/

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
