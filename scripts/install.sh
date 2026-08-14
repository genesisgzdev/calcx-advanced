#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 -m pip install --user "$ROOT"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/calcx"
cp "$ROOT/config/calcx.conf" "${XDG_CONFIG_HOME:-$HOME/.config}/calcx/config.env"
echo "CalcX Advanced installed. Run: calcx --help"
