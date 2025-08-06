#!/bin/bash

# Water Pump Control System - Backup and Restore Script
# Usage: ./backup-restore.sh [backup|restore] [backup_name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="/data/pump-backups"
NODERED_DIR="/data/home/nodered/.node-red"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

create_backup() {
    local backup_name="${1:-$(date +%Y%m%d_%H%M%S)}"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log_info "Creating backup: $backup_name"
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Backup Node-RED flows
    if [ -f "$NODERED_DIR/flows.json" ]; then
        cp "$NODERED_DIR/flows.json" "$backup_path/flows.json"
        log_info "Node-RED flows backed up"
    else
        log_warn "Node-RED flows not found"
    fi
    
    # Backup Node-RED settings
    if [ -f "$NODERED_DIR/settings.js" ]; then
        cp "$NODERED_DIR/settings.js" "$backup_path/settings.js"
        log_info "Node-RED settings backed up"
    fi
    
    # Backup project configuration
    cp -r "$PROJECT_DIR/config" "$backup_path/"
    cp -r "$PROJECT_DIR/flows" "$backup_path/"
    
    # Create backup info
    cat > "$backup_path/backup_info.txt" << EOF
Backup created: $(date)
System: Water Pump Control System
Venus OS version: $(cat /opt/victronenergy/version 2>/dev/null || echo "Unknown")
Node-RED version: $(node-red --version 2>/dev/null || echo "Unknown")
Backup includes:
- Node-RED flows
- Node-RED settings
- Project configuration
- Flow definitions
EOF
    
    log_info "Backup completed: $backup_path"
}

restore_backup() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        log_error "Backup name required for restore"
        list_backups
        exit 1
    fi
    
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        log_error "Backup not found: $backup_path"
        list_backups
        exit 1
    fi
    
    log_info "Restoring backup: $backup_name"
    
    # Stop Node-RED service
    log_info "Stopping Node-RED service..."
    systemctl stop nodered
    
    # Restore Node-RED flows
    if [ -f "$backup_path/flows.json" ]; then
        cp "$backup_path/flows.json" "$NODERED_DIR/flows.json"
        log_info "Node-RED flows restored"
    fi
    
    # Restore Node-RED settings
    if [ -f "$backup_path/settings.js" ]; then
        cp "$backup_path/settings.js" "$NODERED_DIR/settings.js"
        log_info "Node-RED settings restored"
    fi
    
    # Set proper ownership
    chown -R nodered:nodered "$NODERED_DIR"
    
    # Start Node-RED service
    log_info "Starting Node-RED service..."
    systemctl start nodered
    
    log_info "Restore completed from: $backup_path"
    log_info "Please verify system functionality"
}

list_backups() {
    log_info "Available backups:"
    if [ -d "$BACKUP_DIR" ]; then
        ls -la "$BACKUP_DIR" | grep "^d" | awk '{print $9}' | grep -v "^\.$" | grep -v "^\.\.$"
    else
        log_warn "No backup directory found"
    fi
}

install_flow() {
    log_info "Installing water pump control flow..."
    
    # Stop Node-RED service
    systemctl stop nodered
    
    # Ensure Node-RED directory exists
    mkdir -p "$NODERED_DIR"
    
    # Copy flow to Node-RED
    cp "$PROJECT_DIR/flows/water-pump-control.json" "$NODERED_DIR/flows_water_pump.json"
    
    # Set proper ownership
    chown -R nodered:nodered "$NODERED_DIR"
    
    # Start Node-RED service
    systemctl start nodered
    
    log_info "Flow installed. Import manually in Node-RED interface."
    log_info "Access Node-RED at: http://$(hostname -I | awk '{print $1}'):1880"
}

show_usage() {
    echo "Water Pump Control System - Backup and Restore Script"
    echo ""
    echo "Usage:"
    echo "  $0 backup [name]           - Create backup (optional name)"
    echo "  $0 restore <name>          - Restore from backup"
    echo "  $0 list                    - List available backups"
    echo "  $0 install                 - Install flow to Node-RED"
    echo "  $0 help                    - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 backup                  - Create backup with timestamp name"
    echo "  $0 backup pre_update       - Create backup named 'pre_update'"
    echo "  $0 restore 20231201_120000 - Restore specific backup"
    echo "  $0 list                    - Show available backups"
}

# Main script logic
case "$1" in
    backup)
        create_backup "$2"
        ;;
    restore)
        restore_backup "$2"
        ;;
    list)
        list_backups
        ;;
    install)
        install_flow
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        log_error "Invalid command: $1"
        show_usage
        exit 1
        ;;
esac