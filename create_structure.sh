#!/bin/bash

# Base directory for the project
BASE_DIR="/home/user/Nextcloud/Projects/home/FocusFlow"

# Create project structure
echo "Creating project structure in $BASE_DIR..."

# Create main directories and files
mkdir -p "$BASE_DIR"/{scripts,data/{notes,tasks,knowledge_base},templates/{notes,tasks,knowledge_base},logs,config}

# Create main script files
touch "$BASE_DIR"/{install.sh,uninstall.sh,backup.sh,main_menu.sh}

# Create script files
touch "$BASE_DIR"/scripts/{notes_menu.sh,tasks_menu.sh,kb_menu.sh,search.sh,pomodoro_timer.sh,utils.sh}

# Create default templates
cat > "$BASE_DIR/templates/notes/default_note_templatemd" << 'EOF'
Title: 
Date: $(date +%Y-%m-%d)
Tags: 

Content:
EOF

cat > "$BASE_DIR/templates/tasks/default_task_templatemd" << 'EOF'
Title: 
Priority: (High/Medium/Low)
Due Date: 
Status: (Todo/In Progress/Done)
Pomodoros: 0

Description:
EOF

cat > "$BASE_DIR/templates/knowledge_base/default_kb_templatemd" << 'EOF'
Title: 
Category: 
Tags: 
Created: $(date +%Y-%m-%d)
Last Modified: $(date +%Y-%m-%d)

Content:
EOF

# Create initial config file
cat > "$BASE_DIR/config/app_config.ini" << 'EOF'
[General]
app_name=FocusFlow
version=1.0.0

[Paths]
data_dir=/home/user/Nextcloud/Projects/home/FocusFlow/data
templates_dir=/home/user/Nextcloud/Projects/home/FocusFlow/templates
logs_dir=/home/user/Nextcloud/Projects/home/FocusFlow/logs

[Pomodoro]
work_duration=25
break_duration=5

[Search]
default_search_tool=ripgrep
EOF

# Create initial log file
touch "$BASE_DIR/logs/app.log"

# Make scripts executable
chmod +x "$BASE_DIR"/*.sh
chmod +x "$BASE_DIR"/scripts/*.sh

echo "Project structure created successfully!"
