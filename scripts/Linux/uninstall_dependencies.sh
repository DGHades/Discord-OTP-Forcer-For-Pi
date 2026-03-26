#!/usr/bin/env bash
# Uninstall Python dependencies for Discord-OTP-Forcer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$PROJECT_DIR/.venv/bin/activate" ]; then
    source "$PROJECT_DIR/.venv/bin/activate"
fi

echo "Uninstalling dependencies..."
pip uninstall -r "$PROJECT_DIR/dependencies.txt" -y
echo "Dependencies uninstalled!"
