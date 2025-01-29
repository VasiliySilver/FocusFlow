#!/bin/bash
# uninstall.sh

# Папка для установки
INSTALL_DIR="$HOME/.local/share/focusflow"

uninstall() {
    echo "Вы уверены, что хотите удалить FocusFlow? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # echo "Вы хотите сохранить данные? (Y/n)"
        # read -r keep_data
        
        # if [[ "$keep_data" =~ ^[Nn] ]]; then
        #     echo "Удаляю все данные и настройки..."
        #     # Удаление директорий с данными
        #     rm -rf "$INSTALL_DIR/data"
        #     rm -rf "$INSTALL_DIR/config"
        #     rm -rf "$INSTALL_DIR/templates"
        #     rm -rf "$INSTALL_DIR/logs"
        #     rm -rf "$INSTALL_DIR/sounds"
        # fi
        
        echo "Удаляю файлы приложения..."
        rm -rf "$INSTALL_DIR"
        echo "FocusFlow успешно удален!"
    fi
}

uninstall
