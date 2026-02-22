 ClearBreath Flutter Mobile App — Definitive Implementation Plan

 Context

 ClearBreath is a guest-first pranayama breathing exercise app. The Go backend is 100%
 complete (auth, sessions, stats, leaderboard, safety acknowledgements, deployed at
 https://api.clearbreath.life). The Flutter mobile app has solid foundations but most
 features are placeholder or missing. This plan completes all remaining mobile features
 to PRD quality, integrates with the backend, and prepares for App Store submission by
 March 31, 2026.

 ---
 Current State (Verified from Repo)

 Implemented / Working

 - Entry + routing: lib/main.dart, lib/app.dart, lib/core/router/app_router.dart
 (GoRouter with splash→intro→onboarding guards)
 - Theme system: lib/core/theme/* — dark-only Material3, Manrope font, full token system
 (colors, typography, spacing, components). Production ready.
 - Splash screen: lib/features/splash/* — scale-in logo animation. Production ready.
 - Intro screen: lib/features/intro/* — 3-feature showcase. BUG: IntroGate is in-memory
 only, not persisted to Drift — intro re-shows on every app restart.
 - Onboarding: lib/features/onboarding/* — 7-step flow with Drift persistence. BUG:
 Session length options are 5/10/15/30 but PRD requires 2/5/10/20.
 - Session engine: lib/features/session/* — state machine
 (idle→countdown→inhale→hold→exhale→holdAfterExhale→paused→completed), 50ms timer ticks.
 Uses hardcoded 4s preset only.
 - Shell: lib/features/shell/* — 4-tab nav (Home, Techniques, Leaderboard[locked],
 Profile). Production ready.
 - Auth state: lib/features/auth/* — basic sealed class (Guest/SignedIn). Placeholder
 only.
 - Leaderboard locked screen: lib/features/leaderboard/* — guest gate UI. Working.
 - Shared widgets: lib/shared/widgets/slide_to_begin.dart — drag-to-confirm slider.
 Working.
 - Database: lib/core/database/* — Drift with Preferences table only, schema v2.
 - Tests: 18 test files covering routing, sessions, onboarding, splash, DB.

 Placeholders (text on screen only)

 - Home screen — just "Start Session" button
 - Techniques screen — just "Techniques" text
 - Profile screen — just "Profile" text
 - Stats screen — just "Stats" text

 Missing Entirely

 - Technique JSON data layer (11 techniques × 3 presets)
 - Technique grid/list + detail screens + safety warnings
 - Session-to-technique connection
 - Breathing animations (circle, metronome, alternate nostril)
 - Audio cue system + soundscapes
 - Background audio + lock-screen controls
 - Session persistence (no sessions Drift table)
 - Session completion screen
 - Local stats engine + streak system
 - Recommendation engine + real home screen
 - Favorites system
 - Profile/stats full UI + settings screen
 - Apple/Google/Dev authentication
 - Token management + API client
 - Backend session sync + cloud stats
 - Safety acknowledgements sync
 - Leaderboard UI (3 ranking views)
 - Notifications (daily reminder + streak warning)
 - Share card
 - Legal screens (privacy/terms)
 - Build-time config (API URL, feature flags)
 - Device ID generation

 Toolchain Issue (Makefile)

 - Makefile hardcodes FLUTTER := /Users/rahul/sdk/flutter/bin/flutter — not portable.
 Needs FVM or override-friendly variable.

 ---
 Non-Negotiable Constraints

 1. No comments in code — clean, self-documenting everywhere
 2. Dark theme only — strict #000000 background, white text, Manrope font only
 3. All colors via theme tokens — AppColorTokens, AppTypographyTokens, AppSpacingTokens,
 AppComponentTokens
 4. Feature structure: features/<name>/{domain,data,presentation}/, shared under shared/
 5. State management: Riverpod — NotifierProvider<Controller, State>, Provider,
 FutureProvider, StreamProvider
 6. Install deps via CLI (flutter pub add), never type versions into pubspec
 7. Tests after each phase — unit + widget tests; flutter test + flutter analyze green
 before moving on
 8. Offline-first — all breathing exercises work without internet; cloud sync optional
 9. No analytics in v1
 10. Prod API: https://api.clearbreath.life

 ---
 Target Architecture (Final Shape)

 Core layers to add/expand

 lib/
 ├── core/
 │   ├── config/
 │   │   └── app_config.dart          ← build-time --dart-define (API_BASE_URL, DEV_AUTH)
 │   ├── database/
 │   │   ├── app_database.dart        ← expand to schema v3 with 6 new tables
 │   │   └── tables/
 │   │       ├── preferences.dart     ← existing (add intro_complete column)
 │   │       ├── sessions.dart        ← NEW
 │   │       ├── favorites.dart       ← NEW
 │   │       ├── safety_ack.dart      ← NEW
 │   │       ├── stats_cache.dart     ← NEW
 │   │       ├── leaderboard_cache.dart ← NEW
 │   │       └── sync_queue.dart      ← NEW (optional reliability layer)
 │   ├── network/
 │   │   ├── api_client.dart          ← Dio wrapper with base URL from config
 │   │   ├── api_error.dart           ← error envelope {error, code, request_id}
 │   │   ├── auth_interceptor.dart    ← Bearer injection + refresh-on-401
 │   │   └── models/                  ← all API request/response DTOs
 │   │       ├── auth_models.dart
 │   │       ├── user_models.dart
 │   │       ├── session_models.dart
 │   │       ├── stats_models.dart
 │   │       ├── leaderboard_models.dart
 │   │       └── safety_models.dart
 │   ├── router/
 │   │   └── app_router.dart          ← expand with new routes
 │   └── theme/                       ← unchanged (production ready)
 ├── features/
 │   ├── auth/                        ← expand: token storage, OAuth
 │   ├── background_audio/            ← NEW: audio_service, lock-screen, interruptions
 │   ├── home/                        ← rewrite: recommendation engine + full UI
 │   ├── leaderboard/                 ← expand: 3 views, cached offline, self-rank
 │   ├── notifications/               ← NEW: daily reminder + streak warning
 │   ├── onboarding/                  ← fix session lengths, keep-awake → settings
 │   ├── profile/                     ← rewrite: stats, settings, legal, account
 │   ├── session/                     ← major expansion: technique-driven, animations,
 audio, persistence, completion
 │   ├── share/                       ← NEW: share card generation
 │   ├── splash/                      ← unchanged
 │   ├── intro/                       ← fix: persist gate to Drift
 │   ├── stats/                       ← rewrite: engine + full UI
 │   ├── sync/                        ← NEW: session sync, stats sync, safety sync
 │   └── techniques/                  ← rewrite: JSON loader, grid, detail, favorites,
 safety
 └── shared/
     ├── providers/
     │   └── app_database_provider.dart
     ├── secure_storage/
     │   └── secure_storage.dart      ← NEW: wrapper for flutter_secure_storage
     └── widgets/
         └── slide_to_begin.dart      ← unchanged

 API models to implement (from docs/backend_api_contract.md)

 All under lib/core/network/models/:

 - auth_models.dart: ProviderSignInRequest {provider, idToken, deviceId},
 AuthResponse {accessToken, accessTokenExpiresAtUtc, refreshToken,
 refreshTokenExpiresAtUtc, user}
 - user_models.dart: UserProfile {id, displayName, avatarSeed, leaderboardOptIn,
 leaderboardInitialsOnly, createdAtUtc, timezoneOffsetMinutesLatest}, MePatchRequest
 {displayName?, leaderboardOptIn?, leaderboardInitialsOnly?}
 - session_models.dart: SessionSubmitPayload {clientSessionId, techniqueId, presetId,
 startedAtUtc, endedAtUtc, timezoneOffsetMinutes, breathsCompletedEstimated, endedEarly,
 durationSecondsActual}, SessionsIngestResponse {acceptedCount, duplicateCount,
 rejected[], statsSnapshot}
 - stats_models.dart: StatsSnapshot {currentStreakDays, longestStreakDays,
 minutesThisWeek, minutesAllTime, sessionsAllTime, minutesByTechnique, updatedAtUtc}
 - leaderboard_models.dart: LeaderboardListResponse {ranking, generatedAtUtc, top[]},
 LeaderboardRow {rank, displayNameOrInitials, avatarSeed, metricValue, userId},
 LeaderboardSelfResponse {ranking, user{rank, metricValue}}
 - safety_models.dart: SafetyAcknowledgements {techniqueIds[]}

 ---
 Phase Plan

 ---
 Phase 0 — Toolchain + Repo Determinism (Blocker Removal) (DONE)

 Objective: Make make mobile-get, make mobile-analyze, make mobile-test work on any
 machine consistently.

 Why first: Nothing else can be verified without a working toolchain.

 Tasks

 1. Update Makefile — Change FLUTTER := /Users/rahul/sdk/flutter/bin/flutter to FLUTTER
 ?= flutter (override-friendly). Add mobile-pub-add target:
 mobile-pub-add:
     cd apps/mobile && $(FLUTTER) pub add $(PKG)
 2. Verify SDK constraint — pubspec.yaml has sdk: ^3.10.8. Ensure local Flutter Dart SDK
 satisfies this.
 3. Run verification:
 make mobile-get
 make mobile-analyze
 make mobile-test

 Files to modify

 - /Makefile — line 9: FLUTTER ?= flutter, add mobile-pub-add target

 Tests

 - Existing 18 tests must pass. No new tests needed.

 ---
 Phase 1 — Fix Existing Foundation Bugs (PRD Alignment) (DONE)

 Objective: Fix IntroGate persistence (currently in-memory = re-shows intro on every
 restart) and correct onboarding session length options to match PRD (2/5/10/20 not
 5/10/15/30).

 Why now: These are bugs in shipped code. Must fix before building on top.

 Tasks

 1. Persist IntroGate to Drift — Add introComplete boolean column to Preferences table.
 Replace in-memory IntroGate with a persisted gate like OnboardingGate.
 2. Fix session length options — Change SessionLengthStep from 5/10/15/30 to 2/5/10/20
 per PRD. Update OnboardingAnswers.defaults() sessionLengthMinutes default from 5 to 5
 (stays same, but add 2 as option and replace 15→2, 30→20).
 3. Drift schema migration — Bump to schema v2.1 or handle via adding column with
 default. Add introComplete column to preferences with default false. Bump schema version
  appropriately.

 Files to modify

 - lib/features/intro/domain/intro_gate.dart — rewrite to use Drift persistence (follow
 OnboardingGate pattern)
 - lib/core/database/tables/preferences.dart — add BoolColumn introComplete with default
 false
 - lib/core/database/app_database.dart — migration for new column
 - lib/features/onboarding/presentation/steps/session_length_step.dart — change 15→2,
 30→20
 - lib/core/router/app_router.dart — update intro guard to read from persisted gate

 Tests to add/run

 - test/features/intro/intro_gate_persistence_test.dart — intro shows once, persists
 across "restart"
 - test/features/onboarding/session_length_options_test.dart — verify options are
 2/5/10/20
 - Run: flutter test + flutter analyze

 ---
 Phase 2 — Technique Data System (JSON Assets as Source-of-Truth) (DONE)

 Objective: Create the foundational technique data layer. 11 techniques with metadata,
 breathing presets, safety flags, loaded from bundled JSON. This is what everything else
 depends on.

 Senior dev decision: JSON asset is source-of-truth (not hardcoded Dart). The JSON schema
  is richer than the backend's techniques.json — it includes UI copy, animation mode, and
  phase timings that the server doesn't need.

 Tasks

 1. Define technique JSON schema and create asset file:
 apps/mobile/assets/techniques/techniques_v1.json
 1. Schema per technique:
   - id — canonical, matches backend exactly
   - name, shortDescription
   - animationMode: "circle" | "metronome" | "alternate_nostril"
   - safety: { "requiresAck": bool, "title": string, "body": string }
   - about: { "what": string, "how": string, "bestTime": string, "benefits": string,
 "warnings": string }
   - presets: { "beginner"/"intermediate"/"advanced": { "mode": "phases"|"bpm_rounds",
 ...timing fields } }
       - For "phases" mode: inhaleSeconds, holdSeconds, exhaleSeconds,
 holdAfterExhaleSeconds, recommendedDurationsMinutes: [2,5,10,20]
     - For "bpm_rounds" mode (kapalbhati/bhastrika): bpm, rounds, roundSeconds,
 restSeconds, recommendedDurationsMinutes

 Technique IDs (must match backend): hrv_resonance, ultra_slow, diaphragmatic, box,
 four_seven_eight, yogic_three_part, anulom_vilom, ujjayi, bhramari, kapalbhati,
 bhastrika

 Safety-gated: kapalbhati, bhastrika, ultra_slow
 Metronome visual: kapalbhati, bhastrika
 Alternate nostril visual: anulom_vilom
 Circle visual: all others
 2. Domain models:

 2. lib/features/techniques/domain/technique.dart
   - Enum AnimationMode { circle, metronome, alternateNostril }
   - Class TechniqueSafety (immutable): bool requiresAck, String title, String body
   - Class TechniqueAbout (immutable): String what, String how, String bestTime, String
 benefits, String warnings
   - Class Technique (immutable): String id, String name, String shortDescription,
 AnimationMode animationMode, TechniqueSafety safety, TechniqueAbout about, Map<String,
 TechniquePreset> presets

 lib/features/techniques/domain/technique_preset.dart
   - Sealed class TechniquePreset
   - Subclass PhasePreset: int inhaleMs, int holdMs, int exhaleMs, int holdAfterExhaleMs,
  List<int> recommendedDurationsMinutes
   - Subclass BpmRoundsPreset: int bpm, int rounds, int roundSeconds, int restSeconds,
 List<int> recommendedDurationsMinutes
   - Both have String id (beginner/intermediate/advanced), String label
 3. Repository + Provider:

 3. lib/features/techniques/data/technique_repository.dart
   - Class TechniqueRepository
   - Loads assets/techniques/techniques_v1.json via rootBundle, parses once, caches in
 memory
   - Methods: Future<List<Technique>> all(), Future<Technique?> byId(String),
 Future<List<Technique>> safetyGated()
   - Provider: final techniqueRepositoryProvider = Provider<TechniqueRepository>((ref) =>
  TechniqueRepository());
   - final allTechniquesProvider = FutureProvider<List<Technique>>((ref) =>
 ref.read(techniqueRepositoryProvider).all());
 4. Add to pubspec.yaml assets:
 assets:
   - assets/techniques/

 Breathing Timings (key reference for JSON content)

 Technique: diaphragmatic
 Beginner: 4s-0s-6s-0s
 Intermediate: 5s-0s-7s-0s
 Advanced: 6s-0s-8s-0s
 ────────────────────────────────────────
 Technique: box
 Beginner: 4s-4s-4s-4s
 Intermediate: 5s-5s-5s-5s
 Advanced: 6s-6s-6s-6s
 ────────────────────────────────────────
 Technique: four_seven_eight
 Beginner: 4s-7s-8s-0s
 Intermediate: 4s-7s-8s-0s
 Advanced: 4s-7s-8s-0s
 ────────────────────────────────────────
 Technique: yogic_three_part
 Beginner: 4s-2s-6s-0s
 Intermediate: 5s-3s-7s-0s
 Advanced: 6s-4s-8s-0s
 ────────────────────────────────────────
 Technique: anulom_vilom
 Beginner: 4s-0s-4s-0s
 Intermediate: 4s-4s-8s-0s
 Advanced: 4s-16s-8s-0s
 ────────────────────────────────────────
 Technique: ujjayi
 Beginner: 4s-0s-6s-0s
 Intermediate: 5s-2s-7s-0s
 Advanced: 6s-4s-8s-0s
 ────────────────────────────────────────
 Technique: bhramari
 Beginner: 4s-0s-8s-0s
 Intermediate: 4s-0s-10s-0s
 Advanced: 4s-0s-12s-0s
 ────────────────────────────────────────
 Technique: hrv_resonance
 Beginner: 5s-0s-5s-0s (6 BPM)
 Intermediate: 6s-0s-6s-0s (5 BPM)
 Advanced: 6.7s-0s-6.7s-0s (4.5 BPM)
 ────────────────────────────────────────
 Technique: ultra_slow
 Beginner: 10s-0s-10s-0s (3 BPM)
 Intermediate: 15s-0s-15s-0s (2 BPM)
 Advanced: 20s-0s-20s-0s (1.5 BPM)
 ────────────────────────────────────────
 Technique: kapalbhati
 Beginner: bpm_rounds: 60bpm, 3 rounds, 30s each, 30s rest
 Intermediate: 80bpm, 3 rounds, 45s, 30s rest
 Advanced: 120bpm, 3 rounds, 60s, 45s rest
 ────────────────────────────────────────
 Technique: bhastrika
 Beginner: bpm_rounds: 30bpm, 3 rounds, 30s each, 60s rest
 Intermediate: 60bpm, 3 rounds, 30s each, 90s rest
 Advanced: 90bpm, 3 rounds, 40s each, 120s rest

 Tests to add/run

 - test/features/techniques/data/technique_repository_test.dart — loads 11 techniques,
 each has 3 presets, IDs match canonical set, safety-gated list correct, animation modes
 assigned correctly
 - Run: flutter test + flutter analyze

 ---
 Phase 3 — Database Expansion (All New Tables in One Migration) (DONE)

 Objective: Add all 6 new Drift tables in a single schema migration (v3 → v4).
 Define tables now, wire repositories in later phases. Also install uuid package.

 Why consolidate: Multiple schema bumps create migration complexity. One migration for
 all tables is cleaner.

 Packages to install

 cd apps/mobile && flutter pub add uuid

 Tables to create

 lib/core/database/tables/sessions.dart

 ┌───────────────────────────┬──────────┬───────────────┐
 │          Column           │   Type   │  Constraints  │
 ├───────────────────────────┼──────────┼───────────────┤
 │ clientSessionId           │ Text     │ Primary key   │
 ├───────────────────────────┼──────────┼───────────────┤
 │ techniqueId               │ Text     │ Required      │
 ├───────────────────────────┼──────────┼───────────────┤
 │ presetId                  │ Text     │ Required      │
 ├───────────────────────────┼──────────┼───────────────┤
 │ startedAtUtc              │ DateTime │ Required      │
 ├───────────────────────────┼──────────┼───────────────┤
 │ endedAtUtc                │ DateTime │ Required      │
 ├───────────────────────────┼──────────┼───────────────┤
 │ timezoneOffsetMinutes     │ Integer  │ Required      │
 ├───────────────────────────┼──────────┼───────────────┤
 │ durationSecondsActual     │ Integer  │ Required      │
 ├───────────────────────────┼──────────┼───────────────┤
 │ breathsCompletedEstimated │ Integer  │ Required      │
 ├───────────────────────────┼──────────┼───────────────┤
 │ endedEarly                │ Bool     │ Default false │
 ├───────────────────────────┼──────────┼───────────────┤
 │ syncedToCloud             │ Bool     │ Default false │
 ├───────────────────────────┼──────────┼───────────────┤
 │ createdAt                 │ DateTime │ Required      │
 └───────────────────────────┴──────────┴───────────────┘

 lib/core/database/tables/favorites.dart

 ┌─────────────┬──────────┬─────────────┐
 │   Column    │   Type   │ Constraints │
 ├─────────────┼──────────┼─────────────┤
 │ techniqueId │ Text     │ Primary key │
 ├─────────────┼──────────┼─────────────┤
 │ addedAt     │ DateTime │ Required    │
 └─────────────┴──────────┴─────────────┘

 lib/core/database/tables/safety_ack.dart

 ┌────────────────┬──────────┬─────────────┐
 │     Column     │   Type   │ Constraints │
 ├────────────────┼──────────┼─────────────┤
 │ techniqueId    │ Text     │ Primary key │
 ├────────────────┼──────────┼─────────────┤
 │ acknowledgedAt │ DateTime │ Required    │
 └────────────────┴──────────┴─────────────┘

 lib/core/database/tables/stats_cache.dart

 ┌────────────────────────┬──────────┬────────────────────────┐
 │         Column         │   Type   │      Constraints       │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ id                     │ Integer  │ Primary key (always 1) │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ currentStreakDays      │ Integer  │ Default 0              │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ longestStreakDays      │ Integer  │ Default 0              │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ minutesThisWeek        │ Integer  │ Default 0              │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ minutesAllTime         │ Integer  │ Default 0              │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ sessionsAllTime        │ Integer  │ Default 0              │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ minutesByTechniqueJson │ Text     │ Default '{}'           │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ longestSessionMinutes  │ Integer  │ Default 0              │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ favoriteTechniqueId    │ Text     │ Nullable               │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ totalBreathsEstimated  │ Integer  │ Default 0              │
 ├────────────────────────┼──────────┼────────────────────────┤
 │ updatedAt              │ DateTime │ Required               │
 └────────────────────────┴──────────┴────────────────────────┘

 lib/core/database/tables/leaderboard_cache.dart

 ┌────────────────┬──────────┬──────────────────────────────────────┐
 │     Column     │   Type   │             Constraints              │
 ├────────────────┼──────────┼──────────────────────────────────────┤
 │ ranking        │ Text     │ Primary key (streak/weekly/all_time) │
 ├────────────────┼──────────┼──────────────────────────────────────┤
 │ rowsJson       │ Text     │ Required (serialized list)           │
 ├────────────────┼──────────┼──────────────────────────────────────┤
 │ generatedAtUtc │ DateTime │ Required                             │
 ├────────────────┼──────────┼──────────────────────────────────────┤
 │ fetchedAt      │ DateTime │ Required                             │
 └────────────────┴──────────┴──────────────────────────────────────┘

 lib/core/database/tables/sync_queue.dart (reliability layer)

 ┌───────────────┬──────────┬───────────────────────────────┐
 │    Column     │   Type   │          Constraints          │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ id            │ Integer  │ Auto-increment PK             │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ entityType    │ Text     │ Required (session/safety_ack) │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ entityId      │ Text     │ Required                      │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ payload       │ Text     │ Required (JSON)               │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ status        │ Text     │ Default 'pending'             │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ attempts      │ Integer  │ Default 0                     │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ lastAttemptAt │ DateTime │ Nullable                      │
 ├───────────────┼──────────┼───────────────────────────────┤
 │ createdAt     │ DateTime │ Required                      │
 └───────────────┴──────────┴───────────────────────────────┘

 Files to modify

 - lib/core/database/app_database.dart — Add all 6 tables to @DriftDatabase(tables:
 [...]), bump schemaVersion to 4, add migration v3→v4 that creates all new tables
 - Run dart run build_runner build --delete-conflicting-outputs to regenerate

 Tests

 - Verify migration runs cleanly (add migration test)
 - Run: flutter test + flutter analyze

 ---
 Phase 4 — Technique Library UI (Grid + Detail + Safety Gates) (DONE)

 Objective: Replace placeholder Techniques tab with full grid, detail screens with preset
  selection, and safety warning interstitials for kapalbhati/bhastrika/ultra_slow.

 Files to create

 lib/features/techniques/presentation/techniques_screen.dart (replace placeholder)
 - 2-column grid of TechniqueCard widgets
 - Data from ref.watch(allTechniquesProvider)
 - Each card taps → navigates to /techniques/:id
 - Loading/error states handled

 lib/features/techniques/presentation/widgets/technique_card.dart
 - Shows: technique name, short description, animation mode icon, safety warning icon if
 requiresAck
 - Uses AppComponentTokens for card styling (radius: 18, padding: 20)
 - Favorite toggle icon (wired later in Phase 8)

 lib/features/techniques/presentation/technique_detail_screen.dart
 - Sections: What It Is, How To Do It, Best Time, Benefits, Warnings/Contraindications
 - Preset selector: 3 horizontal pills (Beginner / Intermediate / Advanced)
 - Duration selector: shows recommendedDurationsMinutes for selected preset
 - "Start Session" FilledButton
 - If safety-gated and not yet acknowledged → intercept with safety warning sheet
 - On start: set activeSessionConfigProvider, navigate to /session

 lib/features/techniques/presentation/widgets/safety_warning_sheet.dart
 - Modal bottom sheet with technique-specific contraindication text
 - "I understand the risks" confirmation button
 - On confirm: persist acknowledgement to safety_ack Drift table, then proceed

 lib/features/techniques/domain/safety_acknowledgement_repository.dart
 - Class with AppDatabase
 - Methods: Future<bool> isAcknowledged(String techniqueId), Future<void>
 acknowledge(String techniqueId), Future<Set<String>> allAcknowledged()
 - Provider: final safetyAckRepositoryProvider =
 Provider<SafetyAcknowledgementRepository>((ref) => ...);
 - final safetyAcksProvider = FutureProvider<Set<String>>((ref) => ...);

 lib/features/session/domain/active_session_config.dart
 - Class ActiveSessionConfig: Technique technique, TechniquePreset preset, String
 presetId, int durationLimitSeconds
 - Provider: final activeSessionConfigProvider =
 StateProvider<ActiveSessionConfig?>((ref) => null);

 Files to modify

 - lib/core/router/app_router.dart — Add route /techniques/:id → TechniqueDetailScreen

 Tests

 - test/features/techniques/domain/safety_acknowledgement_repository_test.dart
 - test/features/techniques/presentation/techniques_screen_test.dart — grid renders 11
 cards
 - test/features/techniques/presentation/technique_detail_test.dart — preset selector
 works, safety gate fires for gated techniques
 - Run: flutter test + flutter analyze

 ---
 Phase 5 — Session Engine v1 (Technique-Driven + Visuals + Controls) (DONE)

 Objective: Replace hardcoded session with technique-driven SessionPlan + SessionRunner.
 Build 3 animation widgets (circle, metronome, alternate nostril). Full session controls.
  Haptics on transitions.

 Senior dev decision: Session engine evolves from SessionStateMachine into SessionPlan
 (derived from technique JSON, supports phases + rounds) + SessionRunner (drives timing,
 emits phase events, integrates audio/haptics hooks).

 Key architectural change

 The existing SessionStateMachine + SessionController handle simple 4-phase cycling. We
 need to support:
 1. Phase-based techniques (9 of 11): cycle through inhale→hold→exhale→holdAfterExhale
 for N cycles
 2. BPM round-based techniques (kapalbhati, bhastrika): rapid inhale/exhale at BPM for X
 rounds with rest periods between
 3. Alternate nostril guidance (anulom_vilom): left/right nostril indicator per phase

 lib/features/session/domain/session_plan.dart
 - Sealed class SessionPlan
 - PhaseSessionPlan: List<SessionPhase> phaseSequence, Map<SessionPhase, Duration>
 phaseDurations, int totalCycles, Duration totalDuration
 - RoundSessionPlan: int bpm, int rounds, Duration roundDuration, Duration restDuration,
 Duration totalDuration
 - Factory: SessionPlan.fromPreset(TechniquePreset preset, int durationLimitSeconds) —
 computes total cycles from duration
 - For alternate nostril: mark which nostril is active per cycle in the plan

 lib/features/session/domain/session_state_machine.dart (major rewrite)
 - Accept SessionPlan instead of just SessionPreset
 - Add int breathsCompleted counter
 - For RoundSessionPlan: handle round progression with rest intervals
 - For alternate nostril: expose NostrilSide? activeNostril (left/right/null)
 - Add duration limit auto-completion
 - Emit events for phase transitions (used by audio/haptics hooks)

 lib/features/session/domain/session_state.dart — expand:
 - Add: int breathsCompleted, String? techniqueId, String? presetId, int? currentRound,
 int? totalRounds, NostrilSide? activeNostril

 lib/features/session/domain/session_controller.dart — rewrite:
 - startSession(ActiveSessionConfig config) — builds SessionPlan from config, starts
 runner
 - Keep startDefault() for backward compat (delegates to box beginner)
 - On phase transitions: call registered hooks (audio, haptics — wired later)

 Animation widgets

 lib/features/session/presentation/widgets/breathing_circle.dart
 - StatefulWidget with SingleTickerProviderStateMixin
 - Props: SessionPhase phase, Duration phaseRemaining, Duration phaseDuration
 - Inhale: expand 0.3→1.0 scale, Hold: steady with subtle glow pulse, Exhale: contract
 1.0→0.3, HoldAfterExhale: steady contracted
 - White stroke circle on black (colors.textPrimary), phase label centered inside
 - Smooth interpolation: progress = 1 - (phaseRemaining / phaseDuration)

 lib/features/session/presentation/widgets/metronome_pulse.dart
 - For rapid techniques (kapalbhati, bhastrika)
 - Pulsing white dot that beats at BPM rate
 - Shows current round number and rest countdown between rounds

 lib/features/session/presentation/widgets/alternate_nostril_indicator.dart
 - For anulom_vilom only
 - Shows left/right nostril indicator (simple L/R with active side highlighted)
 - Plus the breathing circle underneath

 lib/features/session/presentation/widgets/session_phase_label.dart
 - Animated text crossfade: "INHALE", "HOLD", "EXHALE", "REST" (for rounds)

 lib/features/session/presentation/widgets/session_timer_display.dart
 - Phase remaining countdown (large) + total elapsed (smaller)
 - For rounds: shows "Round 2 of 3" text

 Session screen rewrite

 lib/features/session/presentation/session_screen.dart (major rewrite)
 - Reads activeSessionConfigProvider for technique info
 - Shows appropriate animation widget based on technique.animationMode
 - Integrates SessionPhaseLabel, SessionTimerDisplay
 - Controls at bottom: Pause/Resume, Stop (with end-early confirmation dialog)
 - Mute toggle + volume placeholder (audio wired in Phase 6)
 - Haptics on phase transitions using existing Vibration package, respecting
 hapticsEnabled preference

 Tests

 - test/features/session/domain/session_plan_test.dart — builds correct plan from phase
 preset, builds correct plan from BPM rounds preset, computes total cycles correctly
 - Update test/features/session/session_state_machine_test.dart — phase-based cycling,
 round-based progression with rest, breath counting, duration limit, alternate nostril
 side changes
 - test/features/session/presentation/widgets/breathing_circle_test.dart — renders,
 responds to phases
 - test/features/session/presentation/widgets/metronome_pulse_test.dart — renders, shows
 round info
 - Update test/features/session/presentation/session_screen_test.dart — correct widget
 per animation mode
 - Run: flutter test + flutter analyze

 ---
 Phase 6 — Audio Cues + Background Playback + Lock-Screen Controls (DONE)

 Objective: Phase-transition chime sounds, optional ambient soundscapes, background audio
  continuation, lock-screen media controls, audio interruption handling, wakelock.

 Packages to install

 cd apps/mobile && flutter pub add audio_session
 cd apps/mobile && flutter pub add just_audio_background

 (Note: just_audio and wakelock_plus already in pubspec)

 Assets to add

 - assets/audio/inhale_cue.mp3 — soft bell/chime (~0.5s)
 - assets/audio/exhale_cue.mp3 — softer tone (~0.5s)
 - assets/audio/hold_cue.mp3 — subtle click (~0.3s)
 - assets/audio/session_complete.mp3 — success tone (~1s)
 - assets/audio/tick.mp3 — metronome tick for rapid techniques (~0.1s)

 Source royalty-free CC0 tones. Placeholder files acceptable initially.

 Files to create

 lib/features/session/domain/audio_cue_service.dart
 - Uses just_audio AudioPlayer
 - Methods: playInhaleCue(), playExhaleCue(), playHoldCue(), playTick(), playComplete()
 - Volume: setVolume(double), mute(), unmute(), bool isMuted
 - Provider: final audioCueServiceProvider = Provider<AudioCueService>((ref) => ...);

 lib/features/session/domain/haptic_service.dart
 - Wraps Vibration package
 - Methods: phaseTransition() (40ms light), sessionComplete() (100ms medium), tick()
 (20ms light for rapid)
 - Reads hapticsEnabled from preferences via provider
 - Provider: final hapticServiceProvider = Provider<HapticService>((ref) => ...);

 lib/features/background_audio/data/background_audio_controller.dart
 - Configures AudioSession for .playback category (enables background)
 - Handles audio interruption events: AudioInterruptionEvent.pause → auto-pause session,
 .resume → auto-resume
 - Lock-screen media controls: play/pause → session pause/resume, stop → session stop
 - Updates media notification metadata (technique name, "ClearBreath")

 lib/features/session/domain/wakelock_service.dart
 - Wraps wakelock_plus
 - enable() on session start, disable() on session end
 - Reads keepScreenAwake preference
 - Provider: final wakelockServiceProvider = Provider<WakelockService>((ref) => ...);

 lib/features/session/presentation/widgets/session_audio_controls.dart
 - Mute toggle icon button + volume slider
 - Positioned at top-right of session screen

 Files to modify

 - lib/features/session/domain/session_controller.dart — integrate audio cue hooks on
 phase transitions, haptic hooks, wakelock on start/stop, background audio setup
 - lib/features/session/presentation/session_screen.dart — add WidgetsBindingObserver for
  lifecycle, add audio controls widget, integrate wakelock
 - pubspec.yaml — add assets/audio/ to assets list

 Tests

 - test/features/session/domain/haptic_service_test.dart — fires when enabled, skips when
  disabled
 - test/features/session/domain/wakelock_service_test.dart — enables/disables based on
 preference
 - test/features/background_audio/data/background_audio_controller_test.dart — auto-pause
  on interruption
 - Run: flutter test + flutter analyze

 ---
 Phase 7 — Session Persistence + Completion Screen (DONE)

 Objective: Store completed sessions in Drift sessions table. Build post-session
 completion screen. Generate UUID client_session_id for future backend sync.

 Files to create

 lib/features/session/domain/local_session.dart
 - Class LocalSession (immutable): all fields matching Sessions Drift table
 - Factory LocalSession.fromCompleted({required ActiveSessionConfig config, required
 SessionState finalState, required DateTime startedAt, required int
 timezoneOffsetMinutes}) — computes duration, generates UUID

 lib/features/session/data/session_repository.dart
 - Methods: Future<void> insert(LocalSession), Future<List<LocalSession>> all(),
 Future<List<LocalSession>> unsynced(), Future<void> markSynced(List<String>
 clientSessionIds), Future<List<LocalSession>> forDateRange(DateTime start, DateTime
 end), Future<Map<DateTime, int>> minutesByLocalDay()
 - Provider: final sessionRepositoryProvider = Provider<SessionRepository>((ref) =>
 SessionRepository(ref.watch(appDatabaseProvider)));

 lib/features/session/presentation/session_completion_screen.dart
 - Route: /session/complete
 - Displays: technique name, preset level, actual minutes practiced, estimated breaths,
 streak impact (placeholder until Phase 8 wires real stats)
 - Buttons: "Done" → /home, "Share" (placeholder until Phase 12)
 - Clean dark UI with metric tiles

 Files to modify

 - lib/features/session/domain/session_controller.dart — record _startedAt on start,
 generate clientSessionId via Uuid().v4(), on completion persist LocalSession, navigate
 to completion screen
 - lib/core/router/app_router.dart — add route /session/complete →
 SessionCompletionScreen

 Tests

 - test/features/session/data/session_repository_test.dart — insert, query all, query
 unsynced, mark synced, date range query
 - test/features/session/domain/local_session_test.dart — factory computes correct fields
 - test/features/session/presentation/session_completion_screen_test.dart — displays
 stats, done navigates home
 - Run: flutter test + flutter analyze

 ---
 Phase 8 — Stats Engine + Streak System (Offline-First) (DONE)

 Objective: Compute all stats from local Drift sessions data. Implement 2-minute daily
 minimum streak rule with timezone-aware local day calculation. Cache computed snapshot
 in stats_cache table.

 Files to create

 lib/features/stats/domain/stats_snapshot.dart
 - Class StatsSnapshot (immutable): int currentStreakDays, int longestStreakDays, int
 minutesThisWeek, int minutesAllTime, int sessionsAllTime, Map<String, int>
 minutesByTechnique, int longestSessionMinutes, String? favoriteTechniqueId, int
 totalBreathsEstimated, DateTime updatedAt
 - Factory StatsSnapshot.empty()

 lib/features/stats/domain/streak_calculator.dart
 - Pure functions (no side effects, fully testable):
 - int currentStreak(Map<DateTime, int> minutesByLocalDay, DateTime today) — counts
 consecutive days backward from today/yesterday where day total >= 2 minutes
 - int longestStreak(Map<DateTime, int> minutesByLocalDay) — scans all days for max
 consecutive run
 - Edge cases handled: today with <2 min doesn't break streak (yet); yesterday gap
 resets; timezone travel (each session uses its own timezoneOffsetMinutes to determine
 local day)

 lib/features/stats/domain/stats_engine.dart
 - Pure function: StatsSnapshot computeStats(List<LocalSession> sessions, DateTime now,
 int currentTimezoneOffset)
 - Groups sessions by local date (using each session's own timezone offset)
 - Computes: current/longest streak, weekly minutes (Monday start), all-time
 minutes/sessions, minutes by technique, longest session, favorite technique, total
 breaths
 - Provider: final localStatsProvider = FutureProvider<StatsSnapshot>((ref) async { ...
 }); — reads from session repository, computes, caches in stats_cache table

 lib/features/stats/data/stats_cache_repository.dart
 - Reads/writes stats_cache Drift table
 - Future<StatsSnapshot?> readCached(), Future<void> writeCache(StatsSnapshot)
 - Provider: final statsCacheRepositoryProvider = Provider<StatsCacheRepository>((ref) =>
  ...);

 Files to modify

 - lib/features/session/presentation/session_completion_screen.dart — wire real streak
 from localStatsProvider; show "Day X streak!" or "Streak started!" or "Keep going — X
 min toward today's streak"

 Tests (critical — streak logic is complex)

 - test/features/stats/domain/streak_calculator_test.dart:
   - 2-minute threshold: 1 min day doesn't count, 2 min does
   - Consecutive days: 3 days in a row = 3
   - Gap resets: miss a day = 0
   - Today counts if >= 2 min
   - Yesterday counts (session done yesterday, none today = streak still alive for
 display purposes)
   - Empty data = 0
   - Timezone edge: sessions near midnight with different offsets assigned to correct
 local days
 - test/features/stats/domain/stats_engine_test.dart:
   - Correct all-time totals
   - Weekly boundary (Monday start, Monday = first day)
   - Minutes by technique aggregation
   - Longest session detection
   - Favorite technique = most minutes
 - Run: flutter test + flutter analyze

 ---
 Phase 9 — Favorites System (DONE)

 Objective: Toggle favorite techniques, persist in Drift, expose via providers for use in
  technique cards, detail screen, and home screen favorites row.

 Files to create

 lib/features/techniques/domain/favorites_repository.dart
 - Methods: Future<void> add(String techniqueId), Future<void> remove(String
 techniqueId), Future<void> toggle(String techniqueId), Future<bool> isFavorite(String
 techniqueId), Future<Set<String>> allFavoriteIds(), Future<List<Technique>>
 allFavorites(List<Technique> allTechniques)
 - Provider: final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) =>
 FavoritesRepository(ref.watch(appDatabaseProvider)));

 lib/features/techniques/domain/favorites_provider.dart
 - final favoriteTechniqueIdsProvider = FutureProvider<Set<String>>((ref) =>
 ref.read(favoritesRepositoryProvider).allFavoriteIds());
 - Invalidated when favorites change

 Files to modify

 - lib/features/techniques/presentation/widgets/technique_card.dart — add heart icon
 toggle
 - lib/features/techniques/presentation/technique_detail_screen.dart — add favorite
 toggle in AppBar

 Tests

 - test/features/techniques/domain/favorites_repository_test.dart — add, remove, toggle,
 query
 - Run: flutter test + flutter analyze

 ---
 Phase 10 — Recommendation Engine + Home Screen (DONE)

 Objective: Build daypart+goal+experience recommendation logic. Replace placeholder home
 with Today's Practice card, goal shortcuts, favorites row, streak display, and weekly
 minutes chart.

 Senior dev decision: Recommendation mapping loaded from bundled JSON asset for easy
 tuning.

 Files to create

 assets/recommendations/recommendations_v1.json
 - Deterministic mapping keyed by: goal (6) × daypart (4) × experienceLevel (3)
 - Each entry: { "techniqueId": "...", "presetId": "...", "rationale": "..." }
 - Example: { "goal": "calm", "daypart": "evening", "experience": "beginner",
 "techniqueId": "diaphragmatic", "presetId": "beginner", "rationale": "Gentle belly
 breathing to wind down your evening" }

 Mapping baseline:

 ┌───────────┬──────────────────┬───────────────┬──────────────────┬──────────────────┐
 │   Goal    │     Morning      │   Afternoon   │     Evening      │      Night       │
 ├───────────┼──────────────────┼───────────────┼──────────────────┼──────────────────┤
 │ calm      │ diaphragmatic    │ ujjayi        │ diaphragmatic    │ four_seven_eight │
 ├───────────┼──────────────────┼───────────────┼──────────────────┼──────────────────┤
 │ sleep     │ four_seven_eight │ bhramari      │ four_seven_eight │ four_seven_eight │
 ├───────────┼──────────────────┼───────────────┼──────────────────┼──────────────────┤
 │ focus     │ box              │ box           │ hrv_resonance    │ box              │
 ├───────────┼──────────────────┼───────────────┼──────────────────┼──────────────────┤
 │ energy    │ kapalbhati       │ bhastrika     │ ujjayi           │ diaphragmatic    │
 ├───────────┼──────────────────┼───────────────┼──────────────────┼──────────────────┤
 │ hrv       │ hrv_resonance    │ hrv_resonance │ hrv_resonance    │ hrv_resonance    │
 ├───────────┼──────────────────┼───────────────┼──────────────────┼──────────────────┤
 │ spiritual │ yogic_three_part │ anulom_vilom  │ anulom_vilom     │ yogic_three_part │
 └───────────┴──────────────────┴───────────────┴──────────────────┴──────────────────┘

 Preset selected by experience level. Beginner gets beginner preset, etc.

 lib/features/home/domain/recommendation_engine.dart
 - Enum DayPart { morning, afternoon, evening, night }
 - DayPart currentDayPart(DateTime now) — morning 5-11, afternoon 11-17, evening 17-22,
 night 22-5
 - Class Recommendation: String techniqueId, String presetId, String rationale, Technique
  technique, TechniquePreset preset
 - Loads from assets/recommendations/recommendations_v1.json
 - Provider: final dailyRecommendationProvider = FutureProvider<Recommendation>((ref) =>
 ...); — reads onboarding answers for goal/experience, computes daypart from clock

 lib/features/home/domain/active_goal_provider.dart
 - final activeGoalProvider = StateProvider<Set<PrimaryGoal>>((ref) => ...);
 - Initialized from onboarding preferences, user can override from home shortcuts

 lib/features/home/presentation/home_screen.dart (full rewrite)
 - ScrollView:
   - Display name greeting from preferences ("Good morning, {name}" / "Good evening"
 etc.)
   - TodaysPracticeCard — recommended technique + rationale + "Start" FilledButton
   - GoalShortcutRow — 6 horizontal chips (calm, sleep, focus, energy, hrv, spiritual)
   - FavoritesRow — horizontal scroll of favorited technique mini-cards (or empty state)
   - StreakDisplay — large streak number + "day streak" label
   - WeeklyBarChart — 7 white bars Mon-Sun

 Widget files:
 - lib/features/home/presentation/widgets/todays_practice_card.dart
 - lib/features/home/presentation/widgets/goal_shortcut_row.dart
 - lib/features/home/presentation/widgets/favorites_row.dart
 - lib/features/home/presentation/widgets/streak_display.dart
 - lib/features/home/presentation/widgets/weekly_bar_chart.dart — CustomPainter, 7 white
 bars on black

 Files to modify

 - pubspec.yaml — add assets/recommendations/ to assets

 Tests

 - test/features/home/domain/recommendation_engine_test.dart — all 72 combinations (6
 goals × 4 dayparts × 3 experiences) produce valid technique
 - test/features/home/domain/day_part_test.dart — boundary tests (4:59=night,
 5:00=morning, etc.)
 - test/features/home/presentation/home_screen_test.dart — displays recommendation card,
 goal shortcuts render
 - Run: flutter test + flutter analyze

 ---
 Phase 11 — Profile + Settings + Legal Screens (DONE)

 Objective: Full Profile tab with stats display, settings controls, legal pages, account
 actions. Replace placeholder.

 Packages to install

 cd apps/mobile && flutter pub add flutter_markdown

 Assets to add

 - assets/legal/privacy.md — offline copy of privacy policy
 - assets/legal/terms.md — offline copy of terms of service

 Files to create

 lib/features/profile/presentation/profile_screen.dart (full rewrite)
 - Header: display name + deterministic avatar placeholder + edit button
 - Stats section: grid of StatsMetricTile widgets (streak, total minutes, sessions,
 weekly)
 - "View all stats" link → stats detail screen
 - Settings section: list tiles
 - Sign-in CTA card if guest

 lib/features/profile/presentation/widgets/stats_metric_tile.dart
 - Reusable: icon + value + label, dark card style

 lib/features/profile/presentation/widgets/stats_section.dart
 - Grid of metric tiles + weekly bar chart + technique breakdown

 lib/features/profile/presentation/widgets/technique_breakdown_list.dart
 - Minutes per technique with relative progress bars (white fill on dark bg)

 lib/features/stats/presentation/stats_screen.dart (full rewrite)
 - Route: /profile/stats
 - Full stats display with all computed metrics

 lib/features/settings/presentation/settings_screen.dart
 - Route: /profile/settings
 - Sections:
   - Practice: session length (2/5/10/20), haptics toggle, keep-screen-awake toggle
   - Reminders: daily reminder toggle + time picker, streak warning toggle
   - Account: sign in/out, delete account (if signed in)
   - About: version, privacy policy, terms of service, global disclaimer

 lib/features/settings/domain/settings_controller.dart
 - NotifierProvider reading/writing Drift preferences table for individual settings
 - Methods: setSessionLength(int), setHapticsEnabled(bool), setKeepScreenAwake(bool),
 setReminderEnabled(bool), setReminderTime(int), setStreakWarningEnabled(bool)

 lib/features/settings/data/settings_repository.dart
 - Wraps Drift preferences for individual setting read/write

 lib/features/profile/presentation/legal_screen.dart
 - Loads markdown from assets/legal/ via flutter_markdown
 - "Latest version" link to clearbreath.life/privacy and /terms

 Files to modify

 - lib/core/router/app_router.dart — add routes: /profile/settings, /profile/stats,
 /profile/legal/:type
 - pubspec.yaml — add assets/legal/ to assets

 Tests

 - test/features/profile/presentation/profile_screen_test.dart — renders stats, shows
 sign-in CTA for guest
 - test/features/settings/domain/settings_controller_test.dart — toggles persist
 correctly
 - Run: flutter test + flutter analyze

 ---
 Phase 12 — Auth + Backend Integration (Dev Auth First, Apple/Google Abstracted) (DONE)

 Objective: Build-time config, Dio API client with auth interceptor, dev auth flow (for
 testing), token storage, session sync, stats sync, safety ack sync.
 Apple/Google OAuth immediately after dev auth validates the flow.

 Senior dev decision: Dev auth first to validate entire flow end-to-end without App Store
  provisioning dependencies. Apple/Google Sign-In added immediately after. Abstractions
 built from day one.

 Packages to install

 cd apps/mobile && flutter pub add sign_in_with_apple google_sign_in device_info_plus

 Files to create — Config

 lib/core/config/app_config.dart
 - Reads --dart-define values:
   - API_BASE_URL (default: https://api.clearbreath.life)
   - DEV_AUTH_ENABLED (default: false)
   - DEV_AUTH_SECRET (debug only)
 - Class AppConfig with static getters
 - Build command: flutter run --dart-define=API_BASE_URL=http://localhost:8080
 --dart-define=DEV_AUTH_ENABLED=true --dart-define=DEV_AUTH_SECRET=test-secret

 Files to create — Network

 lib/core/network/api_client.dart
 - Dio instance with baseUrl from AppConfig.apiBaseUrl
 - JSON content type headers
 - Provider: final apiClientProvider = Provider<Dio>((ref) => ...);

 lib/core/network/api_error.dart
 - Class ApiError: String error, String code, String? requestId
 - Parses backend error envelope {"error": "...", "code": "...", "request_id": "..."}

 lib/core/network/auth_interceptor.dart
 - Reads access token from TokenStorage, adds Authorization: Bearer header
 - On 401: attempt single token refresh via /v1/auth/refresh, retry original request
 - On refresh failure (401/409): clear tokens, set auth state to guest (hard sign-out)
 - Never infinite-loop refresh — cap to 1 retry per request
 - Thread-safe: queues concurrent 401 responses, refreshes once, replays all

 lib/core/network/models/ — all 6 model files as specified in Architecture section above

 Files to create — Auth

 lib/shared/secure_storage/secure_storage.dart
 - Wrapper around FlutterSecureStorage with typed methods

 lib/features/auth/data/token_storage.dart
 - Methods: readAccessToken(), readRefreshToken(), writeTokens(AuthTokens), clearAll(),
 hasTokens()
 - Class AuthTokens: accessToken, accessTokenExpiresAt, refreshToken,
 refreshTokenExpiresAt

 lib/features/auth/data/device_id_store.dart
 - Generates random UUID on first call, persists in secure storage, returns same ID on
 subsequent calls
 - Provider: final deviceIdProvider = FutureProvider<String>((ref) => ...);

 lib/features/auth/data/auth_repository.dart
 - Methods: signInWithProvider(String provider, String idToken, String deviceId),
 refreshToken(String refreshToken, String deviceId), logout(String deviceId),
  deleteAccount(), fetchProfile(), updateProfile(MePatchRequest)
 - Calls API endpoints via Dio

 lib/features/auth/domain/auth_controller.dart (replaces AuthStateController)
 - Full flow: provider sign-in → API call → store tokens → update auth state
 - Methods: signIn(AuthProvider provider), signOut(), deleteAccount(), restoreSession()
 (check stored tokens on app start, refresh if expired)
 - On first sign-in: if onboarding displayName is non-empty, PATCH /v1/me to set it
 (handle profanity validation errors gracefully)

 lib/features/auth/presentation/sign_in_screen.dart
 - Route: /auth/sign-in
 - ClearBreath logo + brand copy
 - "Sign in with Apple" button, "Sign in with Google" button
 - If DEV_AUTH_ENABLED: additional "Dev Sign In" button
 - Loading states, error handling

 Files to create — Sync

 lib/features/sync/domain/sync_state.dart
 - Sealed: SyncIdle, SyncInProgress(String message), SyncComplete(int accepted, int
 duplicates, int rejected), SyncFailed(String error)

 lib/features/sync/domain/sync_controller.dart
 - On sign-in: bulk sync ALL unsynced local sessions via POST /v1/sessions/sync (up to
 500)
 - On session completion (if signed in): submit single session via POST
 /v1/sessions/submit
 - Parse response: mark accepted as synced in Drift, update stats cache from returned
 stats_snapshot
 - Provider: final syncControllerProvider = NotifierProvider<SyncController,
 SyncState>(...);

 lib/features/sync/data/sync_repository.dart
 - Builds SessionSubmitPayload list from LocalSession list
 - Calls API, parses SessionsIngestResponse

 lib/features/stats/data/cloud_stats_repository.dart
 - Calls GET /v1/stats/snapshot when signed in
 - Returns authoritative StatsSnapshot
 - Provider: final cloudStatsProvider = FutureProvider<StatsSnapshot?>((ref) => ...);

 lib/features/sync/domain/merged_stats_provider.dart
 - If signed in + cloud stats available → use cloud stats (server-authoritative)
 - If guest or offline → use local stats
 - final mergedStatsProvider = FutureProvider<StatsSnapshot>((ref) => ...);

 lib/features/techniques/data/safety_sync_service.dart
 - On sign-in: pull GET /v1/me/safety_acknowledgements, merge with local safety_ack table
 - On local acknowledge (if signed in): push POST /v1/me/safety_acknowledgements

 Files to modify

 - lib/features/auth/domain/auth_state.dart — extend AuthStateSignedIn to include
 UserProfile
 - lib/features/auth/domain/auth_state_provider.dart — rewire to use new AuthController
 - lib/core/router/app_router.dart — add route /auth/sign-in
 - lib/features/leaderboard/presentation/leaderboard_locked_screen.dart — sign-in button
 navigates to /auth/sign-in instead of snackbar
 - lib/features/session/domain/session_controller.dart — after completion, trigger sync
 if signed in
 - All stats consumers — switch from localStatsProvider to mergedStatsProvider

 Tests

 - test/features/auth/domain/auth_controller_test.dart — sign-in stores tokens, sign-out
 clears, restore checks stored tokens
 - test/core/network/auth_interceptor_test.dart — attaches token, refreshes on 401, hard
 sign-out on refresh failure, single-flight refresh
 - test/features/sync/domain/sync_controller_test.dart — triggers on sign-in, handles
 accepted/duplicates/rejected
 - test/features/sync/data/sync_repository_test.dart — builds correct payloads
 - Run: flutter test + flutter analyze

 ---
 Phase 13 — Leaderboard UI (Online + Cached Offline) (DONE)

 Objective: Three ranking views (streak, weekly, all-time), top 50 list, pinned
 self-rank, cached offline display, privacy controls.

 Senior dev decision: Cache leaderboard in Drift. When fetch fails, show cached results +
  "Couldn't refresh" banner.

 Files to create

 lib/features/leaderboard/domain/leaderboard_entry.dart
 - Class: int rank, String displayNameOrInitials, String avatarSeed, int metricValue,
 String? userId

 lib/features/leaderboard/domain/leaderboard_ranking.dart
 - Enum LeaderboardRanking { streak, weekly, allTime }
 - Extension with String toQueryParam() returning "streak", "weekly", "all_time"

 lib/features/leaderboard/data/leaderboard_repository.dart
 - Future<List<LeaderboardEntry>> fetchList(LeaderboardRanking, {int limit = 50}) → GET
 /v1/leaderboard?ranking=...&limit=50
 - Future<LeaderboardEntry?> fetchSelf(LeaderboardRanking) → GET
 /v1/leaderboard/self?ranking=...
 - Caches results to leaderboard_cache Drift table on success
 - On fetch failure: reads from cache, returns cached + error flag

 lib/features/leaderboard/domain/leaderboard_controller.dart
 - NotifierProvider managing: selected ranking, list data, self-rank,
 loading/error/cached states, refresh

 lib/features/leaderboard/presentation/leaderboard_screen.dart (replace existing)
 - If guest → show existing LeaderboardLockedScreen
 - If signed in → ranking selector (3 pills), scrollable top 50 list, pinned self-rank
 card at bottom
 - Pull-to-refresh
 - "Last updated X min ago" timestamp
 - Offline: show cached data + "Couldn't refresh" banner

 lib/features/leaderboard/presentation/widgets/leaderboard_row.dart
 - Rank number, avatar circle (deterministic from seed), display name/initials, metric
 value
 - Highlight own row

 lib/features/leaderboard/presentation/widgets/ranking_selector.dart
 - Three-way segmented toggle

 lib/features/leaderboard/presentation/widgets/self_rank_card.dart
 - Sticky card at bottom: own rank (even outside top 50) + metric value

 Privacy controls (in Profile settings from Phase 11)

 - Toggle leaderboardOptIn → PATCH /v1/me
 - Toggle leaderboardInitialsOnly → PATCH /v1/me
 - Update local state immediately on server confirmation

 Tests

 - test/features/leaderboard/data/leaderboard_repository_test.dart — parses API response,
  caches, serves cached on failure
 - test/features/leaderboard/presentation/leaderboard_screen_test.dart — ranking toggle,
 self-rank visible, guest sees locked
 - Run: flutter test + flutter analyze

 ---
 Phase 14 — Notifications (Daily Reminder + Streak Warning) (DONE)

 Objective: Local notifications for daily practice reminder and streak-at-risk warning.
 Permission requested only after first completed session.

 Packages to install

 cd apps/mobile && flutter pub add flutter_local_notifications timezone

 Files to create

 lib/features/notifications/domain/notification_service.dart
 - scheduleDailyReminder(TimeOfDay time) — repeating daily local notification
 - scheduleStreakWarning() — one-shot at (local midnight - 2 hours) if active streak and
 no qualifying session today
 - cancelDailyReminder(), cancelStreakWarning(), cancelAll()
 - requestPermission() — OS notification permission prompt

 lib/features/notifications/domain/notification_controller.dart
 - NotifierProvider coordinating settings + stats
 - Persist firstSessionCompleted and permissionAsked flags
 - After first completed session: show in-app explanation then trigger OS permission
 - On settings change: reschedule as appropriate

 lib/features/notifications/domain/streak_warning_scheduler.dart
 - Pure function: DateTime? nextStreakWarningTime(int currentStreakDays, bool
 hasQualifyingSessionToday, DateTime now)
 - Returns null if no streak or already qualified today
 - Returns 22:00 local time if streak active and not qualified

 Files to modify

 - lib/features/session/domain/session_controller.dart — after first-ever completion,
 trigger notification permission flow; after any completion, reschedule streak warning
 - lib/features/settings/presentation/settings_screen.dart — wire reminder toggle + time
 picker, streak warning toggle
 - lib/core/database/tables/preferences.dart — add reminderEnabled bool (default true),
 streakWarningEnabled bool (default true) columns if not present

 Tests

 - test/features/notifications/domain/streak_warning_scheduler_test.dart — fires at 22:00
  when streak active + no session, null when session completed, null when no streak
 - test/features/notifications/domain/notification_controller_test.dart — schedules on
 settings change, permission only after first session
 - Run: flutter test + flutter analyze

 ---
 Phase 15 — Share Card (DONE)

 Objective: Shareable image card with streak + ClearBreath branding. No PII.

 Packages to install

 cd apps/mobile && flutter pub add share_plus

 Files to create

 lib/features/share/domain/share_card_renderer.dart
 - Uses RepaintBoundary → RenderRepaintBoundary.toImage() → PNG bytes
 - Saves to temp directory via path_provider
 - Shares file via share_plus

 lib/features/share/presentation/share_card_widget.dart
 - Visual: black background, Manrope white text, streak number, "X day streak",
 ClearBreath logo mark, "2 min today" line
 - 1080×1080 aspect ratio
 - No PII

 lib/features/share/presentation/share_button.dart
 - Button widget that triggers render + share sheet

 Files to modify

 - lib/features/session/presentation/session_completion_screen.dart — wire "Share" button
  to ShareButton

 Tests

 - test/features/share/domain/share_card_renderer_test.dart — generates non-empty bytes
 - Run: flutter test + flutter analyze

 ---
 Phase 16 — Polish + Accessibility + Release Prep (DONE)

 Objective: Accessibility pass, performance verification, regression testing, store
 readiness.

 Tasks

 1. Accessibility pass:
   - Semantics labels on key interactive controls
   - Text scaling verification (1x, 1.5x, 2x)
   - Contrast checks (dark theme tokens already good — verify)
   - Screen reader navigation order
 2. Performance verification:
   - Session timing drift test: run 20-minute session, verify drift ≤ 0.5%
   - Leaderboard scroll performance with 50 items
   - Technique grid scroll performance
 3. Global disclaimer in settings/about:
 "ClearBreath is for wellness and relaxation purposes only. It is not medical advice..."
 4. Final regression suite:
   - All tests green (flutter test)
   - Zero analyzer warnings (flutter analyze)
   - Manual smoke test checklist (see Verification Plan below)
 5. Build verification:
 flutter build apk --release
 flutter build ios --release

 ---
 Dependency Graph

 Phase 0 (Toolchain)
   └→ Phase 1 (Fix Bugs)
        └→ Phase 2 (Technique JSON Data)
             ├→ Phase 3 (Database Expansion)
             │    ├→ Phase 4 (Technique UI + Safety)
             │    │    └→ Phase 9 (Favorites)
             │    ├→ Phase 7 (Session Persistence)
             │    │    └→ Phase 8 (Stats + Streak)
             │    │         ├→ Phase 10 (Home + Recommendations) [+Phase 9]
             │    │         ├→ Phase 11 (Profile + Settings + Legal)
             │    │         └→ Phase 14 (Notifications) [+Phase 11]
             │    └→ Phase 12 (Auth + Backend Sync) [+Phase 7, +Phase 8]
             │         └→ Phase 13 (Leaderboard) [+Phase 11]
             └→ Phase 5 (Session Engine + Animations)
                  └→ Phase 6 (Audio + Background + Wakelock)
                       └→ Phase 15 (Share Card) [+Phase 8]

 Phase 16 (Polish) — after all above

 Suggested execution order (respecting dependencies):
 0 → 1 → 2 → 3 → 4+5 (parallel) → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16

 ---
 Verification Plan

 After each phase: flutter test + flutter analyze

 After all phases, manual smoke test on iOS simulator + Android emulator:

 - Cold launch → splash → onboarding (first run)
 - App restart → skips intro + onboarding (persistence)
 - Home shows recommendation based on goal + time of day
 - Switch goal on home → recommendation updates
 - Technique grid shows 11 techniques
 - Technique detail shows presets, start button works
 - Safety warning fires for kapalbhati/bhastrika/ultra_slow (first time only)
 - Session with circle animation (e.g., box breathing)
 - Session with metronome animation (e.g., kapalbhati) with rounds + rest
 - Session with alternate nostril (anulom vilom)
 - Pause/resume/stop during session
 - Audio cues play on phase transitions
 - Haptics fire on transitions (when enabled)
 - Session completes → completion screen with correct stats
 - Streak increments after 2+ minutes in a day
 - Streak does NOT increment for <2 minutes
 - Favorites toggle from card and detail screen
 - Home favorites row shows favorited techniques
 - Profile shows correct stats
 - Settings: all toggles persist across app restart
 - Settings: session length options are 2/5/10/20
 - Legal: privacy and terms render markdown
 - Sign in with dev auth → sessions sync → leaderboard unlocks
 - Leaderboard: 3 ranking views, self-rank pinned
 - Leaderboard: offline shows cached + error banner
 - Background: session continues when app backgrounds
 - Lock screen: pause/stop controls work
 - Audio interruption (simulate call): auto-pause
 - Keep-screen-awake: screen stays on during session
 - Daily reminder notification fires at set time
 - Streak warning fires at 22:00 if no qualifying session
 - Share card generates and opens share sheet
 - Global disclaimer visible in about section
 - Build: flutter build apk --release succeeds
 - Build: flutter build ios --release succeeds

 ---
 Key Additions from Senior Dev's Plan (Merged In)

 These items were in the senior dev's plan and are now fully incorporated:

 1. Phase 0 — Toolchain fix (FVM-friendly Makefile, SDK constraint)
 2. IntroGate persistence bug — intro re-shows on restart (Phase 1)
 3. Session length PRD mismatch — 5/10/15/30 should be 2/5/10/20 (Phase 1)
 4. Technique JSON as source-of-truth — not hardcoded Dart (Phase 2)
 5. Three animation modes — circle + metronome + alternate_nostril (Phase 5)
 6. Round-based rapid techniques — kapalbhati/bhastrika with rounds + rest periods (Phase
  5)
 7. SessionPlan architecture — sealed class with PhaseSessionPlan + RoundSessionPlan
 (Phase 5)
 8. Build-time config — --dart-define for API_BASE_URL, DEV_AUTH_ENABLED (Phase 12)
 9. Centralized API models — core/network/models/ directory (Phase 12)
 10. Device ID — random UUID in secure storage (Phase 12)
 11. Dev auth first — validate flow before Apple/Google provisioning (Phase 12)
 12. Display name sync — onboarding name → PATCH /v1/me on first sign-in (Phase 12)
 13. Leaderboard caching — Drift table, offline display + error banner (Phase 13)
 14. Stats cache table — avoid recomputing from scratch (Phase 8)
 15. Sync queue table — reliability for offline-to-online transitions (Phase 3)
 16. Legal screens — offline markdown + web links (Phase 11)
 17. Recommendation JSON asset — tunable without code changes (Phase 10)
 18. Accessibility pass — semantics, scaling, contrast (Phase 16)
 19. mobile-pub-add Make target — standardized package installation (Phase 0)

 ---
 Key Patterns to Follow (from Existing Codebase)

 Pattern: Provider naming
 Convention: camelCaseProvider
 Example: sessionControllerProvider
 ────────────────────────────────────────
 Pattern: Notifier
 Convention: NotifierProvider<Controller, State>(Controller.new)
 Example: session_controller.dart:6
 ────────────────────────────────────────
 Pattern: Theme access
 Convention: final colors = Theme.of(context).extension<AppColorTokens>()!;
 Example: Every screen
 ────────────────────────────────────────
 Pattern: Immutable state
 Convention: @immutable + copyWith()
 Example: session_state.dart
 ────────────────────────────────────────
 Pattern: Sealed union
 Convention: sealed class TypeName
 Example: auth_state.dart
 ────────────────────────────────────────
 Pattern: Repository
 Convention: Constructor takes AppDatabase, methods return domain types
 Example: onboarding_repository.dart
 ────────────────────────────────────────
 Pattern: DB provider
 Convention: ref.watch(appDatabaseProvider)
 Example: app_database_provider.dart
 ────────────────────────────────────────
 Pattern: Navigation
 Convention: context.push('/path') or context.go('/path')
 Example: home_screen.dart
 ────────────────────────────────────────
 Pattern: Error snackbar
 Convention: inverseSurface bg, inverseText color, floating, rounded
 Example: onboarding_screen.dart:287-299
 ────────────────────────────────────────
 Pattern: No comments
 Convention: Zero comments in all production code
 Example: Entire codebase
 ────────────────────────────────────────
 Pattern: Test keys
 Convention: Key('descriptive_key') for testability
 Example: session_screen.dart

 ---
 Explicit Assumptions (Locked)

 - Production API: https://api.clearbreath.life
 - No analytics events in v1
 - Technique copy is placeholder text initially (reviewed/replaced later)
 - Audio assets are placeholders until real files are dropped in
 - No voice guidance in v1
 - No monetization in v1
 - No crash/error tracking in v1
 - iOS-first priority for testing, Android follows
