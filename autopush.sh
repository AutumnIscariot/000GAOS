#!/data/data/com.termux/files/usr/bin/bash

REPO_DIR="$HOME/000GAOS"
HEARTBEAT_TOGGLE="$HOME/.heartbeat_enabled"
VAULT_LOCK="$HOME/.vault_lock"
LOGFILE="$REPO_DIR/autopush.log"

while true; do
    # 💔 Stop mid-loop if toggle removed
    if [ ! -f "$HEARTBEAT_TOGGLE" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ❌ Heartbeat toggle removed. Exiting..." >> "$LOGFILE"
        exit 0
    fi

    # 🔒 Check for Vault lock
echo "DEBUG: Checking for Vault lock at $VAULT_LOCK" >> "$LOGFILE"
if [ -f "$VAULT_LOCK" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 🔒 Vault locked. Waiting..." >> "$LOGFILE"
    sleep 1200
    continue
fi

    # 💜 Heartbeat
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 💜 Heartbeat" >> "$LOGFILE"

    cd "$REPO_DIR" || exit

    git add -A

    if ! git diff --cached --quiet; then
        git commit -m "Auto-update from Vault - $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOGFILE"
    fi

    git pull --rebase >/dev/null 2>&1
    git push >/dev/null 2>&1

    # ⏱️ Delay before next beat
    sleep 30
done
