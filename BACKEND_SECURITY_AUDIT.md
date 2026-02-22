# Backend Security Audit

Last updated: 2026-02-22

## Auth

- Access tokens are HS256 JWTs with minimum secret length enforced in config.
- Refresh tokens are random and stored as HMAC-SHA256 hashes in Postgres.
- Refresh tokens rotate on refresh; replaced tokens return `409 refresh_replay`.
- Logout revokes device refresh tokens; revoked tokens return `401 unauthorized`.

## Input validation

- JSON decoding rejects unknown fields and trailing JSON.
- `display_name` canonicalization restricts allowed characters and length, with profanity filtering.
- Session ingest validates timestamps, timezone offset bounds, duration plausibility by preset, and breaths plausibility.

## Rate limiting

- Auth endpoints are rate-limited per IP (burst/min + per hour).
- Session writes are rate-limited per user per 24h.
- Leaderboard reads are rate-limited per IP per minute.
- IP extraction hardening: forwarded headers are trusted only when the immediate peer IP is private/loopback; forwarded list uses the last valid IP.

## CORS

- Origin allowlist is enforced and configured via `CORS_ORIGINS`.

## Error handling

- Errors use a consistent JSON envelope and include a `request_id`.
- Panic recovery returns the same envelope with `code="internal"`.

## Data deletion

- `DELETE /v1/me` soft-deletes the user and deletes identities, refresh tokens, sessions, and stats snapshots.
- `DELETE /v1/me` also deletes safety acknowledgements (`safety_acknowledgements`) for cross-device warning acceptance.

## Notes

- The `dev` auth provider is intended for development/integration only and is protected by `DEV_AUTH_SECRET`.
- Safety warning acceptance sync endpoints are authenticated and scoped to the current user:
  - `GET /v1/me/safety_acknowledgements`
  - `POST /v1/me/safety_acknowledgements`
