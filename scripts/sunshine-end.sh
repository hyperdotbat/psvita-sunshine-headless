#!/bin/bash
cd "$(dirname "$0")" || exit 1

./kill-steam-games.sh
./sunshine-idle.sh

if pgrep -x steam > /dev/null; then
    steam steam://friends/status/invisible
fi
