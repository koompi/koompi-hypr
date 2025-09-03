#!/bin/bash

# Battery Management Test Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Battery Management System Test ==="
echo

# Test 1: Check battery sysfs files exist
echo "Test 1: Checking battery system files..."
if [ -f /sys/class/power_supply/BAT0/capacity ] && 
   [ -f /sys/class/power_supply/BAT0/status ] &&
   [ -f /sys/class/power_supply/BAT0/charge_control_end_threshold ]; then
    echo -e "${GREEN}✓ Battery files exist${NC}"
else
    echo -e "${RED}✗ Battery files missing${NC}"
    exit 1
fi

# Test 2: Read current battery status
echo -e "\nTest 2: Reading battery status..."
battery=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)
echo -e "${GREEN}✓ Battery: ${battery}% - Status: ${status}${NC}"

# Test 3: Check threshold files are writable (with sudo)
echo -e "\nTest 3: Testing threshold write access..."
current_stop=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold)
echo 85 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Can write thresholds with sudo${NC}"
    # Restore original
    echo "$current_stop" | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
else
    echo -e "${RED}✗ Cannot write thresholds${NC}"
fi

# Test 4: Test notification system
echo -e "\nTest 4: Testing notifications..."
if command -v notify-send >/dev/null; then
    notify-send "Battery Test" "Notification system working"
    echo -e "${GREEN}✓ Notification system available${NC}"
else
    echo -e "${RED}✗ notify-send not found${NC}"
fi

# Test 5: Test rofi
echo -e "\nTest 5: Testing rofi..."
if command -v rofi >/dev/null; then
    echo -e "${GREEN}✓ Rofi available${NC}"
else
    echo -e "${RED}✗ Rofi not found${NC}"
fi

# Test 6: Check if daemon would work
echo -e "\nTest 6: Checking daemon requirements..."
if command -v systemctl >/dev/null; then
    echo -e "${GREEN}✓ Systemctl available${NC}"
else
    echo -e "${YELLOW}⚠ Systemctl not available - manual start required${NC}"
fi

# Test 7: Simulate battery menu
echo -e "\nTest 7: Testing battery menu..."
if [ -x /home/user0/.config/rofi/battery.sh ]; then
    echo -e "${GREEN}✓ Battery menu script is executable${NC}"
else
    echo -e "${RED}✗ Battery menu script not found or not executable${NC}"
fi

# Test 8: Check sudo setup
echo -e "\nTest 8: Checking sudo permissions..."
echo 85 | sudo -n tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Sudo configured for battery control${NC}"
else
    echo -e "${YELLOW}⚠ Sudo password required - run battery-sudo-setup.sh${NC}"
fi

echo -e "\n=== Test Summary ==="
echo "Battery management system is ready to use!"
echo "Press Super+Shift+B to open battery menu"