# Contributing to KOOMPI Hyprland

Thank you for your interest in contributing to KOOMPI Hyprland! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### 1. Reporting Issues

Before creating an issue, please:

- **Search existing issues** to avoid duplicates
- **Use the issue templates** when available
- **Provide detailed information** including:
  - Your distribution and version
  - Hyprland version (`hyprland --version`)
  - Steps to reproduce the issue
  - Expected vs actual behavior
  - Relevant log output

### 2. Suggesting Features

Feature requests are welcome! Please:

- Check if the feature already exists or is planned
- Describe the use case and benefits
- Consider if it aligns with the project's goals
- Be open to discussion and feedback

### 3. Code Contributions

#### Prerequisites

- Basic knowledge of Hyprland configuration
- Familiarity with Waybar and Rofi
- Understanding of shell scripting (Bash)
- Git and GitHub workflow knowledge

#### Development Setup

1. **Fork the repository**
   ```bash
   git fork https://github.com/your-repo/koompi-hyprland.git
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/koompi-hyprland.git
   cd koompi-hyprland
   ```

3. **Create a development branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Test your changes**
   ```bash
   ./test-config.sh
   ```

#### Code Style Guidelines

**Configuration Files (Hyprland, Waybar):**
- Use consistent indentation (4 spaces)
- Comment complex configurations
- Follow existing naming conventions
- Keep lines under 100 characters when possible

**Shell Scripts:**
- Use `#!/bin/bash` shebang
- Enable strict mode: `set -e`
- Quote variables: `"$variable"`
- Use descriptive function names
- Add comments for complex logic
- Follow Google Shell Style Guide

**CSS (Waybar styling):**
- Use consistent indentation (4 spaces)
- Organize related styles together
- Comment color schemes and animations
- Use meaningful class/ID names
- Prefer CSS custom properties for themes

#### Commit Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (no functionality change)
- `refactor`: Code refactoring
- `test`: Test additions/modifications
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(waybar): add battery percentage indicator
fix(hyprland): resolve window focusing issue
docs(readme): update installation instructions
style(waybar): improve color consistency
```

#### Pull Request Process

1. **Update your branch**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests**
   ```bash
   ./test-config.sh
   ```

3. **Create descriptive PR**
   - Clear title describing the change
   - Detailed description of what and why
   - Link related issues using `Fixes #123`
   - Include screenshots for UI changes

4. **Review process**
   - Address reviewer feedback promptly
   - Keep discussions constructive
   - Update documentation if needed

## 📁 Project Structure

```
koompi-hyprland/
├── .config/
│   ├── hypr/                  # Hyprland configuration
│   │   ├── hyprland.conf      # Main config file
│   │   ├── hyprpaper.conf     # Wallpaper settings
│   │   ├── scripts/           # Helper scripts
│   │   ├── rofi/              # Rofi themes
│   │   └── .koompi/           # Assets (logos, wallpapers)
│   └── waybar/                # Waybar configuration
│       ├── config             # Module configuration
│       ├── style.css          # Styling
│       └── scripts/           # Waybar scripts
├── install.sh                 # Installation script
├── test-config.sh            # Test suite
├── backup-restore.sh         # Backup utility
├── README.md                 # Documentation
└── CONTRIBUTING.md           # This file
```

## 🎨 Design Principles

### Visual Design
- **Modern Glass Morphism**: Subtle transparency and blur effects
- **Consistent Color Palette**: Based on Catppuccin Mocha
- **Minimal Interface**: Clean, uncluttered layouts
- **Smooth Animations**: 60fps fluid motion
- **Accessibility**: Good contrast ratios and readable fonts

### User Experience
- **Intuitive Navigation**: Familiar keyboard shortcuts
- **Performance First**: Optimized for smooth operation
- **Customizable**: Easy to modify and extend
- **Cross-platform**: Works across different distributions

### Technical Standards
- **Configuration Management**: Modular, well-organized configs
- **Error Handling**: Graceful degradation and helpful messages
- **Documentation**: Clear, comprehensive guides
- **Testing**: Automated validation of configurations

## 🧪 Testing

### Running Tests

```bash
# Full test suite
./test-config.sh

# Fix common issues automatically
./test-config.sh --fix

# Show help
./test-config.sh --help
```

### Test Categories

1. **Configuration Validation**
   - Syntax checking for all config files
   - Required dependencies verification
   - Asset file availability

2. **System Compatibility**
   - Distribution detection
   - Display server compatibility
   - GPU driver validation

3. **Functionality Tests**
   - Waybar module functionality
   - Rofi theme loading
   - Script execution permissions

### Adding New Tests

When adding features, please include tests:

1. Add test function to `test-config.sh`
2. Follow naming convention: `test_feature_name()`
3. Return 0 for success, 1 for failure
4. Use logging functions for output
5. Update test documentation

## 📊 Performance Considerations

### Hyprland Configuration
- Optimize animation curves for smoothness
- Balance visual effects with performance
- Consider different hardware capabilities
- Test on various GPU types (Intel, AMD, NVIDIA)

### Waybar Modules
- Minimize update intervals where possible
- Use efficient scripts for custom modules
- Avoid blocking operations in scripts
- Consider battery life on laptops

## 🌐 Internationalization

While currently English-only, we welcome contributions for:

- Translated documentation
- Locale-aware scripts
- International keyboard layouts
- Region-specific customizations

## 📝 Documentation

### Documentation Standards
- Write clear, concise instructions
- Include code examples
- Add screenshots for visual changes
- Update README.md for user-facing changes
- Comment complex configurations

### Areas Needing Documentation
- Advanced customization guides
- Troubleshooting specific hardware
- Integration with other tools
- Performance tuning guides

## 🔒 Security Considerations

When contributing scripts or configurations:

- Avoid hardcoded credentials
- Validate input parameters
- Use secure temporary files
- Be cautious with `sudo` requirements
- Review third-party dependencies

## 🎯 Roadmap and Priorities

### High Priority
- Multi-monitor improvements
- Performance optimizations
- Better error handling
- Expanded hardware support

### Medium Priority
- Additional Waybar modules
- More Rofi themes
- Enhanced animations
- Better documentation

### Low Priority
- Alternative color schemes
- Additional wallpapers
- Extra utility scripts
- Community showcases

## 🏆 Recognition

Contributors are recognized in:

- README.md contributors section
- Git commit history
- Release notes for significant contributions
- Special thanks for major features

## 💬 Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Provide constructive feedback
- Help newcomers learn
- Focus on technical merit
- Maintain professional communication

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Requests**: Code review and collaboration

## 📞 Getting Help

If you need help contributing:

1. Check existing documentation
2. Search closed issues and PRs
3. Ask in GitHub Discussions
4. Contact maintainers directly

## 🎉 Thank You

Every contribution, no matter how small, helps improve KOOMPI Hyprland for the entire community. Thank you for taking the time to contribute!

---

**Happy coding! 🚀**