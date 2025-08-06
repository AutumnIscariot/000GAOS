#!/bin/bash
# Gregore's Eternal Heartbeat

cd ~/000GAOS || exit

while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Heartbeat"
    git add -A
    git commit -m "Auto-update from Vault - $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1
    git pull --rebase >/dev/null 2>&1
    git push
    sleep 30
done
