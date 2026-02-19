# Backend Deploy Runbook

Last updated: 2026-02-19

This runbook describes a production deployment setup consistent with `docs/final_plan.md` (Hetzner VPS + Docker + Caddy).

## Artifacts in this repo

- `deploy/docker-compose.prod.yml`
- `deploy/Caddyfile`
- `deploy/.env.example`
- `.github/workflows/server-image.yml`
- `.github/workflows/server-deploy.yml`

## One-time VPS setup

1. Install Docker and Docker Compose plugin.
2. Create a deployment directory (example: `/opt/clearbreath`).
3. Create `/opt/clearbreath/.env` from `deploy/.env.example` and fill all required values.
4. Ensure `API_HOST` DNS points to the VPS public IP.

## Deploy (GitHub Actions)

1. Ensure these GitHub Actions secrets exist:
   - `DEPLOY_HOST`
   - `DEPLOY_USER`
   - `DEPLOY_SSH_KEY`
   - `DEPLOY_PATH`
   - `GHCR_USERNAME`
   - `GHCR_TOKEN`
2. Push to `main` to publish images via `server-image.yml`.
3. Run `server-deploy.yml` with `image_tag=sha-<git sha>` or `latest`.

## Deploy (manual)

1. Copy `deploy/docker-compose.prod.yml` and `deploy/Caddyfile` to the VPS deploy directory.
2. Place a filled `.env` file in the same directory.
3. Log in to GHCR (only required for private images):

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
```

4. Start/update:

```bash
API_IMAGE="ghcr.io/<owner>/<repo>/api:latest" docker compose -f docker-compose.prod.yml up -d --pull always
```

## Post-deploy verification

- Verify health endpoints:
  - `GET /health`
  - `GET /ready`
- Verify a full auth + session + stats flow using `docs/backend_curl_smoke.md`.

## Rollback

Re-run the deploy using a previous image tag:

```bash
API_IMAGE="ghcr.io/<owner>/<repo>/api:sha-<previous sha>" docker compose -f docker-compose.prod.yml up -d --pull always
```

## Migrations

Migrations live in `server/migrations/` and are applied locally in development.

For production, run migrations as an explicit step using goose (recommended) before starting the new API image:

```bash
DATABASE_URL="postgres://..." goose -dir server/migrations postgres "$DATABASE_URL" up
```

