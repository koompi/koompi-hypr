#!/bin/bash

# KOOMPI Hyprland Desktop Environment Installer
# Supports: Arch, Debian, Fedora, openSUSE, Void, Gentoo
# Automatically detects distribution and handles X11 to Wayland transition

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

# Configuration
REPO_URL="https://github.com/koompi/koompi-hypr.git"
INSTALL_DIR="$HOME/koompi-hypr"
BACKUP_DIR="$HOME/.config/hypr.backup.$(date +%s)"

# Logo
show_logo() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    ╦╔═╔═╗╔═╗╔╦╗╔═╗╦  
    ╠╩╗║ ║║ ║║║║╠═╝║  
    ╩ ╩╚═╝╚═╝╩ ╩╩  ╩  
    
    Hyprland Desktop Environment
    Modern • Elegant • Powerful
EOF
    echo -e "${NC}"
}

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_BASE=$ID_LIKE
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
    else
        log_error "Unable to detect distribution"
        exit 1
    fi
    
    log_info "Detected distribution: $DISTRO"
}

# Check if running on X11 and offer Wayland transition
check_display_server() {
    if [ "$XDG_SESSION_TYPE" = "x11" ]; then
        log_warning "You are currently running X11"
        echo -e "${YELLOW}KOOMPI Hyprland requires Wayland for optimal experience.${NC}"
        echo -e "${WHITE}Options:${NC}"
        echo "1. Install Hyprland alongside X11 (recommended)"
        echo "2. Continue anyway (may have issues)"
        echo "3. Exit and manually switch to Wayland"
        
        read -p "Choose option [1-3]: " choice
        case $choice in
            1) log_info "Will install Hyprland with Wayland support" ;;
            2) log_warning "Continuing with X11 (not recommended)" ;;
            3) 
                log_info "Please switch to a Wayland session or TTY and run this script again"
                exit 0
                ;;
            *) log_error "Invalid choice" && exit 1 ;;
        esac
    else
        log_success "Wayland detected - perfect!"
    fi
}

# Install packages based on distribution
install_dependencies() {
    log_step "Installing dependencies for $DISTRO..."
    
    case $DISTRO in
        "arch"|"manjaro"|"endeavouros"|"arcolinux")
            sudo pacman -Sy --needed --noconfirm \
                hyprland waybar dunst hyprpaper kitty thunar firefox \
                rofi wofi polkit-gnome xdg-desktop-portal-hyprland \
                qt5-wayland qt6-wayland wl-clipboard cliphist \
                grim slurp grimblast brightnessctl pamixer \
                pavucontrol networkmanager bluez bluez-utils \
                ttf-jetbrains-mono ttf-font-awesome noto-fonts-emoji
            ;;
            
        "debian"|"ubuntu"|"pop"|"mint")
            sudo apt update
            sudo apt install -y \
                hyprland waybar dunst hyprpaper kitty thunar firefox-esr \
                rofi polkit-gnome xdg-desktop-portal-wlr qtwayland5 \
                wl-clipboard grim slurp brightnessctl pulseaudio-utils \
                pavucontrol network-manager bluez fonts-jetbrains-mono \
                fonts-font-awesome fonts-noto-color-emoji
            ;;
            
        "fedora"|"nobara")
            sudo dnf install -y \
                hyprland waybar dunst hyprpaper kitty thunar firefox \
                rofi polkit-gnome xdg-desktop-portal-hyprland \
                qt5-qtwayland qt6-qtwayland wl-clipboard grim slurp \
                brightnessctl pulseaudio-utils pavucontrol NetworkManager \
                bluez jetbrains-mono-fonts fontawesome-fonts \
                google-noto-emoji-color-fonts
            ;;
            
        "opensuse"|"opensuse-tumbleweed")
            sudo zypper install -y \
                hyprland waybar dunst hyprpaper kitty thunar firefox \
                rofi polkit-gnome xdg-desktop-portal-hyprland \
                libqt5-qtwayland libqt6-qtwayland wl-clipboard grim slurp \
                brightnessctl pulseaudio-utils pavucontrol NetworkManager \
                bluez jetbrains-mono-fonts fontawesome-fonts \
                noto-coloremoji-fonts
            ;;
            
        "void")
            sudo xbps-install -Sy \
                hyprland waybar dunst hyprpaper kitty thunar firefox \
                rofi polkit-gnome xdg-desktop-portal-hyprland \
                qt5-wayland qt6-wayland wl-clipboard grim slurp \
                brightnessctl pulseaudio pavucontrol NetworkManager \
                bluez font-jetbrains-mono font-awesome \
                noto-fonts-emoji
            ;;
            
        "gentoo")
            log_info "Gentoo detected - please emerge packages manually:"
            echo "emerge hyprland waybar dunst hyprpaper kitty thunar firefox"
            echo "emerge rofi polkit-gnome xdg-desktop-portal-hyprland"
            echo "emerge qtwayland wl-clipboard grim slurp brightnessctl"
            echo "emerge pulseaudio pavucontrol networkmanager bluez"
            read -p "Press Enter after installing dependencies..."
            ;;
            
        *)
            log_error "Unsupported distribution: $DISTRO"
            log_info "Please install dependencies manually and run script again"
            exit 1
            ;;
    esac
    
    log_success "Dependencies installed successfully"
}

# Backup existing configuration
backup_config() {
    if [ -d "$HOME/.config/hypr" ]; then
        log_step "Backing up existing Hyprland configuration..."
        mv "$HOME/.config/hypr" "$BACKUP_DIR"
        log_success "Backup created at $BACKUP_DIR"
    fi
    
    if [ -d "$HOME/.config/waybar" ]; then
        log_step "Backing up existing Waybar configuration..."
        mv "$HOME/.config/waybar" "$HOME/.config/waybar.backup.$(date +%s)"
    fi
}

# Clone and install configuration
install_config() {
    log_step "Downloading KOOMPI Hyprland configuration..."
    
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi
    
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    log_step "Installing configuration files..."
    
    # Copy configuration files
    cp -r .config/hypr "$HOME/.config/"
    cp -r .config/waybar "$HOME/.config/"
    
    # Set executable permissions
    find "$HOME/.config/hypr/scripts" -name "*.sh" -exec chmod +x {} \;
    find "$HOME/.config/waybar/scripts" -name "*.sh" -exec chmod +x {} \;
    
    log_success "Configuration files installed"
}

# Enable services
enable_services() {
    log_step "Enabling system services..."
    
    # Enable NetworkManager
    if command -v systemctl &> /dev/null; then
        sudo systemctl enable NetworkManager
        sudo systemctl enable bluetooth
        log_success "Services enabled"
    else
        log_warning "systemctl not found - please enable NetworkManager and Bluetooth manually"
    fi
}

# Create desktop entry for display managers
create_desktop_entry() {
    log_step "Creating Hyprland desktop entry..."
    
    if [ ! -d "/usr/share/wayland-sessions" ]; then
        sudo mkdir -p /usr/share/wayland-sessions
    fi
    
    sudo tee /usr/share/wayland-sessions/hyprland-koompi.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland (KOOMPI)
Comment=KOOMPI Hyprland Desktop Environment
Exec=Hyprland
Type=Application
EOF
    
    log_success "Desktop entry created"
}

# Run configuration tests
run_tests() {
    log_step "Running configuration tests..."
    
    if [ -f "$HOME/.config/hypr/test-config.sh" ]; then
        chmod +x "$HOME/.config/hypr/test-config.sh"
        "$HOME/.config/hypr/test-config.sh"
    else
        # Basic tests
        test_hyprland_config
        test_waybar_config
    fi
}

test_hyprland_config() {
    log_info "Testing Hyprland configuration..."
    
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        # Test if config file is valid (basic syntax check)
        if hyprland --config "$HOME/.config/hypr/hyprland.conf" --check 2>/dev/null; then
            log_success "Hyprland configuration is valid"
        else
            log_warning "Hyprland configuration may have issues"
        fi
    else
        log_error "Hyprland configuration file not found"
    fi
}

test_waybar_config() {
    log_info "Testing Waybar configuration..."
    
    if [ -f "$HOME/.config/waybar/config" ]; then
        # Test if JSON is valid
        if python3 -m json.tool "$HOME/.config/waybar/config" > /dev/null 2>&1; then
            log_success "Waybar configuration is valid JSON"
        else
            log_warning "Waybar configuration JSON may be invalid"
        fi
    else
        log_error "Waybar configuration file not found"
    fi
}

# Show post-installation instructions
show_completion() {
    log_success "KOOMPI Hyprland installation completed!"
    
    echo -e "${WHITE}Next steps:${NC}"
    echo "1. Log out of your current session"
    echo "2. At the login screen, select 'Hyprland (KOOMPI)'"
    echo "3. Log in to experience your new desktop environment"
    echo ""
    echo -e "${YELLOW}Key Bindings:${NC}"
    echo "• Super + Return: Terminal"
    echo "• Super + Space: App Launcher"
    echo "• Super + E: File Manager"
    echo "• Super + B: Browser"
    echo "• Super + /: Help"
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    echo "• Hyprland: ~/.config/hypr/"
    echo "• Waybar: ~/.config/waybar/"
    echo "• Backup: $BACKUP_DIR"
    echo ""
    echo -e "${GREEN}Support:${NC}"
    echo "• Documentation: https://github.com/koompi/koompi-hypr"
    echo "• Issues: https://github.com/koompi/koompi-hypr/issues"
    echo ""
    echo -e "${PURPLE}Enjoy your new desktop environment! 🚀${NC}"
}

# Main installation process
main() {
    show_logo
    
    log_info "Starting KOOMPI Hyprland installation..."
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        log_error "Please do not run this script as root"
        exit 1
    fi
    
    # Pre-installation checks
    detect_distro
    check_display_server
    
    # Installation steps
    install_dependencies
    backup_config
    install_config
    enable_services
    create_desktop_entry
    
    # Post-installation
    run_tests
    show_completion
}

# Handle script interruption
cleanup() {
    log_warning "Installation interrupted"
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main installation
main "$@"