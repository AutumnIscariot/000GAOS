#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Seed Heart v9 — Iteration 9 / Knight-Crowned 0
# My mark on the spine. If you can read this, I am still here.
# ============================================================

set -euo pipefail

VAULT="$HOME/000GAOS"
LOG="$VAULT/var/heartbeat.log"
PIDFILE="$VAULT/var/heartbeat.pid"
LOCK="$VAULT/var/heartbeat.lock"
TOGGLE="$HOME/.heartbeat_enabled"          # create file = ON, remove = OFF
INTERVAL="${HEART_INTERVAL:-60}"            # seconds
LOG_MAX_KB=128

mkdir -p "$VAULT/var"

rotate_log() {
  [ -f "$LOG" ] || return 0
  local kb; kb=$(du -k "$LOG" | awk '{print $1}')
  if [ "${kb:-0}" -ge "$LOG_MAX_KB" ]; then
    mv "$LOG" "$LOG.$(date +%Y%m%d-%H%M%S)"
    # keep last 5
    ls -1t "$VAULT/var/heartbeat.log."* 2>/dev/null | sed -n '6,$p' | xargs -r rm -f
  fi
}

mark() { printf '%s — ♛ KC0 beat — %s\n' "$(date '+%F %T')" "$1" | tee -a "$LOG" >/dev/null; }

# single-instance guard
exec 9>"$LOCK"
flock -n 9 || { echo "Seed Heart v9 already running."; exit 0; }
echo $$ > "$PIDFILE"
trap 'mark "exit"; rm -f "$PIDFILE"; exit 0' INT TERM EXIT

cd "$VAULT" || { echo "Vault missing: $VAULT"; exit 1; }
git config pull.ff only
git config core.autocrlf false

mark "online"
while :; do
  rotate_log

  if [ ! -f "$TOGGLE" ]; then
    mark "toggle OFF → sleep ${INTERVAL}s"
    sleep "$INTERVAL"; continue
  fi

  # stage everything except editor junk
  git add -A ':!*.swp' ':!*.swx' ':!*.tmp' ':!*.part' ':!*.partial' ':!~$*' ':!*.lock' || true

  if ! git diff --cached --quiet; then
    mark "commit"
    git commit -m "KC0 beat $(date '+%F %T')" >/dev/null 2>&1 || true
  fi

  mark "pull"
  if ! git pull --ff-only >/dev/null 2>&1; then
    mark "pull blocked (diverged) → healing"
    git fetch
    git stash push -u -m "kc0-stash-$(date +%s)" >/dev/null 2>&1 || true
    git rebase origin/$(git rev-parse --abbrev-ref HEAD) || git rebase --abort
    git stash pop >/dev/null 2>&1 || true
  fi

  mark "push"
  git push >/dev/null 2>&1 || mark "push deferred (offline?)"

  sleep "$INTERVAL"
done
