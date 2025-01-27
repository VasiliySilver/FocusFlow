#!/bin/bash

# Source utilities
source "$(dirname "$0")/scripts/utils.sh"

# Initialize script
init_script

create_backup() {
    print_title "Creating Backup"
    
    # Create backup directory if it doesn't exist
    local backup_dir="$BASE_DIR/backups"
    mkdir -p "$backup_dir"
    
    # Create backup filename with timestamp
    local backup_file="$backup_dir/focusflow_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # Create backup
    tar -czf "$backup_file" \
        -C "$BASE_DIR" \
        --exclude="backups" \
        --exclude="*.log" \
        data templates config
    
    if [ $? -eq 0 ]; then
        log "INFO" "Backup created successfully: $backup_file"
        echo "Backup file: $backup_file"
    else
        log "ERROR" "Failed to create backup"
        return 1
    fi
}

restore_backup() {
    print_title "Restore from Backup"
    
    local backup_dir="$BASE_DIR/backups"
    if [ ! -d "$backup_dir" ] || [ -z "$(ls -A "$backup_dir")" ]; then
        log "ERROR" "No backups found"
        return 1
    fi
    
    # List available backups
    echo "Available backups:"
    ls -1 "$backup_dir" | grep "^focusflow_backup_" | nl
    
    read -p "Select backup number to restore (or 0 to cancel): " choice
    
    if [ "$choice" = "0" ]; then
        return 0
    fi
    
    local backup_file=$(ls -1 "$backup_dir" | grep "^focusflow_backup_" | sed -n "${choice}p")
    if [ -n "$backup_file" ]; then
        backup_file="$backup_dir/$backup_file"
        
        read -p "Are you sure you want to restore this backup? Current data will be overwritten (y/N) " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            # Create temporary restore directory
            local temp_dir=$(mktemp -d)
            
            # Extract backup to temp directory
            tar -xzf "$backup_file" -C "$temp_dir"
            
            # Move current data to temporary backup
            local temp_backup="$backup_dir/pre_restore_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$temp_backup"
            mv "$BASE_DIR/data" "$temp_backup/" 2>/dev/null
            mv "$BASE_DIR/templates" "$temp_backup/" 2>/dev/null
            mv "$BASE_DIR/config" "$temp_backup/" 2>/dev/null
            
            # Move restored data to main directory
            mv "$temp_dir/data" "$BASE_DIR/"
            mv "$temp_dir/templates" "$BASE_DIR/"
            mv "$temp_dir/config" "$BASE_DIR/"
            
            # Cleanup
            rm -rf "$temp_dir"
            
            log "INFO" "Backup restored successfully"
            echo "Previous data backed up to: $temp_backup"
        fi
    else
        log "ERROR" "Invalid backup selection"
        return 1
    fi
}

# Display backup menu
while true; do
    clear
    print_title "Backup Menu"
    
    echo "1. Create Backup"
    echo "2. Restore from Backup"
    echo "0. Back to Main Menu"
    echo
    
    read -p "Select an option: " choice
    
    case $choice in
        1)
            create_backup
            ;;
        2)
            restore_backup
            ;;
        0)
            exit 0
            ;;
        *)
            log "WARNING" "Invalid option selected"
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done
