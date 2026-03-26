#!/usr/bin/env bash
# =============================================================================
# Raspberry Pi full setup script for Discord-OTP-Forcer
#
# This script handles everything needed to run the project on a Raspberry Pi
# running Raspberry Pi OS (Debian-based, ARM architecture):
#
#   1. Installs required system packages (Chromium, chromedriver, Python, etc.)
#   2. Creates a Python virtual environment
#   3. Installs Python dependencies
#   4. Sets recommended config defaults for Pi (Chromium browser, headless)
#   5. Prints next-step instructions
#
# Usage:
#   chmod +x scripts/RaspberryPi/setup.sh
#   ./scripts/RaspberryPi/setup.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "============================================="
echo " Discord-OTP-Forcer: Raspberry Pi Setup"
echo "============================================="
echo ""

# --- 1. System packages ---
echo "[1/5] Installing system packages..."
sudo apt-get update

# Detect Chromium package names — Trixie uses "chromium" + "chromium-driver",
# while Bookworm uses "chromium-browser" + "chromium-chromedriver".
CHROMIUM_PKG="chromium-browser"
CHROMEDRIVER_PKG="chromium-chromedriver"
if apt-cache show chromium &>/dev/null && ! apt-cache show chromium-browser &>/dev/null; then
    CHROMIUM_PKG="chromium"
    CHROMEDRIVER_PKG="chromium-driver"
fi

sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    "$CHROMIUM_PKG" \
    "$CHROMEDRIVER_PKG" \
    libxkbcommon0 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libnspr4 \
    libnss3 \
    xdg-utils

echo "System packages installed."
echo ""

# --- 2. Verify Python version ---
echo "[2/5] Checking Python version..."
PYTHON_CMD=""
for cmd in python3 python; do
    if command -v "$cmd" &>/dev/null; then
        PYTHON_CMD="$cmd"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "ERROR: Python 3 not found even after installing. Check your system."
    exit 1
fi

PY_VERSION=$("$PYTHON_CMD" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PY_MAJOR=$("$PYTHON_CMD" -c "import sys; print(sys.version_info.major)")
PY_MINOR=$("$PYTHON_CMD" -c "import sys; print(sys.version_info.minor)")

if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 11 ]; }; then
    echo "WARNING: Python >= 3.11 is required. Found Python $PY_VERSION."
    echo "Raspberry Pi OS Bookworm ships Python 3.11. If you are on an older release,"
    echo "upgrade your OS or install Python 3.11+ manually."
    exit 1
fi

echo "Python $PY_VERSION found ($PYTHON_CMD)."
echo ""

# --- 3. Virtual environment ---
echo "[3/5] Setting up Python virtual environment..."
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    "$PYTHON_CMD" -m venv "$PROJECT_DIR/.venv"
    echo "Virtual environment created at $PROJECT_DIR/.venv"
else
    echo "Virtual environment already exists."
fi

source "$PROJECT_DIR/.venv/bin/activate"
echo ""

# --- 4. Python dependencies ---
echo "[4/5] Installing Python dependencies..."
pip install --upgrade pip
pip install -r "$PROJECT_DIR/dependencies.txt"
echo "Python dependencies installed."
echo ""

# --- 5. Recommend Pi-friendly config ---
echo "[5/5] Verifying configuration..."

PROGRAM_YML="$PROJECT_DIR/config/program.yml"

# Check if browser is set; suggest Chromium if empty
if grep -qE '^\s*browser:\s*$' "$PROGRAM_YML" 2>/dev/null; then
    echo "NOTE: 'browser' is not set in program.yml."
    echo "      For Raspberry Pi, set it to: Chromium"
fi

# Check headless setting
if grep -qE '^\s*headless:\s*False' "$PROGRAM_YML" 2>/dev/null; then
    echo "NOTE: 'headless' is set to False in program.yml."
    echo "      For headless Pi (no display), set it to: True"
fi

echo ""
echo "============================================="
echo " Setup complete!"
echo "============================================="
echo ""
echo "Next steps:"
echo "  1. Edit your configuration files:"
echo "       nano $PROJECT_DIR/config/program.yml"
echo "       nano $PROJECT_DIR/config/account.yml"
echo ""
echo "     Recommended program.yml settings for Raspberry Pi:"
echo "       browser: Chromium"
echo "       headless: True      (if no display attached)"
echo "       headless: False     (if using a desktop environment)"
echo ""
echo "  2. Run the program:"
echo "       $PROJECT_DIR/scripts/RaspberryPi/start.sh"
echo ""
echo "     Or manually:"
echo "       cd $PROJECT_DIR"
echo "       source .venv/bin/activate"
echo "       python3 main.py"
echo ""
