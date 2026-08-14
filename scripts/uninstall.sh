#!/usr/bin/env bash
set -euo pipefail
python3 -m pip uninstall -y calcx-advanced 2>/dev/null || true
echo "CalcX Advanced package removed. User configuration and history were preserved."
echo "Remove them explicitly if desired: ${XDG_CONFIG_HOME:-$HOME/.config}/calcx and ${XDG_STATE_HOME:-$HOME/.local/state}/calcx"
