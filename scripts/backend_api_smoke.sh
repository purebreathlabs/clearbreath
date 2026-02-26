#!/usr/bin/env bash
set -euo pipefail

BASE="${API_BASE:-http://localhost:8080}"
DEV_SECRET="${DEV_AUTH_SECRET:-dev_secret_change_me}"
PASS=0
FAIL=0

ok()   { PASS=$((PASS+1)); printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { FAIL=$((FAIL+1)); printf "  \033[31mFAIL\033[0m %s\n" "$1"; }

assert_status() {
  local label="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then ok "$label (HTTP $expected)"; else fail "$label (expected $expected, got $actual)"; fi
}

assert_field() {
  local label="$1" json="$2" field="$3"
  if echo "$json" | jq -e "$field" >/dev/null 2>&1; then ok "$label"; else fail "$label"; fi
}

assert_no_field() {
  local label="$1" json="$2" field="$3"
  if echo "$json" | jq -e "$field" >/dev/null 2>&1; then fail "$label (field exists)"; else ok "$label"; fi
}

printf "\n=== ClearBreath API smoke test ===\n\n"

printf "1. Sign in user A\n"
RESP_A=$(curl -sS -w '\n%{http_code}' -X POST "$BASE/v1/auth/provider_sign_in" \
  -H 'Content-Type: application/json' \
  -H "X-Dev-Auth: $DEV_SECRET" \
  -d '{"provider":"dev","id_token":"smoke_user_a","device_id":"smoke_dev_a","email":"smokeuser@example.com"}')
HTTP_A=$(echo "$RESP_A" | tail -1)
BODY_A=$(echo "$RESP_A" | sed '$d')
assert_status "sign-in user A" "200" "$HTTP_A"
ACCESS_A=$(echo "$BODY_A" | jq -r .access_token)
assert_field "user.username exists" "$BODY_A" '.user.username'
assert_field "user.name exists" "$BODY_A" '.user | has("name")'
assert_no_field "no display_name" "$BODY_A" '.user.display_name'

printf "\n2. GET /v1/me\n"
RESP_ME=$(curl -sS -w '\n%{http_code}' "$BASE/v1/me" -H "Authorization: Bearer $ACCESS_A")
HTTP_ME=$(echo "$RESP_ME" | tail -1)
BODY_ME=$(echo "$RESP_ME" | sed '$d')
assert_status "GET /v1/me" "200" "$HTTP_ME"
assert_field "username field" "$BODY_ME" '.username'
assert_field "name field" "$BODY_ME" 'has("name")'
assert_field "leaderboard_opt_in" "$BODY_ME" 'has("leaderboard_opt_in")'
assert_no_field "no display_name" "$BODY_ME" '.display_name'

printf "\n3. PATCH username to alice_smoke\n"
RESP_PATCH=$(curl -sS -w '\n%{http_code}' -X PATCH "$BASE/v1/me" \
  -H "Authorization: Bearer $ACCESS_A" \
  -H 'Content-Type: application/json' \
  -d '{"username":"alice_smoke"}')
HTTP_PATCH=$(echo "$RESP_PATCH" | tail -1)
BODY_PATCH=$(echo "$RESP_PATCH" | sed '$d')
assert_status "PATCH username" "200" "$HTTP_PATCH"
UNAME=$(echo "$BODY_PATCH" | jq -r .username)
if [ "$UNAME" = "alice_smoke" ]; then ok "username updated"; else fail "username not updated (got $UNAME)"; fi

printf "\n4. PATCH invalid username (too short)\n"
RESP_SHORT=$(curl -sS -w '\n%{http_code}' -X PATCH "$BASE/v1/me" \
  -H "Authorization: Bearer $ACCESS_A" \
  -H 'Content-Type: application/json' \
  -d '{"username":"ab"}')
HTTP_SHORT=$(echo "$RESP_SHORT" | tail -1)
assert_status "short username rejected" "400" "$HTTP_SHORT"

printf "\n5. PATCH invalid username (special chars)\n"
RESP_SPECIAL=$(curl -sS -w '\n%{http_code}' -X PATCH "$BASE/v1/me" \
  -H "Authorization: Bearer $ACCESS_A" \
  -H 'Content-Type: application/json' \
  -d '{"username":"a!b"}')
HTTP_SPECIAL=$(echo "$RESP_SPECIAL" | tail -1)
assert_status "special chars rejected" "400" "$HTTP_SPECIAL"

printf "\n6. Sign in user B + duplicate username\n"
RESP_B=$(curl -sS -w '\n%{http_code}' -X POST "$BASE/v1/auth/provider_sign_in" \
  -H 'Content-Type: application/json' \
  -H "X-Dev-Auth: $DEV_SECRET" \
  -d '{"provider":"dev","id_token":"smoke_user_b","device_id":"smoke_dev_b"}')
HTTP_B=$(echo "$RESP_B" | tail -1)
BODY_B=$(echo "$RESP_B" | sed '$d')
assert_status "sign-in user B" "200" "$HTTP_B"
ACCESS_B=$(echo "$BODY_B" | jq -r .access_token)

RESP_DUP=$(curl -sS -w '\n%{http_code}' -X PATCH "$BASE/v1/me" \
  -H "Authorization: Bearer $ACCESS_B" \
  -H 'Content-Type: application/json' \
  -d '{"username":"alice_smoke"}')
HTTP_DUP=$(echo "$RESP_DUP" | tail -1)
BODY_DUP=$(echo "$RESP_DUP" | sed '$d')
assert_status "duplicate username" "409" "$HTTP_DUP"
DUP_CODE=$(echo "$BODY_DUP" | jq -r .code)
if [ "$DUP_CODE" = "username_taken" ]; then ok "code=username_taken"; else fail "expected code=username_taken, got $DUP_CODE"; fi

printf "\n7. Submit session for user A\n"
START=$(python3 -c 'import datetime; print((datetime.datetime.now(datetime.timezone.utc)-datetime.timedelta(minutes=10)).replace(microsecond=0).isoformat().replace("+00:00","Z"))')
END=$(python3 -c 'import datetime; print((datetime.datetime.now(datetime.timezone.utc)-datetime.timedelta(minutes=5)).replace(microsecond=0).isoformat().replace("+00:00","Z"))')
RESP_SESS=$(curl -sS -w '\n%{http_code}' -X POST "$BASE/v1/sessions/submit" \
  -H "Authorization: Bearer $ACCESS_A" \
  -H 'Content-Type: application/json' \
  -d "{\"sessions\":[{\"client_session_id\":\"aaaaaaaa-bbbb-cccc-dddd-eeeeeeee0001\",\"technique_id\":\"hrv_resonance\",\"preset_id\":\"beginner\",\"started_at_utc\":\"$START\",\"ended_at_utc\":\"$END\",\"timezone_offset_minutes\":0,\"breaths_completed_estimated\":30,\"ended_early\":false}]}")
HTTP_SESS=$(echo "$RESP_SESS" | tail -1)
BODY_SESS=$(echo "$RESP_SESS" | sed '$d')
assert_status "submit session" "200" "$HTTP_SESS"
ACCEPTED=$(echo "$BODY_SESS" | jq -r .accepted_count)
if [ "$ACCEPTED" -ge 0 ]; then ok "session accepted (count=$ACCEPTED)"; else fail "bad accepted_count"; fi

printf "\n8. GET /v1/leaderboard\n"
RESP_LB=$(curl -sS -w '\n%{http_code}' "$BASE/v1/leaderboard?ranking=xp&limit=10")
HTTP_LB=$(echo "$RESP_LB" | tail -1)
BODY_LB=$(echo "$RESP_LB" | sed '$d')
assert_status "GET leaderboard" "200" "$HTTP_LB"
assert_field "top array exists" "$BODY_LB" '.top'
assert_no_field "no display_name_or_initials" "$BODY_LB" '.top[0].display_name_or_initials'

printf "\n9. GET /v1/leaderboard/self\n"
RESP_LS=$(curl -sS -w '\n%{http_code}' "$BASE/v1/leaderboard/self?ranking=xp" -H "Authorization: Bearer $ACCESS_A")
HTTP_LS=$(echo "$RESP_LS" | tail -1)
assert_status "GET leaderboard/self" "200" "$HTTP_LS"

printf "\n=== Results: %d passed, %d failed ===\n\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
