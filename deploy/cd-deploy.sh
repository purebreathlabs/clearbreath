#!/usr/bin/env bash
#
# ClearBreath CD Auto-Deploy Script
# ==================================
# Safe, non-interactive deployment with rollback on failure.
# Designed to be called by GitHub Actions after CI passes.
#
# Usage: bash deploy/cd-deploy.sh
#
# Safety: If migration, startup, or health check fails,
# the previous binary is restored and the service restarted.
#

set -euo pipefail

# Ensure Go and user binaries are in PATH (non-login SSH sessions skip .profile)
export PATH="/usr/local/go/bin:/home/rahul/go/bin:${PATH}"

# ── Configuration ──────────────────────────────────────────────────────
PROJECT_DIR="/home/rahul/production/clearbreath"
DEPLOY_DIR="/opt/clearbreath"
SERVER_DIR="${PROJECT_DIR}/server"
MIGRATIONS_DIR="${SERVER_DIR}/migrations"
BINARY_DST="${DEPLOY_DIR}/api"
BINARY_BACKUP="${DEPLOY_DIR}/api.backup"
GOOSE="/home/rahul/go/bin/goose"
SERVICE_NAME="clearbreath-api"

ROLLED_BACK=false

# ── Helpers ────────────────────────────────────────────────────────────
log()  { echo "==> $*"; }
ok()   { echo "  OK: $*"; }
fail() { echo "  FAIL: $*" >&2; }

rollback() {
    if [[ "${ROLLED_BACK}" == "true" ]]; then
        return
    fi
    ROLLED_BACK=true

    echo ""
    fail "Deployment failed — rolling back..."

    if [[ -f "${BINARY_BACKUP}" ]]; then
        sudo cp "${BINARY_BACKUP}" "${BINARY_DST}"
        sudo chown clearbreath:clearbreath "${BINARY_DST}"
        sudo chmod 755 "${BINARY_DST}"
        ok "Restored previous binary from backup"
    fi

    sudo systemctl start "${SERVICE_NAME}" 2>/dev/null || true
    sleep 2

    if sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
        ok "Service restored and running (rolled back)"
    else
        fail "Service could not be restored — manual intervention needed"
        fail "Check: sudo journalctl -u ${SERVICE_NAME} -n 50"
    fi
}

# ── Pre-flight checks ─────────────────────────────────────────────────
log "Pre-flight checks..."

[[ -d "${PROJECT_DIR}" ]] || { fail "Project dir ${PROJECT_DIR} not found"; exit 1; }
[[ -d "${DEPLOY_DIR}" ]] || { fail "Deploy dir ${DEPLOY_DIR} not found"; exit 1; }
[[ -f "${DEPLOY_DIR}/.env" ]] || { fail "Env file ${DEPLOY_DIR}/.env not found"; exit 1; }
[[ -f "${GOOSE}" ]] || { fail "Goose not found at ${GOOSE}"; exit 1; }
command -v go >/dev/null || { fail "Go not found"; exit 1; }

ok "All checks passed"

# ── Step 1: Pull latest code ──────────────────────────────────────────
log "Step 1/7: Pulling latest code..."
cd "${PROJECT_DIR}"
git pull origin main
ok "Code updated"

# ── Step 2: Build binary ──────────────────────────────────────────────
log "Step 2/7: Building binary..."
VERSION=$(cat "${PROJECT_DIR}/VERSION" 2>/dev/null || echo "0.0.0")
BUILD=$(git rev-list --count HEAD 2>/dev/null || echo "1")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

cd "${SERVER_DIR}"
CGO_ENABLED=0 go build -ldflags="-s -w -X main.version=${VERSION}+${BUILD}" -o /tmp/clearbreath-api ./cmd/api
ok "Binary built (v${VERSION}+${BUILD}, ${COMMIT})"

# ── Step 3: Backup current binary ────────────────────────────────────
log "Step 3/7: Backing up current binary..."
if [[ -f "${BINARY_DST}" ]]; then
    sudo cp "${BINARY_DST}" "${BINARY_BACKUP}"
    ok "Backup saved to ${BINARY_BACKUP}"
else
    echo "  No existing binary to back up (first deploy?)"
fi

# ── Step 4: Stop service ──────────────────────────────────────────────
log "Step 4/7: Stopping service..."
sudo systemctl stop "${SERVICE_NAME}" 2>/dev/null && ok "Service stopped" || echo "  Service was not running"

# From here on, if anything fails we must rollback
trap rollback ERR

# ── Step 5: Deploy binary + registry ──────────────────────────────────
log "Step 5/7: Deploying binary and registry..."
sudo cp /tmp/clearbreath-api "${BINARY_DST}"
sudo chown clearbreath:clearbreath "${BINARY_DST}"
sudo chmod 755 "${BINARY_DST}"

sudo cp -r "${SERVER_DIR}/registry" "${DEPLOY_DIR}/"
sudo chown -R clearbreath:clearbreath "${DEPLOY_DIR}/registry"
ok "Binary and registry deployed"

# ── Step 6: Run migrations ────────────────────────────────────────────
log "Step 6/7: Running database migrations..."
DB_URL=$(sudo grep '^DATABASE_URL=' "${DEPLOY_DIR}/.env" | cut -d'=' -f2-)
${GOOSE} -dir "${MIGRATIONS_DIR}" postgres "${DB_URL}" up
ok "Migrations applied"

# ── Step 7: Start service + health check ──────────────────────────────
log "Step 7/7: Starting service..."
sudo systemctl start "${SERVICE_NAME}"
sleep 2

if ! sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
    fail "Service failed to start"
    exit 1
fi
ok "Service is running"

# Health check with retry
if curl -sf http://localhost:8080/health >/dev/null 2>&1; then
    ok "Health check passed"
else
    echo "  Retrying health check in 3s..."
    sleep 3
    if curl -sf http://localhost:8080/health >/dev/null 2>&1; then
        ok "Health check passed (retry)"
    else
        fail "Health check failed"
        exit 1
    fi
fi

# Disable rollback trap — deployment succeeded
trap - ERR

# Clean up backup
sudo rm -f "${BINARY_BACKUP}"

# Reload nginx
sudo nginx -t 2>/dev/null && sudo systemctl reload nginx && ok "Nginx reloaded" || echo "  Nginx reload skipped"

echo ""
echo "========================================="
echo "  Deployment successful!"
echo "  Version: v${VERSION}+${BUILD} (${COMMIT})"
echo "  Time:    $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="
