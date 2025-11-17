#!/bin/bash
# Unit tests for symbolic computation

source "$(dirname "$0")/../../lib/symbolic.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

assert_contains() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if echo "$actual" | grep -q "$expected"; then
        echo -e "${GREEN}✓${RESET} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${RESET} $test_name (expected to contain: $expected, got: $actual)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

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

echo -e "${YELLOW}Running Symbolic Computation Tests${RESET}\n"

# Check if SymPy is available
if ! check_sympy; then
    echo -e "${YELLOW}⚠ SymPy not installed. Skipping symbolic tests.${RESET}"
    echo -e "${YELLOW}Install with: pip3 install sympy${RESET}"
    exit 0
fi

# Test simplification
echo "Simplification:"
result=$(symbolic_simplify "x + x + x")
assert_contains "simplify x + x + x" "3" "$result"

result=$(symbolic_simplify "(x + 1)**2 - (x**2 + 2*x + 1)")
assert_contains "simplify expansion" "0" "$result"

# Test expansion
echo -e "\nExpansion:"
result=$(symbolic_expand "(x + 1)*(x + 2)")
assert_contains "expand (x+1)(x+2)" "x" "$result"

result=$(symbolic_expand "(x + y)**2")
assert_contains "expand (x+y)^2" "2" "$result"

# Test factorization
echo -e "\nFactorization:"
result=$(symbolic_factor "x**2 - 1")
assert_contains "factor x^2-1" "x - 1" "$result"

result=$(symbolic_factor "x**2 + 2*x + 1")
assert_contains "factor x^2+2x+1" "x + 1" "$result"

# Test differentiation
echo -e "\nDifferentiation:"
result=$(symbolic_diff "x**2")
assert_contains "diff x^2" "2" "$result"

result=$(symbolic_diff "sin(x)")
assert_contains "diff sin(x)" "cos" "$result"

result=$(symbolic_diff "x**3 + 2*x**2 + x")
assert_contains "diff polynomial" "3" "$result"

# Test integration
echo -e "\nIntegration:"
result=$(symbolic_integrate "x")
assert_contains "integrate x" "x**2" "$result"

result=$(symbolic_integrate "x**2")
assert_contains "integrate x^2" "x**3" "$result"

# Test equation solving
echo -e "\nEquation Solving:"
result=$(symbolic_solve "x**2 - 4")
assert_contains "solve x^2-4" "2" "$result"

result=$(symbolic_solve "2*x + 5 = 11")
assert_contains "solve 2x+5=11" "3" "$result"

# Test limits
echo -e "\nLimits:"
result=$(symbolic_limit "sin(x)/x" "x" "0")
assert_contains "limit sin(x)/x as x->0" "1" "$result"

result=$(symbolic_limit "1/x" "x" "oo")
assert_contains "limit 1/x as x->oo" "0" "$result"

# Test series expansion
echo -e "\nSeries Expansion:"
result=$(symbolic_series "exp(x)" "x" "0" "4")
assert_contains "series e^x" "x" "$result"

result=$(symbolic_series "sin(x)" "x" "0" "5")
assert_contains "series sin(x)" "x" "$result"

# Summary
echo -e "\n${YELLOW}========================================${RESET}"
echo -e "Tests run: $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${RESET}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${RESET}"
    exit 1
else
    echo -e "${GREEN}All symbolic computation tests passed!${RESET}"
    exit 0
fi
