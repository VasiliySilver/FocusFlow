#!/bin/bash

# Base directory of the project
BASE_DIR="/home/user/Nextcloud/Projects/home/FocusFlow"
CONFIG_FILE="$BASE_DIR/config/app_config.ini"
LOG_FILE="$BASE_DIR/logs/app.log"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR")
            echo -e "${RED}Error: $message${NC}" >&2
            ;;
        "WARNING")
            echo -e "${YELLOW}Warning: $message${NC}" >&2
            ;;
        "INFO")
            echo -e "${GREEN}$message${NC}"
            ;;
        "DEBUG")
            echo -e "${BLUE}Debug: $message${NC}"
            ;;
    esac
}

# Read config value
get_config_value() {
    local section="$1"
    local key="$2"
    
    awk -F '=' -v section="$section" -v key="$key" '
        $0 ~ /^\[.*\]/ { current_section = substr($0, 2, length($0)-2) }
        current_section == section && $1 ~ /^[[:space:]]*'"$key"'[[:space:]]*$/ { 
            sub(/^[[:space:]]*'"$key"'[[:space:]]*=/, "");
            sub(/^[[:space:]]+/, "");
            sub(/[[:space:]]+$/, "");
            print
        }
    ' "$CONFIG_FILE"
}

# Check if required commands are available
check_dependencies() {
    local deps=("fzf" "rg")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log "ERROR" "Missing dependencies: ${missing_deps[*]}"
        echo "Please install the following dependencies:"
        printf '%s\n' "${missing_deps[@]}"
        return 1
    fi
    return 0
}

# Create title for menus
print_title() {
    local title="$1"
    local width=50
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo
    printf '%*s' "$width" | tr ' ' '='
    echo
    printf "%*s%s%*s\n" $padding "" "$title" $padding ""
    printf '%*s' "$width" | tr ' ' '='
    echo
}

# Select file using fzf
select_file() {
    local dir="$1"
    local prompt="${2:-Select a file}"
    
    find "$dir" -type f -name "*md" | fzf --prompt="$prompt> "
}

# Validate date format (YYYY-MM-DD)
validate_date() {
    local date_str="$1"
    if [[ ! "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 1
    fi
    
    local year="${date_str:0:4}"
    local month="${date_str:5:2}"
    local day="${date_str:8:2}"
    
    # Check month and day validity
    if [ "$month" -lt 1 ] || [ "$month" -gt 12 ] || \
       [ "$day" -lt 1 ] || [ "$day" -gt 31 ]; then
        return 1
    fi
    
    return 0
}

# Get filename safe string
get_safe_filename() {
    local string="$1"
    echo "${string}"
}

# Select template using fzf
select_template() {
    local type="$1"  # notes, tasks, or knowledge_base
    local templates_dir="$BASE_DIR/templates/$type"
    
    select_file "$templates_dir" "Select template"
}

# Create a new file from template
create_from_template() {
    local template="$1"
    local output_file="$2"
    
    if [ ! -f "$template" ]; then
        log "ERROR" "Template file not found: $template"
        return 1
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$output_file")"
    
    # Copy template and replace date placeholders
    sed "s/\$(date +%Y-%m-%d)/$(date +%Y-%m-%d)/g; s/\$(date +%Y-%m-%d %H:%M:%S)/$(date +%Y-%m-%d %H:%M:%S)/g" "$template" > "$output_file"
    
    if [ $? -eq 0 ]; then
        log "INFO" "Created new file: $output_file"
        return 0
    else
        log "ERROR" "Failed to create file: $output_file"
        return 1
    fi
}

# Check if file exists
file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        log "ERROR" "File not found: $file"
        return 1
    fi
    return 0
}

# Create a new template
create_template() {
    local type="$1" # notes, tasks, or knowledge_base
    local templates_dir="$BASE_DIR/templates/$type"
    
    read -p "Enter template name: " template_name
    if [ -z "$template_name" ]; then
        log "ERROR" "Template name cannot be empty"
        return 1
    fi
    
    local filename="$(get_safe_filename "$template_name")"
    local filepath="$templates_dir/${filename}md"
    
    if [ -f "$filepath" ]; then
        log "ERROR" "Template already exists: $filepath"
        return 1
    fi
    
    touch "$filepath"
    ${EDITOR:-nano} "$filepath"
    
    if [ $? -eq 0 ]; then
        log "INFO" "Created new template: $filepath"
        return 0
    else
        log "ERROR" "Failed to create template: $filepath"
        return 1
    fi
}

# Edit a template
edit_template() {
    local type="$1" # notes, tasks, or knowledge_base
    local templates_dir="$BASE_DIR/templates/$type"
    
    local template=$(select_file "$templates_dir" "Select template to edit")
    if [ -n "$template" ]; then
        ${EDITOR:-nano} "$template"
        if [ $? -eq 0 ]; then
            log "INFO" "Template edited: $template"
            return 0
        else
            log "ERROR" "Failed to edit template: $template"
            return 1
        fi
    fi
}

# Backup single file
backup_file() {
    local file="$1"
    local backup_dir="$BASE_DIR/data/backups/$(date +%Y-%m-%d)"
    
    mkdir -p "$backup_dir"
    cp "$file" "$backup_dir/$(basename "$file").$(date +%H-%M-%S).bak"
}

# Initialize script (call at the beginning of each script)
init_script() {
    # Check if we're in the correct directory
    if [ ! -d "$BASE_DIR" ]; then
        echo "Error: Project directory not found: $BASE_DIR"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies || exit 1
}
