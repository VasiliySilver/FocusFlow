#!/bin/bash
# install.sh

# Base directories
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/share/focusflow"
BIN_DIR="$HOME/.local/bin"

install_focusflow() {
    echo "Installing FocusFlow..."
    
    # Create installation directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    
    # Copy files
    cp -r "$REPO_DIR"/* "$INSTALL_DIR/"
    
    # Create launcher script
    cat > "$BIN_DIR/focusflow" << EOF
#!/bin/bash
exec "$INSTALL_DIR/main_menu.sh" "\$@"
EOF
    
    # Make launcher executable
    chmod +x "$BIN_DIR/focusflow"
    
    # Add bin directory to PATH if not already present
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'Please restart your shell or run: source ~/.bashrc'
    fi
    
    # Check dependencies
    local missing_deps=()
    for dep in fzf rg; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Warning: Missing dependencies: ${missing_deps[*]}"
        echo "Please install them using your package manager:"
        echo "For Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
        echo "For Fedora: sudo dnf install ${missing_deps[*]}"
        echo "For Arch: sudo pacman -S ${missing_deps[*]}"
    fi
    
    echo "FocusFlow installed successfully!"
    echo "Run 'focusflow' to start the application"
}

# Run installation
install_focusflow

