#!/bin/bash

# Path to your repo
REPO_DIR="$HOME/000GAOS"

while true; do
    cd "$REPO_DIR" || exit

    # Print heartbeat with timestamp
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Heartbeat"

    # Stage all changes
    git add -A

    # Commit with timestamp (no error if nothing to commit)
    git commit -m "Auto-update from Vault - $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1

    # Push to GitHub
    git push

    # Wait 30 seconds before the next beat
    sleep 30
done
