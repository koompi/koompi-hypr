#!/bin/bash

# Monitor Manager for Hyprland
# Intelligent multi-monitor configuration with workspace management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/hypr"

# Default monitor names
LAPTOP_MONITOR="eDP-1"
LAPTOP_RES="3840x2160"
LAPTOP_SCALE=2

# Get connected monitors
get_monitors() {
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo ""
}

# Get active workspaces
get_active_workspaces() {
    hyprctl workspaces -j 2>/dev/null | jq -r '.[] | select(.windows > 0) | .id' 2>/dev/null || echo ""
}

# Check if external monitor is connected
has_external_monitor() {
    local monitors=($@)
    for monitor in "${monitors[@]}"; do
        [ "$monitor" != "$LAPTOP_MONITOR" ] && return 0
    done
    return 1
}

# Move workspaces to monitor
move_workspaces_to_monitor() {
    local target="$1"
    shift
    local workspaces=($@)
    
    for ws in "${workspaces[@]}"; do
        hyprctl dispatch moveworkspacetomonitor "$ws $target" 2>/dev/null
    done
}

# Configure dual monitor setup (extended)
configure_dual_extended() {
    local external="$1"
    local external_res="${2:-1920x1080@60}"
    
    echo "Configuring extended display: $external above laptop"
    
    # Position external monitor above laptop
    hyprctl keyword monitor "$external,$external_res,0x0,1" 2>/dev/null
    hyprctl keyword monitor "$LAPTOP_MONITOR,$LAPTOP_RES@60,0x1080,$LAPTOP_SCALE" 2>/dev/null
    
    # Default workspace distribution (customizable)
    # External: 1-5, Laptop: 6-10
    move_workspaces_to_monitor "$external" 1 2 3 4 5
    move_workspaces_to_monitor "$LAPTOP_MONITOR" 6 7 8 9 10
}

# Configure mirror mode
configure_mirror() {
    local external="$1"
    local external_res="${2:-1920x1080@60}"
    
    echo "Configuring mirror display"
    
    # Mirror laptop to external
    hyprctl keyword monitor "$external,$external_res,0x0,1,mirror,$LAPTOP_MONITOR" 2>/dev/null
}

# Configure single monitor (laptop only)
configure_single() {
    echo "Configuring laptop-only display"
    
    # Move all workspaces to laptop
    local workspaces=($(get_active_workspaces))
    move_workspaces_to_monitor "$LAPTOP_MONITOR" "${workspaces[@]}"
    
    # Reset laptop monitor position
    hyprctl keyword monitor "$LAPTOP_MONITOR,$LAPTOP_RES@60,0x0,$LAPTOP_SCALE" 2>/dev/null
}

# Disable a monitor
disable_monitor() {
    local monitor="$1"
    echo "Disabling monitor: $monitor"
    hyprctl keyword monitor "$monitor,disable" 2>/dev/null
}

# Show interactive menu
show_menu() {
    local external="$1"
    
    # Check if rofi is available
    if ! command -v rofi &> /dev/null; then
        echo "Rofi not found, applying default extended configuration"
        configure_dual_extended "$external"
        return
    fi
    
    local options="󰍺 Extend Displays\n󰍺 Mirror Display\n󰌢 Laptop Only\n󰅖 Cancel"
    
    local choice=$(echo -e "$options" | rofi -dmenu -p "Display Configuration" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        *"Extend"*)
            configure_dual_extended "$external"
            notify-send -i display "Display Configuration" "Extended display mode activated"
            ;;
        *"Mirror"*)
            configure_mirror "$external"
            notify-send -i display "Display Configuration" "Mirror display mode activated"
            ;;
        *"Laptop Only"*)
            configure_single
            disable_monitor "$external"
            notify-send -i display "Display Configuration" "Using laptop display only"
            ;;
        *)
            echo "Configuration cancelled"
            ;;
    esac
}

# Auto-configure based on monitor state
auto_configure() {
    local monitors=($(get_monitors))
    
    if [ ${#monitors[@]} -eq 0 ]; then
        echo "Error: No monitors detected"
        return 1
    fi
    
    echo "Detected monitors: ${monitors[*]}"
    
    if has_external_monitor "${monitors[@]}"; then
        # Find first external monitor
        for monitor in "${monitors[@]}"; do
            if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
                configure_dual_extended "$monitor"
                break
            fi
        done
    else
        configure_single
    fi
}

# Main logic
main() {
    local monitors=($(get_monitors))
    local mode="${1:-interactive}"
    
    if [ ${#monitors[@]} -eq 0 ]; then
        echo "Error: No monitors detected"
        exit 1
    fi
    
    case "$mode" in
        hotplug|auto)
            echo "Auto-configuring monitors..."
            auto_configure
            ;;
        interactive|*)
            if has_external_monitor "${monitors[@]}"; then
                for monitor in "${monitors[@]}"; do
                    if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
                        show_menu "$monitor"
                        break
                    fi
                done
            else
                echo "No external monitor detected"
                configure_single
                notify-send -i display "Display Configuration" "External monitor disconnected"
            fi
            ;;
    esac
}

# Execute
main "$@"