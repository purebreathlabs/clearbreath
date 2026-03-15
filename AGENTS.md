# AGENTS.md

## Project
ClearBreath - breathing exercise app. Monorepo: Flutter mobile, Go API, Astro website.

## Setup
- Install all: `make setup`
- Local Postgres + Redis: `make docker-up`
- Run server: `make server-dev`
- Run mobile: `make mobile-run`
- Run web: `make web-dev`

## Global rules
- Never write code comments. No single-line, no multi-line, no doc comments. Zero tolerance. Exception: goose migration directives (`-- +goose Up/Down`) are required by the migration tool and are allowed.
- Version source of truth: `VERSION` file at root. Run `make version-bump-patch` then `make version-sync`.
- Use Makefile targets for all build/test/lint commands. Do not cd into subprojects manually.
