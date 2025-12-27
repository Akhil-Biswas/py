#!/bin/bash
# -----------------------------------------------------------------------------
# setup.sh
#
# Cross-platform Python project setup script.
#
# Supports:
#   - macOS / Linux
#   - Windows via Git Bash or WSL
#
# Features:
#   - Detects Python (python3 / python)
#   - Enforces minimum Python version
#   - Creates or reuses virtual environment (.venv or venv)
#   - Activates virtual environment
#   - Installs dependencies using:
#       * uv (preferred, via pyproject.toml)
#       * pip + requirements.txt (fallback)
#   - Safe defaults with clear error messages
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh
#
# -----------------------------------------------------------------------------

# Exit immediately if any command fails
set -e

# -----------------------------------------------------------------------------
# ANSI color codes
# -----------------------------------------------------------------------------
GREEN_BOLD="\033[92;1m"
RED_BOLD="\033[91;1m"
CYAN="\033[36m"
MAGENTA_BOLD="\033[95;1m"
YELLOW="\033[93m"
RESET="\033[0m"

echo -e "${GREEN_BOLD}===== Python Project Setup =====${RESET}"

# -----------------------------------------------------------------------------
# Output helper functions
# -----------------------------------------------------------------------------
info() {
    echo -e "${CYAN}$1${RESET}"
}

success() {
    echo -e "${GREEN_BOLD}$1${RESET}"
}

warn() {
    echo -e "${YELLOW}$1${RESET}"
}

error() {
    echo -e "${RED_BOLD}Error:${RESET} $1"
}

# -----------------------------------------------------------------------------
# 1. Detect Python executable
#
# macOS/Linux typically use `python3`
# Windows typically uses `python`
# -----------------------------------------------------------------------------
if command -v python3 &>/dev/null; then
    PYTHON=python3
elif command -v python &>/dev/null; then
    PYTHON=python
else
    echo "Error: Python is not installed or not in PATH."
    exit 1
fi

# ------------------------------------------------------------------------------
# 2 . Rename project directory if it is named 'project'
# -----------------------------------------------------------------------------
if [ -d "./src/project" ]; then
    DEFAULT_NAME="my-project"

    while true; do
        read -rp "Enter your project name [default: $DEFAULT_NAME]: " INPUT

        # Empty → default
        if [ -z "$INPUT" ]; then
            PROJECT_NAME="$DEFAULT_NAME"
            break
        fi

        # Auto-fix:
        # 1. lowercase
        # 2. spaces/underscores → hyphen
        # 3. remove invalid chars
        # 4. trim leading/trailing hyphens
        PROJECT_NAME=$(echo "$INPUT" \
            | tr '[:upper:]' '[:lower:]' \
            | sed -E 's/[ _]+/-/g; s/[^a-z0-9-]//g; s/^-+|-+$//g')

        # If nothing valid remains, re-ask
        if [ -z "$PROJECT_NAME" ]; then
            echo "Invalid project name. Try again."
            continue
        fi

        # Prevent overwrite
        if [ -e "./src/$PROJECT_NAME" ]; then
            echo "Directory './src/$PROJECT_NAME' already exists."
            continue
        fi

        break
    done

    mv "./src/project" "./src/$PROJECT_NAME"
    > README.md
fi



# -----------------------------------------------------------------------------
# 2. Check Python version
#
# Enforces Python >= 3.10
# -----------------------------------------------------------------------------
REQUIRED_PYTHON="3.10"
CURRENT_PYTHON=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

info "Python version detected: $CURRENT_PYTHON"

if [ "$(printf '%s\n' "$REQUIRED_PYTHON" "$CURRENT_PYTHON" | sort -V | head -n1)" != "$REQUIRED_PYTHON" ]; then
    echo -e "\033[1;91mError:\033[0;91;m Python $REQUIRED_PYTHON or higher is required.\033[0m"
    exit 1
fi

# -----------------------------------------------------------------------------
# 3. Detect or create virtual environment
#
# Priority:
#   1. Existing .venv/
#   2. Existing venv/
#   3. Create .venv/
# -----------------------------------------------------------------------------
VENV_DIR=".venv"

if [ -d ".venv" ]; then
    VENV_DIR=".venv"
    info "Using existing virtual environment in ${MAGENTA_BOLD}.venv${RESET}"

elif [ -d "venv" ]; then
    VENV_DIR="venv"
    info "Using existing virtual environment in ${MAGENTA_BOLD}venv${RESET}"

else
    info "Creating virtual environment in ${MAGENTA_BOLD}.venv${RESET}"
    $PYTHON -m venv .venv
    VENV_DIR=".venv"
fi

# -----------------------------------------------------------------------------
# 4. Activate virtual environment
#
# Activation path differs by OS:
#   - Windows (Git Bash / WSL): Scripts/activate
#   - macOS / Linux:            bin/activate
# -----------------------------------------------------------------------------
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    source "$VENV_DIR/Scripts/activate"
else
    source "$VENV_DIR/bin/activate"
fi

# -----------------------------------------------------------------------------
# 5. Upgrade pip
#
# Safe even when using uv (pip is still used internally)
# -----------------------------------------------------------------------------
info "Upgrading pip..."
pip install --upgrade pip &>/dev/null

# -----------------------------------------------------------------------------
# 6. Install dependencies
#
# Priority:
#   1. requirements.txt → pip
#   2. pyproject.toml  → uv
#   3. Fallback: install minimal dependencies
# -----------------------------------------------------------------------------
if [ -f "requirements.txt" ]; then
    info "Installing dependencies from requirements.txt..."
    pip install -r requirements.txt

else
    warn "requirements.txt not found."
fi

if [ -f "pyproject.toml" ]; then
    if ! command -v uv &>/dev/null; then
        warn "uv not found. Installing uv..."
        pip install uv
    fi
    info "Syncing dependencies using uv..."
    uv sync

else
    warn "pyproject.toml found."
fi

# -----------------------------------------------------------------------------
# 7. Optional: install project in editable mode
#
# Uncomment if this is a package under active development
# -----------------------------------------------------------------------------
# pip install -e .

# -----------------------------------------------------------------------------
# 8. Completion message
# -----------------------------------------------------------------------------
success "===== Setup complete! ====="

echo "Activate the virtual environment manually with:"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo "  PowerShell: $VENV_DIR\\Scripts\\Activate.ps1"
    echo "  CMD:        $VENV_DIR\\Scripts\\activate.bat"
else
    echo -e "\033[93m  source $VENV_DIR/bin/activate\033[0m"
fi

# -----------------------------------------------------------------------------
# 9. Optional: run the application
#
# Uncomment to automatically start the app after setup
# -----------------------------------------------------------------------------
# $PYTHON -m project
