­r‡^Ñf¥–Ø¦{NìyÊ'vÃ®¶›­#!/usr/bin/env bash
set -Eeuo pipefail

readonly APP_DIR="/DATA/AppData/portfolio"
readonly ORIGIN_URL="https://github.com/alkval/portfolio.git"
readonly SERVICE_NAME="portfolio-autodeploy.service"
readonly TIMER_NAME="portfolio-autodeploy.timer"

if [[ "$EUID" -eq 0 ]]; then
  printf 'Run this installer as alkval, not with sudo. It requests sudo only for systemd files.\n' >&2
  exit 1
fi

if [[ "$(id -un)" != 'alkval' ]]; then
  printf 'This deployment is configured for the alkval account.\n' >&2
  exit 1
fi

cd "$APP_DIR"
if [[ ! -s secrets/tunnel-token ]]; then
  printf 'Missing production tunnel token; refusing to replace the checkout.\n' >&2
  exit 1
fi

if [[ ! -d .git ]]; then
  git init
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$ORIGIN_URL"
else
  git remote add origin "$ORIGIN_URL"
fi

git fetch --depth=1 origin main
git reset --hard FETCH_HEAD

chmod 0755 scripts/auto-deploy.sh scripts/install-autodeploy.sh
sudo install -m 0644 "deploy/$SERVICE_NAME" "/etc/systemd/system/$SERVICE_NAME"
sudo install -m 0644 "deploy/$TIMER_NAME" "/etc/systemd/system/$TIMER_NAME"
sudo systemctl daemon-reload
sudo systemctl enable --now "$TIMER_NAME"
sudo systemctl start "$SERVICE_NAME"

printf '\nAutomatic portfolio deployment is enabled.\n'
sudo systemctl --no-pager status "$TIMER_NAME"

