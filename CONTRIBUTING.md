# Contributing to ClearBreath

## Welcome

Thanks for your interest in contributing to ClearBreath.
Please review [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before participating.

## How to Contribute

- Use GitHub Issues for bugs and feature requests
- Use GitHub Discussions for questions once they are enabled
- Until Discussions are enabled, open a blank issue for questions that need
  project maintainer input
- Open pull requests for code, docs, tests, and workflow improvements

## Setting Up Local Development

### Prerequisites

- Go 1.25+
- Flutter 3.38+
- Bun 1.3+
- PostgreSQL 17
- Redis 7+
- Docker

If Flutter is not on your `PATH`, pass `FLUTTER=~/sdk/flutter/bin/flutter` to
mobile `make` commands.

### Initial Setup

```bash
git clone https://github.com/purebreathlabs/clearbreath.git
cd clearbreath
make setup
cp .env.example server/.env
make docker-up
```

### Running the Project

Start the backend:

```bash
make server-dev
```

Start the mobile app:

```bash
make mobile-run
```

For Android emulator testing against your local API:

```bash
make mobile-run API_BASE_URL=http://10.0.2.2:8080 MOBILE_RUN_ARGS="--dart-define=DEV_AUTH_ENABLED=true"
```

Start the landing page:

```bash
make web-dev
```

## Running Tests Locally

```bash
make server-test
make server-lint
make mobile-analyze
make mobile-test
make web-build
```

## Pull Request Guidelines

- Target the `dev` branch, never `main`
- Explain what changed and why
- Keep each pull request focused on one fix or feature
- Include before and after screenshots for UI changes
- Use American English in all documentation and UI text
- Ensure local checks and CI pass before requesting review
- Add an entry under `[Unreleased]` in [CHANGELOG.md](CHANGELOG.md) when
  applicable

## AI-Assisted PRs

AI-assisted contributions are welcome.

If you used Codex, Claude, ChatGPT, Cursor, or similar tools, document that in
your pull request description and include:

- Which parts of the change were AI-assisted
- How much of the implementation and testing you personally verified
- Whether you ran a Codex review or comparable final review pass on the diff
- Prompts, session logs, or summaries that materially help reviewers understand
  the change
- Confirmation that you understand the code you are submitting
- Confirmation that you resolved any outstanding bot comments or suggested
  follow-up work before requesting review

AI assistance does not transfer responsibility.
Do not submit code you do not understand, cannot explain, or did not review
carefully yourself.

## Branching Strategy

- `dev` is the integration branch and all contributor pull requests should
  target it
- `main` is the release branch and maintainers merge `dev` into `main` for
  releases
- Releases are tagged from `main`, for example `v0.1.0`

## Maintainers

Current maintainer:

- Rahul Mistry ([`@prodigyrahul`](https://github.com/prodigyrahul))

## Becoming a Maintainer

We are selectively expanding the maintainer team.

If you want to help shape ClearBreath through code, documentation, or community
work, email `rahulmistry.sde@gmail.com` with:

- Links to your ClearBreath pull requests
- Links to other open-source projects you maintain or actively contribute to
- Your Discord, GitHub, and X handles
- A short introduction, preferably written without AI
- Your language, location, and realistic time availability

Being a maintainer is a responsibility, not an honorary title.
We review applications carefully and add maintainers slowly and deliberately.
Please allow a few weeks for a response.

## Style Guide

- Follow existing project structure and naming conventions
- Do not add code comments unless a required tool directive demands it
- Use American English in documentation and UI text
- Do not use emdashes in documentation
