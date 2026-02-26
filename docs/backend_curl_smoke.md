# Backend Manual Smoke (curl)

Last updated: 2026-02-26

## Prerequisites

1. Start Postgres + Redis:

```bash
make docker-up
```

2. Run the API:

```bash
make server-dev
```

Server listens on `http://localhost:8080`.

## Health

```bash
curl -sS -i http://localhost:8080/health
curl -sS -i http://localhost:8080/ready
```

## Auth (dev provider)

```bash
SIGN_IN_JSON='{"provider":"dev","id_token":"curl_user","device_id":"curl_device"}'
RESP=$(curl -sS -X POST http://localhost:8080/v1/auth/provider_sign_in -H 'Content-Type: application/json' -H 'X-Dev-Auth: dev_secret_change_me' -d "$SIGN_IN_JSON")
ACCESS=$(echo "$RESP" | jq -r .access_token)
REFRESH=$(echo "$RESP" | jq -r .refresh_token)
```

Refresh rotation:

```bash
REFRESH_JSON=$(jq -n --arg rt "$REFRESH" '{refresh_token:$rt,device_id:"curl_device"}')
RESP2=$(curl -sS -X POST http://localhost:8080/v1/auth/refresh -H 'Content-Type: application/json' -d "$REFRESH_JSON")
ACCESS2=$(echo "$RESP2" | jq -r .access_token)
REFRESH2=$(echo "$RESP2" | jq -r .refresh_token)
```

Logout:

```bash
curl -sS -i -X POST http://localhost:8080/v1/auth/logout -H "Authorization: Bearer $ACCESS2" -H 'Content-Type: application/json' -d '{"device_id":"curl_device"}'
```

## Profile (`/v1/me`)

```bash
curl -sS -i http://localhost:8080/v1/me -H "Authorization: Bearer $ACCESS2"
curl -sS -i -X PATCH http://localhost:8080/v1/me -H "Authorization: Bearer $ACCESS2" -H 'Content-Type: application/json' -d '{"display_name":"Alice 123"}'
```

## Safety acknowledgements

```bash
curl -sS -i http://localhost:8080/v1/me/safety_acknowledgements -H "Authorization: Bearer $ACCESS2"
curl -sS -i -X POST http://localhost:8080/v1/me/safety_acknowledgements -H "Authorization: Bearer $ACCESS2" -H 'Content-Type: application/json' -d '{"technique_ids":["kapalbhati"]}'
```

## Sessions

Submit:

```bash
START=$(python3 -c 'import datetime; print((datetime.datetime.now(datetime.timezone.utc)-datetime.timedelta(minutes=10)).replace(microsecond=0).isoformat().replace("+00:00","Z"))')
END=$(python3 -c 'import datetime; print((datetime.datetime.now(datetime.timezone.utc)-datetime.timedelta(minutes=5)).replace(microsecond=0).isoformat().replace("+00:00","Z"))')
curl -sS -i -X POST http://localhost:8080/v1/sessions/submit -H "Authorization: Bearer $ACCESS2" -H 'Content-Type: application/json' -d "{\"sessions\":[{\"client_session_id\":\"11111111-1111-1111-1111-111111111111\",\"technique_id\":\"hrv_resonance\",\"preset_id\":\"beginner\",\"started_at_utc\":\"$START\",\"ended_at_utc\":\"$END\",\"timezone_offset_minutes\":0,\"breaths_completed_estimated\":30,\"ended_early\":false}]}"
```

Sync:

```bash
curl -sS -i -X POST http://localhost:8080/v1/sessions/sync -H "Authorization: Bearer $ACCESS2" -H 'Content-Type: application/json' -d "{\"sessions\":[{\"client_session_id\":\"22222222-2222-2222-2222-222222222222\",\"technique_id\":\"hrv_resonance\",\"preset_id\":\"beginner\",\"started_at_utc\":\"$START\",\"ended_at_utc\":\"$END\",\"timezone_offset_minutes\":0,\"breaths_completed_estimated\":30,\"ended_early\":false}]}"
```

Stats (includes total_xp and current_level):

```bash
curl -sS -i http://localhost:8080/v1/stats/snapshot -H "Authorization: Bearer $ACCESS2"
```

## Daily Open (XP login bonus)

```bash
curl -sS -i -X POST http://localhost:8080/v1/me/daily-open -H "Authorization: Bearer $ACCESS2" -H 'Content-Type: application/json' -d '{"timezone_offset_minutes":0}'
```

## XP History

```bash
curl -sS -i 'http://localhost:8080/v1/xp/history?days=7&timezone_offset_minutes=0' -H "Authorization: Bearer $ACCESS2"
```

## Leaderboard

```bash
curl -sS -i 'http://localhost:8080/v1/leaderboard?ranking=xp&limit=10'
curl -sS -i 'http://localhost:8080/v1/leaderboard/self?ranking=xp' -H "Authorization: Bearer $ACCESS2"
```
