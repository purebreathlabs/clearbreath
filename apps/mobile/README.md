# ClearBreath Mobile App

The ClearBreath mobile app is the Flutter client for guided pranayama sessions,
streaks, XP, stats, leaderboards, notifications, and local progress tracking.

## Prerequisites

- Flutter 3.38+
- Android Studio and Android SDK for Android development
- Xcode for iOS development

If Flutter is not on your `PATH`, pass `FLUTTER=~/sdk/flutter/bin/flutter` to
mobile `make` commands.

## Run the App

Install dependencies:

```bash
make mobile-get
```

Run the app:

```bash
make mobile-run
```

By default, the app points at the hosted API.
If you want to test against a local backend on an Android emulator, start the
backend first and then run:

```bash
make docker-up
make server-dev
make mobile-run API_BASE_URL=http://10.0.2.2:8080 MOBILE_RUN_ARGS="--dart-define=DEV_AUTH_ENABLED=true"
```

For a physical Android device on the same Wi-Fi network, replace `10.0.2.2`
with your machine's local IP address.

See the [root README](../../README.md#quick-start) for broader local development
setup and backend notes.

## Project Structure

- `lib/core/` holds app configuration, routing, theme, networking, and database
  foundations
- `lib/features/` contains product features grouped by domain
- `lib/shared/` contains reusable widgets, providers, utilities, and storage
  helpers

## Testing

```bash
make mobile-analyze
make mobile-test
```

## Contributing

Review the root [CONTRIBUTING.md](../../CONTRIBUTING.md) for pull request
guidelines, branching rules, and contributor expectations.
