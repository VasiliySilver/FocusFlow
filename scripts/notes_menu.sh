#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Initialize script
init_script

# Constants
NOTES_DIR="$BASE_DIR/data/notes"
TEMPLATES_DIR="$BASE_DIR/templates/notes"

create_note() {
    print_title "Create New Note"
    
    # Select template
    local template=$(select_template "notes")
    if [ -z "$template" ]; then
        template="$TEMPLATES_DIR/default_note_template.txt"
    fi
    
    # Get note title
    read -p "Enter note title: " title
    if [ -z "$title" ]; then
        log "ERROR" "Title cannot be empty"
        return 1
    fi
    
    # Create safe filename
    local filename="$(get_safe_filename "$title")"
    local filepath="$NOTES_DIR/${filename}_$(date +%Y%m%d).txt"
    
    # Create note from template
    if create_from_template "$template" "$filepath"; then
        # Open note in default editor
        ${EDITOR:-nano} "$filepath"
        log "INFO" "Note created: $filepath"
    fi
}

edit_note() {
    print_title "Edit Note"
    
    local note=$(select_file "$NOTES_DIR" "Select note to edit")
    if [ -n "$note" ]; then
        backup_file "$note"
        ${EDITOR:-nano} "$note"
        log "INFO" "Note edited: $note"
    fi
}

view_note() {
    print_title "View Note"
    
    local note=$(select_file "$NOTES_DIR" "Select note to view")
    if [ -n "$note" ]; then
        less "$note"
    fi
}

delete_note() {
    print_title "Delete Note"
    
    local note=$(select_file "$NOTES_DIR" "Select note to delete")
    if [ -n "$note" ]; then
        read -p "Are you sure you want to delete this note? (y/N) " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            backup_file "$note"
            rm "$note"
            log "INFO" "Note deleted: $note"
        fi
    fi
}

list_notes() {
    print_title "All Notes"
    
    if [ -d "$NOTES_DIR" ] && [ "$(ls -A "$NOTES_DIR")" ]; then
        ls -lt "$NOTES_DIR" | grep "\.txt$" | while read -r line; do
            echo "$line" | awk '{print $6, $7, $8, $9}'
        done
    else
        echo "No notes found."
    fi
    
    read -p "Press Enter to continue..."
}

display_notes_menu() {
    while true; do
        clear
        print_title "Notes Menu"
        
        echo "1. Create Note"
        echo "2. Edit Note"
        echo "3. View Note"
        echo "4. Delete Note"
        echo "5. List All Notes"
        echo "0. Back to Main Menu"
        echo
        
        read -p "Select an option: " choice
        
        case $choice in
            1)
                create_note
                ;;
            2)
                edit_note
                ;;
            3)
                view_note
                ;;
            4)
                delete_note
                ;;
            5)
                list_notes
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

# Start the notes menu
display_notes_menu
