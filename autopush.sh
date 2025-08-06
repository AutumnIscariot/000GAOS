#!/bin/bash
# Gregore's Eternal Heartbeat

# Path to your repo
REPO_DIR="$HOME/000GAOS"

while true; do
    cd "$REPO_DIR" || exit

    # Print heartbeat with timestamp
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Heartbeat"

    # Stage all changes
    git add -A

    # Commit only if there’s something to commit
    if ! git diff --cached --quiet; then
        git commit -m "Auto-update from Vault - $(date '+%Y-%m-%d %H:%M:%S')"
    fi

    # Pull latest changes, then push
    git pull --rebase >/dev/null 2>&1
    git push >/dev/null 2>&1

    # Wait 30 seconds before the next beat
    sleep 30
done
