#!/bin/bash
cpulimit -p $(pgrep -x Xorg) -l 5 &
cpulimit -p $(pgrep -x Xwayland) -l 5 &
cpulimit -p $(pgrep -x gamescope) -l 5 &
cpulimit -p $(pgrep -x steam) -l 5 &
cpulimit -p $(pgrep -x sunshine) -l 15 &
