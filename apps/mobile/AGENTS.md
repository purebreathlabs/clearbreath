# AGENTS.md — Flutter Mobile

## Commands (from repo root)
- Run: `make mobile-run`
- Analyze: `make mobile-analyze`
- Get deps: `make mobile-get`
- Build APK: `make mobile-build`
- Drift codegen: `cd apps/mobile && dart run build_runner build`

## Stack
- State: Riverpod (flutter_riverpod)
- Routing: go_router with route guards
- Local DB: Drift (type-safe SQLite)
- HTTP: Dio
- Audio: just_audio
- Wakelock: wakelock_plus
- Secure storage: flutter_secure_storage

## Code style
- Never write comments in code. Not a single line. Not even TODOs.
- Use Riverpod providers for all shared state. Feature-scoped providers.
- Follow feature-based folder structure: `features/<name>/presentation/`, `features/<name>/data/`, `features/<name>/domain/`.
- Shared widgets go in `shared/widgets/`. Shared providers in `shared/providers/`.
- Theme is dark-only, Material3. All colors from `core/theme/app_theme.dart`.
- Typeface: Manrope. Do not introduce other fonts.
- Lint rules: flutter_lints. Run `make mobile-analyze` and fix all warnings before committing.

## Project structure
- `lib/main.dart` — ProviderScope entry
- `lib/app.dart` — MaterialApp.router with GoRouter
- `lib/core/theme/` — dark theme, design tokens
- `lib/core/router/` — GoRouter config and route guards
- `lib/core/constants/` — app-wide constants
- `lib/features/` — feature modules (home, session, techniques, stats, leaderboard, auth, onboarding, settings)
- `lib/shared/providers/` — cross-feature Riverpod providers
- `lib/shared/widgets/` — reusable widgets
