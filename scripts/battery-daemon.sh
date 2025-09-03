#!/bin/bash

# Simple Battery Daemon
# Monitors battery and manages charging limits

LOG="/tmp/battery.log"
WARNED_10=false
WARNED_5=false

log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

log "Battery daemon started"

# Set initial limits (85/20 balanced mode)
echo 85 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
echo 20 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold >/dev/null

while true; do
    battery=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)
    ac=$(cat /sys/class/power_supply/AC/online)
    
    # Reset warnings when charging or above threshold
    if [ "$battery" -gt 10 ] || [ "$status" = "Charging" ]; then
        WARNED_10=false
    fi
    if [ "$battery" -gt 5 ] || [ "$status" = "Charging" ]; then
        WARNED_5=false
    fi
    
    # Battery warnings (only when on battery)
    if [ "$ac" = "0" ] && [ "$status" = "Discharging" ]; then
        if [ "$battery" -le 10 ] && [ "$WARNED_10" = false ]; then
            notify-send -u normal "Battery Low" "${battery}% remaining"
            log "Low battery warning: ${battery}%"
            WARNED_10=true
            
        elif [ "$battery" -le 5 ] && [ "$WARNED_5" = false ]; then
            notify-send -u critical "Battery Critical" "${battery}% - System will sleep soon"
            log "Critical battery: ${battery}%"
            WARNED_5=true
            
            # Sleep in 60 seconds
            (
                sleep 60
                if [ "$(cat /sys/class/power_supply/BAT0/capacity)" -le 5 ] && 
                   [ "$(cat /sys/class/power_supply/AC/online)" = "0" ]; then
                    log "Suspending due to critical battery"
                    systemctl suspend
                fi
            ) &
        fi
    fi
    
    sleep 30
done