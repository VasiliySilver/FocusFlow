#!/bin/bash

source "$(dirname "$0")/tasks_constants.sh"

edit_template() {
    print_title "Edit Template"
    
    local template=$(find "$TEMPLATES_DIR" -name "*.md" -printf "%f\n" | fzf --prompt="Select template> ")
    if [ -n "$template" ]; then
        ${EDITOR:-nano} "$TEMPLATES_DIR/$template"
        log "INFO" "Template edited: $template"
    fi
}

create_template() {
    print_title "Create Template"
    
    read -p "Enter template name: " name
    if [ -n "$name" ]; then
        local filename="$(get_safe_filename "$name").md"
        local filepath="$TEMPLATES_DIR/$filename"
        
        cat > "$filepath" << EOL
Title: 
Priority: 
Due Date: 
Status: Todo
Created: 
Pomodoros: 0

Description:

EOL
        
        ${EDITOR:-nano} "$filepath"
        log "INFO" "Template created: $filepath"
    fi
}
