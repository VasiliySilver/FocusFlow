#!/bin/bash

source "$(dirname "$0")/tasks_constants.sh"

debug_log() {
    if [ "$DEBUG_MODE" = "true" ]; then
        echo "DEBUG: $1"
    fi
}

print_tasks() {
    local directory="$1"
    local show_all="${2:-false}"
    echo -e "\n${BLUE}Current Tasks:${NC}"
    
    # Create temporary file for table data
    local tmp_file=$(mktemp)
    
    # Add header
    echo -e "${BLUE}Title|Status|Priority|Due Date|Created|Updated${NC}" > "$tmp_file"
    
    # Add tasks data
    format_tasks "$directory" "$show_all" >> "$tmp_file"
    
    # Display formatted table
    column -t -s '|' -o ' │ ' "$tmp_file" | while read -r line; do
        echo "├$(printf '%.0s─' {1..120})┤"
        echo "│ $line │"
    done
    echo "└$(printf '%.0s─' {1..120})┘"
    
    # Cleanup
    rm "$tmp_file"
}

display_tasks() {
    local show_all="${1:-false}"
    tput clear  # Clear the entire screen
    print_tasks "$ACTIVE_DIR" "$show_all"
}

format_tasks() {
    local dir="$1"
    local show_all="${2:-false}"
    
    debug_log "Processing directory: $dir"
    
    if [ -d "$dir" ]; then
        debug_log "Directory exists"
        while IFS= read -r task_file; do
            debug_log "Processing file: $task_file"
            
            # Extract information from filename
            local filename=$(basename "$task_file")
            debug_log "Filename: $filename"
            
            # Split filename into components using double underscore
            IFS='__' read -ra parts <<< "$filename"
            debug_log "Number of parts: ${#parts[@]}"
            
            # We expect 6 parts: title, status, due_date, priority, created_at, none.md
            if [ ${#parts[@]} -lt 6 ]; then
                debug_log "Skipping file due to incorrect number of parts"
                continue
            fi
            
            # Extract parts in correct order based on filename format
            local title="${parts[0]}"
            local status="${parts[2]}"
            local due_date="${parts[4]}"
            local priority="${parts[6]}"
            local created_at="${parts[8]}_${parts[9]}"
            local updated_at=$(echo "${parts[11]}" | sed 's/\.md$//')
            
            debug_log "Extracted info:"
            debug_log "  Title: $title"
            debug_log "  Status: $status"
            debug_log "  Due date: $due_date"
            debug_log "  Priority: $priority"
            debug_log "  Created at: $created_at"
            debug_log "  Updated at: $updated_at"
            
            # Validate extracted values
            if [ -z "$title" ] || [ -z "$status" ] || [ -z "$priority" ]; then
                debug_log "Skipping file due to missing required fields"
                continue
            fi

            # Skip non-Todo tasks unless show_all is true
            if [ "$show_all" != "true" ] && [ "$status" != "Todo" ]; then
                debug_log "Skipping non-Todo task (show_all=$show_all, status=$status)"
                continue
            fi
            
            # Format dates for display
            created_at=$(echo "$created_at" | sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)_\([0-9]\{2\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
            if [ "$updated_at" != "none" ]; then
                updated_at=$(echo "$updated_at" | sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)_\([0-9]\{2\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
            fi
            
            # Set color and symbol based on priority
            local color_code
            local priority_symbol
            case "$priority" in
                "High") 
                    color_code="$RED"
                    priority_symbol="$HIGH_PRIORITY"
                    ;;
                "Medium") 
                    color_code="$YELLOW"
                    priority_symbol="$MEDIUM_PRIORITY"
                    ;;
                "Low") 
                    color_code="$GREEN"
                    priority_symbol="$LOW_PRIORITY"
                    ;;
                *) 
                    color_code="$NC"
                    priority_symbol=" "
                    ;;
            esac
            
            # Get status symbol
            local status_symbol
            if [ "$status" = "Done" ]; then
                status_symbol="$CHECK_MARK"
            else
                status_symbol="$PENDING_MARK"
            fi
            
            # Format due date
            local due_date_display="$due_date"
            if [ "$due_date" = "NoDueDate" ]; then
                due_date_display="No due date"
            fi
            
            # Output task information in pipe-separated format
            echo -e "${color_code}${title}|${status_symbol}${status}|${priority_symbol}${priority}|${due_date_display}|${created_at}|${updated_at:--}${NC}"
        done < <(find "$dir" -name "*.md" 2>/dev/null | sort)
    fi
}
