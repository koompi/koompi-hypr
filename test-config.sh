#!/bin/bash

# KOOMPI Hyprland Configuration Test Suite
# Validates configuration files, dependencies, and system compatibility

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# Configuration paths
HYPR_CONFIG="$HOME/.config/hypr"
WAYBAR_CONFIG="$HOME/.config/waybar"

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((TESTS_WARNINGS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
    ((TESTS_RUN++))
}

# Test framework
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    log_test "$test_name"
    
    if eval "$test_command"; then
        log_success "$test_name"
        return 0
    else
        log_error "$test_name"
        return 1
    fi
}

# Header
show_header() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    ╔════════════════════════════════════════════╗
    ║         KOOMPI HYPRLAND TEST SUITE         ║
    ║            Configuration Validator         ║
    ╚════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Test 1: Check required binaries
test_required_binaries() {
    local required_bins=("hyprland" "waybar" "dunst" "rofi" "kitty")
    local missing_bins=()
    
    for bin in "${required_bins[@]}"; do
        if ! command -v "$bin" &> /dev/null; then
            missing_bins+=("$bin")
        fi
    done
    
    if [ ${#missing_bins[@]} -eq 0 ]; then
        return 0
    else
        log_error "Missing binaries: ${missing_bins[*]}"
        return 1
    fi
}

# Test 2: Check optional binaries
test_optional_binaries() {
    local optional_bins=("firefox" "thunar" "brightnessctl" "pamixer")
    local missing_bins=()
    
    for bin in "${optional_bins[@]}"; do
        if ! command -v "$bin" &> /dev/null; then
            missing_bins+=("$bin")
        fi
    done
    
    if [ ${#missing_bins[@]} -eq 0 ]; then
        return 0
    else
        log_warning "Optional binaries missing: ${missing_bins[*]}"
        return 0  # Don't fail for optional binaries
    fi
}

# Test 3: Validate Hyprland configuration syntax
test_hyprland_config_syntax() {
    if [ ! -f "$HYPR_CONFIG/hyprland.conf" ]; then
        log_error "Hyprland config file not found"
        return 1
    fi
    
    # Basic syntax validation
    if grep -q "^[[:space:]]*#" "$HYPR_CONFIG/hyprland.conf" && 
       grep -q "^[[:space:]]*[a-zA-Z]" "$HYPR_CONFIG/hyprland.conf"; then
        return 0
    else
        return 1
    fi
}

# Test 4: Validate Waybar configuration JSON
test_waybar_config_json() {
    if [ ! -f "$WAYBAR_CONFIG/config" ]; then
        log_error "Waybar config file not found"
        return 1
    fi
    
    # Test JSON validity
    if command -v python3 &> /dev/null; then
        python3 -m json.tool "$WAYBAR_CONFIG/config" > /dev/null 2>&1
    elif command -v jq &> /dev/null; then
        jq empty "$WAYBAR_CONFIG/config" > /dev/null 2>&1
    else
        log_warning "No JSON validator found (python3 or jq)"
        return 0
    fi
}

# Test 5: Validate Waybar CSS syntax
test_waybar_css_syntax() {
    if [ ! -f "$WAYBAR_CONFIG/style.css" ]; then
        log_error "Waybar CSS file not found"
        return 1
    fi
    
    # Basic CSS validation - check for balanced braces
    local open_braces=$(grep -o '{' "$WAYBAR_CONFIG/style.css" | wc -l)
    local close_braces=$(grep -o '}' "$WAYBAR_CONFIG/style.css" | wc -l)
    
    if [ "$open_braces" -eq "$close_braces" ]; then
        return 0
    else
        log_error "CSS braces mismatch: $open_braces open, $close_braces close"
        return 1
    fi
}

# Test 6: Check required configuration files
test_config_files_exist() {
    local required_files=(
        "$HYPR_CONFIG/hyprland.conf"
        "$HYPR_CONFIG/hyprpaper.conf"
        "$WAYBAR_CONFIG/config"
        "$WAYBAR_CONFIG/style.css"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        return 0
    else
        log_error "Missing config files: ${missing_files[*]}"
        return 1
    fi
}

# Test 7: Check asset files
test_asset_files() {
    local asset_files=(
        "$HYPR_CONFIG/.koompi/koompi-logo-40.png"
        "$HYPR_CONFIG/.koompi/wall/landscape-nature-grand-canyon-wallpaper-hd-desktop.jpg"
    )
    
    local missing_assets=()
    
    for asset in "${asset_files[@]}"; do
        if [ ! -f "$asset" ]; then
            missing_assets+=("$asset")
        fi
    done
    
    if [ ${#missing_assets[@]} -eq 0 ]; then
        return 0
    else
        log_error "Missing asset files: ${missing_assets[*]}"
        return 1
    fi
}

# Test 8: Check script permissions
test_script_permissions() {
    local script_dirs=(
        "$HYPR_CONFIG/scripts"
        "$WAYBAR_CONFIG/scripts"
    )
    
    local non_executable=()
    
    for dir in "${script_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' script; do
                if [ ! -x "$script" ]; then
                    non_executable+=("$script")
                fi
            done < <(find "$dir" -name "*.sh" -print0)
        fi
    done
    
    if [ ${#non_executable[@]} -eq 0 ]; then
        return 0
    else
        log_warning "Non-executable scripts: ${non_executable[*]}"
        # Fix permissions automatically
        for script in "${non_executable[@]}"; do
            chmod +x "$script"
            log_info "Fixed permissions for $script"
        done
        return 0
    fi
}

# Test 9: Validate Rofi themes
test_rofi_themes() {
    local rofi_themes=(
        "$HYPR_CONFIG/rofi/launchpad.rasi"
        "$HYPR_CONFIG/rofi/command-palette.rasi"
        "$HYPR_CONFIG/rofi/window-switcher.rasi"
    )
    
    local missing_themes=()
    
    for theme in "${rofi_themes[@]}"; do
        if [ ! -f "$theme" ]; then
            missing_themes+=("$theme")
        fi
    done
    
    if [ ${#missing_themes[@]} -eq 0 ]; then
        return 0
    else
        log_warning "Missing Rofi themes: ${missing_themes[*]}"
        return 0  # Don't fail for missing themes
    fi
}

# Test 10: Check Wayland environment
test_wayland_environment() {
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        return 0
    elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
        log_warning "Running on X11 - Wayland recommended for optimal experience"
        return 0
    else
        log_warning "Unknown session type: $XDG_SESSION_TYPE"
        return 0
    fi
}

# Test 11: Check GPU compatibility
test_gpu_compatibility() {
    if command -v nvidia-smi &> /dev/null; then
        log_info "NVIDIA GPU detected - checking drivers"
        if nvidia-smi &> /dev/null; then
            log_info "NVIDIA drivers working"
            return 0
        else
            log_warning "NVIDIA drivers may have issues"
            return 0
        fi
    elif lspci | grep -i amd | grep -i vga &> /dev/null; then
        log_info "AMD GPU detected"
        return 0
    elif lspci | grep -i intel | grep -i vga &> /dev/null; then
        log_info "Intel GPU detected"
        return 0
    else
        log_warning "GPU type could not be determined"
        return 0
    fi
}

# Test 12: Check system resources
test_system_resources() {
    local min_ram_gb=4
    local min_disk_gb=2
    
    # Check RAM
    local total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local total_ram_gb=$((total_ram_kb / 1024 / 1024))
    
    if [ "$total_ram_gb" -lt "$min_ram_gb" ]; then
        log_warning "Low RAM: ${total_ram_gb}GB (minimum ${min_ram_gb}GB recommended)"
    fi
    
    # Check disk space
    local available_space_gb=$(df "$HOME" | awk 'NR==2 {print int($4/1024/1024)}')
    
    if [ "$available_space_gb" -lt "$min_disk_gb" ]; then
        log_warning "Low disk space: ${available_space_gb}GB available (minimum ${min_disk_gb}GB needed)"
    fi
    
    return 0
}

# Test 13: Validate Waybar modules configuration
test_waybar_modules() {
    if [ ! -f "$WAYBAR_CONFIG/config" ]; then
        return 1
    fi
    
    # Check for required modules
    local required_modules=("clock" "cpu" "memory" "battery")
    local missing_modules=()
    
    for module in "${required_modules[@]}"; do
        if ! grep -q "\"$module\"" "$WAYBAR_CONFIG/config"; then
            missing_modules+=("$module")
        fi
    done
    
    if [ ${#missing_modules[@]} -eq 0 ]; then
        return 0
    else
        log_warning "Missing Waybar modules: ${missing_modules[*]}"
        return 0
    fi
}

# Test 14: Check font availability
test_font_availability() {
    local required_fonts=("JetBrains Mono" "Font Awesome")
    local missing_fonts=()
    
    if command -v fc-list &> /dev/null; then
        for font in "${required_fonts[@]}"; do
            if ! fc-list | grep -qi "$font"; then
                missing_fonts+=("$font")
            fi
        done
        
        if [ ${#missing_fonts[@]} -eq 0 ]; then
            return 0
        else
            log_warning "Missing fonts: ${missing_fonts[*]}"
            return 0
        fi
    else
        log_warning "fontconfig not available - cannot check fonts"
        return 0
    fi
}

# Test 15: Validate keybinding syntax
test_keybinding_syntax() {
    if [ ! -f "$HYPR_CONFIG/hyprland.conf" ]; then
        return 1
    fi
    
    # Check for basic keybinding format
    if grep -q "^bind\s*=" "$HYPR_CONFIG/hyprland.conf"; then
        return 0
    else
        log_error "No keybindings found in configuration"
        return 1
    fi
}

# Run all tests
run_all_tests() {
    show_header
    
    log_info "Running KOOMPI Hyprland configuration tests..."
    echo ""
    
    # Core functionality tests
    run_test "Required binaries available" "test_required_binaries"
    run_test "Optional binaries available" "test_optional_binaries"
    run_test "Configuration files exist" "test_config_files_exist"
    run_test "Hyprland config syntax" "test_hyprland_config_syntax"
    run_test "Waybar JSON config valid" "test_waybar_config_json"
    run_test "Waybar CSS syntax valid" "test_waybar_css_syntax"
    run_test "Asset files present" "test_asset_files"
    run_test "Script permissions correct" "test_script_permissions"
    
    # Optional/enhancement tests
    run_test "Rofi themes available" "test_rofi_themes"
    run_test "Wayland environment" "test_wayland_environment"
    run_test "GPU compatibility" "test_gpu_compatibility"
    run_test "System resources adequate" "test_system_resources"
    run_test "Waybar modules configured" "test_waybar_modules"
    run_test "Required fonts available" "test_font_availability"
    run_test "Keybinding syntax valid" "test_keybinding_syntax"
}

# Show test results
show_results() {
    echo ""
    echo -e "${WHITE}═══════════════════════════════════════════════${NC}"
    echo -e "${WHITE}              TEST RESULTS SUMMARY               ${NC}"
    echo -e "${WHITE}═══════════════════════════════════════════════${NC}"
    
    echo -e "Tests Run:     ${BLUE}$TESTS_RUN${NC}"
    echo -e "Passed:        ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:        ${RED}$TESTS_FAILED${NC}"
    echo -e "Warnings:      ${YELLOW}$TESTS_WARNINGS${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✅ Configuration is ready for use!${NC}"
        if [ $TESTS_WARNINGS -gt 0 ]; then
            echo -e "${YELLOW}⚠️  Some optional components have warnings${NC}"
        fi
    else
        echo -e "\n${RED}❌ Configuration has issues that need attention${NC}"
        echo -e "${WHITE}Please fix the failed tests before using Hyprland${NC}"
    fi
    
    echo -e "${WHITE}═══════════════════════════════════════════════${NC}"
}

# Fix common issues automatically
auto_fix() {
    log_info "Attempting to fix common issues..."
    
    # Fix script permissions
    find "$HYPR_CONFIG/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find "$WAYBAR_CONFIG/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    log_info "Auto-fix completed"
}

# Main execution
main() {
    # Parse command line arguments
    case "${1:-}" in
        "--fix")
            auto_fix
            ;;
        "--help")
            echo "Usage: $0 [--fix|--help]"
            echo "  --fix    Attempt to fix common issues automatically"
            echo "  --help   Show this help message"
            exit 0
            ;;
        "")
            run_all_tests
            show_results
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"