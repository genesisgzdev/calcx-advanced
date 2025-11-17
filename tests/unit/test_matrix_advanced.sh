#!/bin/bash
# Unit tests for advanced matrix operations

source "$(dirname "$0")/../../lib/matrix_advanced.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

assert_equals() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    local tolerance="${4:-0.01}"

    TESTS_RUN=$((TESTS_RUN + 1))

    diff=$(echo "scale=10; ($expected - $actual)" | bc -l)
    abs_diff=$(echo "scale=10; if ($diff < 0) -$diff else $diff" | bc -l)
    is_equal=$(echo "$abs_diff < $tolerance" | bc -l)

    if [ "$is_equal" -eq 1 ]; then
        echo -e "${GREEN}✓${RESET} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${RESET} $test_name (expected: $expected, got: $actual)"
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

echo -e "${YELLOW}Running Advanced Matrix Tests${RESET}\n"

# Test 4x4 determinant
echo "4x4 Determinant:"
if command -v python3 >/dev/null 2>&1; then
    result=$(determinant_general 4 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)
    assert_equals "4x4 determinant" 0 "$result"
else
    echo -e "${YELLOW}⚠${RESET} Skipping 4x4 tests (Python not available)"
fi

# Test 5x5 identity determinant
echo -e "\n5x5 Identity Matrix:"
if command -v python3 >/dev/null 2>&1; then
    result=$(determinant_general 5 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1)
    assert_equals "5x5 identity determinant" 1 "$result"
else
    echo -e "${YELLOW}⚠${RESET} Skipping 5x5 tests (Python not available)"
fi

# Test matrix transpose
echo -e "\nMatrix Transpose:"
result=$(matrix_transpose_general 2 3 1 2 3 4 5 6)
expected="1 4 2 5 3 6"
if [ "$result" = "$expected" ]; then
    echo -e "${GREEN}✓${RESET} 2x3 transpose"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${RESET} 2x3 transpose"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Test matrix addition
echo -e "\nMatrix Addition:"
result=$(matrix_add_general 2 2 1 2 3 4 5 6 7 8)
result_arr=($result)
assert_equals "matrix add [0]" 6 "${result_arr[0]}"
assert_equals "matrix add [1]" 8 "${result_arr[1]}"
assert_equals "matrix add [2]" 10 "${result_arr[2]}"
assert_equals "matrix add [3]" 12 "${result_arr[3]}"

# Test 3x3 inverse
echo -e "\n3x3 Matrix Inverse:"
if command -v python3 >/dev/null 2>&1; then
    assert_success "3x3 inverse computation" matrix_inverse_general 3 2 1 0 0 2 1 1 0 1
else
    echo -e "${YELLOW}⚠${RESET} Skipping 3x3 inverse (Python not available)"
fi

# Test parse matrix
echo -e "\nMatrix Parsing:"
result=$(parse_matrix "[[1,2,3],[4,5,6]]")
expected="2 3 1 2 3 4 5 6"
if [ "$result" = "$expected" ]; then
    echo -e "${GREEN}✓${RESET} Matrix parsing"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${RESET} Matrix parsing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Summary
echo -e "\n${YELLOW}========================================${RESET}"
echo -e "Tests run: $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${RESET}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${RESET}"
    exit 1
else
    echo -e "${GREEN}All advanced matrix tests passed!${RESET}"
    exit 0
fi
