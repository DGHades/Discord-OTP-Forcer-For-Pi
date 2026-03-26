#!/usr/bin/env bash
# Update Python dependencies for Discord-OTP-Forcer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$PROJECT_DIR/.venv/bin/activate" ]; then
    source "$PROJECT_DIR/.venv/bin/activate"
fi

echo "Updating dependencies..."
pip install --upgrade -r "$PROJECT_DIR/dependencies.txt"
echo "Dependencies updated!"
