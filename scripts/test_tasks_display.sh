#!/bin/bash

# Source необходимые файлы
source "$(dirname "$0")/tasks_constants.sh"
source "$(dirname "$0")/tasks_display.sh"

# Функция для вывода отладочной информации
debug_info() {
    echo "=== Debug Info ==="
    echo "BASE_DIR: $BASE_DIR"
    echo "ACTIVE_DIR: $ACTIVE_DIR"
    echo
    echo "Checking ACTIVE_DIR existence:"
    if [ -d "$ACTIVE_DIR" ]; then
        echo "✓ ACTIVE_DIR exists"
    else
        echo "✗ ACTIVE_DIR does not exist"
    fi
    
    echo
    echo "Files in ACTIVE_DIR:"
    if [ -d "$ACTIVE_DIR" ]; then
        ls -la "$ACTIVE_DIR"
        echo
        echo "MD files count:"
        find "$ACTIVE_DIR" -name "*.md" | wc -l
        
        echo
        echo "MD files list:"
        find "$ACTIVE_DIR" -name "*.md" | while read -r file; do
            echo "File: $file"
            echo "Content preview:"
            head -n 1 "$file"
            echo "---"
        done
    else
        echo "Cannot list files - directory does not exist"
    fi
    echo "=================="
}

# Тестовая функция для проверки format_tasks
test_format_tasks() {
    echo
    echo "=== Testing format_tasks directly ==="
    echo "Calling: format_tasks \"$ACTIVE_DIR\" false"
    
    # Проверяем find команду отдельно
    echo
    echo "Testing find command:"
    find "$ACTIVE_DIR" -name "*.md" 2>/dev/null
    
    echo
    echo "Executing format_tasks:"
    format_tasks "$ACTIVE_DIR" false
    echo "=================="
}

# Тестовая функция для проверки print_tasks
test_print_tasks() {
    echo
    echo "=== Testing print_tasks ==="
    echo "Calling: print_tasks \"$ACTIVE_DIR\" false"
    print_tasks "$ACTIVE_DIR" false
    echo "=================="
}

# Основная тестовая функция
main() {
    echo "Starting tests at $(date)"
    echo "=========================="
    
    # Вывести отладочную информацию
    debug_info
    
    # Тест format_tasks
    test_format_tasks
    
    # Тест print_tasks
    test_print_tasks
    
    echo
    echo "Tests completed at $(date)"
}

# Запуск тестов
main
