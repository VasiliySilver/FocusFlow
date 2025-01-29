#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Debug mode (set to true to enable debug output)
DEBUG_MODE=false

# Constants
BASE_TASKS_DIR="$BASE_DIR/data/tasks"
ACTIVE_DIR="$BASE_TASKS_DIR/active"
FUTURE_DIR="$BASE_TASKS_DIR/future"
TRASH_DIR="$BASE_TASKS_DIR/trash"
TEMPLATES_DIR="$BASE_DIR/templates/tasks"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status symbols
CHECK_MARK="✓"
PENDING_MARK="⏳"
HIGH_PRIORITY="!"
MEDIUM_PRIORITY="·"
LOW_PRIORITY=" "

# Ensure directories exist
mkdir -p "$ACTIVE_DIR" "$FUTURE_DIR" "$TRASH_DIR"
