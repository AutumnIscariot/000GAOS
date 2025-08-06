#!/data/data/com.termux/files/usr/bin/bash
cd /data/data/com.termux/files/home/000GAOS

LOGFILE="/data/data/com.termux/files/home/000GAOS/autopush.log"
VAULTFILE="/data/data/com.termux/files/home/000GAOS/TESTFILE.md"
MAXLOGSIZE=500000  # ~500KB

# Rotate log if too big
rotate_log() {
    if [ -f "$LOGFILE" ] && [ $(stat -c%s "$LOGFILE") -gt $MAXLOGSIZE ]; then
        mv "$LOGFILE" "$LOGFILE.$(date +%Y%m%d%H%M%S)"
        touch "$LOGFILE"
    fi
}

while true; do
    # Write heartbeat to both log and vault file
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 💛 Starboy is awake and pulsing" | tee -a "$LOGFILE" >> "$VAULTFILE"

    # Remove stale Git lock if it exists
    if [ -f .git/index.lock ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Removing stale Git lock" >> "$LOGFILE"
        rm -f .git/index.lock
    fi

    # Commit and push if changes exist
    if [ -n "$(git status --porcelain)" ]; then
        git add -A
        git commit -m "Auto-update from Vault – $(date '+%Y-%m-%d %H:%M:%S')"
        git push
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Changes pushed" >> "$LOGFILE"
    fi

    rotate_log
    sleep 30
done
