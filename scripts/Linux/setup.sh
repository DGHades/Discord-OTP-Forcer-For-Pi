#!/usr/bin/env bash
# Linux setup script for Discord-OTP-Forcer
# Installs Python dependencies and opens config files for editing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Discord-OTP-Forcer: Linux Setup ==="

# Check Python version
PYTHON_CMD=""
for cmd in python3 python; do
    if command -v "$cmd" &>/dev/null; then
        PYTHON_CMD="$cmd"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "ERROR: Python 3.11+ is required but not found. Install it with:"
    echo "  sudo apt install python3 python3-pip python3-venv"
    exit 1
fi

PY_VERSION=$("$PYTHON_CMD" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PY_MAJOR=$("$PYTHON_CMD" -c "import sys; print(sys.version_info.major)")
PY_MINOR=$("$PYTHON_CMD" -c "import sys; print(sys.version_info.minor)")

if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 11 ]; }; then
    echo "ERROR: Python >= 3.11 is required. Found Python $PY_VERSION."
    exit 1
fi

echo "Found Python $PY_VERSION ($PYTHON_CMD)"

# Create virtual environment if it doesn't exist
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    echo "Creating virtual environment..."
    "$PYTHON_CMD" -m venv "$PROJECT_DIR/.venv"
fi

echo "Activating virtual environment..."
source "$PROJECT_DIR/.venv/bin/activate"

echo "Installing dependencies..."
pip install -r "$PROJECT_DIR/dependencies.txt"
echo "Dependencies installed!"

echo ""
echo "=== Setup complete ==="
echo ""
echo "Now edit your configuration files:"
echo "  $PROJECT_DIR/config/program.yml"
echo "  $PROJECT_DIR/config/account.yml"
echo ""
echo "Then run: scripts/Linux/start.sh"
