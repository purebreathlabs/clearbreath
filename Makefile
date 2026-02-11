.PHONY: server-dev server-build server-lint server-test \
       mobile-run mobile-build mobile-analyze mobile-get \
       web-dev web-build \
       docker-up docker-down \
       db-create setup clean

FLUTTER := /Users/rahul/sdk/flutter/bin/flutter
PSQL := /opt/homebrew/opt/postgresql@17/bin/psql

server-dev:
	cd server && go run ./cmd/api

server-build:
	cd server && go build -o bin/api ./cmd/api

server-lint:
	cd server && go vet ./...

server-test:
	cd server && go test ./...

mobile-run:
	cd apps/mobile && $(FLUTTER) run

mobile-build:
	cd apps/mobile && $(FLUTTER) build apk --release

mobile-analyze:
	cd apps/mobile && $(FLUTTER) analyze

mobile-get:
	cd apps/mobile && $(FLUTTER) pub get

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

setup:
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
	cd server && go mod download
	cd apps/mobile && $(FLUTTER) pub get
	cd apps/web && bun install

clean:
	rm -rf server/bin
	cd apps/web && rm -rf dist .astro
