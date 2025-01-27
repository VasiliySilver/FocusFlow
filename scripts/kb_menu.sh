#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Initialize script
init_script

# Constants
KB_DIR="$BASE_DIR/data/knowledge_base"
TEMPLATES_DIR="$BASE_DIR/templates/knowledge_base"

create_kb_entry() {
    print_title "Create New Knowledge Base Entry"
    
    # Select template
    local template=$(select_template "knowledge_base")
    if [ -z "$template" ]; then
        template="$TEMPLATES_DIR/default_kb_template.txt"
    fi
    
    # Get entry details
    read -p "Enter entry title: " title
    if [ -z "$title" ]; then
        log "ERROR" "Title cannot be empty"
        return 1
    fi
    
    read -p "Enter category: " category
    read -p "Enter tags (comma-separated): " tags
    
    # Create safe filename
    local filename="$(get_safe_filename "$title")"
    local filepath="$KB_DIR/${category:+${category}_}${filename}.txt"
    
    # Create entry from template
    if create_from_template "$template" "$filepath"; then
        # Update entry details
        sed -i "s/Category: .*/Category: $category/" "$filepath"
        sed -i "s/Tags: .*/Tags: $tags/" "$filepath"
        
        # Open entry in editor
        ${EDITOR:-nano} "$filepath"
        log "INFO" "Knowledge base entry created: $filepath"
    fi
}

edit_kb_entry() {
    print_title "Edit Knowledge Base Entry"
    
    local entry=$(select_file "$KB_DIR" "Select entry to edit")
    if [ -n "$entry" ]; then
        backup_file "$entry"
        ${EDITOR:-nano} "$entry"
        # Update modification date
        sed -i "s/Last Modified: .*/Last Modified: $(date +%Y-%m-%d)/" "$entry"
        log "INFO" "Knowledge base entry edited: $entry"
    fi
}

view_kb_entry() {
    print_title "View Knowledge Base Entry"
    
    local entry=$(select_file "$KB_DIR" "Select entry to view")
    if [ -n "$entry" ]; then
        less "$entry"
    fi
}

list_by_category() {
    print_title "List Entries by Category"
    
    # Get unique categories
    local categories=$(find "$KB_DIR" -type f -name "*.txt" -exec grep "Category:" {} \; | cut -d' ' -f2- | sort -u)
    
    if [ -z "$categories" ]; then
        echo "No categories found."
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Available categories:"
    echo "$categories" | nl
    echo
    
    read -p "Select category number (or Enter to see all): " choice
    echo
    
    if [ -n "$choice" ]; then
        local selected_category=$(echo "$categories" | sed -n "${choice}p")
        echo "Entries in category: $selected_category"
        echo "----------------------------------------"
        find "$KB_DIR" -type f -name "*.txt" -exec grep -l "Category: $selected_category" {} \; | while read -r file; do
            echo "- $(grep "Title:" "$file" | cut -d' ' -f2-)"
        done
    else
        echo "All entries by category:"
        echo "----------------------------------------"
        echo "$categories" | while read -r category; do
            echo
            echo "Category: $category"
            echo "----------------"
            find "$KB_DIR" -type f -name "*.txt" -exec grep -l "Category: $category" {} \; | while read -r file; do
                echo "- $(grep "Title:" "$file" | cut -d' ' -f2-)"
            done
        done
    fi
    
    echo
    read -p "Press Enter to continue..."
}

delete_kb_entry() {
    print_title "Delete Knowledge Base Entry"
    
    local entry=$(select_file "$KB_DIR" "Select entry to delete")
    if [ -n "$entry" ]; then
        read -p "Are you sure you want to delete this entry? (y/N) " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            backup_file "$entry"
            rm "$entry"
            log "INFO" "Knowledge base entry deleted: $entry"
        fi
    fi
}

display_kb_menu() {
    while true; do
        clear
        print_title "Knowledge Base Menu"
        
        echo "1. Create Entry"
        echo "2. Edit Entry"
        echo "3. View Entry"
        echo "4. List by Category"
        echo "5. Delete Entry"
        echo "0. Back to Main Menu"
        echo
        
        read -p "Select an option: " choice
        
        case $choice in
            1)
                create_kb_entry
                ;;
            2)
                edit_kb_entry
                ;;
            3)
                view_kb_entry
                ;;
            4)
                list_by_category
                ;;
            5)
                delete_kb_entry
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

# Start the knowledge base menu
display_kb_menu
