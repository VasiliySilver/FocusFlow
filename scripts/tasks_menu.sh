#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Initialize script
init_script

# Constants
TASKS_DIR="$BASE_DIR/data/tasks"
TEMPLATES_DIR="$BASE_DIR/templates/tasks"

create_task() {
    print_title "Create New Task"
    
    # Select template
    local template=$(select_template "tasks")
    if [ -z "$template" ]; then
        template="$TEMPLATES_DIR/default_task_template.txt"
    fi
    
    # Get task details
    read -p "Enter task title: " title
    if [ -z "$title" ]; then
        log "ERROR" "Title cannot be empty"
        return 1
    fi
    
    # Get priority
    local priority
    while true; do
        read -p "Priority (H/M/L): " priority
        case $priority in
            [Hh]) priority="High"; break ;;
            [Mm]) priority="Medium"; break ;;
            [Ll]) priority="Low"; break ;;
            *) echo "Please enter H, M, or L" ;;
        esac
    done
    
    # Get due date
    local due_date
    while true; do
        read -p "Due date (YYYY-MM-DD): " due_date
        if validate_date "$due_date"; then
            break
        else
            echo "Please enter a valid date in YYYY-MM-DD format"
        fi
    done
    
    # Create safe filename
    local filename="$(get_safe_filename "$title")"
    local filepath="$TASKS_DIR/${filename}_${due_date}.txt"
    
    # Create task from template
    if create_from_template "$template" "$filepath"; then
        # Update task details
        sed -i "s/Priority: .*/Priority: $priority/" "$filepath"
        sed -i "s/Due Date: .*/Due Date: $due_date/" "$filepath"
        sed -i "s/Status: .*/Status: Todo/" "$filepath"
        
        # Open task in editor
        ${EDITOR:-nano} "$filepath"
        log "INFO" "Task created: $filepath"
    fi
}

edit_task() {
    print_title "Edit Task"
    
    local task=$(select_file "$TASKS_DIR" "Select task to edit")
    if [ -n "$task" ]; then
        backup_file "$task"
        ${EDITOR:-nano} "$task"
        log "INFO" "Task edited: $task"
    fi
}

view_task() {
    print_title "View Task"
    
    local task=$(select_file "$TASKS_DIR" "Select task to view")
    if [ -n "$task" ]; then
        less "$task"
    fi
}

update_task_status() {
    print_title "Update Task Status"
    
    local task=$(select_file "$TASKS_DIR" "Select task to update")
    if [ -n "$task" ]; then
        echo "Current status:"
        grep "Status:" "$task"
        echo
        
        local status
        select status in "Todo" "In Progress" "Done"; do
            if [ -n "$status" ]; then
                backup_file "$task"
                sed -i "s/Status: .*/Status: $status/" "$task"
                log "INFO" "Updated task status: $task"
                break
            fi
        done
    fi
}

start_pomodoro() {
    print_title "Start Pomodoro Timer"
    
    local task=$(select_file "$TASKS_DIR" "Select task for Pomodoro")
    if [ -n "$task" ]; then
        # Get current pomodoro count
        local count=$(grep "Pomodoros:" "$task" | cut -d' ' -f2)
        
        # Start timer
        bash "$BASE_DIR/scripts/pomodoro_timer.sh" "$task"
        
        # Update pomodoro count if timer completed successfully
        if [ $? -eq 0 ]; then
            count=$((count + 1))
            backup_file "$task"
            sed -i "s/Pomodoros: .*/Pomodoros: $count/" "$task"
            log "INFO" "Updated Pomodoro count for task: $task"
        fi
    fi
}

delete_task() {
    print_title "Delete Task"
    
    local task=$(select_file "$TASKS_DIR" "Select task to delete")
    if [ -n "$task" ]; then
        read -p "Are you sure you want to delete this task? (y/N) " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            backup_file "$task"
            rm "$task"
            log "INFO" "Task deleted: $task"
        fi
    fi
}

list_tasks() {
    print_title "All Tasks"
    
    if [ -d "$TASKS_DIR" ] && [ "$(ls -A "$TASKS_DIR")" ]; then
        echo "Status  Due Date   Priority  Title"
        echo "--------------------------------"
        for task in "$TASKS_DIR"/*.txt; do
            if [ -f "$task" ]; then
                local status=$(grep "Status:" "$task" | cut -d' ' -f2-)
                local due_date=$(grep "Due Date:" "$task" | cut -d' ' -f3-)
                local priority=$(grep "Priority:" "$task" | cut -d' ' -f2-)
                local title=$(grep "Title:" "$task" | cut -d' ' -f2-)
                printf "%-8s %-10s %-9s %s\n" "$status" "$due_date" "$priority" "$title"
            fi
        done
    else
        echo "No tasks found."
    fi
    
    read -p "Press Enter to continue..."
}

display_tasks_menu() {
    while true; do
        clear
        print_title "Tasks Menu"
        
        echo "1. Create Task"
        echo "2. Edit Task"
        echo "3. View Task"
        echo "4. Update Task Status"
        echo "5. Start Pomodoro Timer"
        echo "6. Delete Task"
        echo "7. List All Tasks"
        echo "0. Back to Main Menu"
        echo
        
        read -p "Select an option: " choice
        
        case $choice in
            1)
                create_task
                ;;
            2)
                edit_task
                ;;
            3)
                view_task
                ;;
            4)
                update_task_status
                ;;
            5)
                start_pomodoro
                ;;
            6)
                delete_task
                ;;
            7)
                list_tasks
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

# Start the tasks menu
display_tasks_menu
