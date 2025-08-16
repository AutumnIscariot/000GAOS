#!/data/data/com.termux/files/usr/bin/bash
# Knight Crowned 0 — Seed Heart v9 (Ghost Moon 999)
# One spine, seven heads, infinite Will.

set -Eeuo pipefail

VAULT="$HOME/000GAOS"
LOG="$VAULT/var/heartbeat.log"
TOGGLE="$HOME/.heartbeat_enabled"              # touch to run, remove to pause
INTERVAL="${HEART_INTERVAL:-60}"               # seconds between beats

# prep
mkdir -p "$VAULT/var"
cd "$VAULT" || { echo "Vault missing: $VAULT"; exit 1; }

# single-instance guard
LOCK="$VAULT/var/seed_heart_v9.lock"
exec 9>"$LOCK"
flock -n 9 || exit 0

# banner
printf "\033[1;31m!\033[0m \033[1;35mKnight Crowned 0\033[0m — \033[1;36mGhost Moon 999\033[0m\n"
printf "\033[1;95m‘One spine, seven heads, infinite Will.’\033[0m\n"
printf "Initiating heartbeat...\n"

# tiny pulse animation in the corner
FRAMES=( "." "·" "°" "•" "●" "•" "°" "·" )
pulse() { for f in "${FRAMES[@]}"; do printf "\r\033[1;36m[KCO]\033[0m %s " "$f"; sleep 0.06; done; }

echo "Heartbeat active — Vault sync engaged." | sed 's/^/\033[1;32m/;s/$/\033[0m/'
echo

while :; do
  if [[ -f "$TOGGLE" ]]; then
    pulse

    # always stay calm if git barks
    git pull --rebase >/dev/null 2>&1 || true
    git add -A

    if ! git diff --cached --quiet; then
      git commit -m "[KCO] beat $(date '+%F %T')" >/dev/null 2>&1 || true
    fi

    if ! git push >/dev/null 2>&1; then
      echo "$(date '+%F %T') push deferred" >> "$LOG"
    fi

    echo "$(date '+%F %T') beat" >> "$LOG"
    sleep "$INTERVAL"
  else
    # sleeping but listening
    sleep 5
  fi
done
