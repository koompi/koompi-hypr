#!/bin/bash

# Setup sudoers rule for battery threshold control

SUDOERS_FILE="/etc/sudoers.d/battery-manager"

echo "Setting up battery manager sudo permissions..."

# Create sudoers content
cat << EOF | sudo tee "$SUDOERS_FILE" > /dev/null
# Allow battery threshold control without password
$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT0/charge_control_end_threshold
$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT0/charge_control_start_threshold
$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT0/charge_stop_threshold
$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/power_supply/BAT0/charge_start_threshold
EOF

# Set proper permissions
sudo chmod 0440 "$SUDOERS_FILE"

echo "Sudo permissions configured for battery management"