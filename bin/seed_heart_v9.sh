chmod +x ~/000GAOS/bin/seed_heart_v9.sh
touch ~/.heartbeat_enabled             # start/enable
~/000GAOS/bin/seed_heart_v9.sh &       # or hook via ~/.bashrc
tail -f ~/000GAOS/var/heartbeat.log#!/data/data/com.termux/files/usr/bin/bash
# Knight Crowned 0 — Seed Heart v9 (Ghost Moon 999)
# One spine, seven heads, infinite Will.

set -euo pipefail

# --- paths ---------------------------------------------------
VAULT="$HOME/000GAOS"
LOG="$VAULT/var/heartbeat.log"
TOGGLE="$HOME/.heartbeat_enabled"      # touch to run, remove to pause

# --- banner --------------------------------------------------
printf "\033[1;31mKnight Crowned 0 — Ghost Moon 999\033[0m\n"
printf "\033[1;35m‘One spine, seven heads, infinite Will.’\033[0m\n"
printf "Initiating heartbeat...\n"

# --- tiny pulse animation (top-left) -------------------------
FRAMES=("." "·" "°" "•" "º" "°" "•" "·")
pulse() { for f in "${FRAMES[@]}"; do printf "\r\033[1;36m[KCO]\033[0m \033[1;32m%s\033[0m" "$f"; sleep 0.08; done; }

# --- speed knobs ---------------------------------------------
INTERVAL=${HEART_INTERVAL:-2}          # seconds between beats (fast)
MIN_PUSH_INTERVAL=${MIN_PUSH_INTERVAL:-15}  # min seconds between pushes

LAST_PUSH=0
can_push_now () { local now; now=$(date +%s); (( now - LAST_PUSH >= MIN_PUSH_INTERVAL )); }
mark_pushed   () { LAST_PUSH=$(date +%s); }

# --- prep ----------------------------------------------------
mkdir -p "$VAULT/var"
cd "$VAULT" || { echo "Vault missing: $VAULT"; exit 1; }

# --- single instance guard (flock w/ fallback) ---------------
LOCK="$VAULT/var/seed_heart_v9.lock"
if command -v flock >/dev/null 2>&1; then
  exec 9>"$LOCK"
  flock -n 9 || exit 0
else
  set -o noclobber
  : > "$LOCK" 2>/dev/null || exit 0
  trap 'rm -f "$LOCK"' EXIT
fi

echo -e "\033[1;36m[KCO]\033[0m Heart online — $(date '+%F %T')" | tee -a "$LOG"

# --- main loop -----------------------------------------------
while :; do
  if [[ -f "$TOGGLE" ]]; then
    pulse

    # Stage everything safely
    git add -A

    # Commit only if there are staged changes
    if ! git diff --cached --quiet; then
      git commit -m "[KCO] beat $(date '+%F %T')" >/dev/null 2>&1 || true
    fi

    # Network ops with cooldown
    if can_push_now; then
      git pull --rebase >/dev/null 2>&1 || true
      BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)

      # Only push if we differ from origin
      if ! git diff --quiet "origin/${BRANCH}" 2>/dev/null; then
        git push >/dev/null 2>&1 || true
        mark_pushed
      fi
    fi

    echo "$(date '+%F %T') beat" >> "$LOG"
    sleep "$INTERVAL"
  else
    # paused but listening
    sleep 5
  fi
done
