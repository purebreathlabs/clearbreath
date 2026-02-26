#!/usr/bin/env bash
set -euo pipefail

# ClearBreath API deployment script
# Usage: ./deploy.sh

PROJECT_DIR="/home/rahul/production/clearbreath"
DEPLOY_DIR="/opt/clearbreath"
SERVER_DIR="${PROJECT_DIR}/server"
VERSION=$(cat "${PROJECT_DIR}/VERSION" 2>/dev/null || echo "0.0.0")
BUILD=$(cd "${PROJECT_DIR}" && git rev-list --count HEAD 2>/dev/null || echo "1")

echo "==> Building ClearBreath API v${VERSION}+${BUILD}..."
cd "${SERVER_DIR}"
CGO_ENABLED=0 go build -ldflags="-s -w -X main.version=${VERSION}+${BUILD}" -o /tmp/clearbreath-api ./cmd/api

echo "==> Deploying binary to ${DEPLOY_DIR}..."
sudo systemctl stop clearbreath-api 2>/dev/null || true
sudo cp /tmp/clearbreath-api "${DEPLOY_DIR}/api"
sudo chown clearbreath:clearbreath "${DEPLOY_DIR}/api"
sudo chmod 755 "${DEPLOY_DIR}/api"

echo "==> Syncing registry..."
sudo cp -r "${SERVER_DIR}/registry" "${DEPLOY_DIR}/"
sudo chown -R clearbreath:clearbreath "${DEPLOY_DIR}/registry"

echo "==> Running database migrations..."
DB_URL=$(sudo grep '^DATABASE_URL=' "${DEPLOY_DIR}/.env" | cut -d'=' -f2-)
/home/rahul/go/bin/goose -dir "${SERVER_DIR}/migrations" postgres "${DB_URL}" up

echo "==> Starting service..."
sudo systemctl start clearbreath-api
sleep 2

if sudo systemctl is-active --quiet clearbreath-api; then
    echo "==> ClearBreath API is running!"
    curl -sf http://localhost:8080/health && echo " (health: OK)" || echo " (health check failed)"
else
    echo "==> FAILED to start. Check: sudo journalctl -u clearbreath-api -n 50"
    exit 1
fi
