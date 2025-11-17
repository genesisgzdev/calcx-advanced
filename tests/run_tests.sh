#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}======================================${RESET}"
echo -e "${BLUE}  CalcX Advanced - Test Suite${RESET}"
echo -e "${BLUE}======================================${RESET}\n"

# Get the directory where this script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to run tests in a directory
run_test_suite() {
    local suite_name="$1"
    local suite_dir="$2"

    if [ ! -d "$suite_dir" ]; then
        echo -e "${YELLOW}⚠ Warning: $suite_name directory not found${RESET}"
        return
    fi

    local tests_found=false
    for test in "$suite_dir"/*.sh; do
        if [ -f "$test" ]; then
            tests_found=true
            echo -e "${BLUE}Running:${RESET} $(basename "$test")"
            if bash "$test"; then
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                FAILED_TESTS=$((FAILED_TESTS + 1))
            fi
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
            echo "--------------------------------"
        fi
    done

    if [ "$tests_found" = false ]; then
        echo -e "${YELLOW}No tests found in $suite_name${RESET}\n"
    fi
}

# Run basic tests in current directory
echo -e "${YELLOW}=== Basic Tests ===${RESET}"
for test in "$TEST_DIR"/test_*.sh; do
    if [ -f "$test" ]; then
        echo -e "${BLUE}Running:${RESET} $(basename "$test")"
        if bash "$test"; then
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo "--------------------------------"
    fi
done

# Run unit tests
echo -e "\n${YELLOW}=== Unit Tests ===${RESET}"
run_test_suite "Unit Tests" "$TEST_DIR/unit"

# Run integration tests
echo -e "\n${YELLOW}=== Integration Tests ===${RESET}"
run_test_suite "Integration Tests" "$TEST_DIR/integration"

# Run benchmark tests
echo -e "\n${YELLOW}=== Benchmark Tests ===${RESET}"
run_test_suite "Benchmark Tests" "$TEST_DIR/benchmark"

# Summary
echo -e "\n${BLUE}======================================${RESET}"
echo -e "${BLUE}  Test Summary${RESET}"
echo -e "${BLUE}======================================${RESET}"
echo -e "Total test suites: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${RESET}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed: ${FAILED_TESTS}${RESET}"
    echo -e "\n${RED}Some tests failed!${RESET}"
    exit 1
else
    echo -e "${RED}Failed: ${FAILED_TESTS}${RESET}"
    echo -e "\n${GREEN}All tests passed!${RESET}"
    exit 0
fi
