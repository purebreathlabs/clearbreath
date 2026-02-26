# Founder TODOs — ClearBreath Monorepo

Last updated: 2026-02-22

This is a checklist of external setup and manual verification steps that are not fully solved by code alone.

## OAuth / Identity (Required for production sign-in)

- Google OAuth client IDs
  - [x] Created Android + iOS + Web OAuth client IDs in Google Cloud Console for `life.clearbreath.clearbreath`.
  - [x] Backend env `GOOGLE_OAUTH_CLIENT_ID` set in `server/.env` (Web client ID).
  - [x] `serverClientId` + `clientId` configured in `sign_in_screen.dart`.
  - [x] iOS `Info.plist` configured with `GIDClientID` and `CFBundleURLSchemes`.
  - [x] Release keystore SHA-1 registered in Google Cloud Console as separate Android client.
  - Google OAuth Client ID reference:
    - Web: `884656805579-ptcbmv99ha49rcfm7lelagp5e0ooeepm.apps.googleusercontent.com` (backend token verification)
    - Android debug: `884656805579-i2irrcd5dnr8iup04jh0d096665u8ieb.apps.googleusercontent.com`
    - Android release: `884656805579-frpshahbr2hf92c187quctgbdadl5bgb.apps.googleusercontent.com`
    - iOS: `884656805579-kb298tik2g9e92fi5dbn5nas1ivlsvhl.apps.googleusercontent.com`
- Apple Sign In
  - Enable “Sign In with Apple” for the iOS bundle id `life.clearbreath.clearbreath` (`apps/mobile/ios/Runner.xcodeproj/project.pbxproj:480`).
  - Add `Runner.entitlements` with the Apple Sign In capability and wire it in Xcode (no `*.entitlements` exists in `apps/mobile/ios/`).
  - [x] Backend env `APPLE_OAUTH_AUDIENCE` set in `server/.env`.

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

- Emulator: `make mobile-run MOBILE_RUN_ARGS="--dart-define=API_BASE_URL=http://10.0.2.2:8080 --dart-define=DEV_AUTH_ENABLED=true"`
- Physical device (same WiFi): `make mobile-run MOBILE_RUN_ARGS="--dart-define=API_BASE_URL=http://<your-ip>:8080 --dart-define=DEV_AUTH_ENABLED=true"`
- Release APK for local testing: `flutter build apk --release --split-per-abi --dart-define=API_BASE_URL=http://<your-ip>:8080 --dart-define=DEV_AUTH_ENABLED=true --dart-define=DEV_AUTH_SECRET=dev_secret_change_me`
- Google Sign-In works on debug builds when debug SHA-1 is registered in Google Cloud Console.
- Manual checks that require device testing:
  - Background audio + lock-screen controls (iOS + Android).
  - Notification delivery and time-based scheduling behavior.
  - Google sign-in on emulator/device (requires Google Play Services).

## Android release

- [x] Release keystore created at `apps/mobile/android/app/clearbreath-release.keystore` (gitignored).
- [x] `key.properties` configured at `apps/mobile/android/app/key.properties` (gitignored).
- [x] `build.gradle.kts` loads `key.properties` for release signing, falls back to debug if absent.
- [ ] Back up keystore + password securely (losing it means you cannot update the app on Play Store).
- [ ] Confirm Play Store release workflow (App Bundle build, signing, upload).

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
