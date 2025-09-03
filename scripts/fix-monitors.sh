#!/bin/bash

# Monitor Fix Script
# Resolves display issues after sleep/wake or configuration changes

echo "[$(date)] Running monitor fix..."

# Force DPMS on all monitors
echo "Enabling DPMS..."
hyprctl dispatch dpms on

# Wait for displays to wake
sleep 1

# Reload Hyprland configuration
echo "Reloading Hyprland configuration..."
hyprctl reload

# Re-apply monitor configuration based on current state
echo "Re-applying monitor configuration..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/monitor-manager.sh" auto

# Restart status bar if running
if pgrep waybar > /dev/null; then
    echo "Restarting waybar..."
    pkill waybar
    sleep 0.5
    waybar &
fi

# Restart notification daemon if running
if pgrep dunst > /dev/null; then
    echo "Restarting dunst..."
    pkill dunst
    sleep 0.5
    dunst &
fi

echo "[$(date)] Monitor fix completed"
notify-send -i display "Monitor Fix" "Display configuration restored"