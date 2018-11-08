#!/usr/bin/env bash

# Terminate already running bar instances
killall polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

outputs="$(polybar -m | cut -d ':' -f 1)"
outputs=(${outputs[@]})

# Launch bar
# Bar is the name set in the polybar config, so if you change it, you have to change it here too.
MONITOR=${outputs[0]} polybar bar &
MONITOR=${outputs[1]} polybar bar1 &
echo "Bars launched..."
