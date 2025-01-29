#!/bin/bash

source "$(dirname "$0")/tasks_constants.sh"

move_task() {
    print_title "Move Task"
    
    local source_dirs=("$ACTIVE_DIR" "$FUTURE_DIR" "$TRASH_DIR")
    local source_dir=$(printf "%s\n" "${source_dirs[@]}" | fzf --prompt="Select source directory> ")
    
    if [ -n "$source_dir" ]; then
        local task=$(select_file "$source_dir" "Select task to move")
        if [ -n "$task" ]; then
            local target_dir=$(printf "%s\n" "${source_dirs[@]}" | fzf --prompt="Select target directory> ")
            if [ -n "$target_dir" ] && [ "$source_dir" != "$target_dir" ]; then
                mv "$task" "$target_dir/"
                log "INFO" "Task moved to: $target_dir"
            fi
        fi
    fi
}

delete_task() {
    print_title "Delete Task"
    
    local task=$(select_file "$ACTIVE_DIR" "Select task to delete")
    if [ -n "$task" ]; then
        read -p "Are you sure you want to delete this task? (y/N) " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            backup_file "$task"
            mv "$task" "$TRASH_DIR/"
            log "INFO" "Task moved to trash: $task"
        fi
    fi
}

search_tasks() {
    print_title "Search Tasks"
    
    read -p "Enter search term: " term
    if [ -n "$term" ]; then
        echo "Searching in active tasks:"
        grep -l "$term" "$ACTIVE_DIR"/*md 2>/dev/null
        
        echo -e "\nSearching in future tasks:"
        grep -l "$term" "$FUTURE_DIR"/*md 2>/dev/null
        
        read -p "Press Enter to continue..."
    fi
}
