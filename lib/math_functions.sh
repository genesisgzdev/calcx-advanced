#!/bin/bash
# Mathematical Functions Library for CalcX Advanced

factorial() {
    local n=$1
    if [ $n -le 1 ]; then
        echo 1
    else
        echo $(($n * $(factorial $(($n - 1)))))
    fi
}

fibonacci() {
    local n=$1
    local a=0 b=1
    for ((i=0; i<n; i++)); do
        echo -n "$a "
        fn=$((a + b))
        a=$b
        b=$fn
    done
    echo
}

gcd() {
    local a=$1 b=$2
    while [ $b -ne 0 ]; do
        temp=$b
        b=$((a % b))
        a=$temp
    done
    echo $a
}

lcm() {
    local a=$1 b=$2
    echo $(($a * $b / $(gcd $a $b)))
}

is_prime() {
    local n=$1
    if [ $n -le 1 ]; then return 1; fi
    if [ $n -le 3 ]; then return 0; fi
    if [ $((n % 2)) -eq 0 ] || [ $((n % 3)) -eq 0 ]; then return 1; fi
    i=5
    while [ $((i * i)) -le $n ]; do
        if [ $((n % i)) -eq 0 ] || [ $((n % (i + 2))) -eq 0 ]; then
            return 1
        fi
        i=$((i + 6))
    done
    return 0
}

export -f factorial fibonacci gcd lcm is_prime
