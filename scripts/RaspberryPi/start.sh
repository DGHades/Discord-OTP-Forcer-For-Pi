#!/usr/bin/env bash
# Raspberry Pi start script for Discord-OTP-Forcer
#
# Activates the venv and launches the program.
# Usage:
#   ./scripts/RaspberryPi/start.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_DIR"

if [ -f "$PROJECT_DIR/.venv/bin/activate" ]; then
    source "$PROJECT_DIR/.venv/bin/activate"
else
    echo "ERROR: Virtual environment not found. Run setup.sh first:"
    echo "  ./scripts/RaspberryPi/setup.sh"
    exit 1
fi

python3 main.py
