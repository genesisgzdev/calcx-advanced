#!/bin/bash
# Basic functionality tests for CalcX Advanced

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CALCX="${SCRIPT_DIR}/../calcx.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Test helper with numerical comparison
assert_result() {
    local test_name="$1"
    local expression="$2"
    local expected="$3"
    local tolerance="${4:-0.01}"

    TESTS_RUN=$((TESTS_RUN + 1))

    result=$($CALCX "$expression" 2>/dev/null)

    # Numerical comparison with tolerance
    diff=$(echo "scale=10; ($expected - $result)" | bc -l)
    abs_diff=$(echo "scale=10; if ($diff < 0) -$diff else $diff" | bc -l)
    is_equal=$(echo "$abs_diff < $tolerance" | bc -l)

    if [ "$is_equal" -eq 1 ]; then
        echo -e "${GREEN}✓${RESET} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${RESET} $test_name (expected: $expected, got: $result)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo -e "${YELLOW}Running Basic Functionality Tests${RESET}\n"

# Arithmetic tests
echo "Arithmetic Operations:"
assert_result "Addition" "2 + 2" "4"
assert_result "Subtraction" "10 - 3" "7"
assert_result "Multiplication" "5 * 6" "30"
assert_result "Division" "20 / 4" "5"
assert_result "Exponentiation" "2 ^ 8" "256"

# Function tests
echo -e "\nMathematical Functions:"
assert_result "Square root" "sqrt(16)" "4"
assert_result "Square root with decimals" "sqrt(2) ^ 2" "2"

# Complex expressions
echo -e "\nComplex Expressions:"
assert_result "Order of operations" "(5 + 3) * 2" "16"
assert_result "Nested operations" "((10 + 5) * 3) / 5" "9"

# Summary
echo -e "\n${YELLOW}========================================${RESET}"
echo -e "Tests run: $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${RESET}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${RESET}"
    exit 1
else
    echo -e "${GREEN}All basic tests passed!${RESET}"
    exit 0
fi
