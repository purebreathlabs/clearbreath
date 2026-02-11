#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="$(cat "$REPO_ROOT/VERSION" | tr -d '[:space:]')"
PART="${1:-}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$VER"

case "$PART" in
  patch) PATCH=$((PATCH + 1)) ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  *) echo "Usage: version-bump.sh <patch|minor|major>" && exit 1 ;;
esac

NEW="${MAJOR}.${MINOR}.${PATCH}"
echo "$NEW" > "$REPO_ROOT/VERSION"
echo "Bumped $VER -> $NEW"

bash "$REPO_ROOT/scripts/version-sync.sh"
