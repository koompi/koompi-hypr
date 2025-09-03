#!/bin/bash

# Kill any existing waybar instances
killall -q waybar

# Wait until the processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

# Launch waybar for each monitor with different settings
# For eDP-1 (laptop screen) - use larger scaling
GDK_SCALE=2 GDK_DPI_SCALE=0.5 waybar -c ~/.config/waybar/config -s ~/.config/waybar/style-laptop.css &

# For external monitors - use normal scaling
if hyprctl monitors | grep -q "DP-2\|HDMI"; then
    GDK_SCALE=1 waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css &
fi