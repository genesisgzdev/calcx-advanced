#!/bin/bash
echo "================================"
echo "CalcX Advanced - Test Suite"
echo "================================"
for test in test_*.sh; do
    if [ -f "$test" ]; then
        echo "Running: $test"
        bash "$test"
        echo "--------------------------------"
    fi
done
echo "All tests completed!"
