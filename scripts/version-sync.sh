#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="$(cat "$REPO_ROOT/VERSION" | tr -d '[:space:]')"
BUILD="$(git -C "$REPO_ROOT" rev-list --count HEAD 2>/dev/null || echo 1)"

update_json() {
  node -e "
    const fs = require('fs');
    const p = JSON.parse(fs.readFileSync('$1', 'utf8'));
    p.version = '$VER';
    fs.writeFileSync('$1', JSON.stringify(p, null, 2) + '\n');
  "
}

update_json "$REPO_ROOT/package.json"
update_json "$REPO_ROOT/apps/web/package.json"

perl -i -pe "s/^version: .*/version: ${VER}+${BUILD}/" "$REPO_ROOT/apps/mobile/pubspec.yaml"

echo "Synced v${VER}+${BUILD} across all packages"
