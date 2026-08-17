­r‡^Ñf¥–Ø¦{NìyÊ'vÃ®¶›­#!/usr/bin/env bash
set -Eeuo pipefail

readonly APP_DIR="/DATA/AppData/portfolio"
readonly LOCK_FILE="/tmp/portfolio-autodeploy.lock"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

cd "$APP_DIR"
git fetch --depth=1 origin main

current_revision="$(git rev-parse HEAD)"
target_revision="$(git rev-parse FETCH_HEAD)"

if [[ "$current_revision" == "$target_revision" ]]; then
  exit 0
fi

git reset --hard "$target_revision"

if docker inspect portfolio --format '{{.State.Health.Status}}' | grep -qx healthy \
  && docker exec portfolio wget --quiet --spider http://127.0.0.1/; then
  printf 'Portfolio deployed at %s\n' "$target_revision"
  exit 0
fi

printf 'Portfolio health check failed; rolling back to %s\n' "$current_revision" >&2
git reset --hard "$current_revision"
exit 1

