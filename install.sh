#!/bin/bash
# install.sh

# Папка для установки
INSTALL_DIR="$HOME/.local/share/focusflow"

install() {
    echo "Устанавливаю FocusFlow..."
    # Создание директорий
    mkdir -p "$INSTALL_DIR/data/backups"
    mkdir -p "$INSTALL_DIR/logs"
    mkdir -p "$INSTALL_DIR/config" 
    mkdir -p "$INSTALL_DIR/scripts"
    
    # Копирование файлов
    cp -r data "$INSTALL_DIR/"
    cp -r templates "$INSTALL_DIR/"
    cp -r scripts "$INSTALL_DIR/"
    cp -r config "$INSTALL_DIR/"
    cp -r sounds "$INSTALL_DIR/"
    cp backup.sh "$INSTALL_DIR/"
    cp main_menu.sh "$INSTALL_DIR/"
    cp CHECKLIST.md "$INSTALL_DIR/"
    cp config/app_config.ini "$INSTALL_DIR/config/"
    
    # Установка прав
    chmod +x "$INSTALL_DIR/backup.sh"
    chmod +x "$INSTALL_DIR/main_menu.sh"
    chmod +x $INSTALL_DIR/scripts/*.sh
    
    echo "Установка завершена!"
}

# Запуск установки
install
