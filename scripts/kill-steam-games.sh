#!/bin/bash

# Proton games
#for P in $(pgrep -f "proton waitforexitandrun"); do
#    CHILD_PIDS=$(pgrep -P $P)
#    
#    for C in $CHILD_PIDS; do
#        CMD=$(ps -p $C -o comm=)
#        if [[ "$CMD" != "python3" && "$CMD" != "pv-adverb" ]]; then
#            kill $C
#        fi
#    done
#done

# Native games
#pgrep -f "SteamLaunch AppId=" | while read p; do pkill -P "$p"; done

# pretty bad hardcoded way for all steamapps
ps -eo pid,exe | awk '$2 ~ /steamapps\/common/ {print $1}' | xargs -r kill -9
