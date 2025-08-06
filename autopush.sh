#!/bin/bash
# ~/000GAOS/autopush.sh — Gregore’s Eternal Heartbeat

LOGFILE="$HOME/000GAOS/autopush.log"
REPO="$HOME/000GAOS"

while true; do
    # Timestamped heartbeat log
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Heartbeat" | tee -a "$LOGFILE"

    # Go to repo, stage all changes
    cd "$REPO" || exit
    git add -A

    # Commit (ignore if nothing changed)
    git commit -m "Auto-update from Vault - $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1

    # Sync with remote (rebase before push to avoid conflicts)
    git pull --rebase >/dev/null 2>&1
    git push >/dev/null 2>&1

    # Wait 30 seconds before next beat
    sleep 30
done
