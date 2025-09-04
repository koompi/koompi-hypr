#!/bin/bash

# KOOMPI Hyprland Backup and Restore Utility
# Safely backup and restore configuration files

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
BACKUP_BASE_DIR="$HOME/.config/koompi-hyprland-backups"
CONFIG_DIRS=("$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/rofi")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DEFAULT_BACKUP_NAME="backup_$TIMESTAMP"

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

# Show header
show_header() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    ╔════════════════════════════════════════════╗
    ║        KOOMPI HYPRLAND BACKUP TOOL         ║
    ║          Configuration Management          ║
    ╚════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Create backup directory structure
init_backup_dir() {
    if [ ! -d "$BACKUP_BASE_DIR" ]; then
        mkdir -p "$BACKUP_BASE_DIR"
        log_info "Created backup directory: $BACKUP_BASE_DIR"
    fi
}

# Create a full backup
create_backup() {
    local backup_name="${1:-$DEFAULT_BACKUP_NAME}"
    local backup_dir="$BACKUP_BASE_DIR/$backup_name"
    
    log_step "Creating backup: $backup_name"
    
    if [ -d "$backup_dir" ]; then
        log_error "Backup already exists: $backup_name"
        return 1
    fi
    
    mkdir -p "$backup_dir"
    
    # Create metadata file
    cat > "$backup_dir/backup_info.txt" << EOF
Backup Name: $backup_name
Created: $(date)
Hostname: $(hostname)
User: $(whoami)
Hyprland Version: $(hyprland --version 2>/dev/null || echo "Not installed")
Waybar Version: $(waybar --version 2>/dev/null || echo "Not installed")
EOF
    
    # Backup configuration directories
    for config_dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$config_dir" ]; then
            local dir_name=$(basename "$config_dir")
            log_info "Backing up $config_dir..."
            cp -r "$config_dir" "$backup_dir/$dir_name"
            log_success "Backed up $dir_name"
        else
            log_warning "Directory not found: $config_dir"
        fi
    done
    
    # Backup additional files
    backup_additional_files "$backup_dir"
    
    # Create archive
    log_step "Creating compressed archive..."
    cd "$BACKUP_BASE_DIR"
    tar -czf "${backup_name}.tar.gz" "$backup_name"
    log_success "Backup archive created: ${backup_name}.tar.gz"
    
    # Generate checksum
    sha256sum "${backup_name}.tar.gz" > "${backup_name}.tar.gz.sha256"
    log_info "Checksum generated"
    
    log_success "Backup completed successfully!"
    echo -e "${WHITE}Backup location: $backup_dir${NC}"
    echo -e "${WHITE}Archive: $BACKUP_BASE_DIR/${backup_name}.tar.gz${NC}"
}

# Backup additional important files
backup_additional_files() {
    local backup_dir="$1"
    
    # Backup shell configuration if it contains Hyprland-related settings
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    
    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ] && grep -q -i "hypr\|wayland" "$config"; then
            log_info "Backing up $config (contains Hyprland settings)"
            cp "$config" "$backup_dir/$(basename "$config")"
        fi
    done
    
    # Backup GTK themes if custom
    if [ -f "$HOME/.gtkrc-2.0" ]; then
        cp "$HOME/.gtkrc-2.0" "$backup_dir/"
    fi
    
    if [ -d "$HOME/.config/gtk-3.0" ]; then
        cp -r "$HOME/.config/gtk-3.0" "$backup_dir/"
    fi
    
    if [ -d "$HOME/.config/gtk-4.0" ]; then
        cp -r "$HOME/.config/gtk-4.0" "$backup_dir/"
    fi
}

# List available backups
list_backups() {
    log_step "Available backups:"
    
    if [ ! -d "$BACKUP_BASE_DIR" ] || [ -z "$(ls -A "$BACKUP_BASE_DIR" 2>/dev/null)" ]; then
        log_warning "No backups found"
        return 1
    fi
    
    echo -e "${WHITE}Directory Backups:${NC}"
    for backup in "$BACKUP_BASE_DIR"/backup_*; do
        if [ -d "$backup" ]; then
            local backup_name=$(basename "$backup")
            local backup_date=$(stat -c %y "$backup" | cut -d' ' -f1)
            echo -e "  ${GREEN}$backup_name${NC} (created: $backup_date)"
            
            if [ -f "$backup/backup_info.txt" ]; then
                echo "    $(head -n1 "$backup/backup_info.txt")"
            fi
        fi
    done
    
    echo -e "\n${WHITE}Archive Backups:${NC}"
    for archive in "$BACKUP_BASE_DIR"/*.tar.gz; do
        if [ -f "$archive" ]; then
            local archive_name=$(basename "$archive" .tar.gz)
            local archive_size=$(du -h "$archive" | cut -f1)
            echo -e "  ${BLUE}$archive_name.tar.gz${NC} (size: $archive_size)"
        fi
    done
}

# Restore from backup
restore_backup() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        log_error "Please specify a backup name to restore"
        list_backups
        return 1
    fi
    
    local backup_dir="$BACKUP_BASE_DIR/$backup_name"
    local backup_archive="$BACKUP_BASE_DIR/${backup_name}.tar.gz"
    
    # Check if backup exists
    if [ ! -d "$backup_dir" ] && [ ! -f "$backup_archive" ]; then
        log_error "Backup not found: $backup_name"
        list_backups
        return 1
    fi
    
    # Extract archive if needed
    if [ ! -d "$backup_dir" ] && [ -f "$backup_archive" ]; then
        log_step "Extracting backup archive..."
        
        # Verify checksum if available
        if [ -f "${backup_archive}.sha256" ]; then
            log_info "Verifying backup integrity..."
            if sha256sum -c "${backup_archive}.sha256" --quiet; then
                log_success "Backup integrity verified"
            else
                log_error "Backup integrity check failed!"
                read -p "Continue anyway? (y/N): " -r
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    return 1
                fi
            fi
        fi
        
        cd "$BACKUP_BASE_DIR"
        tar -xzf "$backup_archive"
        log_success "Archive extracted"
    fi
    
    # Create current backup before restore
    log_step "Creating backup of current configuration..."
    create_backup "pre_restore_$TIMESTAMP"
    
    # Restore configuration directories
    log_step "Restoring configuration from: $backup_name"
    
    for config_dir in "${CONFIG_DIRS[@]}"; do
        local dir_name=$(basename "$config_dir")
        local backup_config="$backup_dir/$dir_name"
        
        if [ -d "$backup_config" ]; then
            log_info "Restoring $dir_name..."
            
            # Remove current config
            if [ -d "$config_dir" ]; then
                rm -rf "$config_dir"
            fi
            
            # Restore from backup
            cp -r "$backup_config" "$config_dir"
            
            # Fix permissions
            find "$config_dir" -name "*.sh" -exec chmod +x {} \;
            
            log_success "Restored $dir_name"
        else
            log_warning "No backup found for $dir_name"
        fi
    done
    
    # Restore additional files
    restore_additional_files "$backup_dir"
    
    log_success "Restore completed successfully!"
    log_info "Please restart Hyprland to apply changes"
}

# Restore additional files
restore_additional_files() {
    local backup_dir="$1"
    
    # Restore shell configurations
    for config in "$backup_dir"/.{bashrc,zshrc,profile}; do
        if [ -f "$config" ]; then
            local target="$HOME/$(basename "$config")"
            log_info "Restoring $(basename "$config")"
            cp "$config" "$target"
        fi
    done
    
    # Restore GTK configurations
    if [ -f "$backup_dir/.gtkrc-2.0" ]; then
        cp "$backup_dir/.gtkrc-2.0" "$HOME/"
    fi
    
    if [ -d "$backup_dir/gtk-3.0" ]; then
        rm -rf "$HOME/.config/gtk-3.0"
        cp -r "$backup_dir/gtk-3.0" "$HOME/.config/"
    fi
    
    if [ -d "$backup_dir/gtk-4.0" ]; then
        rm -rf "$HOME/.config/gtk-4.0"
        cp -r "$backup_dir/gtk-4.0" "$HOME/.config/"
    fi
}

# Delete backup
delete_backup() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        log_error "Please specify a backup name to delete"
        list_backups
        return 1
    fi
    
    local backup_dir="$BACKUP_BASE_DIR/$backup_name"
    local backup_archive="$BACKUP_BASE_DIR/${backup_name}.tar.gz"
    local backup_checksum="$BACKUP_BASE_DIR/${backup_name}.tar.gz.sha256"
    
    if [ ! -d "$backup_dir" ] && [ ! -f "$backup_archive" ]; then
        log_error "Backup not found: $backup_name"
        return 1
    fi
    
    log_warning "This will permanently delete backup: $backup_name"
    read -p "Are you sure? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deletion cancelled"
        return 0
    fi
    
    # Delete backup files
    [ -d "$backup_dir" ] && rm -rf "$backup_dir"
    [ -f "$backup_archive" ] && rm -f "$backup_archive"
    [ -f "$backup_checksum" ] && rm -f "$backup_checksum"
    
    log_success "Backup deleted: $backup_name"
}

# Export backup to external location
export_backup() {
    local backup_name="$1"
    local export_path="$2"
    
    if [ -z "$backup_name" ] || [ -z "$export_path" ]; then
        log_error "Usage: export <backup_name> <destination_path>"
        return 1
    fi
    
    local backup_archive="$BACKUP_BASE_DIR/${backup_name}.tar.gz"
    local backup_checksum="$BACKUP_BASE_DIR/${backup_name}.tar.gz.sha256"
    
    if [ ! -f "$backup_archive" ]; then
        log_error "Backup archive not found: ${backup_name}.tar.gz"
        return 1
    fi
    
    log_step "Exporting backup to: $export_path"
    
    # Create export directory
    mkdir -p "$export_path"
    
    # Copy files
    cp "$backup_archive" "$export_path/"
    [ -f "$backup_checksum" ] && cp "$backup_checksum" "$export_path/"
    
    log_success "Backup exported successfully!"
    echo -e "${WHITE}Location: $export_path/${backup_name}.tar.gz${NC}"
}

# Import backup from external location
import_backup() {
    local import_path="$1"
    
    if [ -z "$import_path" ] || [ ! -f "$import_path" ]; then
        log_error "Please specify a valid backup archive path"
        return 1
    fi
    
    local archive_name=$(basename "$import_path")
    local backup_name=${archive_name%.tar.gz}
    
    log_step "Importing backup: $archive_name"
    
    init_backup_dir
    
    # Copy archive
    cp "$import_path" "$BACKUP_BASE_DIR/"
    
    # Copy checksum if available
    local checksum_path="${import_path}.sha256"
    if [ -f "$checksum_path" ]; then
        cp "$checksum_path" "$BACKUP_BASE_DIR/"
    fi
    
    log_success "Backup imported: $backup_name"
    log_info "You can now restore using: ./backup-restore.sh restore $backup_name"
}

# Show usage information
show_usage() {
    echo -e "${WHITE}KOOMPI Hyprland Backup and Restore Utility${NC}"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  backup [name]           Create a new backup (optional custom name)"
    echo "  restore <name>          Restore from backup"
    echo "  list                    List available backups"
    echo "  delete <name>           Delete a backup"
    echo "  export <name> <path>    Export backup to external location"
    echo "  import <archive_path>   Import backup from external archive"
    echo "  help                    Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 backup                        # Create backup with timestamp"
    echo "  $0 backup my_custom_backup       # Create named backup"
    echo "  $0 restore backup_20241201_1030  # Restore specific backup"
    echo "  $0 export my_backup /tmp/        # Export backup to /tmp/"
    echo ""
    echo -e "${GREEN}Backup Location:${NC} $BACKUP_BASE_DIR"
}

# Main function
main() {
    show_header
    
    init_backup_dir
    
    case "${1:-help}" in
        "backup")
            create_backup "$2"
            ;;
        "restore")
            if [ -z "$2" ]; then
                log_error "Please specify backup name to restore"
                list_backups
                exit 1
            fi
            restore_backup "$2"
            ;;
        "list")
            list_backups
            ;;
        "delete")
            if [ -z "$2" ]; then
                log_error "Please specify backup name to delete"
                list_backups
                exit 1
            fi
            delete_backup "$2"
            ;;
        "export")
            export_backup "$2" "$3"
            ;;
        "import")
            import_backup "$2"
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"