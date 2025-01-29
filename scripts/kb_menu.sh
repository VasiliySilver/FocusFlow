#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Initialize script
init_script

# Constants
KB_DIR="$BASE_DIR/data/knowledge_base"
TEMPLATES_DIR="$BASE_DIR/templates/knowledge_base"
ATTACHMENTS_DIR="$BASE_DIR/data/attachments"
EDITOR="lvim"  # Set default editor to lvim

# Add this to the top of the script with other dependencies
check_dependencies() {
    local deps=("zenity")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "ERROR" "$dep is required but not installed. Installing..."
            sudo apt-get update && sudo apt-get install -y "$dep"
        fi
    done
}

# Modified attach_files function with GUI file picker
attach_files() {
    local entry_dir="$1"
    local files_attached=false
    
    while true; do
        read -p "Would you like to attach a file? (y/n): " attach
        case $attach in
            [Yy]*)
                # Use zenity for file selection with a GUI dialog
                local file_to_attach=$(zenity --file-selection --title="Select a file to attach" 2>/dev/null)
                
                if [ $? -eq 0 ] && [ -n "$file_to_attach" ] && [ -f "$file_to_attach" ]; then
                    # Create attachments directory if it doesn't exist
                    mkdir -p "$entry_dir/attachments"
                    
                    # Copy file to attachments directory
                    local filename=$(basename "$file_to_attach")
                    local timestamp=$(date +%Y%m%d_%H%M%S)
                    local safe_filename="${timestamp}_${filename}"
                    
                    cp "$file_to_attach" "$entry_dir/attachments/$safe_filename"
                    
                    # Add reference to the markdown file
                    echo -e "\n## Attachments\n- [$filename](attachments/$safe_filename)" >> "$entry_dir.md"
                    
                    log "INFO" "File attached: $filename"
                    files_attached=true
                    
                    # Show success message
                    zenity --info \
                        --title="Success" \
                        --text="File '$filename' has been attached successfully." \
                        --width=300 2>/dev/null
                else
                    zenity --error \
                        --title="Error" \
                        --text="No file was selected or the file is invalid." \
                        --width=300 2>/dev/null
                fi
                ;;
            [Nn]*)
                break
                ;;
            *)
                log "WARNING" "Please answer y or n"
                ;;
        esac
    done
    
    return $files_attached
}

create_kb_entry() {
    print_title "Create New Knowledge Base Entry"
    
    # Get entry details
    read -p "Enter entry title: " title
    if [ -z "$title" ]; then
        log "ERROR" "Title cannot be empty"
        return 1
    fi
    
    read -p "Enter category: " category
    read -p "Enter tags (comma-separated): " tags
    
    # Create timestamp and safe filename
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local safe_title="$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')"
    local filename="${timestamp}_${safe_title}"
    local filepath="$KB_DIR/${category:+${category}/}$filename"
    
    # Create category directory if it doesn't exist
    mkdir -p "$(dirname "$filepath")"
    
    # Create entry
    cat > "$filepath.md" << EOF
---
title: $title
category: $category
tags: $tags
created: $(date +%Y-%m-%d\ %H:%M:%S)
modified: $(date +%Y-%m-%d\ %H:%M:%S)
---

# $title

EOF
    
    # Open in lvim
    $EDITOR "$filepath.md"
    
    # Handle attachments
    attach_files "$filepath"
    
    log "INFO" "Knowledge base entry created: $filepath.md"
}

# Modify edit_kb_entry to handle attachments
edit_kb_entry() {
    print_title "Edit Knowledge Base Entry"
    
    # Use fzf with preview for file selection
    local entry=$(find "$KB_DIR" -type f -name "*.md" | \
        fzf --preview 'head -n 10 {}' \
            --preview-window=right:50% \
            --prompt="Select entry to edit> ")
    
    if [ -n "$entry" ]; then
        backup_file "$entry"
        $EDITOR "$entry"
        
        # Handle attachments
        local entry_dir="${entry%.md}"
        attach_files "$entry_dir"
        
        sed -i "s/modified: .*/modified: $(date +%Y-%m-%d\ %H:%M:%S)/" "$entry"
        log "INFO" "Knowledge base entry edited: $entry"
    fi
}

# Add function to manage attachments
manage_attachments() {
    print_title "Manage Attachments"
    
    local entry=$(find "$KB_DIR" -type f -name "*.md" | \
        fzf --preview 'head -n 10 {}' \
            --preview-window=right:50% \
            --prompt="Select entry to manage attachments> ")
    
    if [ -n "$entry" ]; then
        local entry_dir="${entry%.md}"
        local attachments_dir="$entry_dir/attachments"
        
        if [ ! -d "$attachments_dir" ]; then
            log "INFO" "No attachments found for this entry"
            read -p "Press Enter to continue..."
            return
        fi
        
        while true; do
            clear
            print_title "Attachment Management"
            echo "1. View attachments"
            echo "2. Add new attachment"
            echo "3. Remove attachment"
            echo "0. Back"
            
            read -p "Select option: " option
            
            case $option in
                1)
                    local attachment=$(find "$attachments_dir" -type f | \
                        fzf --preview 'file {}' \
                            --preview-window=right:50% \
                            --prompt="Select attachment to view> ")
                    if [ -n "$attachment" ]; then
                        xdg-open "$attachment" 2>/dev/null || open "$attachment" 2>/dev/null
                    fi
                    ;;
                2)
                    attach_files "$entry_dir"
                    ;;
                3)
                    local attachment=$(find "$attachments_dir" -type f | \
                        fzf --preview 'file {}' \
                            --preview-window=right:50% \
                            --prompt="Select attachment to remove> ")
                    if [ -n "$attachment" ]; then
                        rm "$attachment"
                        log "INFO" "Attachment removed: $(basename "$attachment")"
                    fi
                    ;;
                0)
                    break
                    ;;
                *)
                    log "WARNING" "Invalid option"
                    ;;
            esac
        done
    fi
}

# Modify display_kb_menu to include attachment management
display_kb_menu() {
    while true; do
        clear
        print_title "Knowledge Base Menu"
        
        local choice=$(echo "1. 🆕 Create Entry
2. 📝 Quick Note (Today's Journal)
3. 🔍 Search Entries
4. 📅 Recent Entries
5. 📂 Browse Categories
6. 📎 Manage Attachments
0. 🔙 Exit" | fzf --prompt="Select an option> " --preview 'echo "Select an option to continue..."' | cut -d'.' -f1)
        
        case $choice in
            1)
                create_kb_entry
                ;;
            2)
                create_daily_note
                ;;
            3)
                search_kb
                ;;
            4)
                show_recent
                ;;
            5)
                list_by_category
                ;;
            6)
                manage_attachments
                ;;
            0)
                return 0
                ;;
            *)
                log "WARNING" "Invalid option selected"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Rest of the script remains unchanged...

# Ensure required directories exist
mkdir -p "$KB_DIR" "$TEMPLATES_DIR" "$ATTACHMENTS_DIR"

# Start the knowledge base menu
display_kb_menu