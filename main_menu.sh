#!/bin/bash

# Source utilities
source "$(dirname "$0")/scripts/utils.sh"

# Initialize script
init_script

display_main_menu() {
    while true; do
        clear
        print_title "FocusFlow - Main Menu"
        
        echo "1. 📒 Notes"
        echo "2. ✅ Tasks"
        echo "3. 📚 Knowledge Base"
        echo "4. 🔍 Search"
        echo "5. 💾 Backup Data"
        echo "6. 📝 Create Template"
        echo "7. ✏️ Edit Template"
        echo "0. ❌ Exit"
        echo
        
        local choice=$(echo "1. 📒 Notes
2. ✅ Tasks
3. 📚 Knowledge Base
4. 🔍 Search
5. 💾 Backup Data
6. 📝 Create Template
7. ✏️ Edit Template
0. ❌ Exit" | fzf --prompt="Select an option> " | cut -d'.' -f1)
        
        case $choice in
            1)
                bash "$BASE_DIR/scripts/notes_menu.sh"
                ;;
            2)
                bash "$BASE_DIR/scripts/tasks_menu.sh"
                ;;
            3)
                bash "$BASE_DIR/scripts/kb_menu.sh"
                ;;
            4)
                bash "$BASE_DIR/scripts/search.sh"
                ;;
            5)
                bash "$BASE_DIR/backup.sh"
                ;;
            6)
                local type=$(echo "notes
tasks
knowledge_base" | fzf --prompt="Select template type> ")
                if [ -n "$type" ]; then
                    create_template "$type"
                fi
                ;;
            7)
                local type=$(echo "notes
tasks
knowledge_base" | fzf --prompt="Select template type> ")
                if [ -n "$type" ]; then
                    edit_template "$type"
                fi
                ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                log "WARNING" "Invalid option selected"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Start the main menu
display_main_menu
