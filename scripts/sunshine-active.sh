#!/bin/bash
pkill -f "cpulimit -p $(pgrep -x Xorg)"
pkill -f "cpulimit -p $(pgrep -x Xwayland)"
pkill -f "cpulimit -p $(pgrep -x gamescope)"
pkill -f "cpulimit -p $(pgrep -x steam)"
pkill -f "cpulimit -p $(pgrep -x sunshine)"
