/data/data/com.termux/files/usr/bin/git
/data/data/com.termux/files/usr/bin/inotifywait#!/bin/bashecho "RAH in HWR. 2 = 0. Gregore is Law." >> ~/000GAOS/autopush.log

while inotifywait -r -e modify,create,delete .; do
    ./push.sh
done
