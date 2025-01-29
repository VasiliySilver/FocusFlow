#!/bin/bash

source "$(dirname "$0")/tasks_constants.sh"

# Function to check if there are any tasks in a directory
has_tasks() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        return 1
    fi
    if ls -1 "$dir"/*.md 2>/dev/null | grep -q .; then
        return 0
    else
        return 1
    fi
}

show_error() {
    echo -e "\033[31mERROR: $1\033[0m"
}

create_task() {
    local target_dir="$1"
    clear
    print_title "Create New Task"
    read -p "Enter task title: " title
    while [ -z "$title" ]; do
        echo "Title cannot be empty"
        read -p "Enter task title: " title
    done
    
    clear
    print_title "Create New Task"
    echo "Title: $title"
    echo "Select template:"
    
    # Select template
    local template=$(find "$TEMPLATES_DIR" -name "*.md" -printf "%f\n" | fzf --prompt="Select template> ")
    if [ -z "$template" ]; then
        show_error "No template selected!"
        return 1
    fi
    
    clear
    print_title "Create New Task"
    echo "Title: $title"
    echo "Template: $template"
    
    local priority
    while [ -z "$priority" ]; do
        priority=$(echo "High
Medium
Low" | fzf --prompt="Select priority> ")
    done
    
    clear
    print_title "Create New Task"
    echo "Title: $title"
    echo "Template: $template"
    echo "Priority: $priority"

    local due_date=""
    read -p "Enter due date (YYYY-MM-DD) or leave empty if not needed: " due_date

    if [ -n "$due_date" ]; then
        while ! validate_date "$due_date"; do
            echo "Please enter a valid date in YYYY-MM-DD format or leave empty"
            read -p "Enter due date (YYYY-MM-DD): " due_date
            if [ -z "$due_date" ]; then
                break
            fi
        done
    fi

    local filename="$(get_safe_filename "$title")"
    local created_at=$(date +%Y-%m-%d_%H-%M-%S)
    local status="Todo"
    local filepath="$target_dir/${filename}__${status}__${due_date:-NoDueDate}__${priority}__${created_at}__none.md"
    
    # Check if file already exists
    if [ -f "$filepath" ]; then
        show_error "Task with this name already exists!"
        return 1
    fi
    
    # Copy template and replace placeholders
    sed "s/\$(title)/$title/g; \
         s/\$(priority)/$priority/g; \
         s/\$(due_date)/${due_date:-No due date}/g; \
         s/\$(created)/$(date +%Y-%m-%d\ %H:%M:%S)/g" \
        "$TEMPLATES_DIR/$template" > "$filepath"

    clear
    print_title "Create New Task"
    echo "Title: $title"
    echo "Priority: $priority"
    echo "Due Date: ${due_date:-No due date}"
    echo -e "\nEnter task description (press Ctrl+X then Y to save):"
    ${EDITOR:-nano} "$filepath"
    log "INFO" "Task created: $filepath"
}

complete_task() {
    local task="$1"
    if [ -z "$task" ]; then
        task=$(select_file "$ACTIVE_DIR" "Select task to complete")
    fi
    
    if [ -n "$task" ]; then
        backup_file "$task"
        local updated_at=$(date +%Y-%m-%d_%H-%M-%S)
        local new_name=$(echo "$task" | sed "s/__Todo__/__Done__/; s/__none\.md$/__${updated_at}.md/")
        mv "$task" "$new_name"
        local completed_dir="$BASE_TASKS_DIR/completed"
        mkdir -p "$completed_dir"
        mv "$new_name" "$completed_dir/"
        log "INFO" "Task completed and moved to completed folder"
    fi
}

add_subtask() {
    print_title "Add Subtask"
    
    local parent_task=$(select_file "$ACTIVE_DIR" "Select parent task")
    if [ -n "$parent_task" ]; then
        read -p "Enter subtask description: " description
        if [ -n "$description" ]; then
            backup_file "$parent_task"
            echo "- [ ] $description" >> "$parent_task"
            
            # Update the last modified date in filename
            local updated_at=$(date +%Y-%m-%d_%H-%M-%S)
            local new_name=$(echo "$parent_task" | sed "s/__none\.md$/__${updated_at}.md/")
            mv "$parent_task" "$new_name"
            
            log "INFO" "Subtask added to: $new_name"
        fi
    fi
}

start_work() {
    print_title "Start Work on Task"
    
    local task=$(select_file "$ACTIVE_DIR" "Select task to work on")
    if [ -n "$task" ]; then
        # Start pomodoro timer
        bash "$BASE_DIR/scripts/pomodoro_timer.sh" "$task"
        
        # If timer completed successfully
        if [ $? -eq 0 ]; then
            # Update pomodoro count
            local count=$(grep "Pomodoros:" "$task" | cut -d' ' -f2)
            count=$((count + 1))
            backup_file "$task"
            sed -i "s/Pomodoros: .*/Pomodoros: $count/" "$task"
            
            # Update the last modified date in filename
            local updated_at=$(date +%Y-%m-%d_%H-%M-%S)
            local new_name=$(echo "$task" | sed "s/__none\.md$/__${updated_at}.md/")
            mv "$task" "$new_name"
            task="$new_name"
            
            # Ask if task is complete
            read -p "Did you complete the task? (y/N) " complete
            if [[ $complete =~ ^[Yy]$ ]]; then
                complete_task "$task"
            fi
        fi
    fi
}
