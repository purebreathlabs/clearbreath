# ClearBreath v1 PRD and Execution Plan

## 1. Document Metadata

- Product: ClearBreath
- Domain: clearbreath.life
- Tagline: Breathe with intention.
- Date: February 11, 2026
- Target launch window: App store review submission by March 31, 2026, public launch in April 2026
- Platforms: iOS and Android (Flutter), supporting website (Astro)
- Primary stack: Flutter (Riverpod, go_router, Drift), Go (Chi, PostgreSQL, Redis)
- Audience for this document: Junior developers, contributors, and implementation owners

## 1.1 Changelog

- 2026-02-26: Pace and duration unlocks now use `practice_days_all_time` (habit-based) instead of XP level thresholds to prevent same-day grinding and align 5-minute unlock with ~7–15 days of use. Updated sections: 4.4, 4.5, 8.1 note, 9.2, 17.3.

## 2. Executive Summary

ClearBreath v1 is a guest-first, dark-mode breathing app focused on simplicity and consistency. The core experience is a one-tap breathing session with clear visual pacing, three phase-specific soft chime cues (inhale, hold, exhale), optional haptics, background playback support, and strong streak-based motivation.

The MVP includes:
- Complete breathing journey from splash to onboarding to daily sessions
- Full technique library (9 techniques at launch; 2 planned additions)
- Offline-first session tracking and local stats
- 2-minute daily streak system
- Optional account system for cloud backup and leaderboard participation
- Global leaderboard with privacy controls and anti-cheat baseline
- Landing website, legal pages, and 10 SEO pages

The MVP excludes monetization and advanced social/community complexity to maximize launch quality and speed.

## 3. Product Goals and Constraints

### 3.1 Goals

- Enable any user to start a session in less than 10 seconds after onboarding.
- Keep UX simple enough for ages 12-80 with high readability and large tap targets.
- Build a daily habit loop through streaks and clear progress visibility.
- Keep the app fully useful without login.
- Ship production-grade engineering quality with module-level testing.

### 3.2 Business Goal

- Reach 1000 monthly active users by December 2026.

### 3.3 Delivery Constraint

- Store-submitted release candidate by March 31, 2026.
- April 2026 launch readiness, including app, backend, and website.

### 3.4 Non-Goals in v1

- Paid plans, ads, subscriptions, or donations
- Voice-guided coaching
- Wearables and widgets
- Community-generated recommendations
- Custom breath pattern builder

## 4. Confirmed Product Decisions (Locked)

### 4.1 UX and Navigation

- Four bottom tabs: Home, Techniques, Leaderboard, Profile
- Leaderboard tab visible but locked for guests
- Stats and Settings live inside Profile

### 4.2 Visual Direction

- Strict black background and white text/lines only
- Single brand typeface: Manrope
- Splash screen with subtle scale-in logo animation

### 4.3 Core Breathing Guidance

- Slow techniques use expanding/contracting circle animation
- Rapid techniques use pulsing metronome-style visual
- Distinct phase sounds for inhale, hold, exhale
- Beeps play once at phase start
- In-session sound controls: volume slider and mute
- Haptics enabled by default, user configurable

### 4.4 Onboarding

- Exactly 5 questions (updated from 7: experience level and session length removed — now auto-managed by practice days)
- One question per screen
- Notification permission request is deferred until after first completed session

### 4.5 Streak, Stats, and XP Gamification

- Daily streak requires at least 2 minutes of total practice on a day
- Partial sessions still count toward total minutes and can qualify streak
- Week starts Monday (user-local timezone)
- Practice days: `practice_days_all_time` is the count of user-local days with at least 2 minutes of total practice (used for pace and duration unlocks)
- XP system: 10 XP per full minute of practice, 50% penalty for ended-early sessions
- Streak multiplier: min(1.0 + 0.1 * streak_days, 3.0) applied per session using streak_days at that session’s local_day (non-qualifying local_day uses the previous day’s streak)
- Daily practice XP cap: 300 XP/day (login bonus of 5 XP excluded from cap)
- Level curve: xp_required(L) = floor(10 * (2 + 0.05*L + 0.0001*L^2)), levels 0-999
- Pace auto-progression (by practice days): D0-14 beginner, D15-49 intermediate, D50+ advanced
- Duration unlocks (by practice days): D0-6=2min, D7-29=5min, D30-59=10min, D60-99=15min, D100+=20min
- XP stored in dedicated tables (user_progress, xp_events) with curve_version for future recompute

### 4.6 Accounts and Leaderboard

- Guest mode supports full breathing and local stats
- Account required only for leaderboard and cloud backup
- Providers: Apple and Google
- Leaderboard visibility default ON (opt-out available)

### 4.7 Leaderboard Rules

- Single view: Total XP (replaced streak/weekly/all-time views — XP is the unified progression metric)
- Top 50 visible
- User rank pinned even outside top 50
- Refresh every 5 minutes
- Profanity filter required on display names
- Silent shadow-ban available for suspicious behavior
- Daily practice XP cap of 300 XP/day (login bonus excluded)
- API backward compatibility: old ranking params (streak/weekly/all_time) silently map to xp; response shape changed (total_xp + level instead of metric_value)
- DB idempotency: unique partial indexes prevent double-awarding (daily_open per user/day, session XP per session_id)
- Timestamp validation: sessions rejected if started_at_utc > 24h in the future or > 90 days in the past
- local_day computed server-side from started_at_utc + timezone_offset_minutes (offset validated -840 to +840)

### 4.8 Backend and Infra

- Go API with Chi
- PostgreSQL on Neon
- Redis on Upstash
- Migration tool: goose
- CI deploy to Hetzner VPS with Docker and Caddy

### 4.9 Website Scope

- Landing page
- Privacy page
- Terms page
- 10 SEO pages
- Primary CTA: Download app

### 4.10 Analytics and Monitoring

- Minimal anonymous analytics with opt-out toggle
- No crash/error tracking in v1 (accepted risk)

## 5. Personas and Outcomes

### 5.1 Beginner

- Needs clear daily recommendation and simple instructions
- Measures success by consistency and calmness

### 5.2 Intermediate Practitioner

- Needs trusted technique variety and guidance quality
- Measures success by regular practice and stronger control

### 5.3 Advanced User

- Needs ultra-slow and forceful technique support with safety guidance
- Measures success by depth and precision

## 6. End-to-End User Journeys

### 6.1 First-Time Guest Journey

1. Splash with scale-in logo
2. Five-question onboarding (goals, practice window, haptics, reminder, display name)
3. Home opens with Today’s Practice card
4. User taps Start and begins session in one tap
5. Session completes and updates local stats/streak
6. Notification permission requested only after first completed session

### 6.2 Daily Returning Guest Journey

1. Open app to Home
2. See recommendation based on goal and time of day
3. Start from recommendation, shortcut, or favorites
4. Complete session
5. Review summary and updated streak

### 6.3 Guest to Signed-In Journey

1. User taps locked Leaderboard or sees post-session prompt (after 3 guest sessions)
2. Continue with Apple or Google sign-in
3. Merge local history into cloud account
4. Leaderboard visibility is on by default; user can opt out from Profile settings

### 6.4 Signed-In Leaderboard Journey

1. Open Leaderboard tab
2. View XP-ranked leaderboard with level display
3. View top list and pinned self rank
4. Manage visibility and initials-only mode from Profile settings

## 7. Information Architecture and Screen Inventory

### 7.1 Mobile Screens

- Splash screen
- Onboarding step screens (5)
- Home screen
- Techniques grid
- Technique detail with presets and safety notes
- Pre-session countdown view
- Session active view
- Session completion view
- Profile screen (Stats)
- Settings sections (embedded in Profile)
- Leaderboard screen
- Sign-in gate screen
- Legal screens (Privacy, Terms)

### 7.2 Website Pages

- Home landing page
- Privacy page
- Terms page
- 10 SEO pages for breathing techniques and breathing-for-sleep hub

## 8. Onboarding Requirements

## 8.1 Questions (Fixed Order)

1. Primary goal (Calm, Sleep, Focus, Energy, HRV, Spiritual)
2. Typical practice window (Morning/Afternoon/Evening/Varies)
3. Haptics preference (On/Off)
4. Daily reminder preferred time
5. Display name

Note: Experience level and session length were removed — both are now auto-managed by practice days (see Section 4.5).

## 8.2 UX Rules

- One question per screen
- Always provide skip/back controls where applicable
- Completion must take less than 2 minutes for average user
- Store answers locally and apply defaults immediately

## 9. Home and Recommendation Rules

## 9.1 Home Structure

- Top: Today’s Practice card with one primary Start button
- Middle: Goal shortcuts row (6 goals)
- Next: Favorites row
- Additional: Current streak display and key summary

## 9.2 Recommendation Logic v1

Inputs:
- Selected goal
- Time-of-day segment (Morning 5-11, Afternoon 11-17, Evening 17-22, Night 22-5)
- Preset ID derived from practice days (beginner/intermediate/advanced via practice_days_all_time)

Outputs:
- Technique id
- Preset id or duration option
- Rationale text (short, friendly)

## 9.3 Goal Switching

- User can switch goal from Home in one to two taps
- Recommendation refreshes immediately

## 10. Technique Library and Safety

## 10.1 Library Presentation

- Card grid layout
- Each card includes technique name, short descriptor, and safety marker if needed
- Favorites action available on cards and detail screen

## 10.2 Technique Detail

Must include:
- What it is
- How to do it
- Wellness phrasing benefits (no medical claims)
- Contraindications and warnings
- Preset options shown as durations/cycles

## 10.3 Safety Gate Rules

- One-time safety warning required before first run of forceful or advanced-risk techniques
- Warnings persisted locally per technique and synced if signed in
- No global mandatory disclaimer acceptance flow

## 10.4 Canonical Technique Set (v1)

1. HRV Resonance Breathing
2. Ultra-Slow Breathing (must support down to 1 BPM)
3. Box Breathing
4. 4-7-8 Breathing
5. Anulom Vilom (with visual left/right guidance)
6. Ujjayi
7. Bhramari
8. Kapalbhati (rapid)
9. Bhastrika (rapid)

Planned additions (post-v1): Diaphragmatic (Belly) Breathing, Three-Part Breath (Dirga)

## 11. Session Engine Requirements

## 11.1 Session Lifecycle

- Pre-session countdown (3-2-1)
- Active phase progression loop
- Pause/resume
- End early
- Completion summary

## 11.2 Visual Guidance

- Slow patterns: breathing circle
- Rapid patterns: metronome pulse visual
- Visible phase labels and timer info

## 11.3 Audio Guidance

- Three phase-specific soft chimes
- Phase-start cues only
- Rapid techniques use metronome ticks as pacing support
- Volume slider and mute toggle in session

## 11.4 Haptic Guidance

- Phase transition haptics (subtle)
- Toggle in settings
- Respect onboarding preference default

## 11.5 Background Behavior

- Session continues when app goes background
- Session continues when phone locks
- Lock-screen controls expose pause and stop
- Audio interruptions auto-pause session and show interruption state upon return

## 11.6 Keep Awake

- Keep screen awake during active session when enabled
- Default ON
- User setting available in Profile/Settings

## 11.7 Session Completion Screen

Must show:
- Technique and preset information
- Actual practiced minutes
- Estimated breaths completed
- Streak result
- Share streak card CTA

## 12. Stats, Streak, and Sharing

## 12.1 Streak Rules

- Daily streak increments if total practiced time for local day is at least 2 minutes
- Missing a full day resets current streak
- Timezone uses session-local offset

## 12.2 Required Stats

- Total minutes (all-time)
- Total sessions (all-time)
- Current streak
- Longest streak
- Minutes this week
- Minutes by technique
- Longest single session
- Favorite technique
- Estimated breaths completed (session and aggregate)

## 12.3 Weekly Definition

- Week starts Monday
- Computed in user-local timezone

## 12.4 Share Card

- Focus on streak number + ClearBreath branding
- Include simple line such as "2 min today"
- No personal data

## 13. Notifications and Reminder Rules

- Daily reminder at selected time
- Streak warning reminder 2 hours before local midnight if no qualifying session
- Prompt OS notification permission only after first completed session
- User can enable/disable reminders and streak warning independently

## 14. Account, Auth, and Privacy Requirements

## 14.1 Sign-In Policy

- Sign-in is optional
- Sign-in required for leaderboard participation and cloud backup

## 14.2 Providers

- Apple Sign-In
- Google Sign-In

## 14.3 Age Gate

- No age gate in v1.

## 14.4 Identity Defaults

- Random generated display handle by default
- Generated avatar from seed
- Display name rules: 3-20 chars, letters/numbers/space, profanity filtered

## 14.5 Account Controls

- Rename display name
- Delete account and server data
- Leaderboard visibility toggle and initials-only preference

## 14.6 Analytics Privacy

- Minimal anonymous analytics only
- Opt-out toggle in Settings > Privacy
- No ads tracking

## 15. Leaderboard Product and Anti-Cheat Requirements

## 15.1 Leaderboard Access

- Tab visible for all users
- Guests see locked entry with sign-in gate

## 15.2 Leaderboard View

- Single view: Total XP (ranked by total_xp; level computed from XP via levelFromTotalXP)
- Each row displays: rank, display name, avatar, level, total XP

## 15.3 Display Rules

- Top 50 list
- Pinned self rank always shown
- Display name or initials based on user preference

## 15.4 Refresh Strategy

- Update every 5 minutes server-side

## 15.5 Integrity Rules

- Validate session plausibility against preset bounds
- Apply daily practice XP cap (300 XP/day)
- Streak calculation independent from XP cap
- Silent shadow-ban support for suspicious patterns

## 15.6 Moderation Baseline

- Profanity filter on display names
- No report workflow in v1

## 16. Technical Architecture (Mobile)

## 16.1 Mobile Layers

- Presentation: Screens, widgets, navigation, theming
- Domain: Session engine, recommendation rules, streak logic
- Data: Drift local storage, repositories, API client sync queue
- Infrastructure: Audio, haptics, notifications, keep awake, auth tokens

## 16.2 State Management

- Riverpod for app state and dependency wiring
- Feature-scoped providers for session, user, settings, stats, leaderboard

## 16.3 Navigation

- go_router with route guards for locked flows
- Guest vs signed-in state handled at routing layer

## 16.4 Local Database

- Drift for sessions, settings, favorite techniques, streak cache, sync queue
- Migration strategy defined per schema change

## 16.5 Reusable Component Plan (Frontend Component-Wise)

Core reusable components:
- Primary action button
- Goal shortcut chip
- Technique card
- Safety warning sheet
- Session phase indicator
- Breathing circle widget
- Rapid pulse/metronome widget
- In-session control strip
- Stats metric tile
- Bar chart widget for weekly minutes
- Leaderboard row with rank and avatar
- Locked feature gate card

Each component must include:
- Props contract
- Usage examples in feature screen
- Widget tests for rendering and interaction

## 16.6 Frontend Module Plan with Task-Local Tests

### Module M1: App Shell, Theme, Typography, and Splash

Scope:
- Black/white theme tokens
- Manrope integration
- Splash animation
- Base app shell and tab scaffold

Tests to implement within module:
- Theme snapshot/widget tests for contrast and typography rendering
- Navigation smoke test for 4-tab shell and locked leaderboard tab state

### Module M2: Onboarding and Initial Preferences

Scope:
- Five-question flow (goals, practice window, haptics, reminder, display name)
- Local persistence of answers
- Apply default preferences immediately

Tests to implement within module:
- Widget tests validating question order and completion path
- Unit tests for onboarding state persistence and defaults mapping

### Module M3: Home Recommendations and Favorites

Scope:
- Today’s Practice card
- Goal shortcuts
- Favorites list
- Daypart recommendation rule engine

Tests to implement within module:
- Unit tests for recommendation mapping by daypart and goal
- Widget tests for one-tap start and goal switching refresh

### Module M4: Technique Library and Detail

Scope:
- Card grid listing
- Detail view with about/safety
- Preset selection by duration/cycles
- Favorites actions

Tests to implement within module:
- Widget tests for card grid rendering and detail open behavior
- Unit tests for favorites add/remove persistence

### Module M5: Session Engine Foreground

Scope:
- Countdown
- Phase timing state machine
- Slow/rapid visual mode switching
- Sound and haptics triggers

Tests to implement within module:
- Unit tests for phase scheduler timing correctness and transitions
- Widget tests for phase label changes and control interactions

### Module M6: Session Engine Background and Interruptions

Scope:
- Background continuation
- Lock-screen controls
- Auto-pause on interruption
- Keep-awake behavior

Tests to implement within module:
- Integration tests covering start -> background -> lock -> pause/resume -> complete
- Integration tests for simulated interruption auto-pause state

### Module M7: Completion, Stats, Streak, and Share Card

Scope:
- Completion screen
- Stats aggregation
- Streak updates
- Share card generation

Tests to implement within module:
- Unit tests for streak logic (2-minute threshold and reset)
- Unit tests for weekly and all-time aggregation
- Widget tests for completion summary and share card CTA

### Module M8: Notifications and Preferences

Scope:
- Reminder scheduling
- Streak warning scheduling
- Post-first-session permission prompt

Tests to implement within module:
- Unit tests for schedule time calculations and edge cases
- Widget tests for settings toggles and permission flow triggers

### Module M9: Auth, Age Gate, and Cloud Sync

Scope:
- Birth-year gate
- Apple/Google sign-in UI flow
- Token storage
- Guest-to-account merge

Tests to implement within module:
- Unit tests for age eligibility calculation
- Integration tests for local session merge and dedupe behavior

### Module M10: Leaderboard and Profile Privacy Controls

Scope:
- Locked tab behavior for guest
- Single XP leaderboard view
- Pinned self rank
- Visibility and initials-only preferences

Tests to implement within module:
- Widget tests for locked guest state and sign-in gate
- Unit tests for leaderboard filter state and row rendering rules

## 17. Technical Architecture (Backend Go)

## 17.1 Backend Services and Responsibilities

- Auth service: provider token verification, access/refresh token issuance and rotation
- User service: profile retrieval/update, visibility preferences, delete account
- Session service: ingest sessions, validate, dedupe, aggregate
- Stats service: authoritative snapshot generation
- Leaderboard service: ranking computation and Redis caching

## 17.2 API Contract Behavior Tables

Route naming remains implementation-defined, but behavior is normative.

### Auth contract table

| Capability | Auth requirement | Request field constraints | Response semantics | Idempotency | Rate-limit policy | Error classes |
| --- | --- | --- | --- | --- | --- | --- |
| Provider sign-in (Apple/Google) | No prior JWT required | Must include valid provider identity token and client context metadata; reject malformed or expired provider tokens | Returns access token, refresh token, and normalized user profile state | Not idempotent for token issuance; idempotent for user identity linkage | Strict per-IP limit with short burst (per-minute) + hourly cap. Device ID is client-submitted and not used for rate limiting because it is trivially spoofable. | 400 validation, 401 invalid provider token, 429 rate-limited, 500 internal |
| Refresh access token | Valid refresh token required | Refresh token must be active, unrevoked, unexpired, and bound to user/session policy | Rotates refresh token and returns new access token | Single-use rotation required; replay of old token must fail and return 409 | Per-IP limit with short burst (per-minute) + hourly cap | 400 validation, 401 invalid/expired token, 409 replay detected, 429 rate-limited |
| Logout/revoke | Valid JWT required | Must include device_id to identify token family to revoke | Revokes active refresh tokens for user+device pair | Idempotent | Standard authenticated limits | 400 validation, 401 unauthorized, 429 rate-limited |

### User contract table

| Capability | Auth requirement | Request field constraints | Response semantics | Idempotency | Rate-limit policy | Error classes |
| --- | --- | --- | --- | --- | --- | --- |
| Get profile | JWT required | User scope must match requester unless explicitly allowed by privacy rules | Returns canonical profile and privacy preferences | Idempotent | Standard authenticated read limits | 401 unauthorized, 403 forbidden, 404 not found |
| Update display name | JWT required | 3-20 chars, letters/numbers/space, profanity filter enforced | Returns updated profile snapshot | Idempotent by same value | Standard authenticated write limits | 400 validation, 401 unauthorized, 409 constraint conflict |
| Update leaderboard/privacy flags | JWT required | Boolean flags only; visibility defaults ON, user may opt out | Returns updated visibility/initials settings | Idempotent by same value | Standard authenticated write limits | 400 validation, 401 unauthorized |
| Delete account | JWT required (AuthAllowDeleted — permits already soft-deleted users to complete cleanup) | Valid short-lived JWT serves as high-confidence session proof. Re-auth can be enforced client-side before calling DELETE if desired. | Soft-deletes user, wipes auth identities, refresh tokens, safety acknowledgements, sessions, and stats snapshot | Idempotent | Standard authenticated limits | 401 unauthorized, 204 success |

### Sessions contract table

| Capability | Auth requirement | Request field constraints | Response semantics | Idempotency | Rate-limit policy | Error classes |
| --- | --- | --- | --- | --- | --- | --- |
| Submit completed session(s) | JWT required for server persistence | client_session_id required; technique/preset must exist; duration and timestamps must be plausible; timezone offset required | Returns 200 with per-session breakdown: accepted_count, duplicate_count, rejected[] (with per-session code/message), and refreshed stats_snapshot. Duplicates are silent no-ops. Rejections include validation and plausibility codes. | Idempotent on client_session_id (ON CONFLICT DO NOTHING) | Write limits per user/day (Redis-backed) | 400 validation (empty/oversized batch), 401 unauthorized, 413 payload too large (>200 sessions), 429 rate-limited |
| Bulk sync (guest->account merge) | JWT required | All sessions require client_session_id and required timing fields | Same response shape as submit. Higher batch limit (500). Upserts deduplicated sessions and returns authoritative stats + streak. | Idempotent on client_session_id set (ON CONFLICT DO NOTHING) | Same per-user/day limit, capped at 500 sessions per request | 400 validation, 401 unauthorized, 413 payload too large (>500 sessions), 429 rate-limited |
| Fetch stats snapshot | JWT required | Optional filter params must be bounded and validated | Returns authoritative streak/stats snapshot | Idempotent | Standard authenticated read limits | 400 validation, 401 unauthorized |

### Leaderboard contract table

| Capability | Auth requirement | Request field constraints | Response semantics | Idempotency | Rate-limit policy | Error classes |
| --- | --- | --- | --- | --- | --- | --- |
| Fetch leaderboard list | JWT optional; guest sees locked gate behavior in app | ranking=xp (legacy values silently map to xp); limit max 50 | Returns ordered list by total_xp with computed level, excluding opted-out users | Idempotent | Tight read limits per IP/user to prevent scraping | 400 validation, 429 rate-limited |
| Fetch self-rank snapshot | JWT required | ranking=xp | Returns requester rank, total_xp, and level even when outside top list | Idempotent | Standard authenticated read limits | 400 validation, 401 unauthorized |

### Cross-cutting middleware contract

- CORS: allow only approved app/web origins per environment registry.
- Auth middleware: verifies access token, checks user existence in DB, injects user_id into request context.
- Rate limiting: Redis-backed fixed-window counters. Per-IP for auth and leaderboard reads. Per-user for session writes.
- Strict JSON decoding: unknown fields rejected, trailing data rejected, body size limits enforced per endpoint.
- Structured logging: request_id, method, path, status, duration_ms, user_id (if present). Note: user_id relies on auth middleware enriching the request context; Logger middleware captures it post-response.
- Panic recovery: catches handler panics, returns safe 500 JSON error envelope with request_id.

## 17.3 Data Model Requirements

### User
- id
- display_name
- avatar_seed
- leaderboard_opt_in
- leaderboard_initials_only
- created_at

### Session
- id
- user_id
- client_session_id
- technique_id
- preset_id
- started_at_utc
- ended_at_utc
- timezone_offset_minutes
- duration_seconds_actual
- breaths_completed_estimated
- ended_early
- created_at

### Stats Snapshot
- current_streak_days
- longest_streak_days
- minutes_this_week
- minutes_all_time
- sessions_all_time
- minutes_by_technique
- total_xp (from user_progress table)
- current_level (from user_progress table)

### User Progress (XP)
- user_id
- total_xp
- current_level
- curve_version

### XP Event
- id
- user_id
- source (session | daily_open)
- amount (final XP after multiplier and cap)
- multiplier
- base_amount
- session_id (nullable)
- local_day
- curve_version

### Leaderboard Entry
- rank
- display_name_or_initials
- avatar_seed
- total_xp
- level
- user_id

## 17.3.5 Data Constraints Matrix

### User constraints

| Field | Type | Required | Constraints | Uniqueness | Privacy class | Source of truth | Merge behavior |
| --- | --- | --- | --- | --- | --- | --- | --- |
| id | UUID | Yes | Immutable | Unique | Internal identifier | Server | Never merged across identities |
| display_name | String | Yes | 3-20 chars, letters/numbers/space, profanity blocked | Not globally unique | Public when user opts in | Server | Last valid update wins |
| avatar_seed | String | Yes | Deterministic generation seed, immutable after create unless product policy changes | Not unique | Public when user opts in | Server | Stable per user |
| leaderboard_opt_in | Bool | Yes | Default true | N/A | Private preference | Server | Explicit user action only |
| leaderboard_initials_only | Bool | Yes | Effective only when opt-in true | N/A | Private preference | Server | Explicit user action only |
| created_at | Timestamp | Yes | Server timestamp | N/A | Internal metadata | Server | Immutable |

### Session constraints

| Field | Type | Required | Constraints | Uniqueness | Privacy class | Source of truth | Merge behavior |
| --- | --- | --- | --- | --- | --- | --- | --- |
| id | UUID | Yes | Immutable server id | Unique | Internal identifier | Server | Immutable |
| user_id | UUID | Yes | Must reference existing user for persisted sessions | Indexed | Internal identifier | Server | Assigned at persistence |
| client_session_id | UUID | Yes | Must be UUID v4 or equivalent stable unique value from client | Unique | Internal dedupe key | Client generated, server enforced | Deduplicate on conflict |
| technique_id | String | Yes | Must match bundled canonical technique set | Indexed | Non-sensitive usage | Client submitted, server validated | Reject unknown values |
| preset_id | String | Yes | Must map to known preset/duration profile | Indexed | Non-sensitive usage | Client submitted, server validated | Reject unknown values |
| started_at_utc | Timestamp | Yes | UTC required | N/A | Internal event time | Client submitted, server validated | First-write-wins (ON CONFLICT DO NOTHING). A client_session_id represents one immutable session — resubmissions with different timestamps indicate a client bug, not a merge opportunity. |
| ended_at_utc | Timestamp | Yes | Must be >= started_at_utc | N/A | Internal event time | Client submitted, server validated | First-write-wins (ON CONFLICT DO NOTHING). Merging timestamps from duplicate submissions could inflate durations and corrupt stats/leaderboard metrics. |
| timezone_offset_minutes | Int | Yes | Must be within realistic offset bounds | N/A | Internal locale context | Client submitted, server validated | Preserve submitted value per session |
| duration_seconds_actual | Int | Yes | Must be positive and plausible for technique/preset | N/A | Non-sensitive usage | Server normalized from timestamps and request | Server canonical value |
| breaths_completed_estimated | Int | Yes | Non-negative and bounded by duration/technique | N/A | Non-sensitive usage | Client estimate, server sanity check | Server may clamp |
| ended_early | Bool | Yes | True if user ended before planned duration | N/A | Non-sensitive usage | Client submitted, server validated | Preserve |
| created_at | Timestamp | Yes | Server timestamp | N/A | Internal metadata | Server | Immutable |

### Stats Snapshot constraints

| Field | Type | Required | Constraints | Uniqueness | Privacy class | Source of truth | Merge behavior |
| --- | --- | --- | --- | --- | --- | --- | --- |
| current_streak_days | Int | Yes | >=0 | N/A | User-private unless shared | Server for signed-in, device for guest | Server authoritative after sync |
| longest_streak_days | Int | Yes | >=0 | N/A | User-private unless shared | Server for signed-in, device for guest | Max-preserving aggregation |
| practice_days_all_time | Int | Yes | >=0, count of user-local days with at least 2 minutes of total practice | N/A | User-private unless shared | Server for signed-in, device for guest | Recomputed authoritative |
| minutes_this_week | Int | Yes | >=0, Monday-start local-week definition | N/A | User-private unless shared | Server for signed-in, device for guest | Recomputed authoritative |
| minutes_all_time | Int | Yes | >=0 | N/A | User-private unless shared | Server for signed-in, device for guest | Recomputed authoritative |
| sessions_all_time | Int | Yes | >=0 | N/A | User-private unless shared | Server for signed-in, device for guest | Recomputed authoritative |
| minutes_by_technique | Map<String,Int> | Yes | Keys must be valid technique ids, values >=0 | N/A | User-private unless shared | Server for signed-in, device for guest | Recomputed authoritative |

### Leaderboard Entry constraints

| Field | Type | Required | Constraints | Uniqueness | Privacy class | Source of truth | Merge behavior |
| --- | --- | --- | --- | --- | --- | --- | --- |
| rank | Int | Yes | >=1, contiguous within generated view | Unique per ranking view | Public leaderboard data | Server/Redis cache | Recomputed every refresh |
| display_name_or_initials | String | Yes | Must respect user visibility and initials-only setting | Not unique | Public leaderboard data | Server | Derived at read time |
| avatar_seed | String | Yes | Derived from user profile seed | Not unique | Public leaderboard data | Server | Derived at read time |
| total_xp | BigInt | Yes | >=0 | Not unique | Public leaderboard data | Server/Redis cache (lb:xp) | Recomputed every refresh |
| level | Int | Yes | 0-999, derived from total_xp | Not unique | Public leaderboard data | Server (computed at read time) | Derived from total_xp |
| user_id | UUID | Yes | Must map to opted-in active user | Unique per entry | Internal/public mixed | Server | Recomputed every refresh |

## 17.4 Backend Security Baseline

- Short-lived access tokens and refresh token rotation
- Refresh token secure storage (hashed)
- Rate limiting on auth and session submission endpoints
- Strict payload validation
- TLS everywhere

## 17.5 Backend Caching and Jobs

- Redis sorted set for XP leaderboard (lb:xp key; old lb:streak/lb:weekly/lb:all_time keys cleaned up on refresh)
- Refresh ranking every 5 minutes
- Exclude non-opt-in users from ranking sets

## 17.6 Backend Module Plan with Task-Local Tests

### Module B1: Config, Bootstrapping, and Infra Wiring

Scope:
- Environment config
- Database and Redis connections
- Migration command integration
- Health and readiness checks

Tests to implement within module:
- Config parse tests for required env and defaults
- Health handler integration test

### Module B2: Auth and Token Lifecycle

Scope:
- Apple/Google verification adapters
- Access/refresh issuance
- Rotation and revoke flows

Tests to implement within module:
- Unit tests for token generation and expiry checks
- Unit tests for refresh rotation and revoked token behavior
- Integration tests for sign-in -> refresh -> logout path

### Module B3: User Profile and Privacy Preferences

Scope:
- Get/update profile
- Display name validation and profanity filtering
- Leaderboard visibility and initials preference
- Delete account

Tests to implement within module:
- Unit tests for name validation and profanity filter
- Integration tests for profile update and soft/hard delete logic

### Module B4: Session Ingestion and Dedupe

Scope:
- Batch session submission
- Session plausibility validation
- Dedupe by client_session_id

Tests to implement within module:
- Unit tests for validation bounds by technique/preset
- Integration tests for duplicate payload behavior and idempotency

### Module B5: Stats and Streak Computation

Scope:
- Authoritative daily streak calculation
- Weekly and all-time aggregates
- Timezone-local day handling

Tests to implement within module:
- Unit tests for streak under timezone travel scenarios
- Unit tests for 2-minute threshold behavior
- Integration tests for stats snapshot correctness from fixture sessions

### Module B6: Leaderboard Ranking and Anti-Cheat

Scope:
- Build ranking datasets
- Apply leaderboard minute caps
- Compute pinned self rank
- Shadow-ban filtering

Tests to implement within module:
- Unit tests for ranking order and tie handling
- Unit tests for daily cap application
- Integration tests for top50 and self-rank response shape

### Module B7: Scheduled Refresh and Cache Consistency

Scope:
- 5-minute leaderboard refresh job
- Cache invalidation and repopulation

Tests to implement within module:
- Integration tests verifying cache updates after new sessions
- Failure-path tests for partial refresh recovery

## 18. Website Plan (Astro)

## 18.1 Required Pages

- Landing page
- Privacy page
- Terms page
- 10 SEO pages

## 18.2 Content Rules

- Wellness-first language only
- No medical claims
- Clear Download app CTA
- No email capture in v1

## 18.3 SEO Page Set

- 9 technique-specific pages
- 1 breathing-for-sleep hub page

## 18.4 Web Module Plan with Task-Local Tests

### Module W1: Design System and Layout

Scope:
- Shared layout
- Monochrome visual language
- Manrope typography
- Responsive baseline

Tests to implement within module:
- Basic visual QA checklist across mobile and desktop breakpoints
- Accessibility checks for heading order and contrast

### Module W2: Landing and Legal

Scope:
- Brand message
- Download CTA blocks
- Privacy and Terms pages

Tests to implement within module:
- Link validation tests for legal and store links
- Metadata checks for title/description/canonical

### Module W3: SEO Page Templates and Content

Scope:
- Template for technique pages
- 10 pages final content

Tests to implement within module:
- Build validation for all routes
- No broken internal links

## 19. Analytics Event Plan (Minimal Anonymous)

Mandatory events:
- onboarding_completed
- session_started
- session_completed
- goal_changed
- sign_in_started
- sign_in_completed
- leaderboard_opt_in_changed

Rules:
- No PII event payloads
- Provide settings toggle for analytics opt-out
- Track only product health and flow metrics

## 20. Release Engineering and CI/CD

## 20.1 CI Required Checks

- Backend lint and tests
- Mobile analyze and tests
- Web build and checks

## 20.2 Deployment Rules

- Main branch deploy pipeline for backend with rollback runbook
- App release candidates managed on weekly cadence
- Store submission package validation before final cut

## 20.3 Operational Readiness

Required before submission:
- Environment variable registry complete
- Production secrets configured
- DB migrations validated on staging-like environment
- Backup and rollback procedures documented

## 20.4 Environment and Deployment Contract

### Environment variable registry

| Variable | Purpose | Required stage |
| --- | --- | --- |
| ENV | Runtime mode selection | Dev, staging, prod |
| PORT | API listen port | Dev, staging, prod |
| DATABASE_URL | PostgreSQL connection string | Dev, staging, prod |
| REDIS_ADDR | Redis host:port for cache and rate limiting | Dev, staging, prod |
| REDIS_PASSWORD | Redis password (if required) | Dev, staging, prod |
| JWT_ACCESS_SECRET | Access token signing secret | Dev, staging, prod |
| JWT_REFRESH_SECRET | Refresh token signing secret | Dev, staging, prod |
| JWT_ACCESS_TTL_MINUTES | Access token lifetime | Dev, staging, prod |
| JWT_REFRESH_TTL_MINUTES | Refresh token lifetime | Dev, staging, prod |
| GOOGLE_OAUTH_CLIENT_ID | Google token audience validation | Staging, prod |
| APPLE_OAUTH_AUDIENCE | Apple token audience validation | Staging, prod |
| CORS_ORIGINS | Allowed web origins list | Dev, staging, prod |
| TECHNIQUE_REGISTRY_PATH | Technique registry JSON path | Dev, staging, prod |
| DEV_AUTH_ENABLED | Enable dev provider sign-in | Dev |
| DEV_AUTH_SECRET | Dev provider sign-in secret | Dev |
| RATE_LIMIT_AUTH_BURST_PER_MIN | Auth endpoint burst throttling | Dev, staging, prod |
| RATE_LIMIT_AUTH_PER_HOUR | Auth endpoint throttling | Dev, staging, prod |
| RATE_LIMIT_SESSION_WRITES_PER_DAY | Session write throttling baseline | Dev, staging, prod |
| RATE_LIMIT_LEADERBOARD_READS_PER_MIN | Leaderboard read throttling | Dev, staging, prod |
| LEADERBOARD_DAILY_CAP_MINUTES | Leaderboard minutes cap per day | Dev, staging, prod |

### Deployment readiness checklist

- Staging deployment completes with production-like config.
- Migration dry-run executed against staging database copy.
- Rollback script validated for latest and previous release.
- Secret rotation process documented and tested at least once.
- Release artifact provenance documented (git sha + build timestamp).
- Health/readiness checks verified after deploy.

## 20.5 Critical Dependencies and Critical Path

### Critical dependencies

1. Config and schema baseline must be complete before auth/session features.
2. Auth token lifecycle must be complete before protected user/session endpoints.
3. Session ingestion and dedupe must be complete before authoritative stats.
4. Stats/streak correctness must be complete before leaderboard ranking.
5. Leaderboard privacy filters must be complete before public ranking exposure.
6. Operational readiness gates must pass before release candidate sign-off.

### Critical path sequence

config and schema baseline -> auth lifecycle -> session ingest and dedupe -> streak/stats computation -> leaderboard caching and filters -> release checks and submission

## 21. Weekly Delivery Plan (February 11 to March 31)

## Week 1 (Feb 11 to Feb 17)

Objectives:
- Mobile shell, theme, splash, onboarding skeleton, session engine v0
- Backend bootstrap and migration baseline

Must-complete outputs:
- Working 4-tab shell with locked leaderboard tab
- Working 5-step onboarding flow and local preference persistence
- Session phase scheduler MVP with pause/resume
- Backend service boots with config and health endpoint

Required tests in same week:
- Mobile unit tests for scheduler and streak threshold
- Backend health and config tests

## Week 2 (Feb 18 to Feb 24)

Objectives:
- Techniques grid/detail, local session storage, completion and stats MVP

Must-complete outputs:
- 9 techniques rendered from bundled config
- Detail pages with safety content and warnings
- Local session write path and stats aggregation

Required tests in same week:
- Widget tests for techniques flow
- Unit tests for local aggregation and favorites

## Week 3 (Feb 25 to Mar 3)

Objectives:
- Background behavior, reminders, legal pages, website baseline

Must-complete outputs:
- Background playback and lock controls
- Interruption auto-pause behavior
- Notification scheduling and post-first-session permission flow
- Landing, Privacy, Terms pages live in web project

Required tests in same week:
- Mobile integration tests for background/interruptions
- Web link and metadata checks

## Week 4 (Mar 4 to Mar 10)

Objectives:
- Auth and cloud sync foundations

Must-complete outputs:
- Apple/Google sign-in backend + app flow
- Guest-to-account session merge and dedupe

Required tests in same week:
- Backend auth/token tests
- Integration tests for sync and idempotency

## Week 5 (Mar 11 to Mar 17)

Objectives:
- Leaderboard production implementation

Must-complete outputs:
- Three ranking views
- Opt-in visibility and initials-only behavior
- 5-minute refresh and Redis ranking sets
- Anti-cheat baseline and profanity filtering

Required tests in same week:
- Backend ranking and cap tests
- Mobile leaderboard rendering and locked gate tests

## Week 6 (Mar 18 to Mar 24)

Objectives:
- Hardening, accessibility, SEO completion, beta testing

Must-complete outputs:
- All 10 SEO pages completed
- Accessibility pass on mobile and web
- Input validation and rate limiting hardening
- Internal then broader beta cycle

Required tests in same week:
- Full regression suite in CI
- Manual exploratory test checklist run

## Week 7 (Mar 25 to Mar 31)

Objectives:
- Release candidate stabilization and store submission

Must-complete outputs:
- Bug triage and fix closure
- Store listing assets finalized
- Submission package complete for iOS and Android
- Website URLs stable for legal/store references

Required tests in same week:
- Final smoke and release checklist pass
- Zero critical or blocker issues open at submission cut

## 22. Acceptance Criteria (Definition of Done)

Product behavior:
- Users can start breathing quickly with one-tap paths
- Session visuals and cues remain synchronized through long sessions
- Background and lock-screen controls work on both platforms

Data behavior:
- Streak and stats calculations are correct under timezone travel and partial sessions
- Signed-in sync avoids duplicates and keeps stats authoritative

Privacy/compliance:
- No medical claims in app or website copy
- Legal pages available in app and website
- Under-13 account restriction enforced

Engineering quality:
- Required module tests implemented alongside each module
- CI checks passing on release branch
- No unresolved critical defects at submission

## 22.1 Operational Quality Gates

### Performance and timing gates

- Session timing drift must be <=0.5% over a 20-minute guided session.
- Leaderboard refresh job must complete on a 5-minute cadence with max 2-minute lag tolerance.
- API read endpoints must target p95 <=300ms under baseline load.
- API write endpoints must target p95 <=500ms under baseline load.

### Data integrity gates

- Re-submission of identical client_session_id values must not create duplicates.
- Guest-to-account sync must preserve total minutes and streak equivalence after dedupe.
- Timezone-local day logic must pass travel edge-case test scenarios.

### Release blocker gates

- Any unresolved P0 issue blocks release candidate submission.
- Any unresolved P1 in auth/session/streak/leaderboard paths requires explicit waiver decision.
- Any regression in legal URL availability blocks store submission.

## 23. Risks and Mitigations

### Risk: Schedule compression

Mitigation:
- Enforce weekly scope boundaries
- Prioritize must-ship flows over enhancements

### Risk: Background behavior edge cases across devices

Mitigation:
- Add device-matrix integration testing during Week 3 and Week 6

### Risk: Leaderboard abuse

Mitigation:
- Apply caps, validation, profanity filtering, and shadow-ban support

### Risk: Compliance issues from wording

Mitigation:
- Add copy review checklist for wellness-only claims before release

### Risk: No crash tracking in v1

Mitigation:
- Strengthen QA and logging discipline
- Revisit crash monitoring immediately post-launch

## 24. Out-of-Scope Backlog (Post v1)

- Voice-guided sessions
- Community recommendations and moderation workflow
- Subscription and monetization
- Wearables and widgets
- Advanced adaptive coaching and custom builder

## 25. Implementation Ownership Template (for Team Use)

Use this structure for every feature ticket:

- Feature name
- Module id (M*, B*, W*)
- Owner
- Dependencies
- Scope checklist
- Required tests checklist
- QA checklist
- Rollback or fallback notes
- Done criteria

## 26. Final Release Checklist

### 26.1 Pre-development checklist

- Repository conventions and ownership model documented.
- Environment variable registry reviewed and approved.
- Local and staging setup instructions validated by a second run-through.
- Baseline schema and migration process verified.
- Module test strategy mapped to feature tickets.

### 26.2 Pre-submission checklist

- All must-ship modules complete.
- Test suites green in CI.
- Legal and policy URLs final and accessible.
- Store metadata complete and compliant.
- Known issues documented and explicitly accepted.
- Build artifacts generated and validated.
- Release blocker gates reviewed and passed.
- Submission to App Store and Play Store completed.

### 26.3 Post-launch week-1 stabilization checklist

- Daily health and error-log review completed.
- Leaderboard refresh cadence verified in production.
- Sync idempotency spot checks completed on live telemetry/log samples.
- Critical user-reported issues triaged within 24 hours.
- First-week changelog and patch plan published internally.

## 27. Doc Consistency Guardrails

- Section 4 (Confirmed Product Decisions) is the highest-priority source of truth inside this document.
- Any new section that conflicts with Section 4 must be treated as invalid until Section 4 is explicitly updated.
- Scope, policy, and contract changes require changelog entries with date, rationale, and impacted sections.
- Endpoint and data-model updates must be reflected in both behavior tables and constraint matrices in the same change.

## 28. Documentation Consistency Checks

- Consistency check: each endpoint group includes auth, validation, rate-limit, idempotency, and error semantics.
- Compatibility check: no section conflicts with locked decisions in Section 4.
- Completeness check: every required model field includes constraints and source-of-truth ownership.
- Release-readiness check: each weekly plan stage maps to measurable acceptance or operational quality gates.

---

This document is the source-of-truth plan for ClearBreath v1 delivery. Any scope changes must be recorded by updating this file first, then reflected in ticket breakdown and sprint priorities.
