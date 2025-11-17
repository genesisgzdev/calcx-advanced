#!/bin/bash
# Unit tests for lib/conversions.sh

# Source the conversions library
source "$(dirname "$0")/../../lib/conversions.sh"

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
    local tolerance="${4:-0.001}"  # Default tolerance for floating point comparison

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

echo -e "${YELLOW}Running Conversion Unit Tests${RESET}\n"

# Temperature conversion tests
echo "Temperature Conversions:"
result=$(celsius_to_fahrenheit 0)
assert_equals "0°C to Fahrenheit" 32 "$result"

result=$(celsius_to_fahrenheit 100)
assert_equals "100°C to Fahrenheit" 212 "$result"

result=$(fahrenheit_to_celsius 32)
assert_equals "32°F to Celsius" 0 "$result"

result=$(celsius_to_kelvin 0)
assert_equals "0°C to Kelvin" 273.15 "$result"

# Length conversion tests
echo -e "\nLength Conversions:"
result=$(miles_to_kilometers 1)
assert_equals "1 mile to kilometers" 1.609344 "$result"

result=$(meters_to_feet 1)
assert_equals "1 meter to feet" 3.28084 "$result"

result=$(inches_to_centimeters 1)
assert_equals "1 inch to centimeters" 2.54 "$result"

# Weight conversion tests
echo -e "\nWeight Conversions:"
result=$(kilograms_to_pounds 1)
assert_equals "1 kg to pounds" 2.20462 "$result"

result=$(pounds_to_kilograms 2.20462)
assert_equals "2.20462 lbs to kilograms" 1 "$result"

# Speed conversion tests
echo -e "\nSpeed Conversions:"
result=$(mph_to_kph 60)
assert_equals "60 mph to kph" 96.56064 "$result"

result=$(kph_to_mps 3.6)
assert_equals "3.6 kph to m/s" 1 "$result"

# Data conversion tests
echo -e "\nData Conversions:"
result=$(bytes_to_kilobytes 1024)
assert_equals "1024 bytes to KB" 1 "$result"

result=$(megabytes_to_gigabytes 1024)
assert_equals "1024 MB to GB" 1 "$result"

# Volume conversion tests
echo -e "\nVolume Conversions:"
result=$(liters_to_gallons 3.78541)
assert_equals "3.78541 liters to gallons" 1 "$result" 0.01

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
