# KOOMPI Hyprland Configuration

A modern, minimalist Hyprland configuration featuring beautiful aesthetics, smooth animations, and powerful productivity features.

![Hyprland Version](https://img.shields.io/badge/Hyprland-0.50.1-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Linux-orange)

## ✨ Features

- **Modern Glass Morphism Design** - Beautiful blur effects and transparency
- **Smooth Animations** - Carefully tuned bezier curves for fluid motion
- **Smart Window Management** - Automatic workspace assignments and tiling
- **Multiple Launcher Options** - Rofi with custom themes (launchpad, command palette, spotlight)
- **Productivity Tools** - Clipboard history, emoji picker, quick actions menu
- **Eye Comfort** - Built-in blue light filter shader
- **Performance Optimized** - Special rules for games and resource-intensive apps

## 📸 Screenshots

<details>
<summary>Click to view screenshots</summary>

![Desktop Overview](screenshots/desktop.png)
![Rofi Launcher](screenshots/rofi-launcher.png)
![Window Management](screenshots/windows.png)

</details>

## 🚀 Quick Start

### Prerequisites

- **Hyprland** 0.50.0 or newer
- **Rofi** (for application launcher)
- **Waybar** (status bar)
- **Dunst** (notifications)
- **swww** (wallpaper daemon)
- **cliphist** (clipboard manager)
- **brightnessctl** (brightness control)
- **wpctl** (audio control)
- **JetBrains Mono** and **SF Pro Display** fonts

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/koompi-hyprland
   cd koompi-hyprland
   ```

2. **Backup your existing config:**
   ```bash
   mv ~/.config/hypr ~/.config/hypr.backup
   ```

3. **Install the configuration:**
   ```bash
   ./install.sh
   ```

4. **Reload Hyprland:**
   Press `Super + Shift + C` or run `hyprctl reload`

## ⌨️ Key Bindings

### Essential Keys

| Key Combination | Action |
|----------------|--------|
| `Super` | Open application launcher |
| `Super + Return` | Open terminal |
| `Super + Q` | Close window |
| `Super + M` | Exit Hyprland |
| `Super + Space` | Toggle floating |
| `Super + F` | Toggle fullscreen |

### Window Management

| Key Combination | Action |
|----------------|--------|
| `Super + [H/J/K/L]` | Focus window (Vim motions) |
| `Super + Shift + [H/J/K/L]` | Move window |
| `Super + Ctrl + [H/J/K/L]` | Resize window |
| `Super + [1-9]` | Switch to workspace |
| `Super + Shift + [1-9]` | Move window to workspace |
| `Super + Tab` | Window switcher |

### Productivity

| Key Combination | Action |
|----------------|--------|
| `Super + V` | Clipboard history |
| `Super + Period` | Emoji picker |
| `Super + P` | Quick actions menu |
| `Super + /` | Show keybind cheatsheet |
| `Print` | Take screenshot |
| `Ctrl + Super + T` | Change wallpaper |

### Media & System

| Key Combination | Action |
|----------------|--------|
| `Volume Keys` | Adjust volume |
| `Brightness Keys` | Adjust brightness |
| `Super + Shift + M` | Toggle mute |
| `Ctrl + Alt + Delete` | Session menu |

## 📁 Configuration Structure

```
~/.config/hypr/
├── hyprland.conf          # Main configuration file
├── hyprland/
│   ├── keybinds.conf      # All keybindings
│   ├── execs.conf         # Startup applications
│   ├── env.conf           # Environment variables
│   ├── rules.conf         # Window rules
│   ├── visual-enhancements.conf  # Animations & effects
│   └── colors.conf        # Color scheme
├── custom/                # User customizations
├── scripts/               # Helper scripts
├── shaders/               # Custom shaders
└── ~/.config/rofi/        # Rofi themes
```

## 🎨 Customization

### Changing Colors

Edit `hyprland/colors.conf` to change the color scheme. The default uses Catppuccin Mocha palette.

### Custom Keybindings

Add your keybindings to `custom/keybinds.conf`. They will override the defaults.

### Window Rules

Add window-specific rules to `custom/rules.conf`.

### Rofi Themes

Multiple Rofi themes are included:
- `launchpad` - macOS-style app grid
- `command-palette` - VS Code-style command palette
- `spotlight` - macOS Spotlight-style search
- `window-switcher` - Alt-tab replacement

## 🔧 Troubleshooting

### Launcher not working
- Ensure Rofi is installed: `pacman -S rofi`
- Check if themes are in `~/.config/rofi/`

### Missing fonts
Install required fonts:
```bash
# Arch Linux
sudo pacman -S ttf-jetbrains-mono

# For SF Pro Display, download from Apple or use Inter as alternative
sudo pacman -S inter-font
```

### Performance issues
- Disable blur in `visual-enhancements.conf`
- Reduce animation duration
- Check GPU drivers are properly installed

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - The amazing Wayland compositor
- [Catppuccin](https://github.com/catppuccin) - Beautiful pastel color scheme
- [KOOMPI](https://koompi.com/) - Inspiration for the configuration

---

Made with ❤️ for the Hyprland community