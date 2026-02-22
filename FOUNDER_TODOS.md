# Founder TODOs — ClearBreath Monorepo

Last updated: 2026-02-22

This is a checklist of external setup and manual verification steps that are not fully solved by code alone.

## OAuth / Identity (Required for production sign-in)

- Google OAuth client IDs
  - Create Android + iOS OAuth client IDs in Google Cloud Console for the app bundle/package id `life.clearbreath.clearbreath`.
  - Set backend env `GOOGLE_OAUTH_CLIENT_ID` for staging/prod (`server/internal/config/config.go:204`).
  - Configure iOS URL scheme(s) and any required plist entries for `google_sign_in` (no `GoogleService-Info.plist` currently present).
- Apple Sign In
  - Enable “Sign In with Apple” for the iOS bundle id `life.clearbreath.clearbreath` (`apps/mobile/ios/Runner.xcodeproj/project.pbxproj:480`).
  - Add `Runner.entitlements` with the Apple Sign In capability and wire it in Xcode (no `*.entitlements` exists in `apps/mobile/ios/`).
  - Set backend env `APPLE_OAUTH_AUDIENCE` for staging/prod (`server/internal/config/config.go:207`).

## Backend local run (manual)

- Start dependencies: `make docker-up` (Postgres `:5433`, Redis `:6380`, see `docker-compose.dev.yml`).
- Run API: `make server-dev`
- Required env for local dev auth + JWTs (minimum)
  - `ENV=development`
  - `DEV_AUTH_ENABLED=true`
  - `DEV_AUTH_SECRET=<same value mobile uses>`
  - `JWT_ACCESS_SECRET=<32+ chars>`
  - `JWT_REFRESH_SECRET=<32+ chars>`
- Smoke test:
  - Run the curl checklist in `docs/backend_curl_smoke.md`.
  - Run integration tests: `make server-test-integration` (requires Postgres + Redis running).

## Backend production deploy (manual)

- Provision managed Postgres + Redis, then configure required env vars (see `docs/final_plan.md:906`).
- Set `TECHNIQUE_REGISTRY_PATH` to a readable registry file path in the deployed container (uses `server/registry/techniques.json` in this repo).
- Disable dev auth in production:
  - `DEV_AUTH_ENABLED=false`
  - Do not set `DEV_AUTH_SECRET` in prod
- Configure strict `CORS_ORIGINS` for the website domain(s).
- Validate migrations + backups + rollback procedure before first real users.

## Mobile local run (manual)

- Run app: `make FLUTTER=/home/rahul/sdk/flutter/bin/flutter mobile-run`
- For local backend testing (dev auth):
  - `--dart-define=API_BASE_URL=http://localhost:8080`
  - `--dart-define=DEV_AUTH_ENABLED=true`
  - `--dart-define=DEV_AUTH_SECRET=<same as backend>`
- Manual checks that require device testing:
  - Background audio + lock-screen controls (iOS + Android).
  - Notification delivery and time-based scheduling behavior.
  - Apple/Google sign-in on real devices after credentials + capabilities are configured.

## Android release

- Replace debug signing in release builds with a real keystore (`apps/mobile/android/app/build.gradle.kts:32` uses debug signing).
- Confirm Play Store release workflow (App Bundle build, signing, upload).

## iOS release

- Provisioning profiles + signing (Xcode).
- Verify `UIBackgroundModes` includes audio (present in `apps/mobile/ios/Runner/Info.plist:21`).

## Assets / Branding

- Replace placeholder audio cue MP3s with final CC0/licensed files:
  - `apps/mobile/assets/audio/inhale_cue.mp3`
  - `apps/mobile/assets/audio/hold_cue.mp3`
  - `apps/mobile/assets/audio/exhale_cue.mp3`
  - `apps/mobile/assets/audio/tick.mp3`
  - `apps/mobile/assets/audio/session_complete.mp3`
- Decide whether to ship real background soundscapes in v1 (beyond silence) and, if yes, add assets + selection UI + hosting/downloading strategy.
- Store listing assets: screenshots, promo images, privacy policy links, and final app icon review.

## Website publishing (Required for store links + legal URLs)

- Deploy `apps/web` and verify routes render:
  - `/` (landing)
  - `/privacy` (privacy)
  - `/terms` (terms)
  - 12 SEO pages (see `apps/web/src/lib/seo_pages.ts:11`)
- Add final App Store / Play Store URLs to the download section:
  - `apps/web/src/pages/index.astro:67`
- Confirm canonical domain is correct and HTTPS is enforced:
  - `apps/web/astro.config.mjs:5`

## Store compliance and release verification (Manual)

- iOS App Store Connect
  - Add privacy policy URL `https://clearbreath.life/privacy`
  - Add terms URL `https://clearbreath.life/terms`
- Android Play Console
  - Provide privacy policy URL and data safety form responses aligned with app behavior
- Run the manual smoke checklist in `final-mobile-plan.md:1416` on real devices.
