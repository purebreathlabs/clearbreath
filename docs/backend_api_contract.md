# ClearBreath Backend API Contract (v1)

Last updated: 2026-02-22

## Conventions

- Base path: `/v1`
- JSON requests:
  - Body must be JSON.
  - Unknown fields are rejected.
  - Trailing JSON is rejected.
- JSON responses:
  - Successful responses are JSON (except `204 No Content`).
  - Response header `X-Request-ID` is set for all requests.

### Error envelope

Errors use:

```json
{ "error": "message", "code": "validation", "request_id": "..." }
```

### Authentication

- Access token is sent as `Authorization: Bearer <access_token>`.
- Authenticated endpoints return `401` with `code="unauthorized"` when the token is missing/invalid.

### Rate limiting

- `429` returns `code="rate_limited"`.
- Policies are Redis-backed fixed-window counters and are configured via env vars.

## Canonical IDs (mobile integration)

### Technique IDs

From `server/registry/techniques.json`:

- `hrv_resonance`
- `ultra_slow`
- `box`
- `four_seven_eight`
- `anulom_vilom`
- `ujjayi`
- `bhramari`
- `kapalbhati`
- `bhastrika`

Planned additions (not in the registry yet):

- `diaphragmatic`
- `yogic_three_part`

### Preset IDs

Per technique:

- `beginner`
- `intermediate`
- `advanced`

## Endpoints

### POST `/v1/auth/provider_sign_in`

Purpose:

- Provider sign-in (Apple/Google) and dev auth (for local/integration testing).

Auth:

- Not required.

Rate limit:

- Per-IP per minute: `RATE_LIMIT_AUTH_BURST_PER_MIN`
- Per-IP per hour: `RATE_LIMIT_AUTH_PER_HOUR`

Request body:

```json
{
  "provider": "dev",
  "id_token": "user1",
  "device_id": "device1"
}
```

Notes:

- `device_id` is required and must be <= 200 chars.
- `provider="dev"` requires header `X-Dev-Auth: <DEV_AUTH_SECRET>` when `DEV_AUTH_ENABLED=true`.

Response `200`:

```json
{
  "access_token": "…",
  "access_token_expires_at_utc": "2026-02-18T12:00:00Z",
  "refresh_token": "…",
  "refresh_token_expires_at_utc": "2026-03-20T12:00:00Z",
  "user": {
    "id": "…",
    "display_name": "Breather123456",
    "avatar_seed": "…",
    "leaderboard_opt_in": true,
    "leaderboard_initials_only": false,
    "created_at_utc": "2026-02-18T12:00:00Z",
    "timezone_offset_minutes_latest": 0
  }
}
```

Errors:

- `400 validation` (missing/invalid fields, unsupported provider)
- `401 unauthorized` (dev auth disabled/secret invalid)
- `401 invalid_provider_token` (google/apple token invalid)
- `500 provider_not_configured` (google/apple not configured)
- `500 internal`

### POST `/v1/auth/refresh`

Purpose:

- Rotate refresh token and issue a new access token.

Auth:

- Not required (refresh token acts as credential).

Rate limit:

- Per-IP per minute: `RATE_LIMIT_AUTH_BURST_PER_MIN`
- Per-IP per hour: `RATE_LIMIT_AUTH_PER_HOUR`

Request body:

```json
{ "refresh_token": "…", "device_id": "device1" }
```

Response `200`:

- Same shape as `provider_sign_in` response.

Errors:

- `400 validation` (missing/invalid fields)
- `401 unauthorized` (invalid refresh token, device mismatch, expired token, revoked token, deleted account)
- `409 refresh_replay` (refresh token replay detected)
- `500 internal`

### POST `/v1/auth/logout`

Purpose:

- Revoke refresh tokens for a device.

Auth:

- Required.

Request body:

```json
{ "device_id": "device1" }
```

Response `204`:

- No content.

Errors:

- `400 validation`
- `401 unauthorized`
- `500 internal`

### GET `/v1/me`

Purpose:

- Fetch the authenticated user profile and preferences.

Auth:

- Required.

Response `200`:

```json
{
  "id": "…",
  "display_name": "Breather123456",
  "avatar_seed": "…",
  "leaderboard_opt_in": true,
  "leaderboard_initials_only": false,
  "created_at_utc": "2026-02-18T12:00:00Z",
  "timezone_offset_minutes_latest": 0
}
```

Errors:

- `401 unauthorized`
- `500 internal`

### PATCH `/v1/me`

Purpose:

- Update display name and leaderboard privacy preferences.

Auth:

- Required.

Request body (all fields optional):

```json
{
  "display_name": "Alice",
  "leaderboard_opt_in": true,
  "leaderboard_initials_only": false
}
```

Rules:

- `display_name` must be 3–20 chars and only letters/numbers/spaces.
- Profanity is rejected (`400 validation`).
- If `leaderboard_opt_in=false`, `leaderboard_initials_only` is forced to `false`.

Response `200`:

- Same shape as `GET /v1/me`.

Errors:

- `400 validation`
- `401 unauthorized`
- `500 internal`

### DELETE `/v1/me`

Purpose:

- Delete the user account and all server-side data.

Auth:

- Required.

Response `204`:

- No content.

Errors:

- `401 unauthorized`
- `500 internal`

### GET `/v1/me/safety_acknowledgements`

Purpose:

- Fetch the set of technique warning acceptances for cross-device sync.

Auth:

- Required.

Response `200`:

```json
{ "technique_ids": ["kapalbhati", "bhastrika"] }
```

Errors:

- `401 unauthorized`
- `500 internal`

### POST `/v1/me/safety_acknowledgements`

Purpose:

- Add one or more technique warning acceptances (idempotent).

Auth:

- Required.

Request body:

```json
{ "technique_ids": ["kapalbhati"] }
```

Notes:

- `technique_ids` is required and must be <= 50 items.
- All IDs must be valid canonical technique ids.
- Duplicate IDs and previously accepted IDs are ignored.

Response `200`:

- Same shape as `GET /v1/me/safety_acknowledgements`.

Errors:

- `400 validation`
- `401 unauthorized`
- `500 internal`

### POST `/v1/sessions/submit`

Purpose:

- Submit one or more completed sessions.

Auth:

- Required.

Rate limit:

- Per-user per 24h: `RATE_LIMIT_SESSION_WRITES_PER_DAY`

Request body:

```json
{
  "sessions": [
    {
      "client_session_id": "3b9c6e7a-77f2-4b4c-8d7e-3e4a2c4f5a11",
      "technique_id": "hrv_resonance",
      "preset_id": "beginner",
      "started_at_utc": "2026-02-18T11:50:00Z",
      "ended_at_utc": "2026-02-18T11:55:00Z",
      "timezone_offset_minutes": 0,
      "breaths_completed_estimated": 30,
      "ended_early": false,
      "duration_seconds_actual": 300
    }
  ]
}
```

Notes:

- `duration_seconds_actual` is accepted but the server computes the canonical duration from timestamps.
- `client_session_id` is the idempotency key. Duplicate submissions are treated as no-ops.
- `local_day` is computed as the local date of `started_at_utc + timezone_offset_minutes`.

Response `200`:

```json
{
  "accepted_count": 1,
  "duplicate_count": 0,
  "rejected": [],
  "stats_snapshot": {
    "current_streak_days": 1,
    "longest_streak_days": 1,
    "minutes_this_week": 5,
    "minutes_all_time": 5,
    "sessions_all_time": 1,
    "minutes_by_technique": { "hrv_resonance": 5 },
    "updated_at_utc": "2026-02-18T12:00:00Z"
  }
}
```

Per-session rejection:

- Invalid sessions are returned in `rejected` with `code` and `message`, while valid sessions may still be accepted.

Errors:

- `400 validation` (missing sessions array, invalid body)
- `401 unauthorized`
- `413 payload_too_large` (more than 200 sessions)
- `429 rate_limited`
- `500 internal`

### POST `/v1/sessions/sync`

Purpose:

- Bulk sync sessions (guest-to-account merge).

Auth:

- Required.

Rate limit:

- Per-user per 24h: `RATE_LIMIT_SESSION_WRITES_PER_DAY`

Request/response:

- Same shape as `/v1/sessions/submit`.

Errors:

- Same as `/v1/sessions/submit`, with `413 payload_too_large` when more than 500 sessions.

### GET `/v1/stats/snapshot`

Purpose:

- Fetch authoritative stats snapshot.

Auth:

- Required.

Response `200`:

- Same shape as `stats_snapshot` in session ingest responses.

Errors:

- `401 unauthorized`
- `500 internal`

### GET `/v1/leaderboard`

Purpose:

- Fetch top leaderboard rows for a given ranking view.

Auth:

- Not required.

Rate limit:

- Per-IP per minute: `RATE_LIMIT_LEADERBOARD_READS_PER_MIN`

Query params:

- `ranking` (required): `streak` | `weekly` | `all_time`
- `limit` (optional, max 50): integer

Response `200`:

```json
{
  "ranking": "weekly",
  "generated_at_utc": "2026-02-18T12:00:00Z",
  "top": [
    {
      "rank": 1,
      "display_name_or_initials": "AB",
      "avatar_seed": "…",
      "metric_value": 120,
      "user_id": "…"
    }
  ]
}
```

Errors:

- `400 validation` (missing/invalid ranking)
- `429 rate_limited`
- `500 internal`

### GET `/v1/leaderboard/self`

Purpose:

- Fetch the authenticated user rank for a given ranking view.

Auth:

- Required.

Rate limit:

- Per-IP per minute: `RATE_LIMIT_LEADERBOARD_READS_PER_MIN`

Query params:

- `ranking` (required): `streak` | `weekly` | `all_time`

Response `200`:

```json
{
  "ranking": "weekly",
  "user": { "rank": 42, "metric_value": 12 }
}
```

Notes:

- If the user is not present in the current cached dataset, `rank` is `null` and `metric_value` may be `0`.

Errors:

- `400 validation` (missing/invalid ranking)
- `401 unauthorized`
- `429 rate_limited`
- `500 internal`
