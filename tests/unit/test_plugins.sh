#!/bin/bash
# Unit tests for plugin system

source "$(dirname "$0")/../../lib/plugin_system.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

assert_success() {
    local test_name="$1"
    shift

    TESTS_RUN=$((TESTS_RUN + 1))

    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${RESET} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${RESET} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_failure() {
    local test_name="$1"
    shift

    TESTS_RUN=$((TESTS_RUN + 1))

    if "$@" >/dev/null 2>&1; then
        echo -e "${RED}✗${RESET} $test_name (should have failed)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "${GREEN}✓${RESET} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
}

echo -e "${YELLOW}Running Plugin System Tests${RESET}\n"

# Test plugin discovery
echo "Plugin Discovery:"
assert_success "discover plugins" discover_plugins

# Test plugin validation
echo -e "\nPlugin Validation:"
PLUGIN_DIR="$(dirname "$0")/../../plugins"
if [ -f "$PLUGIN_DIR/finance.plugin.sh" ]; then
    assert_success "validate finance plugin" validate_plugin "$PLUGIN_DIR/finance.plugin.sh"
else
    echo -e "${YELLOW}⚠${RESET} Finance plugin not found, skipping validation test"
fi

# Test plugin loading
echo -e "\nPlugin Loading:"
if [ -f "$PLUGIN_DIR/finance.plugin.sh" ]; then
    assert_success "load finance plugin" load_plugin "finance"

    # Test if plugin functions are available
    if declare -f finance_compound_interest >/dev/null 2>&1; then
        echo -e "${GREEN}✓${RESET} Plugin functions exported"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${RESET} Plugin functions not exported"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))

    # Test plugin function execution
    assert_success "call plugin function" call_plugin_function "finance" "compound_interest" 1000 0.05 10 1

    # Test plugin unloading
    assert_success "unload finance plugin" unload_plugin "finance"
else
    echo -e "${YELLOW}⚠${RESET} Finance plugin not found, skipping loading tests"
fi

# Test invalid plugin handling
echo -e "\nError Handling:"
assert_failure "load non-existent plugin" load_plugin "nonexistent_plugin_xyz"

# Summary
echo -e "\n${YELLOW}========================================${RESET}"
echo -e "Tests run: $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${RESET}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${RESET}"
    exit 1
else
    echo -e "${GREEN}All plugin system tests passed!${RESET}"
    exit 0
fi
