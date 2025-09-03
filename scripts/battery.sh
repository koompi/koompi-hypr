#!/bin/bash

# Simple Battery Menu

# Get battery percentage
battery=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)
ac=$(cat /sys/class/power_supply/AC/online)

# Get current limits
stop=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold)
start=$(cat /sys/class/power_supply/BAT0/charge_control_start_threshold)

# Status line
if [ "$ac" = "1" ]; then
    ac_status="Plugged In"
else
    ac_status="On Battery"
fi

# Menu
menu="Battery: $battery% - $status - $ac_status
Current: Stop at $stop%, Start at $start%
───────────────────────────────
Balanced (85% / 20%)
Conservative (80% / 40%)  
Full Charge (100% / 0%)
───────────────────────────────
Custom Limits
View Logs"

choice=$(echo -e "$menu" | rofi -dmenu -p "Battery" -l 8)

case "$choice" in
    "Balanced"*)
        echo 85 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
        echo 20 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold >/dev/null
        notify-send "Battery" "Balanced mode set"
        ;;
    "Conservative"*)
        echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
        echo 40 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold >/dev/null
        notify-send "Battery" "Conservative mode set"
        ;;
    "Full Charge"*)
        echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
        echo 0 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold >/dev/null
        notify-send "Battery" "Full charge mode set"
        ;;
    "Custom Limits")
        stop=$(echo "" | rofi -dmenu -p "Stop charging at %" -l 0)
        if [ -n "$stop" ] && [ "$stop" -ge 50 ] && [ "$stop" -le 100 ]; then
            start=$(echo "" | rofi -dmenu -p "Start charging at %" -l 0)
            if [ -n "$start" ] && [ "$start" -ge 0 ] && [ "$start" -lt "$stop" ]; then
                echo "$stop" | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
                echo "$start" | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold >/dev/null
                notify-send "Battery" "Custom limits set: $stop% / $start%"
            fi
        fi
        ;;
    "View Logs")
        [ -f /tmp/battery.log ] && tail -20 /tmp/battery.log | rofi -dmenu -p "Logs" -l 20
        ;;
esac