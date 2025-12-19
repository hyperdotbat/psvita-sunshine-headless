#!/bin/bash
for out in /sys/class/drm/*; do
    name=$(basename "$out")
    if [[ "$name" =~ HDMI|DP|eDP ]]; then
        status=$(cat "$out/status")
        echo "$name: $status"
    fi
done