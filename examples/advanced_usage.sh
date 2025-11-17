#!/bin/bash
# Advanced Usage Examples - CalcX Advanced
# Demonstrates library functions and complex operations

source ../lib/math_functions.sh
source ../lib/conversions.sh
source ../lib/matrix.sh

echo "==================================================="
echo "CalcX Advanced - Advanced Usage Examples"
echo "==================================================="
echo

# Number theory demonstrations
echo "1. Number Theory Operations"
echo "   Factorial calculations:"
for n in 5 10 15 20; do
    result=$(factorial $n)
    echo "   $n! = $result"
done
echo

echo "   Fibonacci sequence (first 15):"
echo -n "   "
fibonacci 15
echo

echo "   Prime number analysis (1-50):"
primes=()
for n in {1..50}; do
    if is_prime $n; then
        primes+=($n)
    fi
done
echo "   Primes found: ${primes[@]}"
echo "   Total: ${#primes[@]} primes"
echo

echo "   GCD and LCM examples:"
pairs=("48 18" "100 150" "84 96")
for pair in "${pairs[@]}"; do
    read a b <<< "$pair"
    g=$(gcd $a $b)
    l=$(lcm $a $b)
    echo "   GCD($a, $b) = $g, LCM($a, $b) = $l"
done
echo

# Unit conversion demonstrations
echo "2. Unit Conversion Examples"
echo "   Temperature conversions:"
echo "   100°C = $(celsius_to_fahrenheit 100)°F"
echo "   32°F = $(fahrenheit_to_celsius 32)°C"
echo "   373.15K = $(kelvin_to_celsius 373.15)°C"
echo

echo "   Distance conversions (Marathon):"
marathon_miles=26.2
marathon_km=$(miles_to_kilometers $marathon_miles)
marathon_m=$(echo "scale=2; $marathon_km * 1000" | bc)
echo "   Marathon: $marathon_miles miles = ${marathon_km} km = ${marathon_m} meters"
echo

echo "   Data storage conversions:"
sizes=(1024 2048 4096 8192)
for bytes in "${sizes[@]}"; do
    kb=$(bytes_to_kilobytes $bytes)
    echo "   $bytes bytes = $kb KB"
done
echo

# Matrix operations
echo "3. Matrix Operations"
echo "   2x2 Matrix operations:"
echo "   Matrix A = [[3, 8], [4, 6]]"
det=$(determinant_2x2 3 8 4 6)
echo "   Determinant: $det"

echo
echo "   Matrix B = [[4, 7], [2, 6]]"
det=$(determinant_2x2 4 7 2 6)
echo "   Determinant: $det"

inverse=$(inverse_2x2 4 7 2 6)
echo "   Inverse:"
format_matrix_2x2 $inverse

echo
echo "   Matrix multiplication:"
echo "   [[1, 2], [3, 4]] × [[5, 6], [7, 8]]"
result=$(multiply_2x2 1 2 3 4 5 6 7 8)
format_matrix_2x2 $result

echo
echo "   3x3 Matrix operations:"
echo "   Matrix C = [[6, 1, 1], [4, -2, 5], [2, 8, 7]]"
det=$(determinant_3x3 6 1 1 4 -2 5 2 8 7)
echo "   Determinant: $det"
echo

# Natural language conversions
echo "4. Natural Language Conversions"
conversions=(
    "100 celsius to fahrenheit"
    "50 miles to kilometers"
    "1024 megabytes to gigabytes"
    "75 kilograms to pounds"
    "100 kph to mps"
)

for conv in "${conversions[@]}"; do
    result=$(convert "$conv")
    echo "   $conv = $result"
done
echo

echo "==================================================="
echo "All examples completed successfully!"
echo "==================================================="
