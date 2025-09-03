#!/bin/bash

# Monitor Hotplug Detection Service
# Monitors for display connection changes and applies configurations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_MANAGER="$SCRIPT_DIR/monitor-manager.sh"

# Function to handle monitor events
handle_monitor_event() {
    local event="$1"
    echo "[$(date)] Monitor event detected: $event"
    
    # Wait for hardware to stabilize
    sleep 1
    
    # Run monitor configuration
    if [ -x "$MONITOR_MANAGER" ]; then
        "$MONITOR_MANAGER" hotplug
    else
        echo "Error: Monitor manager script not found or not executable"
    fi
}

# Main monitoring loop
echo "[$(date)] Starting monitor hotplug detection service"

# Monitor Hyprland events via socat
if command -v socat &> /dev/null; then
    socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - 2>/dev/null | while read -r line; do
        case "$line" in
            *monitoradded*)
                handle_monitor_event "Monitor connected"
                ;;
            *monitorremoved*)
                handle_monitor_event "Monitor disconnected"
                ;;
        esac
    done
else
    echo "Error: socat not installed. Install it for monitor hotplug detection."
    echo "Fallback: Polling for monitor changes every 5 seconds"
    
    # Fallback polling method
    PREV_MONITORS=""
    while true; do
        CURR_MONITORS=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null | sort | tr '\n' ' ')
        
        if [ "$CURR_MONITORS" != "$PREV_MONITORS" ]; then
            handle_monitor_event "Monitor configuration changed"
            PREV_MONITORS="$CURR_MONITORS"
        fi
        
        sleep 5
    done
fi