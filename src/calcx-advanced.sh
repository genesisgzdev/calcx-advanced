#!/usr/bin/env bash
# Compatibility entry: every calculation uses the maintained Python engine.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v python3 >/dev/null 2>&1; then
    PYTHONPATH="$SCRIPT_DIR/..${PYTHONPATH:+:$PYTHONPATH}" exec python3 -m calcx "$@"
elif command -v python >/dev/null 2>&1; then
    PYTHONPATH="$SCRIPT_DIR/..${PYTHONPATH:+:$PYTHONPATH}" exec python -m calcx "$@"
fi
printf '%s\n' 'CalcX necesita Python 3.10 o posterior. Instálalo y vuelve a abrir la calculadora.' >&2
exit 1
