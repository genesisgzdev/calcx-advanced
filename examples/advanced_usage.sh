#!/bin/bash
source ../lib/math_functions.sh

echo "Advanced Calculator Examples:"
echo "============================="
echo "Factorial of 5: $(factorial 5)"
echo "First 10 Fibonacci numbers:"
fibonacci 10
echo "GCD of 48 and 18: $(gcd 48 18)"
echo "LCM of 12 and 15: $(lcm 12 15)"
for n in 2 3 4 5 10 11 13 15 17 19 20; do
    if is_prime $n; then
        echo "$n is prime"
    else
        echo "$n is not prime"
    fi
done
