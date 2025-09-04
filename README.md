# 🚀 KOOMPI Hyprland Desktop Environment

A modern, elegant Hyprland configuration optimized for productivity and aesthetics. Features a beautiful Waybar with rainbow animations, compact macOS-style spacing, and comprehensive system monitoring.

![Preview](https://img.shields.io/badge/Hyprland-Modern-blue?style=for-the-badge&logo=wayland)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Wayland](https://img.shields.io/badge/Wayland-Ready-purple?style=for-the-badge)

## ✨ Features

- **🌈 Rainbow Border Animation** - Matching Hyprland window borders
- **📊 System Monitoring** - CPU, Memory, Temperature, Battery with colorful indicators  
- **🎨 Glass Morphism UI** - Modern transparent design with subtle effects
- **⚡ Performance Optimized** - Smooth animations for Intel Xeon + NVIDIA Quadro
- **🔧 Professional Workflow** - Vim-style keybindings and workspace management
- **📱 macOS-Style Compact Layout** - Clean, space-efficient design

## 🖥️ Screenshots

```
┌─────────────────────────────────────────────────────────────┐
│  🏠  Workspace  Window Title     🕐 Time     📊 CPU 󰍛 RAM 🌡️ Temp 󰃞 BRI 󰕾 VOL 󰂯 📶 🔋 ⏻  │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Requirements

### System Requirements
- **GPU**: Any modern GPU with OpenGL support (Intel integrated, NVIDIA, AMD)
- **RAM**: 2GB minimum, 4GB recommended for smooth experience
- **CPU**: Any modern x86_64 processor (Intel/AMD from ~2010+)
- **Display**: Any resolution (1080p to 4K+, single or multi-monitor)
- **OS**: Linux distribution with Wayland support

**Note**: Hyprland is lightweight and runs well on older hardware. This configuration is optimized for performance across low to high-end systems.

### Supported Distributions
- ✅ **Arch Linux** (and derivatives: Manjaro, EndeavourOS, ArcoLinux)
- ✅ **Debian** (and derivatives: Ubuntu, Pop!_OS, Linux Mint)
- ✅ **Fedora** (and derivatives: Nobara, Silverblue)
- ✅ **openSUSE** (Tumbleweed, Leap)
- ✅ **Void Linux**
- ✅ **Gentoo**

## 🚀 One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/koompi/koompi-hypr/main/install.sh | bash
```

Or download and run manually:
```bash
git clone https://github.com/koompi/koompi-hypr.git
cd koompi-hypr
chmod +x install.sh
./install.sh
```

## 📋 Manual Installation

### 1. Install Dependencies

#### Arch Linux
```bash
sudo pacman -S hyprland waybar dunst hyprpaper kitty thunar firefox rofi wofi \
               polkit-gnome xdg-desktop-portal-hyprland qt5-wayland qt6-wayland \
               wl-clipboard cliphist grim slurp grimblast brightnessctl pamixer \
               pavucontrol networkmanager bluez bluez-utils
```

#### Debian/Ubuntu
```bash
sudo apt update
sudo apt install hyprland waybar dunst hyprpaper kitty thunar firefox-esr \
                 rofi polkit-gnome xdg-desktop-portal-wlr qtwayland5 \
                 wl-clipboard grim slurp brightnessctl pulseaudio-utils \
                 pavucontrol network-manager bluez
```

#### Fedora
```bash
sudo dnf install hyprland waybar dunst hyprpaper kitty thunar firefox \
                 rofi polkit-gnome xdg-desktop-portal-hyprland qt5-qtwayland \
                 qt6-qtwayland wl-clipboard grim slurp brightnessctl \
                 pulseaudio-utils pavucontrol NetworkManager bluez
```

### 2. Install Configuration

```bash
# Backup existing config (if any)
[ -d ~/.config/hypr ] && mv ~/.config/hypr ~/.config/hypr.backup.$(date +%s)

# Clone and install
git clone https://github.com/koompi/koompi-hypr.git ~/koompi-hypr
cp -r ~/koompi-hypr/.config/hypr ~/.config/
cp -r ~/koompi-hypr/.config/waybar ~/.config/

# Set permissions
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh
```

### 3. Start Hyprland

From TTY:
```bash
Hyprland
```

Or add to your display manager.

## ⌨️ Key Bindings

### Core Applications
| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + E` | File Manager (Thunar) |
| `Super + B` | Browser (Firefox) |
| `Super + C` | Code Editor |
| `Super + Space` | App Launcher (Rofi) |
| `Super + Shift + Space` | Command Palette |

### Window Management
| Key | Action |
|-----|--------|
| `Super + Q` | Close Window |
| `Super + V` | Toggle Floating |
| `Super + F` | Fullscreen |
| `Super + H/J/K/L` | Move Focus (Vim-style) |
| `Super + Shift + H/J/K/L` | Move Window |
| `Super + Ctrl + H/J/K/L` | Resize Window |

### Workspaces
| Key | Action |
|-----|--------|
| `Super + 1-9` | Switch to Workspace |
| `Super + Shift + 1-9` | Move Window to Workspace |
| `Super + S` | Scratchpad |

### System
| Key | Action |
|-----|--------|
| `Print` | Screenshot Area |
| `Shift + Print` | Screenshot Screen |
| `Super + Print` | Screenshot Window |
| `XF86AudioRaise/Lower` | Volume Control |
| `XF86MonBrightnessUp/Down` | Brightness Control |

## 🎨 Customization

### Color Themes
The configuration uses **Catppuccin Mocha** colors:
- **Blue**: `#89b4fa` (CPU, Bluetooth)
- **Purple**: `#cba6f7` (Memory)
- **Orange**: `#fab387` (Temperature, Brightness)
- **Green**: `#a6e3a1` (Audio, Battery)
- **Cyan**: `#94e2d5` (Network)
- **Pink**: `#f5c2e7` (Power)

### Wallpaper
```bash
# Change wallpaper
cp your-wallpaper.jpg ~/.config/hypr/.koompi/wall/
# Update hyprpaper.conf with new path
```

### Waybar Modules
Edit `~/.config/waybar/config` to add/remove modules:
```json
"modules-right": [
    "cpu",           // System monitoring
    "memory", 
    "temperature",
    "battery",       // Power management
    "network",       // Connectivity
    "pulseaudio",
    "custom/power"   // Custom modules
]
```

## 🔧 Configuration Files

```
~/.config/hypr/
├── hyprland.conf          # Main Hyprland config
├── hyprpaper.conf         # Wallpaper configuration
├── .koompi/
│   ├── koompi-logo-40.png # Waybar logo
│   └── wall/              # Wallpapers
└── scripts/
    └── *.sh              # Helper scripts

~/.config/waybar/
├── config                 # Waybar modules
├── style.css             # Waybar styling
└── scripts/
    └── *.sh              # Waybar scripts
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Waybar not starting
```bash
# Check for errors
waybar -l debug

# Restart waybar
pkill waybar && waybar &
```

#### 2. NVIDIA issues
Add to `hyprland.conf`:
```conf
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
```

#### 3. Screen tearing
```conf
general {
    allow_tearing = true
}
```

#### 4. High CPU usage
Reduce animation complexity in `hyprland.conf`:
```conf
animations {
    enabled = true
    
    animation = windows, 1, 4, default, slide
    animation = border, 1, 1, default
    animation = fade, 1, 6, default
}
```

### Logs and Debug
```bash
# View Hyprland logs
journalctl -f -u display-manager

# Check Waybar status
systemctl --user status waybar

# Test configurations
hyprctl reload
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup
```bash
git clone https://github.com/koompi/koompi-hypr.git
cd koompi-hypr

# Make changes and test
./test-config.sh

# Submit pull request
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Hyprland** - Amazing Wayland compositor
- **Waybar** - Highly customizable status bar
- **Catppuccin** - Beautiful color palette
- **KOOMPI Team** - Original design inspiration

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/koompi/koompi-hypr/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/koompi/koompi-hypr/discussions)
- 📧 **Email**: support@koompi.com

---

**Made with ❤️ for the Linux community**

> ⭐ If you find this project useful, please give it a star on GitHub!