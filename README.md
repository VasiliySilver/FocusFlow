# FocusFlow

FocusFlow is a command-line productivity tool that helps you manage notes, tasks, and knowledge base entries with an integrated Pomodoro timer.

## Features

- **Notes Management**: Create, edit, and organize your notes
- **Task Management**: Track tasks with priorities and due dates
- **Knowledge Base**: Build and maintain your personal knowledge base
- **Pomodoro Timer**: Built-in timer for focused work sessions
- **Search**: Fast full-text search across all your data
- **Backup**: Automated backup and restore functionality

## Requirements

- bash
- fzf (for fuzzy finding)
- ripgrep (for searching)

## Installation

1. Clone the repository:
   ```bash
   git clone [repository-url] focusflow
   cd focusflow
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

3. Restart your shell or run:
   ```bash
   source ~/.bashrc
   ```

## Usage

Start FocusFlow by running:
```bash
focusflow
```

### Main Menu Options

1. **Notes**: Manage your notes
2. **Tasks**: Track and manage tasks with Pomodoro timer
3. **Knowledge Base**: Build your knowledge base
4. **Search**: Search across all your data
5. **Backup**: Create and restore backups

## Directory Structure

```
~/.local/share/focusflow/
├── data/
│   ├── notes/
│   ├── tasks/
│   └── knowledge_base/
├── templates/
│   ├── notes/
│   ├── tasks/
│   └── knowledge_base/
├── backups/
├── config/
└── logs/
```

## Backup and Restore

- Create backup: Select "Backup" from main menu
- Restore backup: Select "Backup" → "Restore from Backup"

## Uninstallation

Run the uninstall script:
```bash
~/.local/share/focusflow/uninstall.sh
```

## License

MIT License
