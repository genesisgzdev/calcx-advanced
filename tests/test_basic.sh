#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/.." && pwd)"
source "$ROOT_DIR/lib/colors.sh"
failures=0

echo -e "${BOLD_CYAN}Running Basic Tests...${RESET}"

result=$("$ROOT_DIR/calcx.sh" '2 + 2')
if [ "$result" = "4" ]; then
    print_success "Addition test passed"
else
    failures=$((failures + 1))
    print_error "Addition test failed"
fi

result=$("$ROOT_DIR/calcx.sh" '5 * 3')
if [ "$result" = "15" ]; then
    print_success "Multiplication test passed"
else
    failures=$((failures + 1))
    print_error "Multiplication test failed"
fi

result=$("$ROOT_DIR/calcx.sh" '10 / 3')
if [[ "$result" == 3.33* ]]; then
    print_success "Division test passed"
else
    failures=$((failures + 1))
    print_error "Division test failed"
fi

repl=$(printf 'quit\n' | "$ROOT_DIR/calcx.sh")
if [[ "$repl" == *"Escribe 'help' o 'quit'"* ]]; then
    print_success "No-argument wrapper uses the Python REPL"
else
    failures=$((failures + 1))
    print_error "No-argument wrapper did not use the Python REPL"
fi

legacy_repl=$(printf 'quit\n' | bash "$ROOT_DIR/src/calcx-advanced.sh")
if [[ "$legacy_repl" == *"Escribe 'help' o 'quit'"* ]]; then
    print_success "Historical script delegates to the Python REPL"
else
    failures=$((failures + 1))
    print_error "Historical script exposed the legacy menu"
fi

exit "$failures"
