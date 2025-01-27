#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Initialize script
init_script

# Get work and break durations from config
WORK_DURATION=$(get_config_value "Pomodoro" "work_duration")
BREAK_DURATION=$(get_config_value "Pomodoro" "break_duration")

# Function to display countdown
show_countdown() {
    local duration=$1
    local type=$2
    local end_time=$((SECONDS + duration * 60))
    
    while [ $SECONDS -lt $end_time ]; do
        clear
        print_title "Pomodoro Timer - $type"
        
        local remaining=$((end_time - SECONDS))
        local minutes=$((remaining / 60))
        local seconds=$((remaining % 60))
        
        echo -e "${GREEN}Time remaining: $(printf "%02d:%02d" $minutes $seconds)${NC}"
        echo
        echo "Press Ctrl+C to stop the timer"
        sleep 1
    done
}

# Start Pomodoro timer
start_timer() {
    local task_file="$1"
    local task_name=$(grep "Title:" "$task_file" | cut -d' ' -f2-)
    
    print_title "Starting Pomodoro Timer"
    echo "Task: $task_name"
    echo "Work period: $WORK_DURATION minutes"
    echo "Break period: $BREAK_DURATION minutes"
    echo
    read -p "Press Enter to start..."
    
    # Work period
    show_countdown "$WORK_DURATION" "Work Time"
    
    # Play sound if available
    if command -v paplay &> /dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga &> /dev/null || true
    fi
    
    clear
    print_title "Work Period Complete!"
    echo "Great job! Time for a break."
    echo
    read -p "Press Enter to start break..."
    
    # Break period
    show_countdown "$BREAK_DURATION" "Break Time"
    
    # Play sound if available
    if command -v paplay &> /dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga &> /dev/null || true
    fi
    
    clear
    print_title "Break Complete!"
    echo "Pomodoro session finished!"
    echo
    read -p "Press Enter to continue..."
    
    return 0
}

# Handle command line arguments
if [ $# -eq 1 ]; then
    start_timer "$1"
else
    log "ERROR" "Usage: $0 <task_file>"
    exit 1
fi
