#!/bin/bash

# Source all task-related modules
source "$(dirname "$0")/tasks_constants.sh"
source "$(dirname "$0")/tasks_display.sh"
source "$(dirname "$0")/tasks_core.sh"
source "$(dirname "$0")/tasks_management.sh"
source "$(dirname "$0")/tasks_templates.sh"

display_tasks_menu() {
    local -r MENU_HEIGHT="40%"
    
    while true; do
        # Clear screen and show tasks
        clear
        
        # Display tasks by location
        print_tasks "$ACTIVE_DIR"
        
        # Show menu with status indications
        echo -e "\n${GREEN}Tasks Menu:${NC}\n"
        
        local menu_items
        if has_tasks "$ACTIVE_DIR"; then
            menu_items="➕ New Task
📅 New Future Task
▶️ Start Work
✅ Complete Task
📝 Add Subtask
📦 Move Task
🗑️ Delete Task
🔍 Search
✏️ Edit Template
📄 Create Template
🔙 Back to Main Menu"
        else
            menu_items="➕ New Task
📅 New Future Task
▶️ Start Work ${RED}(No active tasks)${NC}
✅ Complete Task ${RED}(No active tasks)${NC}
📝 Add Subtask ${RED}(No active tasks)${NC}
📦 Move Task ${RED}(No active tasks)${NC}
🗑️ Delete Task ${RED}(No active tasks)${NC}
🔍 Search
✏️ Edit Template
📄 Create Template
🔙 Back to Main Menu"
        fi
        
        local choice
        choice=$(echo -e "$menu_items" | fzf --height "$MENU_HEIGHT" \
                                           --layout=reverse \
                                           --prompt="Select action: " \
                                           --ansi)
        
        clear  # Clear screen before executing action
        
        case "$choice" in
            "➕ New Task")
                create_task "$ACTIVE_DIR"
                ;;
            "📅 New Future Task")
                create_task "$FUTURE_DIR"
                ;;
            "▶️ Start Work"*)
                if has_tasks "$ACTIVE_DIR"; then
                    start_work
                else
                    show_error "No active tasks available."
                    read -p "Press Enter to continue..."
                fi
                ;;
            "✅ Complete Task"*)
                if has_tasks "$ACTIVE_DIR"; then
                    complete_task
                else
                    show_error "No active tasks available."
                    read -p "Press Enter to continue..."
                fi
                ;;
            "📝 Add Subtask"*)
                if has_tasks "$ACTIVE_DIR"; then
                    add_subtask
                else
                    show_error "No active tasks available."
                    read -p "Press Enter to continue..."
                fi
                ;;
            "📦 Move Task"*)
                if has_tasks "$ACTIVE_DIR"; then
                    move_task
                else
                    show_error "No active tasks available."
                    read -p "Press Enter to continue..."
                fi
                ;;
            "🗑️ Delete Task"*)
                if has_tasks "$ACTIVE_DIR"; then
                    delete_task
                else
                    show_error "No active tasks available."
                    read -p "Press Enter to continue..."
                fi
                ;;
            "🔍 Search")
                search_tasks
                ;;
            "✏️ Edit Template")
                edit_template
                ;;
            "📄 Create Template")
                create_template
                ;;
            "🔙 Back to Main Menu")
                return 0
                ;;
            *)
                if [ -n "$choice" ]; then
                    log "WARNING" "Invalid option selected"
                    show_error "Invalid option selected"
                    read -p "Press Enter to continue..."
                fi
                ;;
        esac
    done
}

# Start the tasks menu
display_tasks_menu
