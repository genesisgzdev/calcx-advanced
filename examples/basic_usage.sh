#!/bin/bash
# Basic Usage Examples - CalcX Advanced
# Demonstrates practical command-line usage

CALCX="../calcx.sh"

echo "==================================================="
echo "CalcX Advanced - Basic Usage Examples"
echo "==================================================="
echo

# Scientific calculations
echo "1. Scientific Calculations"
echo "   Calculate pi to 20 decimal places:"
result=$($CALCX "scale=20; 4*a(1)")
echo "   π = $result"
echo

echo "   Calculate e (Euler's number):"
result=$($CALCX "e(1)")
echo "   e = $result"
echo

echo "   Natural logarithm of 10:"
result=$($CALCX "l(10)")
echo "   ln(10) = $result"
echo

# Financial calculations
echo "2. Financial Calculations"
echo "   Compound interest: \$5000 at 7% for 10 years"
result=$($CALCX "scale=2; 5000 * e(0.07 * 10)")
echo "   Future value: \$$result"
echo

# Physics calculations
echo "3. Physics Calculations"
echo "   Kinetic energy: mass=75kg, velocity=25m/s"
result=$($CALCX "scale=2; 0.5 * 75 * 25^2")
echo "   KE = $result Joules"
echo

echo "   Free fall distance after 5 seconds (g=9.8m/s²):"
result=$($CALCX "scale=2; 0.5 * 9.8 * 5^2")
echo "   Distance = $result meters"
echo

# Large number calculations
echo "4. Large Number Calculations"
echo "   2^1000 (first 50 digits):"
result=$($CALCX "2^1000" | head -c 50)
echo "   $result..."
echo

echo "   Factorial of 50:"
result=$($CALCX "import math; math.factorial(50)")
echo "   50! = $result"
echo

echo "==================================================="
echo "For more examples, see advanced_usage.sh"
echo "==================================================="
