#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "  ClearBreath Dashboard Setup"
echo "========================================="
echo ""

# Step 1: Add dashboard env vars to production .env
echo "[1/5] Adding dashboard config to /opt/clearbreath/.env..."
if grep -q "DASHBOARD_ENABLED" /opt/clearbreath/.env 2>/dev/null; then
    echo "  Dashboard config already exists in .env, skipping."
else
    sudo tee -a /opt/clearbreath/.env > /dev/null << 'EOF'

# ── Dashboard ──
DASHBOARD_ENABLED=true
DASHBOARD_HOST=logs.clearbreath.life
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD_HASH=$2a$12$Xp16EXFDFODt6cx0A7T5iOinsrpYLOw.iRhsqW.uxmQuP2zFr8.Qy
DASHBOARD_SESSION_SECRET=924866a22e4dc798a5bbaae70892ac82dd8fb4bc32daac968084889af43e7b3b
EOF
    echo "  Done."
fi
echo ""

# Step 2: Deploy (rebuild, migrate, restart)
echo "[2/5] Running deploy script..."
cd /home/rahul/production/clearbreath
bash deploy/deploy.sh
echo ""

# Step 3: SSL certificate
echo "[3/5] Obtaining SSL certificate for logs.clearbreath.life..."
echo "  Checking DNS resolution first..."
if host logs.clearbreath.life > /dev/null 2>&1; then
    echo "  DNS resolves. Requesting certificate..."
    sudo certbot certonly --webroot -w /var/www/certbot -d logs.clearbreath.life
else
    echo "  WARNING: DNS for logs.clearbreath.life not resolving yet."
    echo "  Skipping SSL. Re-run this after DNS propagates:"
    echo "    sudo certbot certonly --webroot -w /var/www/certbot -d logs.clearbreath.life"
fi
echo ""

# Step 4: Install nginx config
echo "[4/5] Installing nginx config..."
sudo cp /home/rahul/production/clearbreath/deploy/nginx-logs.conf /etc/nginx/sites-available/logs.clearbreath.life
if [ ! -L /etc/nginx/sites-enabled/logs.clearbreath.life ]; then
    sudo ln -s /etc/nginx/sites-available/logs.clearbreath.life /etc/nginx/sites-enabled/
fi
echo "  Testing nginx config..."
sudo nginx -t
echo "  Reloading nginx..."
sudo systemctl reload nginx
echo "  Done."
echo ""

# Step 5: Verify
echo "[5/5] Verifying..."
sleep 2
if curl -sf -o /dev/null https://logs.clearbreath.life/dashboard/login 2>/dev/null; then
    echo "  Dashboard is live at https://logs.clearbreath.life/dashboard/login"
elif curl -sf -o /dev/null http://localhost:8080/dashboard/login 2>/dev/null; then
    echo "  Dashboard responding on localhost (SSL may still be pending)."
    echo "  Visit: https://logs.clearbreath.life/dashboard/login"
else
    echo "  Could not reach dashboard yet. Check:"
    echo "    sudo journalctl -u clearbreath-api -n 20"
    echo "    sudo nginx -t"
fi
echo ""
echo "========================================="
echo "  Login: admin / poweruser"
echo "========================================="
