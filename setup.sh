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

echo "===== Python Project Setup ====="

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

# -----------------------------------------------------------------------------
# 2. Check Python version
#
# Enforces Python >= 3.10
# -----------------------------------------------------------------------------
REQUIRED_PYTHON="3.10"
CURRENT_PYTHON=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

echo "Python version detected: $CURRENT_PYTHON"

if [ "$(printf '%s\n' "$REQUIRED_PYTHON" "$CURRENT_PYTHON" | sort -V | head -n1)" != "$REQUIRED_PYTHON" ]; then
    echo "Error: Python $REQUIRED_PYTHON or higher is required."
    exit 1
fi

# -----------------------------------------------------------------------------
# 3. Detect or create virtual environment
#
# Priority:
#   1. Use existing `venv/` if present
#   2. Use existing `.venv/` if present
#   3. Otherwise, create `.venv/`
# -----------------------------------------------------------------------------
VENV_DIR=".venv"

if [ -d "venv" ]; then
    VENV_DIR="venv"
elif [ ! -d ".venv" ]; then
    echo "Creating virtual environment in .venv..."
    $PYTHON -m venv .venv
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
echo "Upgrading pip..."
pip install --upgrade pip

# -----------------------------------------------------------------------------
# 6. Install dependencies
#
# Priority:
#   1. requirements.txt → pip
#   2. pyproject.toml  → uv
#   3. Fallback: install minimal dependencies
# -----------------------------------------------------------------------------
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install -r requirements.txt

elif [ -f "pyproject.toml" ]; then
    if ! command -v uv &>/dev/null; then
        echo "uv not found. Installing uv..."
        pip install uv
    fi
    echo "Syncing dependencies using uv..."
    uv sync

else
    echo "No dependency configuration found."
    echo "Installing minimal required packages..."
    pip install rich
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
echo "Setup complete!"

echo "Activate the virtual environment manually with:"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    echo "  PowerShell: $VENV_DIR\\Scripts\\Activate.ps1"
    echo "  CMD:        $VENV_DIR\\Scripts\\activate.bat"
else
    echo "  source $VENV_DIR/bin/activate"
fi

# -----------------------------------------------------------------------------
# 9. Optional: run the application
#
# Uncomment to automatically start the app after setup
# -----------------------------------------------------------------------------
# $PYTHON -m src.main
