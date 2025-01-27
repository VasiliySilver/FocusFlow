#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Initialize script
init_script

# Function to search using telescope
search_all() {
    print_title "Search All"
    
    local search_term
    read -p "Enter search term: " search_term
    
    if [ -n "$search_term" ]; then
        telescope find_files --prompt="Search Results> " --hidden --no-ignore --find-command="find $BASE_DIR/data -type f -name '*md'" |
        xargs grep -n "$search_term"
    fi
    
    read -p "Press Enter to continue..."
}

# Start the search
search_all
