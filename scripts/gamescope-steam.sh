#!/bin/bash
cd "$(dirname "$0")" || exit 1

export INTEL_DEBUG=noccs
export DISPLAY=:0

if pgrep -x gamescope > /dev/null; then
    echo "gamescope already running, just setting Steam online"
    steam -gamepadui steam://friends/status/online
    ./sunshine-active.sh
    exit 0
fi

echo "Starting gamescope steam"
gamescope -w 1280 -h 720 -r 60 -e -- steam -gamepadui steam://friends/status/online
./sunshine-active.sh
