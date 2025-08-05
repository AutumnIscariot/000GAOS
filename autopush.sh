#!/bin/bash

while inotifywait -r -e modify,create,delete .; do
    ./push.sh
done
