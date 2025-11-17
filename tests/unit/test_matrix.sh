#!/bin/bash
# Unit tests for lib/matrix.sh

# Source the matrix library
source "$(dirname "$0")/../../lib/matrix.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Test helper function
assert_equals() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    local tolerance="${4:-0.001}"

    TESTS_RUN=$((TESTS_RUN + 1))

    # Compare with tolerance
    local diff=$(echo "scale=10; ($expected - $actual)" | bc -l)
    local abs_diff=$(echo "scale=10; if ($diff < 0) -$diff else $diff" | bc -l)
    local is_equal=$(echo "$abs_diff < $tolerance" | bc -l)

    if [ "$is_equal" -eq 1 ]; then
        echo -e "${GREEN}✓${RESET} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${RESET} $test_name"
        echo -e "  Expected: $expected"
        echo -e "  Got: $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo -e "${YELLOW}Running Matrix Unit Tests${RESET}\n"

# 2x2 Determinant tests
echo "2x2 Determinant:"
result=$(determinant_2x2 1 2 3 4)
assert_equals "det([[1,2],[3,4]])" -2 "$result"

result=$(determinant_2x2 4 7 2 6)
assert_equals "det([[4,7],[2,6]])" 10 "$result"

result=$(determinant_2x2 5 10 2 4)
assert_equals "det([[5,10],[2,4]]) - singular" 0 "$result"

# 3x3 Determinant tests
echo -e "\n3x3 Determinant:"
result=$(determinant_3x3 1 2 3 4 5 6 7 8 9)
assert_equals "det([[1,2,3],[4,5,6],[7,8,9]]) - singular" 0 "$result"

result=$(determinant_3x3 6 1 1 4 -2 5 2 8 7)
assert_equals "det(example matrix)" -306 "$result"

# 2x2 Matrix multiplication
echo -e "\n2x2 Matrix Multiplication:"
result=$(multiply_2x2 1 2 3 4 5 6 7 8)
# [[1,2],[3,4]] * [[5,6],[7,8]] = [[19,22],[43,50]]
result_arr=($result)
assert_equals "multiply result [0,0]" 19 "${result_arr[0]}"
assert_equals "multiply result [0,1]" 22 "${result_arr[1]}"
assert_equals "multiply result [1,0]" 43 "${result_arr[2]}"
assert_equals "multiply result [1,1]" 50 "${result_arr[3]}"

# 2x2 Matrix addition
echo -e "\n2x2 Matrix Addition:"
result=$(add_2x2 1 2 3 4 5 6 7 8)
result_arr=($result)
assert_equals "add result [0,0]" 6 "${result_arr[0]}"
assert_equals "add result [0,1]" 8 "${result_arr[1]}"
assert_equals "add result [1,0]" 10 "${result_arr[2]}"
assert_equals "add result [1,1]" 12 "${result_arr[3]}"

# 2x2 Scalar multiplication
echo -e "\n2x2 Scalar Multiplication:"
result=$(scalar_multiply_2x2 2 1 2 3 4)
result_arr=($result)
assert_equals "scalar multiply [0,0]" 2 "${result_arr[0]}"
assert_equals "scalar multiply [0,1]" 4 "${result_arr[1]}"
assert_equals "scalar multiply [1,0]" 6 "${result_arr[2]}"
assert_equals "scalar multiply [1,1]" 8 "${result_arr[3]}"

# 2x2 Transpose
echo -e "\n2x2 Transpose:"
result=$(transpose_2x2 1 2 3 4)
result_arr=($result)
assert_equals "transpose [0,0]" 1 "${result_arr[0]}"
assert_equals "transpose [0,1]" 3 "${result_arr[1]}"
assert_equals "transpose [1,0]" 2 "${result_arr[2]}"
assert_equals "transpose [1,1]" 4 "${result_arr[3]}"

# Identity matrix
echo -e "\nIdentity Matrices:"
result=$(identity_2x2)
result_arr=($result)
assert_equals "identity_2x2 [0,0]" 1 "${result_arr[0]}"
assert_equals "identity_2x2 [0,1]" 0 "${result_arr[1]}"
assert_equals "identity_2x2 [1,0]" 0 "${result_arr[2]}"
assert_equals "identity_2x2 [1,1]" 1 "${result_arr[3]}"

# Symmetry check
echo -e "\nSymmetry Check:"
if is_symmetric_2x2 1 2 2 4; then
    echo -e "${GREEN}✓${RESET} Symmetric matrix detected"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${RESET} Symmetric matrix not detected"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

if is_symmetric_2x2 1 2 3 4; then
    echo -e "${RED}✗${RESET} Non-symmetric matrix incorrectly detected as symmetric"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    echo -e "${GREEN}✓${RESET} Non-symmetric matrix correctly identified"
    TESTS_PASSED=$((TESTS_PASSED + 1))
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
    echo -e "${GREEN}All tests passed!${RESET}"
    exit 0
fi
