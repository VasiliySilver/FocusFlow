#!/bin/bash
# uninstall.sh

remove_focusflow() {
    echo "Uninstalling FocusFlow..."
    
    # Ask about data preservation
    read -p "Do you want to keep your data? (Y/n) " keep_data
    
    if [[ $keep_data =~ ^[Nn]$ ]]; then
        echo "Creating final backup before removal..."
        "$INSTALL_DIR/backup.sh"
        
        echo "Removing FocusFlow data..."
        rm -rf "$INSTALL_DIR"
    else
        # Move data to backup location
        backup_dir="$HOME/focusflow_data_backup_$(date +%Y%m%d_%H%M%S)"
        echo "Moving data to: $backup_dir"
        mv "$INSTALL_DIR/data" "$backup_dir"
        mv "$INSTALL_DIR/templates" "$backup_dir"
        mv "$INSTALL_DIR/config" "$backup_dir"
        
        # Remove installation
        rm -rf "$INSTALL_DIR"
        rm -rf "$backup_dir/data"
        rm -rf "$backup_dir/templates"
        rm -rf "$backup_dir/config"
    fi
    
    # Remove launcher
    rm -f "$BIN_DIR/focusflow"
    
    # Remove PATH entry
    sed -i '/# FocusFlow PATH/d' "$HOME/.bashrc"
    sed -i '/export PATH=.*focusflow/d' "$HOME/.bashrc"
    
    echo "FocusFlow uninstalled successfully!"
    if [[ ! $keep_data =~ ^[Nn]$ ]]; then
        echo "Your data has been preserved in: $backup_dir"
    fi
}

# Confirm uninstallation
read -p "Are you sure you want to uninstall FocusFlow? (y/N) " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    remove_focusflow
fi
