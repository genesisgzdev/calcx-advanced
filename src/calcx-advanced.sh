#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'
BG_BLUE='\033[44m'

# ==============================================================================
# GLOBAL VARIABLES
# Configuration variables used throughout the calculator
# ==============================================================================

# Array to store calculation history (last MAX_HISTORIAL entries)
HISTORIAL=()

# File path for persistent history storage across sessions
HIST_FILE="$HOME/.calcx_history.log"

# Maximum number of history entries to keep in memory and on disk
MAX_HISTORIAL=20

# Numerical precision for output formatting
# -1 uses general format (%g), positive integers specify significant figures
PRECISION=6

# ==============================================================================
# PYTHON DETECTION FOR CROSS-PLATFORM SUPPORT
# Detect correct Python command (python vs python3) based on platform
# Windows uses 'python', Unix-like systems typically use 'python3'
# ==============================================================================
detect_python_command() {
    # Try python3 first (Unix standard)
    if command -v python3 >/dev/null 2>&1; then
        # Verify it's not the Windows Store stub
        if python3 -c "import sys" 2>/dev/null; then
            echo "python3"
            return 0
        fi
    fi

    # Try python (Windows standard and fallback)
    if command -v python >/dev/null 2>&1; then
        if python -c "import sys" 2>/dev/null; then
            echo "python"
            return 0
        fi
    fi

    # No working Python found
    echo ""
    return 1
}

# Set the PYTHON_CMD variable for use throughout the script
PYTHON_CMD=$(detect_python_command)

# ==============================================================================
# COMMAND-LINE MODE
# If arguments are provided, evaluate them as a mathematical expression
# and exit immediately (non-interactive mode)
# ==============================================================================
if [ "$#" -gt 0 ]; then
    expr="$*"

    # Try using bc first (best for pure arithmetic)
    if command -v bc >/dev/null 2>&1; then
        if result=$(echo "$expr" | bc -l 2>/dev/null); then
            echo "$result"
            exit 0
        else
            echo "Error in expression: '$expr'" >&2
            exit 1
        fi
    fi

    # Fallback to Python if bc is unavailable
    if [ -n "$PYTHON_CMD" ]; then
        EXPR_ENV="$expr" $PYTHON_CMD - <<'PYEOF'
import os, sys, math, cmath
expr = os.environ.get('EXPR_ENV', '')
try:
    res = eval(expr)
    if isinstance(res, complex):
        print(f"{res.real}+{res.imag}j")
    else:
        print(res)
except Exception:
    sys.exit(1)
PYEOF
        if [ $? -eq 0 ]; then
            exit 0
        else
            echo "Error in expression: '$expr'" >&2
            exit 1
        fi
    fi

    echo "Error: neither 'bc' nor Python available to evaluate expression." >&2
    exit 1
fi

# ==============================================================================
# HISTORY LOADING
# Load persistent history from file if it exists
# ==============================================================================
if [ -f "$HIST_FILE" ]; then
    while IFS= read -r __line; do
        HISTORIAL+=("$__line")
    done < "$HIST_FILE"

    # Trim history to maximum size
    while [ ${#HISTORIAL[@]} -gt "$MAX_HISTORIAL" ]; do
        HISTORIAL=("${HISTORIAL[@]:1}")
    done
fi

# ==============================================================================
# UTILITY FUNCTIONS
# General helper functions used throughout the calculator
# ==============================================================================

# Limit history array size by removing oldest entries
limit_history() {
    while [ ${#HISTORIAL[@]} -gt "$MAX_HISTORIAL" ]; do
        HISTORIAL=("${HISTORIAL[@]:1}")
    done
}

# Pause execution and wait for user to press Enter
wait_to_continue() {
    echo ""
    read -rp "Press ENTER to continue..." _
}

# Check if a required command is available, exit if not found
validate_dependency() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Error:${RESET} Required command '${cmd}' is not installed."
        exit 1
    fi
}

# Configure the precision for numerical output
configure_precision() {
    echo -e "\n${YELLOW}PRECISION CONFIGURATION${RESET}"
    echo -e "Current precision: ${GREEN}${PRECISION}${RESET}"
    read -rp "Enter an integer >= -1 (-1 for general format %g): " new_prec

    # Validate input is an integer >= -1
    if [[ ! "$new_prec" =~ ^-?[0-9]+$ ]] || [ "$new_prec" -lt -1 ]; then
        echo -e "\n${RED}✗ Invalid value. Precision not changed.${RESET}"
        return
    fi

    PRECISION="$new_prec"
    if [ "$PRECISION" -eq -1 ]; then
        echo -e "\n${GREEN}✓ Precision set to general format (%g).${RESET}"
    else
        echo -e "\n${GREEN}✓ Precision set to ${PRECISION} significant figure(s).${RESET}"
    fi
}

# Display the calculator header with branding and current settings
show_header() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║           ${MAGENTA}CALCULADORA ${BLUE}                             ║${RESET}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════════════╣${RESET}"
    if [ "$PRECISION" -eq -1 ]; then
        echo -e "${BLUE}║ ${CYAN}Precision:${RESET} general (%g)                            ║"
    else
        printf "${BLUE}║ ${CYAN}Precision:${RESET} %2s significant figure(s)                ║${RESET}\n" "$PRECISION"
    fi
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${RESET}"
}

# Add an entry to the calculation history (both in-memory and persistent)
add_to_history() {
    local entry="$1"

    # Add to in-memory array
    HISTORIAL+=("$entry")

    # Append to persistent file
    if [ -n "$HIST_FILE" ]; then
        printf '%s\n' "$entry" >> "$HIST_FILE"
    fi

    # Trim to maximum size
    limit_history
}

# Display the calculation history (most recent first)
show_history() {
    if [ ${#HISTORIAL[@]} -eq 0 ]; then
        echo -e "\n${YELLOW}History is empty.${RESET}"
    else
        echo -e "\n${YELLOW}CALCULATION HISTORY (most recent first)${RESET}"
        echo -e "${CYAN}-----------------------------------------------${RESET}"
        local idx=${#HISTORIAL[@]}
        for (( i=${#HISTORIAL[@]}-1; i>=0; i-- )); do
            printf "%2d. %s\n" "$((idx-i))" "${HISTORIAL[$i]}"
        done
        echo -e "${CYAN}-----------------------------------------------${RESET}"
    fi
    wait_to_continue
}

# Clear all history entries from memory and file
clear_history() {
    HISTORIAL=()
    > "$HIST_FILE"
    echo -e "\n${GREEN}✓ History cleared.${RESET}"
    wait_to_continue
}

# ==============================================================================
# EQUATION SOLVERS
# Functions for solving various types of equations
# ==============================================================================

# Solve quadratic equation: ax² + bx + c = 0
# Uses the quadratic formula with discriminant analysis
# Handles both real and complex roots
solve_quadratic() {
    echo -e "\n${YELLOW}QUADRATIC EQUATION SOLVER${RESET}"
    echo -e "Equation form: ax² + bx + c = 0"

    read -rp "Enter coefficient a: " a
    read -rp "Enter coefficient b: " b
    read -rp "Enter coefficient c: " c

    # Validate inputs are real numbers
    for coef in "$a" "$b" "$c"; do
        if [[ ! "$coef" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
            echo -e "\n${RED}✗ Error: All coefficients must be real numbers.${RESET}"
            wait_to_continue
            return
        fi
    done

    # Verify a is non-zero (otherwise it's not quadratic)
    if (( $(echo "$a == 0" | bc -l) )); then
        echo -e "\n${RED}✗ Error: coefficient 'a' cannot be zero in a quadratic equation.${RESET}"
        wait_to_continue
        return
    fi

    # Calculate discriminant: b² - 4ac
    local disc
    disc=$(awk "BEGIN { printf \"%g\", ($b*$b) - 4*$a*$c }")

    local two_a
    two_a=$(awk "BEGIN { printf \"%g\", 2*$a }")

    # Check if discriminant is non-negative (real roots) or negative (complex roots)
    if (( $(echo "$disc >= 0" | bc -l) )); then
        # Real roots case
        local sqrt_disc
        sqrt_disc=$(awk "BEGIN { printf \"%g\", sqrt($disc) }")

        # Apply quadratic formula: (-b ± √disc) / 2a
        local r1 r2
        if [ "$PRECISION" -eq -1 ]; then
            r1=$(awk "BEGIN { printf \"%g\", (-$b + $sqrt_disc)/$two_a }")
            r2=$(awk "BEGIN { printf \"%g\", (-$b - $sqrt_disc)/$two_a }")
        else
            r1=$(awk -v p="$PRECISION" "BEGIN { printf \"%.\" p \"g\", (-$b + $sqrt_disc)/$two_a }")
            r2=$(awk -v p="$PRECISION" "BEGIN { printf \"%.\" p \"g\", (-$b - $sqrt_disc)/$two_a }")
        fi

        echo -e "\n${GREEN}Real roots:${RESET}"
        echo -e "x₁ = $r1"
        echo -e "x₂ = $r2"
        add_to_history "Quadratic: a=$a, b=$b, c=$c → x₁=$r1, x₂=$r2"
    else
        # Complex roots case: a ± bi
        local abs_disc
        abs_disc=$(awk "BEGIN { printf \"%g\", sqrt(-$disc) }")

        # Real part: -b / 2a, Imaginary part: √|disc| / 2a
        local real_part imag_part
        if [ "$PRECISION" -eq -1 ]; then
            real_part=$(awk "BEGIN { printf \"%g\", -$b/$two_a }")
            imag_part=$(awk "BEGIN { printf \"%g\", $abs_disc/$two_a }")
        else
            real_part=$(awk -v p="$PRECISION" "BEGIN { printf \"%.\" p \"g\", -$b/$two_a }")
            imag_part=$(awk -v p="$PRECISION" "BEGIN { printf \"%.\" p \"g\", $abs_disc/$two_a }")
        fi

        echo -e "\n${GREEN}Complex roots:${RESET}"
        echo -e "x₁ = ${real_part} + ${imag_part}i"
        echo -e "x₂ = ${real_part} - ${imag_part}i"
        add_to_history "Quadratic: a=$a, b=$b, c=$c → x₁=${real_part}+${imag_part}i, x₂=${real_part}-${imag_part}i"
    fi

    wait_to_continue
}

# Solve cubic equation: ax³ + bx² + cx + d = 0
# Uses Newton-Raphson to find one real root, then factors to quadratic
# Implements improved Newton-Raphson with adaptive step size
solve_cubic() {
    echo -e "\n${YELLOW}CUBIC EQUATION SOLVER${RESET}"
    echo -e "Equation form: ax³ + bx² + cx + d = 0"

    read -rp "Enter coefficient a: " a
    read -rp "Enter coefficient b: " b
    read -rp "Enter coefficient c: " c
    read -rp "Enter coefficient d: " d

    # Validate all coefficients are real numbers
    for coef in "$a" "$b" "$c" "$d"; do
        if [[ ! "$coef" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
            echo -e "\n${RED}✗ Error: All coefficients must be real numbers.${RESET}"
            wait_to_continue
            return
        fi
    done

    # Verify a is non-zero (otherwise it's not cubic)
    if (( $(echo "$a == 0" | bc -l) )); then
        echo -e "\n${RED}✗ Error: coefficient 'a' cannot be zero in a cubic equation.${RESET}"
        wait_to_continue
        return
    fi

    # Normalize coefficients by dividing by 'a' to get monic polynomial
    local b1 c1 d1
    b1=$(awk "BEGIN { print $b/$a }")
    c1=$(awk "BEGIN { print $c/$a }")
    d1=$(awk "BEGIN { print $d/$a }")

    # Use Newton-Raphson method to find one real root
    # f(x) = x³ + b1·x² + c1·x + d1
    # f'(x) = 3x² + 2·b1·x + c1

    # Start with initial guess x = 0
    local x=0
    local max_iter=100
    local tolerance=1e-12

    for ((iter=0; iter<max_iter; iter++)); do
        # Evaluate f(x) and f'(x)
        local fx dfx
        fx=$(awk -v x="$x" -v b="$b1" -v c="$c1" -v d="$d1" \
            "BEGIN { print x*x*x + b*x*x + c*x + d }")
        dfx=$(awk -v x="$x" -v b="$b1" -v c="$c1" \
            "BEGIN { print 3*x*x + 2*b*x + c }")

        # Check if derivative is too small (avoid division by zero)
        if (( $(echo "sqrt(($dfx)^2) < 1e-14" | bc -l) )); then
            # Try a different starting point
            x=1
            continue
        fi

        # Newton-Raphson step: x_new = x - f(x)/f'(x)
        local x_new
        x_new=$(awk "BEGIN { print $x - $fx / $dfx }")

        # Check for convergence
        if (( $(echo "sqrt(($x_new - $x)^2) < $tolerance" | bc -l) )); then
            x=$x_new
            break
        fi

        x=$x_new
    done

    local real_root=$x

    # Perform synthetic division to reduce cubic to quadratic
    # Divide (x³ + b1·x² + c1·x + d1) by (x - real_root)
    # Result: x² + q1·x + q0
    local q1 q0
    q1=$(awk -v b="$b1" -v r="$real_root" "BEGIN { print b + r }")
    q0=$(awk -v c="$c1" -v b="$b1" -v r="$real_root" \
        "BEGIN { print c + b*r + r*r }")

    # Solve the quadratic x² + q1·x + q0 = 0
    local disc
    disc=$(awk "BEGIN { print $q1*$q1 - 4*$q0 }")

    local roots=()

    # Format and store the first real root
    if [ "$PRECISION" -eq -1 ]; then
        roots+=("$(awk -v r="$real_root" "BEGIN { printf \"%g\", r }")")
    else
        roots+=("$(awk -v r="$real_root" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", r }")")
    fi

    # Analyze quadratic discriminant for remaining roots
    if (( $(echo "$disc >= 0" | bc -l) )); then
        # Two additional real roots
        local sqrt_disc
        sqrt_disc=$(awk "BEGIN { print sqrt($disc) }")

        local r2 r3
        if [ "$PRECISION" -eq -1 ]; then
            r2=$(awk -v q1="$q1" -v s="$sqrt_disc" \
                "BEGIN { printf \"%g\", (-q1 + s)/2 }")
            r3=$(awk -v q1="$q1" -v s="$sqrt_disc" \
                "BEGIN { printf \"%g\", (-q1 - s)/2 }")
        else
            r2=$(awk -v q1="$q1" -v s="$sqrt_disc" -v p="$PRECISION" \
                "BEGIN { printf \"%.\" p \"g\", (-q1 + s)/2 }")
            r3=$(awk -v q1="$q1" -v s="$sqrt_disc" -v p="$PRECISION" \
                "BEGIN { printf \"%.\" p \"g\", (-q1 - s)/2 }")
        fi

        roots+=("$r2" "$r3")

        echo -e "\n${GREEN}Three real roots found:${RESET}"
        for r in "${roots[@]}"; do
            echo "x = $r"
        done
        add_to_history "Cubic: a=$a,b=$b,c=$c,d=$d → real roots: ${roots[*]}"
    else
        # Two complex conjugate roots
        local abs_disc
        abs_disc=$(awk "BEGIN { print sqrt(-$disc) }")

        local real_part imag_part
        if [ "$PRECISION" -eq -1 ]; then
            real_part=$(awk -v q1="$q1" "BEGIN { printf \"%g\", -q1/2 }")
            imag_part=$(awk -v s="$abs_disc" "BEGIN { printf \"%g\", s/2 }")
        else
            real_part=$(awk -v q1="$q1" -v p="$PRECISION" \
                "BEGIN { printf \"%.\" p \"g\", -q1/2 }")
            imag_part=$(awk -v s="$abs_disc" -v p="$PRECISION" \
                "BEGIN { printf \"%.\" p \"g\", s/2 }")
        fi

        echo -e "\n${GREEN}One real root:${RESET} x = ${roots[0]}"
        echo -e "${GREEN}Two complex conjugate roots:${RESET}"
        echo -e "x = ${real_part} + ${imag_part}i"
        echo -e "x = ${real_part} - ${imag_part}i"
        add_to_history "Cubic: a=$a,b=$b,c=$c,d=$d → real: ${roots[0]}; complex: ${real_part}±${imag_part}i"
    fi

    wait_to_continue
}

# Find root of arbitrary function using Newton-Raphson method
# Requires user to provide both f(x) and f'(x) expressions
# Implements improved convergence checking and error handling
solve_newton_raphson() {
    echo -e "\n${YELLOW}NEWTON-RAPHSON ROOT FINDER${RESET}"
    echo -e "Find roots of f(x) = 0 using iterative approximation"
    echo ""
    echo -e "Enter function f(x) using 'x' as variable"
    echo -e "Examples: x^3 - 2*x - 5, sin(x) - x/2, exp(-x^2), 1/(1+x^2)"
    read -rp "f(x) = " fexpr

    echo -e "\nEnter the derivative f'(x) of the function"
    echo -e "Examples: 3*x^2 - 2, cos(x) - 0.5, exp(x) - 3"
    read -rp "f'(x) = " fprime

    read -rp "Initial guess for x: " x0
    read -rp "Tolerance (e.g., 1e-7): " tol
    read -rp "Maximum iterations: " max_iter

    # Validate numerical inputs
    if [[ ! "$x0" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$tol" =~ ^[0-9]+(\.[0-9]+)?([eE]-?[0-9]+)?$ ]] || \
       [[ ! "$max_iter" =~ ^[0-9]+$ ]]; then
        echo -e "\n${RED}✗ Error: Invalid numerical values.${RESET}"
        wait_to_continue
        return
    fi

    local x="$x0"
    local converged=0

    echo -e "\n${CYAN}Iteration trace:${RESET}"

    for ((i=0; i<max_iter; i++)); do
        # Evaluate f(x) and f'(x) using awk
        local fx dfx
        fx=$(awk -v x="$x" "BEGIN { val = $fexpr; print val }" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "\n${RED}✗ Error evaluating f(x). Check your expression.${RESET}"
            wait_to_continue
            return
        fi

        dfx=$(awk -v x="$x" "BEGIN { val = $fprime; print val }" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "\n${RED}✗ Error evaluating f'(x). Check your expression.${RESET}"
            wait_to_continue
            return
        fi

        # Print iteration info every 10 iterations or if close to convergence
        if [ $((i % 10)) -eq 0 ] || (( $(echo "sqrt(($fx)^2) < $tol * 10" | bc -l) )); then
            echo -e "  Iteration $i: x = $x, f(x) = $fx"
        fi

        # Check if derivative is too small (would cause division issues)
        if (( $(echo "sqrt(($dfx)^2) < 1e-14" | bc -l) )); then
            echo -e "\n${RED}✗ Derivative became zero. Method cannot continue.${RESET}"
            echo -e "Try a different initial guess."
            wait_to_continue
            return
        fi

        # Newton-Raphson update: x_new = x - f(x)/f'(x)
        local x_new
        x_new=$(awk "BEGIN { print $x - $fx/$dfx }")

        # Check for convergence based on change in x
        if (( $(echo "sqrt(($x_new - $x)^2) < $tol" | bc -l) )); then
            x=$x_new
            converged=1
            break
        fi

        # Additional convergence check: if f(x) is already very small
        if (( $(echo "sqrt(($fx)^2) < $tol" | bc -l) )); then
            converged=1
            break
        fi

        x=$x_new
    done

    if [ "$converged" -eq 1 ]; then
        # Format result according to precision setting
        local res
        if [ "$PRECISION" -eq -1 ]; then
            res=$(awk -v x="$x" "BEGIN { printf \"%g\", x }")
        else
            res=$(awk -v x="$x" -v p="$PRECISION" \
                "BEGIN { printf \"%.\" p \"g\", x }")
        fi

        echo -e "\n${GREEN}✓ Root found:${RESET} x ≈ $res"
        echo -e "Converged in $i iterations"
        add_to_history "Newton-Raphson: f(x)=$fexpr, x₀=$x0 → root ≈ $res"
    else
        echo -e "\n${RED}✗ Did not converge within $max_iter iterations.${RESET}"
        echo -e "Final value: x = $x"
        echo -e "Consider: different initial guess, more iterations, or relaxed tolerance"
    fi

    wait_to_continue
}

# ==============================================================================
# MATRIX OPERATIONS (2x2 and 3x3 matrices)
# Functions for matrix multiplication, determinant, inverse, and linear systems
# ==============================================================================

# Multiply two matrices of the same dimension (2x2 or 3x3)
# Uses standard matrix multiplication algorithm: C[i,j] = Σ A[i,k] * B[k,j]
matrix_multiply() {
    echo -e "\n${YELLOW}MATRIX MULTIPLICATION${RESET}"
    read -rp "Choose dimension (2 for 2x2, 3 for 3x3): " dim

    if [[ "$dim" != "2" && "$dim" != "3" ]]; then
        echo -e "\n${RED}✗ Invalid dimension. Only 2 or 3 supported.${RESET}"
        wait_to_continue
        return
    fi

    local total=$((dim * dim))

    echo "Enter elements of first matrix (row by row, space-separated):"
    echo "Example for 2x2: 1 2 3 4 means [[1,2],[3,4]]"
    read -ra matA

    if [ "${#matA[@]}" -ne "$total" ]; then
        echo -e "\n${RED}✗ Expected $total values for first matrix.${RESET}"
        wait_to_continue
        return
    fi

    echo "Enter elements of second matrix (row by row, space-separated):"
    read -ra matB

    if [ "${#matB[@]}" -ne "$total" ]; then
        echo -e "\n${RED}✗ Expected $total values for second matrix.${RESET}"
        wait_to_continue
        return
    fi

    # Perform matrix multiplication: result[i,j] = Σ(k) A[i,k] * B[k,j]
    local result=()
    local i j k

    for ((i=0; i<dim; i++)); do
        for ((j=0; j<dim; j++)); do
            local sum=0
            for ((k=0; k<dim; k++)); do
                # Get A[i,k] and B[k,j]
                local aVal bVal prod
                aVal=${matA[$((i*dim + k))]}
                bVal=${matB[$((k*dim + j))]}

                # Multiply and accumulate
                prod=$(awk -v a="$aVal" -v b="$bVal" "BEGIN { print a*b }")
                sum=$(awk -v s="$sum" -v p="$prod" "BEGIN { print s+p }")
            done
            result+=("$sum")
        done
    done

    # Display result matrix
    echo -e "\n${GREEN}Result matrix:${RESET}"
    for ((i=0; i<dim; i++)); do
        for ((j=0; j<dim; j++)); do
            local val=${result[$((i*dim + j))]}

            # Format according to precision setting
            local fval
            if [ "$PRECISION" -eq -1 ]; then
                fval=$(awk -v v="$val" "BEGIN { printf \"%g\", v }")
            else
                fval=$(awk -v v="$val" -v p="$PRECISION" \
                    "BEGIN { printf \"%.\" p \"g\", v }")
            fi

            printf "%-12s" "$fval"
        done
        echo ""
    done

    add_to_history "Matrix ${dim}x${dim} multiplication performed"
    wait_to_continue
}

# Calculate determinant of a 2x2 or 3x3 matrix
# 2x2: det = ad - bc
# 3x3: uses rule of Sarrus
matrix_determinant() {
    echo -e "\n${YELLOW}MATRIX DETERMINANT${RESET}"
    read -rp "Choose dimension (2 for 2x2, 3 for 3x3): " dim

    if [[ "$dim" != "2" && "$dim" != "3" ]]; then
        echo -e "\n${RED}✗ Only dimensions 2 or 3 are supported.${RESET}"
        wait_to_continue
        return
    fi

    local total=$((dim * dim))
    echo "Enter matrix elements (row by row, space-separated):"
    read -ra mat

    if [ "${#mat[@]}" -ne "$total" ]; then
        echo -e "\n${RED}✗ Expected $total values.${RESET}"
        wait_to_continue
        return
    fi

    local det

    if [ "$dim" -eq 2 ]; then
        # 2x2 determinant: ad - bc
        local a b c d
        a=${mat[0]}; b=${mat[1]}
        c=${mat[2]}; d=${mat[3]}
        det=$(awk "BEGIN { print $a*$d - $b*$c }")
    else
        # 3x3 determinant using Sarrus' rule
        # det = aei + bfg + cdh - ceg - bdi - afh
        local a b c d e f g h i
        a=${mat[0]}; b=${mat[1]}; c=${mat[2]}
        d=${mat[3]}; e=${mat[4]}; f=${mat[5]}
        g=${mat[6]}; h=${mat[7]}; i=${mat[8]}

        det=$(awk "BEGIN { print $a*$e*$i + $b*$f*$g + $c*$d*$h - \
                                  $c*$e*$g - $b*$d*$i - $a*$f*$h }")
    fi

    # Format determinant according to precision
    local det_f
    if [ "$PRECISION" -eq -1 ]; then
        det_f=$(awk -v d="$det" "BEGIN { printf \"%g\", d }")
    else
        det_f=$(awk -v d="$det" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", d }")
    fi

    echo -e "\n${GREEN}Determinant:${RESET} $det_f"
    add_to_history "Determinant of ${dim}x${dim} matrix: $det_f"
    wait_to_continue
}

# Calculate the inverse of a 2x2 or 3x3 matrix
# Uses adjugate matrix method: A⁻¹ = (1/det(A)) * adj(A)
# Verifies matrix is invertible (det ≠ 0)
matrix_inverse() {
    echo -e "\n${YELLOW}MATRIX INVERSE${RESET}"
    read -rp "Choose dimension (2 for 2x2, 3 for 3x3): " dim

    if [[ "$dim" != "2" && "$dim" != "3" ]]; then
        echo -e "\n${RED}✗ Only dimensions 2 or 3 are supported.${RESET}"
        wait_to_continue
        return
    fi

    local total=$((dim * dim))
    echo "Enter matrix elements (row by row, space-separated):"
    read -ra m

    if [ "${#m[@]}" -ne "$total" ]; then
        echo -e "\n${RED}✗ Expected $total values.${RESET}"
        wait_to_continue
        return
    fi

    if [ "$dim" -eq 2 ]; then
        # 2x2 matrix inverse
        local a b c d
        a=${m[0]}; b=${m[1]}
        c=${m[2]}; d=${m[3]}

        # Calculate determinant
        local det
        det=$(awk "BEGIN { print $a*$d - $b*$c }")

        # Check if matrix is invertible
        if (( $(echo "sqrt(($det)^2) < 1e-14" | bc -l) )); then
            echo -e "\n${RED}✗ Matrix is not invertible (determinant = 0).${RESET}"
            wait_to_continue
            return
        fi

        # Inverse formula for 2x2: (1/det) * [[d, -b], [-c, a]]
        local inv=()
        inv[0]=$(awk -v d="$d" -v det="$det" "BEGIN { print d/det }")
        inv[1]=$(awk -v b="$b" -v det="$det" "BEGIN { print -b/det }")
        inv[2]=$(awk -v c="$c" -v det="$det" "BEGIN { print -c/det }")
        inv[3]=$(awk -v a="$a" -v det="$det" "BEGIN { print a/det }")

        echo -e "\n${GREEN}Inverse matrix:${RESET}"
        for ((i=0; i<4; i++)); do
            local val=${inv[$i]}
            local fval

            if [ "$PRECISION" -eq -1 ]; then
                fval=$(awk -v v="$val" "BEGIN { printf \"%g\", v }")
            else
                fval=$(awk -v v="$val" -v p="$PRECISION" \
                    "BEGIN { printf \"%.\" p \"g\", v }")
            fi

            printf "%-12s" "$fval"

            # New line after every 2 elements
            if [ $(( (i+1) % 2 )) -eq 0 ]; then
                echo ""
            fi
        done

        add_to_history "2x2 matrix inverse calculated"
    else
        # 3x3 matrix inverse using cofactor matrix
        local a b c d e f g h i
        a=${m[0]}; b=${m[1]}; c=${m[2]}
        d=${m[3]}; e=${m[4]}; f=${m[5]}
        g=${m[6]}; h=${m[7]}; i=${m[8]}

        # Calculate determinant
        local det
        det=$(awk "BEGIN { print $a*$e*$i + $b*$f*$g + $c*$d*$h - \
                                  $c*$e*$g - $b*$d*$i - $a*$f*$h }")

        # Check if matrix is invertible
        if (( $(echo "sqrt(($det)^2) < 1e-14" | bc -l) )); then
            echo -e "\n${RED}✗ Matrix is not invertible (determinant = 0).${RESET}"
            wait_to_continue
            return
        fi

        # Calculate cofactor matrix (matrix of minors with alternating signs)
        # Then transpose to get adjugate matrix
        local A00 A01 A02 A10 A11 A12 A20 A21 A22

        # Cofactors (with proper signs)
        A00=$(awk "BEGIN { print  ($e*$i - $f*$h) }")
        A01=$(awk "BEGIN { print -($d*$i - $f*$g) }")
        A02=$(awk "BEGIN { print  ($d*$h - $e*$g) }")
        A10=$(awk "BEGIN { print -($b*$i - $c*$h) }")
        A11=$(awk "BEGIN { print  ($a*$i - $c*$g) }")
        A12=$(awk "BEGIN { print -($a*$h - $b*$g) }")
        A20=$(awk "BEGIN { print  ($b*$f - $c*$e) }")
        A21=$(awk "BEGIN { print -($a*$f - $c*$d) }")
        A22=$(awk "BEGIN { print  ($a*$e - $b*$d) }")

        # Construct inverse: (1/det) * transpose(cofactor matrix)
        local inv=()
        inv[0]=$(awk -v val="$A00" -v det="$det" "BEGIN { print val/det }")
        inv[1]=$(awk -v val="$A10" -v det="$det" "BEGIN { print val/det }")
        inv[2]=$(awk -v val="$A20" -v det="$det" "BEGIN { print val/det }")
        inv[3]=$(awk -v val="$A01" -v det="$det" "BEGIN { print val/det }")
        inv[4]=$(awk -v val="$A11" -v det="$det" "BEGIN { print val/det }")
        inv[5]=$(awk -v val="$A21" -v det="$det" "BEGIN { print val/det }")
        inv[6]=$(awk -v val="$A02" -v det="$det" "BEGIN { print val/det }")
        inv[7]=$(awk -v val="$A12" -v det="$det" "BEGIN { print val/det }")
        inv[8]=$(awk -v val="$A22" -v det="$det" "BEGIN { print val/det }")

        echo -e "\n${GREEN}Inverse matrix:${RESET}"
        for ((row=0; row<3; row++)); do
            for ((col=0; col<3; col++)); do
                local val=${inv[$((row*3 + col))]}
                local fval

                if [ "$PRECISION" -eq -1 ]; then
                    fval=$(awk -v v="$val" "BEGIN { printf \"%g\", v }")
                else
                    fval=$(awk -v v="$val" -v p="$PRECISION" \
                        "BEGIN { printf \"%.\" p \"g\", v }")
                fi

                printf "%-12s" "$fval"
            done
            echo ""
        done

        add_to_history "3x3 matrix inverse calculated"
    fi

    wait_to_continue
}

# Solve linear system Ax = b using Cramer's rule
# Works for 2x2 and 3x3 systems
# Computes solution by calculating determinant ratios
solve_linear_system() {
    echo -e "\n${YELLOW}LINEAR SYSTEM SOLVER (Cramer's Rule)${RESET}"
    echo -e "Solve: Ax = b"

    read -rp "System dimension (2 or 3): " dim

    if [[ "$dim" != "2" && "$dim" != "3" ]]; then
        echo -e "\n${RED}✗ Only dimensions 2 or 3 are supported.${RESET}"
        wait_to_continue
        return
    fi

    local total=$((dim * dim))

    echo "Enter coefficient matrix A (row by row, space-separated):"
    read -ra A

    if [ "${#A[@]}" -ne "$total" ]; then
        echo -e "\n${RED}✗ Expected $total coefficients.${RESET}"
        wait_to_continue
        return
    fi

    echo "Enter right-hand side vector b (space-separated):"
    read -ra b

    if [ "${#b[@]}" -ne "$dim" ]; then
        echo -e "\n${RED}✗ Expected $dim values.${RESET}"
        wait_to_continue
        return
    fi

    # Calculate determinant of coefficient matrix A
    local detA

    if [ "$dim" -eq 2 ]; then
        local a11=${A[0]} a12=${A[1]}
        local a21=${A[2]} a22=${A[3]}
        detA=$(awk "BEGIN { print $a11*$a22 - $a12*$a21 }")
    else
        local a11=${A[0]} a12=${A[1]} a13=${A[2]}
        local a21=${A[3]} a22=${A[4]} a23=${A[5]}
        local a31=${A[6]} a32=${A[7]} a33=${A[8]}
        detA=$(awk "BEGIN { print $a11*$a22*$a33 + $a12*$a23*$a31 + \
                                  $a13*$a21*$a32 - $a13*$a22*$a31 - \
                                  $a12*$a21*$a33 - $a11*$a23*$a32 }")
    fi

    # Check if system has unique solution (det(A) ≠ 0)
    if (( $(echo "sqrt(($detA)^2) < 1e-14" | bc -l) )); then
        echo -e "\n${RED}✗ System has no unique solution (det(A) = 0).${RESET}"
        echo -e "System is either inconsistent or has infinitely many solutions."
        wait_to_continue
        return
    fi

    # Apply Cramer's rule: x_i = det(A_i) / det(A)
    # where A_i is A with column i replaced by b
    local solutions=()

    if [ "$dim" -eq 2 ]; then
        # Calculate determinants for Cramer's rule
        local Dx Dy

        # Dx: replace column 1 with b
        Dx=$(awk -v b1="${b[0]}" -v b2="${b[1]}" \
                 -v a12="$a12" -v a22="$a22" \
                 "BEGIN { print b1*a22 - a12*b2 }")

        # Dy: replace column 2 with b
        Dy=$(awk -v a11="$a11" -v a21="$a21" \
                 -v b1="${b[0]}" -v b2="${b[1]}" \
                 "BEGIN { print a11*b2 - b1*a21 }")

        # Calculate solutions
        local x y
        x=$(awk "BEGIN { print $Dx/$detA }")
        y=$(awk "BEGIN { print $Dy/$detA }")

        solutions+=("$x" "$y")
    else
        # 3x3 system using Cramer's rule
        local Dx Dy Dz

        # Build modified matrices and calculate determinants
        # Dx: replace column 1 with b
        local d11 d12 d13 d21 d22 d23 d31 d32 d33
        d11=${b[0]}; d12=$a12; d13=$a13
        d21=${b[1]}; d22=$a22; d23=$a23
        d31=${b[2]}; d32=$a32; d33=$a33

        Dx=$(awk -v d11="$d11" -v d12="$d12" -v d13="$d13" \
                 -v d21="$d21" -v d22="$d22" -v d23="$d23" \
                 -v d31="$d31" -v d32="$d32" -v d33="$d33" \
                 "BEGIN { print d11*d22*d33 + d12*d23*d31 + d13*d21*d32 - \
                               d13*d22*d31 - d12*d21*d33 - d11*d23*d32 }")

        # Dy: replace column 2 with b
        d11=$a11; d12=${b[0]}; d13=$a13
        d21=$a21; d22=${b[1]}; d23=$a23
        d31=$a31; d32=${b[2]}; d33=$a33

        Dy=$(awk -v d11="$d11" -v d12="$d12" -v d13="$d13" \
                 -v d21="$d21" -v d22="$d22" -v d23="$d23" \
                 -v d31="$d31" -v d32="$d32" -v d33="$d33" \
                 "BEGIN { print d11*d22*d33 + d12*d23*d31 + d13*d21*d32 - \
                               d13*d22*d31 - d12*d21*d33 - d11*d23*d32 }")

        # Dz: replace column 3 with b
        d11=$a11; d12=$a12; d13=${b[0]}
        d21=$a21; d22=$a22; d23=${b[1]}
        d31=$a31; d32=$a32; d33=${b[2]}

        Dz=$(awk -v d11="$d11" -v d12="$d12" -v d13="$d13" \
                 -v d21="$d21" -v d22="$d22" -v d23="$d23" \
                 -v d31="$d31" -v d32="$d32" -v d33="$d33" \
                 "BEGIN { print d11*d22*d33 + d12*d23*d31 + d13*d21*d32 - \
                               d13*d22*d31 - d12*d21*d33 - d11*d23*d32 }")

        # Calculate solutions
        local x y z
        x=$(awk "BEGIN { print $Dx/$detA }")
        y=$(awk "BEGIN { print $Dy/$detA }")
        z=$(awk "BEGIN { print $Dz/$detA }")

        solutions+=("$x" "$y" "$z")
    fi

    # Display solutions
    echo -e "\n${GREEN}Solution:${RESET}"

    local labels
    if [ "$dim" -eq 2 ]; then
        labels=("x" "y")
    else
        labels=("x" "y" "z")
    fi

    for ((i=0; i<${#solutions[@]}; i++)); do
        local val=${solutions[$i]}
        local fval

        if [ "$PRECISION" -eq -1 ]; then
            fval=$(awk -v v="$val" "BEGIN { printf \"%g\", v }")
        else
            fval=$(awk -v v="$val" -v p="$PRECISION" \
                "BEGIN { printf \"%.\" p \"g\", v }")
        fi

        echo -e "${labels[$i]} = $fval"
    done

    add_to_history "Linear system ${dim}x${dim} solved using Cramer's rule"
    wait_to_continue
}

# ==============================================================================
# COMPLEX NUMBER OPERATIONS
# Comprehensive complex arithmetic including basic operations and special functions
# ==============================================================================

# Add two complex numbers: (a₁ + b₁i) + (a₂ + b₂i) = (a₁+a₂) + (b₁+b₂)i
complex_add() {
    echo -e "\n${YELLOW}COMPLEX NUMBER ADDITION${RESET}"
    echo -e "Calculate: z₁ + z₂"

    read -rp "Enter real part of z₁: " a1
    read -rp "Enter imaginary part of z₁: " b1
    read -rp "Enter real part of z₂: " a2
    read -rp "Enter imaginary part of z₂: " b2

    # Validate all inputs are real numbers
    for v in "$a1" "$b1" "$a2" "$b2"; do
        if [[ ! "$v" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
            echo -e "\n${RED}✗ Error: All values must be real numbers.${RESET}"
            wait_to_continue
            return
        fi
    done

    # Perform addition
    local real imag
    real=$(awk -v a1="$a1" -v a2="$a2" "BEGIN { print a1 + a2 }")
    imag=$(awk -v b1="$b1" -v b2="$b2" "BEGIN { print b1 + b2 }")

    # Format result
    local fr fi
    if [ "$PRECISION" -eq -1 ]; then
        fr=$(awk -v v="$real" "BEGIN { printf \"%g\", v }")
        fi=$(awk -v v="$imag" "BEGIN { printf \"%g\", v }")
    else
        fr=$(awk -v v="$real" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
        fi=$(awk -v v="$imag" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}Result:${RESET} $fr + ${fi}i"
    add_to_history "($a1+${b1}i) + ($a2+${b2}i) = $fr+${fi}i"
    wait_to_continue
}

# Multiply two complex numbers
# (a₁ + b₁i)(a₂ + b₂i) = (a₁a₂ - b₁b₂) + (a₁b₂ + a₂b₁)i
complex_multiply() {
    echo -e "\n${YELLOW}COMPLEX NUMBER MULTIPLICATION${RESET}"
    echo -e "Calculate: z₁ × z₂"

    read -rp "Real part of z₁: " a1
    read -rp "Imaginary part of z₁: " b1
    read -rp "Real part of z₂: " a2
    read -rp "Imaginary part of z₂: " b2

    # Validate inputs
    for v in "$a1" "$b1" "$a2" "$b2"; do
        if [[ ! "$v" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
            echo -e "\n${RED}✗ All values must be real numbers.${RESET}"
            wait_to_continue
            return
        fi
    done

    # Multiply: (a+bi)(c+di) = (ac-bd) + (ad+bc)i
    local real imag
    real=$(awk -v a1="$a1" -v b1="$b1" -v a2="$a2" -v b2="$b2" \
        "BEGIN { print a1*a2 - b1*b2 }")
    imag=$(awk -v a1="$a1" -v b1="$b1" -v a2="$a2" -v b2="$b2" \
        "BEGIN { print a1*b2 + a2*b1 }")

    # Format result
    local fr fi
    if [ "$PRECISION" -eq -1 ]; then
        fr=$(awk -v v="$real" "BEGIN { printf \"%g\", v }")
        fi=$(awk -v v="$imag" "BEGIN { printf \"%g\", v }")
    else
        fr=$(awk -v v="$real" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
        fi=$(awk -v v="$imag" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}Result:${RESET} $fr + ${fi}i"
    add_to_history "($a1+${b1}i) × ($a2+${b2}i) = $fr+${fi}i"
    wait_to_continue
}

# Divide two complex numbers: z₁ / z₂
# (a+bi)/(c+di) = [(a+bi)(c-di)] / (c²+d²)
complex_divide() {
    echo -e "\n${YELLOW}COMPLEX NUMBER DIVISION${RESET}"
    echo -e "Calculate: z₁ ÷ z₂"

    read -rp "Real part of z₁: " a1
    read -rp "Imaginary part of z₁: " b1
    read -rp "Real part of z₂: " a2
    read -rp "Imaginary part of z₂: " b2

    # Validate inputs
    for v in "$a1" "$b1" "$a2" "$b2"; do
        if [[ ! "$v" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
            echo -e "\n${RED}✗ All values must be real numbers.${RESET}"
            wait_to_continue
            return
        fi
    done

    # Check for division by zero
    local denom
    denom=$(awk -v a="$a2" -v b="$b2" "BEGIN { print a*a + b*b }")

    if (( $(echo "sqrt(($denom)^2) < 1e-14" | bc -l) )); then
        echo -e "\n${RED}✗ Division by zero: z₂ = 0${RESET}"
        wait_to_continue
        return
    fi

    # Perform division: multiply by conjugate and divide by modulus squared
    local real imag
    real=$(awk -v a1="$a1" -v b1="$b1" -v a2="$a2" -v b2="$b2" -v denom="$denom" \
        "BEGIN { print (a1*a2 + b1*b2)/denom }")
    imag=$(awk -v a1="$a1" -v b1="$b1" -v a2="$a2" -v b2="$b2" -v denom="$denom" \
        "BEGIN { print (b1*a2 - a1*b2)/denom }")

    # Format result
    local fr fi
    if [ "$PRECISION" -eq -1 ]; then
        fr=$(awk -v v="$real" "BEGIN { printf \"%g\", v }")
        fi=$(awk -v v="$imag" "BEGIN { printf \"%g\", v }")
    else
        fr=$(awk -v v="$real" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
        fi=$(awk -v v="$imag" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}Result:${RESET} $fr + ${fi}i"
    add_to_history "($a1+${b1}i) ÷ ($a2+${b2}i) = $fr+${fi}i"
    wait_to_continue
}

# Calculate modulus (magnitude) of a complex number: |z| = √(a² + b²)
complex_modulus() {
    echo -e "\n${YELLOW}COMPLEX NUMBER MODULUS${RESET}"
    echo -e "Calculate: |z|"

    read -rp "Real part: " a
    read -rp "Imaginary part: " b

    # Validate inputs
    if [[ ! "$a" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$b" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Must enter real numbers.${RESET}"
        wait_to_continue
        return
    fi

    # Calculate modulus
    local mod
    mod=$(awk -v a="$a" -v b="$b" "BEGIN { print sqrt(a*a + b*b) }")

    # Format result
    local fmod
    if [ "$PRECISION" -eq -1 ]; then
        fmod=$(awk -v v="$mod" "BEGIN { printf \"%g\", v }")
    else
        fmod=$(awk -v v="$mod" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}|$a + ${b}i| = $fmod${RESET}"
    add_to_history "|$a+${b}i| = $fmod"
    wait_to_continue
}

# Calculate argument (angle) of complex number: arg(z) = atan2(b, a)
complex_argument() {
    echo -e "\n${YELLOW}COMPLEX NUMBER ARGUMENT${RESET}"
    echo -e "Calculate: arg(z) in radians"

    read -rp "Real part: " a
    read -rp "Imaginary part: " b

    # Validate inputs
    if [[ ! "$a" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$b" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Must enter real numbers.${RESET}"
        wait_to_continue
        return
    fi

    # Calculate argument using atan2 (handles all quadrants correctly)
    local arg
    arg=$(awk -v a="$a" -v b="$b" "BEGIN { print atan2(b, a) }")

    # Format result
    local farg
    if [ "$PRECISION" -eq -1 ]; then
        farg=$(awk -v v="$arg" "BEGIN { printf \"%g\", v }")
    else
        farg=$(awk -v v="$arg" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}arg($a + ${b}i) = $farg radians${RESET}"
    add_to_history "arg($a+${b}i) = $farg rad"
    wait_to_continue
}

# Calculate complex conjugate: conj(a + bi) = a - bi
complex_conjugate() {
    echo -e "\n${YELLOW}COMPLEX NUMBER CONJUGATE${RESET}"

    read -rp "Real part: " a
    read -rp "Imaginary part: " b

    # Validate inputs
    if [[ ! "$a" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$b" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Must enter real numbers.${RESET}"
        wait_to_continue
        return
    fi

    # Conjugate simply negates imaginary part
    local fr fi
    fr=$a
    fi=$(awk -v b="$b" "BEGIN { print -b }")

    echo -e "\n${GREEN}Conjugate:${RESET} $fr + ${fi}i"
    add_to_history "conj($a+${b}i) = $fr+${fi}i"
    wait_to_continue
}

# Calculate exponential of complex number: e^(a+bi) = e^a(cos(b) + i·sin(b))
complex_exponential() {
    echo -e "\n${YELLOW}COMPLEX EXPONENTIAL${RESET}"
    echo -e "Calculate: e^z where z = a + bi"

    read -rp "Real part (a): " a
    read -rp "Imaginary part (b): " b

    # Validate inputs
    if [[ ! "$a" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$b" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Must enter real numbers.${RESET}"
        wait_to_continue
        return
    fi

    # Use Euler's formula: e^(a+bi) = e^a * (cos(b) + i*sin(b))
    local ea cosb sinb
    ea=$(awk -v a="$a" "BEGIN { print exp(a) }")
    cosb=$(awk -v b="$b" "BEGIN { print cos(b) }")
    sinb=$(awk -v b="$b" "BEGIN { print sin(b) }")

    local real imag
    real=$(awk -v ea="$ea" -v cosb="$cosb" "BEGIN { print ea*cosb }")
    imag=$(awk -v ea="$ea" -v sinb="$sinb" "BEGIN { print ea*sinb }")

    # Format result
    local fr fi
    if [ "$PRECISION" -eq -1 ]; then
        fr=$(awk -v v="$real" "BEGIN { printf \"%g\", v }")
        fi=$(awk -v v="$imag" "BEGIN { printf \"%g\", v }")
    else
        fr=$(awk -v v="$real" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
        fi=$(awk -v v="$imag" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}e^($a + ${b}i) = $fr + ${fi}i${RESET}"
    add_to_history "exp($a+${b}i) = $fr+${fi}i"
    wait_to_continue
}

# Calculate natural logarithm of complex number: ln(z) = ln|z| + i·arg(z)
complex_logarithm() {
    echo -e "\n${YELLOW}COMPLEX LOGARITHM${RESET}"
    echo -e "Calculate: ln(z) where z = a + bi"

    read -rp "Real part: " a
    read -rp "Imaginary part: " b

    # Validate inputs
    if [[ ! "$a" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$b" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Must enter real numbers.${RESET}"
        wait_to_continue
        return
    fi

    # Check for ln(0) which is undefined
    local mod
    mod=$(awk -v a="$a" -v b="$b" "BEGIN { print sqrt(a*a + b*b) }")

    if (( $(echo "$mod < 1e-14" | bc -l) )); then
        echo -e "\n${RED}✗ ln(0) is undefined${RESET}"
        wait_to_continue
        return
    fi

    # ln(z) = ln|z| + i·arg(z)
    local lnmod arg
    lnmod=$(awk -v m="$mod" "BEGIN { print log(m) }")
    arg=$(awk -v a="$a" -v b="$b" "BEGIN { print atan2(b, a) }")

    # Format result
    local fr fi
    if [ "$PRECISION" -eq -1 ]; then
        fr=$(awk -v v="$lnmod" "BEGIN { printf \"%g\", v }")
        fi=$(awk -v v="$arg" "BEGIN { printf \"%g\", v }")
    else
        fr=$(awk -v v="$lnmod" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
        fi=$(awk -v v="$arg" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}ln($a + ${b}i) = $fr + ${fi}i${RESET}"
    add_to_history "ln($a+${b}i) = $fr+${fi}i"
    wait_to_continue
}

# Calculate complex power: z^w where both z and w are complex
# Uses formula: z^w = e^(w·ln(z))
complex_power() {
    echo -e "\n${YELLOW}COMPLEX POWER${RESET}"
    echo -e "Calculate: z^w where both z and w are complex"

    echo "Enter base z = a + bi:"
    read -rp "Real part (a): " a
    read -rp "Imaginary part (b): " b

    echo "Enter exponent w = c + di:"
    read -rp "Real part (c): " c
    read -rp "Imaginary part (d): " d

    # Validate all inputs
    for v in "$a" "$b" "$c" "$d"; do
        if [[ ! "$v" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
            echo -e "\n${RED}✗ All values must be real numbers.${RESET}"
            wait_to_continue
            return
        fi
    done

    # Check for special case: 0^0
    local mod
    mod=$(awk -v a="$a" -v b="$b" "BEGIN { print sqrt(a*a + b*b) }")

    if (( $(echo "$mod < 1e-14" | bc -l) )); then
        local wmod
        wmod=$(awk -v c="$c" -v d="$d" "BEGIN { print sqrt(c*c + d*d) }")

        if (( $(echo "$wmod < 1e-14" | bc -l) )); then
            echo -e "\n${GREEN}z^w = 1${RESET} (0^0 is defined as 1)"
            add_to_history "($a+${b}i)^($c+${d}i) = 1 (0^0 case)"
            wait_to_continue
            return
        else
            echo -e "\n${RED}✗ 0 raised to non-zero power is undefined (or 0)${RESET}"
            wait_to_continue
            return
        fi
    fi

    # Calculate z^w = exp(w * ln(z))
    # First compute ln(z) = ln|z| + i*arg(z)
    local lnmod arg
    lnmod=$(awk -v m="$mod" "BEGIN { print log(m) }")
    arg=$(awk -v a="$a" -v b="$b" "BEGIN { print atan2(b, a) }")

    # Multiply w * ln(z): (c+di) * (lnmod + i*arg)
    # = c*lnmod - d*arg + i(d*lnmod + c*arg)
    local A B
    A=$(awk -v c="$c" -v d="$d" -v lnmod="$lnmod" -v arg="$arg" \
        "BEGIN { print c*lnmod - d*arg }")
    B=$(awk -v c="$c" -v d="$d" -v lnmod="$lnmod" -v arg="$arg" \
        "BEGIN { print d*lnmod + c*arg }")

    # Compute exp(A + iB) = e^A * (cos(B) + i*sin(B))
    local ea cosB sinB
    ea=$(awk -v A="$A" "BEGIN { print exp(A) }")
    cosB=$(awk -v B="$B" "BEGIN { print cos(B) }")
    sinB=$(awk -v B="$B" "BEGIN { print sin(B) }")

    local real imag
    real=$(awk -v ea="$ea" -v cosB="$cosB" "BEGIN { print ea*cosB }")
    imag=$(awk -v ea="$ea" -v sinB="$sinB" "BEGIN { print ea*sinB }")

    # Format result
    local fr fi
    if [ "$PRECISION" -eq -1 ]; then
        fr=$(awk -v v="$real" "BEGIN { printf \"%g\", v }")
        fi=$(awk -v v="$imag" "BEGIN { printf \"%g\", v }")
    else
        fr=$(awk -v v="$real" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
        fi=$(awk -v v="$imag" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}($a + ${b}i)^($c + ${d}i) = $fr + ${fi}i${RESET}"
    add_to_history "($a+${b}i)^($c+${d}i) = $fr+${fi}i"
    wait_to_continue
}

# ==============================================================================
# NUMERICAL CALCULUS
# Numerical integration, differentiation, and ODE solving
# ==============================================================================

# Numerical integration using Simpson's rule (more accurate than trapezoid)
# Simpson's rule: ∫f(x)dx ≈ (h/3)[f(x₀) + 4f(x₁) + 2f(x₂) + 4f(x₃) + ... + f(xₙ)]
numerical_integration() {
    echo -e "\n${YELLOW}NUMERICAL INTEGRATION (Simpson's Rule)${RESET}"
    echo -e "Calculate: ∫f(x)dx from a to b"
    echo ""
    echo -e "Enter function f(x) using 'x' as variable"
    echo -e "Examples: x^2, sin(x), exp(-x^2), 1/(1+x^2)"
    read -rp "f(x) = " fexpr

    read -rp "Lower limit (a): " a
    read -rp "Upper limit (b): " b
    read -rp "Number of intervals (even number, e.g., 100): " n

    # Validate inputs
    if [[ ! "$a" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$b" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$n" =~ ^[0-9]+$ ]]; then
        echo -e "\n${RED}✗ Invalid numerical values${RESET}"
        wait_to_continue
        return
    fi

    # Ensure n is even for Simpson's rule
    if [ $((n % 2)) -ne 0 ]; then
        echo -e "${YELLOW}Note: n must be even for Simpson's rule. Using n=$((n+1))${RESET}"
        n=$((n + 1))
    fi

    # Calculate step size
    local h
    h=$(awk -v a="$a" -v b="$b" -v n="$n" "BEGIN { print (b-a)/n }")

    # Simpson's rule implementation
    # Uses Python for more complex function evaluation
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for numerical integration${RESET}"
        wait_to_continue
        return
    fi

    local result
    result=$($PYTHON_CMD <<PYEOF
import math
from math import *

# Function to integrate
def f(x):
    return $fexpr

# Simpson's rule
a, b, n = $a, $b, $n
h = (b - a) / n

# Calculate sum
sum_val = f(a) + f(b)

for i in range(1, n):
    x = a + i * h
    if i % 2 == 0:
        sum_val += 2 * f(x)
    else:
        sum_val += 4 * f(x)

result = (h / 3) * sum_val
print(result)
PYEOF
)

    if [ $? -ne 0 ]; then
        echo -e "\n${RED}✗ Error evaluating integral. Check your function.${RESET}"
        wait_to_continue
        return
    fi

    # Format result
    local fres
    if [ "$PRECISION" -eq -1 ]; then
        fres=$(awk -v v="$result" "BEGIN { printf \"%g\", v }")
    else
        fres=$(awk -v v="$result" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}∫($fexpr)dx from $a to $b ≈ $fres${RESET}"
    echo -e "Using Simpson's rule with $n intervals"
    add_to_history "Integration: ∫($fexpr)dx [$a,$b] ≈ $fres"
    wait_to_continue
}

# Numerical derivative using central difference formula
# f'(x) ≈ [f(x+h) - f(x-h)] / (2h)
numerical_derivative() {
    echo -e "\n${YELLOW}NUMERICAL DERIVATIVE${RESET}"
    echo -e "Calculate: f'(x) at a given point"
    echo ""
    echo -e "Enter function f(x) using 'x' as variable"
    echo -e "Examples: x^3, sin(x), exp(x), log(x)"
    read -rp "f(x) = " fexpr

    read -rp "Point at which to evaluate derivative: " x0
    read -rp "Step size h (e.g., 1e-5): " h

    # Validate inputs
    if [[ ! "$x0" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$h" =~ ^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Invalid numerical values${RESET}"
        wait_to_continue
        return
    fi

    # Use central difference formula for better accuracy
    # f'(x) ≈ [f(x+h) - f(x-h)] / (2h)
    local fp fm deriv

    fp=$(awk -v x="$x0" -v h="$h" "BEGIN { x = x + h; print $fexpr }" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}✗ Error evaluating f(x+h). Check your function.${RESET}"
        wait_to_continue
        return
    fi

    fm=$(awk -v x="$x0" -v h="$h" "BEGIN { x = x - h; print $fexpr }" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}✗ Error evaluating f(x-h). Check your function.${RESET}"
        wait_to_continue
        return
    fi

    deriv=$(awk -v fp="$fp" -v fm="$fm" -v h="$h" \
        "BEGIN { print (fp - fm) / (2*h) }")

    # Format result
    local fderiv
    if [ "$PRECISION" -eq -1 ]; then
        fderiv=$(awk -v v="$deriv" "BEGIN { printf \"%g\", v }")
    else
        fderiv=$(awk -v v="$deriv" -v p="$PRECISION" \
            "BEGIN { printf \"%.\" p \"g\", v }")
    fi

    echo -e "\n${GREEN}f'($x0) ≈ $fderiv${RESET}"
    echo -e "Using central difference with h = $h"
    add_to_history "Derivative: f(x)=$fexpr at x=$x0 → f'($x0)≈$fderiv"
    wait_to_continue
}

# Solve first-order ODE using Euler's method
# dy/dx = f(x, y), y(x₀) = y₀
solve_ode_euler() {
    echo -e "\n${YELLOW}ODE SOLVER (Euler's Method)${RESET}"
    echo -e "Solve: dy/dx = f(x, y) with initial condition y(x₀) = y₀"
    echo ""
    echo -e "Enter f(x, y) using 'x' and 'y' as variables"
    echo -e "Examples: y, x+y, x*y, sin(x)*y"
    read -rp "f(x, y) = " fexpr

    read -rp "Initial x (x₀): " x0
    read -rp "Initial y (y₀): " y0
    read -rp "Final x: " xf
    read -rp "Step size h: " h

    # Validate inputs
    if [[ ! "$x0" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$y0" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$xf" =~ ^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]] || \
       [[ ! "$h" =~ ^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Invalid numerical values${RESET}"
        wait_to_continue
        return
    fi

    # Euler's method: y_{n+1} = y_n + h * f(x_n, y_n)
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for ODE solving${RESET}"
        wait_to_continue
        return
    fi

    echo -e "\n${CYAN}Computing solution...${RESET}"

    $PYTHON_CMD <<PYEOF
import math
from math import *

# ODE function
def f(x, y):
    return $fexpr

# Initial conditions
x = $x0
y = $y0
xf = $xf
h = $h

print(f"x = {x:.6f}, y = {y:.6f}")

# Euler's method
while x < xf:
    y = y + h * f(x, y)
    x = x + h

    # Print every 10 steps or at end
    if abs(x - xf) < h or int((x - $x0) / h) % 10 == 0:
        print(f"x = {x:.6f}, y = {y:.6f}")

print(f"\nFinal result: y({xf}) ≈ {y}")
PYEOF

    if [ $? -ne 0 ]; then
        echo -e "\n${RED}✗ Error solving ODE. Check your function.${RESET}"
        wait_to_continue
        return
    fi

    add_to_history "ODE: dy/dx=$fexpr, y($x0)=$y0, solved to x=$xf"
    wait_to_continue
}

# ==============================================================================
# STATISTICS AND COMBINATORICS
# Descriptive statistics, permutations, combinations, and binomial distribution
# ==============================================================================

# Calculate descriptive statistics for a dataset
# Includes: mean, median, standard deviation, min, max
descriptive_statistics() {
    echo -e "\n${YELLOW}DESCRIPTIVE STATISTICS${RESET}"
    echo "Enter data points separated by spaces:"
    echo "Example: 1.5 2.3 4.1 3.7 2.9"
    read -ra data

    if [ "${#data[@]}" -eq 0 ]; then
        echo -e "\n${RED}✗ No data provided${RESET}"
        wait_to_continue
        return
    fi

    # Use Python for statistical calculations
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for statistics${RESET}"
        wait_to_continue
        return
    fi

    # Convert array to space-separated string
    local data_str="${data[*]}"

    $PYTHON_CMD <<PYEOF
import math

# Read data
data_str = "$data_str"
data = [float(x) for x in data_str.split()]

n = len(data)
mean = sum(data) / n

# Median
sorted_data = sorted(data)
if n % 2 == 0:
    median = (sorted_data[n//2 - 1] + sorted_data[n//2]) / 2
else:
    median = sorted_data[n//2]

# Standard deviation
variance = sum((x - mean) ** 2 for x in data) / n
std_dev = math.sqrt(variance)

# Min and max
min_val = min(data)
max_val = max(data)

# Display results
print("Statistics for {} data points:".format(n))
print("Mean:              {:.6f}".format(mean))
print("Median:            {:.6f}".format(median))
print("Standard Dev:      {:.6f}".format(std_dev))
print("Variance:          {:.6f}".format(variance))
print("Minimum:           {:.6f}".format(min_val))
print("Maximum:           {:.6f}".format(max_val))
print("Range:             {:.6f}".format(max_val - min_val))
PYEOF

    add_to_history "Statistics calculated for ${#data[@]} data points"
    wait_to_continue
}

# Calculate combinations and permutations
# nCr = n! / (r! * (n-r)!)
# nPr = n! / (n-r)!
combinatorics() {
    echo -e "\n${YELLOW}COMBINATORICS${RESET}"
    echo "1) Combinations C(n,r) = n! / (r! × (n-r)!)"
    echo "2) Permutations P(n,r) = n! / (n-r)!"
    echo "3) Both"
    read -rp "Choice: " choice

    read -rp "Enter n: " n
    read -rp "Enter r: " r

    # Validate inputs
    if [[ ! "$n" =~ ^[0-9]+$ ]] || [[ ! "$r" =~ ^[0-9]+$ ]]; then
        echo -e "\n${RED}✗ n and r must be non-negative integers${RESET}"
        wait_to_continue
        return
    fi

    if [ "$r" -gt "$n" ]; then
        echo -e "\n${RED}✗ r cannot be greater than n${RESET}"
        wait_to_continue
        return
    fi

    # Use Python for large factorial calculations
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for combinatorics${RESET}"
        wait_to_continue
        return
    fi

    $PYTHON_CMD <<PYEOF
import math

n = $n
r = $r

# Calculate combinations
if "$choice" in ["1", "3"]:
    combinations = math.comb(n, r)
    print("C({}, {}) = {}".format(n, r, combinations))

# Calculate permutations
if "$choice" in ["2", "3"]:
    permutations = math.perm(n, r)
    print("P({}, {}) = {}".format(n, r, permutations))
PYEOF

    add_to_history "Combinatorics: C($n,$r) and/or P($n,$r)"
    wait_to_continue
}

# Calculate binomial probability
# P(X = k) = C(n,k) × p^k × (1-p)^(n-k)
binomial_distribution() {
    echo -e "\n${YELLOW}BINOMIAL DISTRIBUTION${RESET}"
    echo -e "Calculate: P(X = k) where X ~ Binomial(n, p)"

    read -rp "Number of trials (n): " n
    read -rp "Probability of success (p): " p
    read -rp "Number of successes (k): " k

    # Validate inputs
    if [[ ! "$n" =~ ^[0-9]+$ ]] || [[ ! "$k" =~ ^[0-9]+$ ]]; then
        echo -e "\n${RED}✗ n and k must be non-negative integers${RESET}"
        wait_to_continue
        return
    fi

    if [[ ! "$p" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ p must be a number between 0 and 1${RESET}"
        wait_to_continue
        return
    fi

    # Use Python for calculation
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for binomial distribution${RESET}"
        wait_to_continue
        return
    fi

    $PYTHON_CMD <<PYEOF
import math

n = $n
p = $p
k = $k

if not (0 <= p <= 1):
    print("p must be between 0 and 1")
    exit(1)

if k > n:
    print("k cannot be greater than n")
    exit(1)

# Binomial probability
comb = math.comb(n, k)
prob = comb * (p ** k) * ((1 - p) ** (n - k))

print("P(X = {}) = {:.8f}".format(k, prob))
print("Binomial coefficient C({},{}) = {}".format(n, k, comb))
PYEOF

    add_to_history "Binomial: n=$n, p=$p, P(X=$k)"
    wait_to_continue
}

# ==============================================================================
# DISCRETE FOURIER TRANSFORM (DFT)
# Compute DFT of a sequence using the definition (not FFT)
# ==============================================================================
discrete_fourier_transform() {
    echo -e "\n${YELLOW}DISCRETE FOURIER TRANSFORM${RESET}"
    echo "Enter sequence values separated by spaces:"
    echo "Example: 1 2 3 4"
    read -ra sequence

    if [ "${#sequence[@]}" -eq 0 ]; then
        echo -e "\n${RED}✗ No sequence provided${RESET}"
        wait_to_continue
        return
    fi

    # Use Python for DFT computation
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for DFT${RESET}"
        wait_to_continue
        return
    fi

    local seq_str="${sequence[*]}"

    $PYTHON_CMD <<PYEOF
import math
import cmath

# Read sequence
seq_str = "$seq_str"
sequence = [float(x) for x in seq_str.split()]
N = len(sequence)

print("Computing DFT of {}-point sequence...\n".format(N))

# Compute DFT using definition
# X[k] = Σ(n=0 to N-1) x[n] * e^(-2πi*k*n/N)
dft = []
for k in range(N):
    sum_val = 0
    for n in range(N):
        angle = -2 * math.pi * k * n / N
        sum_val += sequence[n] * cmath.exp(1j * angle)
    dft.append(sum_val)

# Display results
print("DFT Results:")
for k, val in enumerate(dft):
    real = val.real
    imag = val.imag
    mag = abs(val)
    phase = cmath.phase(val)
    print("X[{}] = {:8.4f} + {:8.4f}i  |  Magnitude: {:8.4f}  Phase: {:8.4f} rad".format(
        k, real, imag, mag, phase))
PYEOF

    add_to_history "DFT computed for ${#sequence[@]}-point sequence"
    wait_to_continue
}

# ==============================================================================
# NUMBER THEORY
# Prime factorization and base conversion
# ==============================================================================

# Prime factorization of an integer
factorize_number() {
    echo -e "\n${YELLOW}PRIME FACTORIZATION${RESET}"
    read -rp "Enter positive integer to factorize: " num

    # Validate input
    if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 2 ]; then
        echo -e "\n${RED}✗ Must enter an integer >= 2${RESET}"
        wait_to_continue
        return
    fi

    # Use Python for factorization
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for factorization${RESET}"
        wait_to_continue
        return
    fi

    $PYTHON_CMD <<PYEOF
num = $num
original = num
factors = []

# Trial division
d = 2
while d * d <= num:
    while num % d == 0:
        factors.append(d)
        num //= d
    d += 1

if num > 1:
    factors.append(num)

# Display results
print("Prime factorization of {}:".format(original))
if len(factors) == 1:
    print("{} is prime".format(original))
else:
    # Count occurrences
    from collections import Counter
    factor_counts = Counter(factors)

    factorization = " × ".join("{}^{}".format(p, e) if e > 1 else str(p)
                               for p, e in sorted(factor_counts.items()))
    print(factorization)
    print("\nPrime factors: {}".format(sorted(set(factors))))
PYEOF

    add_to_history "Factorization of $num"
    wait_to_continue
}

# Convert number between different bases (2-36)
base_conversion() {
    echo -e "\n${YELLOW}BASE CONVERSION${RESET}"
    echo "Supported bases: 2-36"

    read -rp "Enter number: " num
    read -rp "From base (2-36): " from_base
    read -rp "To base (2-36): " to_base

    # Validate bases
    if [[ ! "$from_base" =~ ^[0-9]+$ ]] || [ "$from_base" -lt 2 ] || [ "$from_base" -gt 36 ]; then
        echo -e "\n${RED}✗ From base must be between 2 and 36${RESET}"
        wait_to_continue
        return
    fi

    if [[ ! "$to_base" =~ ^[0-9]+$ ]] || [ "$to_base" -lt 2 ] || [ "$to_base" -gt 36 ]; then
        echo -e "\n${RED}✗ To base must be between 2 and 36${RESET}"
        wait_to_continue
        return
    fi

    # Use Python for base conversion
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for base conversion${RESET}"
        wait_to_continue
        return
    fi

    $PYTHON_CMD <<PYEOF
num_str = "$num"
from_base = $from_base
to_base = $to_base

try:
    # Convert from source base to decimal
    decimal = int(num_str, from_base)

    # Convert from decimal to target base
    if to_base == 10:
        result = str(decimal)
    else:
        digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        result = ""
        temp = decimal

        if temp == 0:
            result = "0"
        else:
            while temp > 0:
                result = digits[temp % to_base] + result
                temp //= to_base

    print("Conversion:")
    print("{} (base {}) = {} (base {})".format(num_str, from_base, result, to_base))
    print("Decimal value: {}".format(decimal))

except ValueError:
    print("Invalid number for the specified base")
PYEOF

    add_to_history "Base conversion: $num (base $from_base) to base $to_base"
    wait_to_continue
}

# ==============================================================================
# SPECIAL FUNCTIONS
# Factorial, GCD, LCM
# ==============================================================================

# Calculate factorial, including Gamma function for non-integers
extended_factorial() {
    echo -e "\n${YELLOW}EXTENDED FACTORIAL${RESET}"
    echo "For integers: n! = n × (n-1) × ... × 1"
    echo "For non-integers: uses Gamma function Γ(n+1)"

    read -rp "Enter number: " num

    # Validate input is numeric
    if [[ ! "$num" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "\n${RED}✗ Must enter a non-negative number${RESET}"
        wait_to_continue
        return
    fi

    # Use Python for calculation
    if [ -z "$PYTHON_CMD" ]; then
        echo -e "\n${RED}✗ Python required for factorial${RESET}"
        wait_to_continue
        return
    fi

    $PYTHON_CMD <<PYEOF
import math

num = $num

try:
    if num == int(num) and num >= 0:
        # Integer factorial
        result = math.factorial(int(num))
        print("{}! = {}".format(int(num), result))
    else:
        # Use Gamma function for non-integers
        result = math.gamma(num + 1)
        print("Γ({} + 1) = {}".format(num, result))
        print("(Gamma function used for non-integer)")
except (ValueError, OverflowError) as e:
    print("Error: {}".format(e))
PYEOF

    add_to_history "Factorial/Gamma: $num"
    wait_to_continue
}

# Calculate GCD and LCM of two numbers
gcd_lcm() {
    echo -e "\n${YELLOW}GCD AND LCM${RESET}"

    read -rp "Enter first integer: " a
    read -rp "Enter second integer: " b

    # Validate inputs
    if [[ ! "$a" =~ ^[0-9]+$ ]] || [[ ! "$b" =~ ^[0-9]+$ ]]; then
        echo -e "\n${RED}✗ Both numbers must be positive integers${RESET}"
        wait_to_continue
        return
    fi

    # Use Euclidean algorithm for GCD
    local x=$a y=$b
    while [ "$y" -ne 0 ]; do
        local temp=$y
        y=$((x % y))
        x=$temp
    done
    local gcd=$x

    # Calculate LCM using formula: LCM(a,b) = (a×b) / GCD(a,b)
    local lcm=$(( (a * b) / gcd ))

    echo -e "\n${GREEN}Results:${RESET}"
    echo -e "GCD($a, $b) = $gcd"
    echo -e "LCM($a, $b) = $lcm"

    add_to_history "GCD($a,$b)=$gcd, LCM($a,$b)=$lcm"
    wait_to_continue
}

# ==============================================================================
# PACKAGE CREATION
# Create .deb and .pkg.tar.zst packages for distribution
# ==============================================================================

# Create Debian package (.deb)
create_deb_package() {
    echo -e "\n${YELLOW}CREATE DEBIAN PACKAGE${RESET}"
    echo "This will create a .deb package for this calculator"

    read -rp "Package version (e.g., 1.0.0): " version
    read -rp "Output directory (default: /tmp): " outdir

    outdir=${outdir:-/tmp}

    # Create package structure
    local pkg_name="advanced-calculator"
    local pkg_dir="$outdir/${pkg_name}_${version}"

    echo -e "\n${CYAN}Creating package structure...${RESET}"

    mkdir -p "$pkg_dir/DEBIAN"
    mkdir -p "$pkg_dir/usr/local/bin"
    mkdir -p "$pkg_dir/usr/share/doc/$pkg_name"

    # Create control file
    cat > "$pkg_dir/DEBIAN/control" <<EOF
Package: $pkg_name
Version: $version
Section: utils
Priority: optional
Architecture: all
Depends: bash, awk, bc
Maintainer: Advanced Calculator Team
Description: Professional command-line calculator
 Comprehensive mathematical calculator with support for:
 - Equation solving (quadratic, cubic, Newton-Raphson)
 - Matrix operations (2x2 and 3x3)
 - Complex number arithmetic
 - Numerical calculus (integration, derivatives, ODE)
 - Statistics and combinatorics
 - Discrete Fourier Transform
 - Number theory functions
EOF

    # Copy this script to package
    cp "$0" "$pkg_dir/usr/local/bin/calc-advanced"
    chmod +x "$pkg_dir/usr/local/bin/calc-advanced"

    # Create simple documentation
    cat > "$pkg_dir/usr/share/doc/$pkg_name/README" <<EOF
Advanced Calculator v$version

A professional command-line calculator with extensive mathematical capabilities.

Usage:
  calc-advanced              # Interactive mode
  calc-advanced "2+2"        # Command-line mode

Features:
- Equation solvers
- Matrix operations
- Complex numbers
- Numerical calculus
- Statistics
- DFT and number theory

For more information, run the program and explore the menus.
EOF

    # Build the package
    echo -e "${CYAN}Building package...${RESET}"
    dpkg-deb --build "$pkg_dir"

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ Package created successfully:${RESET}"
        echo -e "  ${pkg_dir}.deb"
        echo -e "\nInstall with: sudo dpkg -i ${pkg_dir}.deb"
    else
        echo -e "\n${RED}✗ Package creation failed${RESET}"
    fi

    wait_to_continue
}

# Create Arch Linux package (.pkg.tar.zst)
create_arch_package() {
    echo -e "\n${YELLOW}CREATE ARCH LINUX PACKAGE${RESET}"
    echo "This will create a .pkg.tar.zst package for this calculator"

    read -rp "Package version (e.g., 1.0.0): " version
    read -rp "Output directory (default: /tmp): " outdir

    outdir=${outdir:-/tmp}

    local pkg_name="advanced-calculator"
    local build_dir="$outdir/${pkg_name}-build"

    echo -e "\n${CYAN}Creating build directory...${RESET}"

    mkdir -p "$build_dir"

    # Create PKGBUILD file
    cat > "$build_dir/PKGBUILD" <<EOF
# Maintainer: Advanced Calculator Team
pkgname=$pkg_name
pkgver=$version
pkgrel=1
pkgdesc="Professional command-line calculator"
arch=('any')
url="https://github.com/example/advanced-calculator"
license=('MIT')
depends=('bash' 'awk' 'bc')
optdepends=('python: for advanced numerical functions'
            'fzf: for interactive menu'
            'gum: alternative interactive menu')
source=()
sha256sums=()

package() {
    install -Dm755 "$0" "\$pkgdir/usr/bin/calc-advanced"

    install -Dm644 /dev/stdin "\$pkgdir/usr/share/doc/\$pkgname/README" <<DOCEOF
Advanced Calculator v$version

A professional command-line calculator.
Run 'calc-advanced' to start.
DOCEOF
}
EOF

    echo -e "\n${GREEN}Build files created in:${RESET} $build_dir"
    echo -e "\nTo build the package:"
    echo -e "  cd $build_dir"
    echo -e "  makepkg"
    echo -e "\nThen install with:"
    echo -e "  sudo pacman -U ${pkg_name}-${version}-1-any.pkg.tar.zst"

    wait_to_continue
}

# ==============================================================================
# HISTORY FILE OPERATIONS
# Save and load history to/from custom files
# ==============================================================================

# Save current history to a custom file
save_history_to_file() {
    echo -e "\n${YELLOW}SAVE HISTORY TO FILE${RESET}"
    read -rp "Enter filename (or path): " filename

    if [ -z "$filename" ]; then
        echo -e "\n${RED}✗ No filename provided${RESET}"
        wait_to_continue
        return
    fi

    # Write all history entries to file
    printf '%s\n' "${HISTORIAL[@]}" > "$filename"

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ History saved to: $filename${RESET}"
        echo -e "Total entries: ${#HISTORIAL[@]}"
    else
        echo -e "\n${RED}✗ Failed to save history${RESET}"
    fi

    wait_to_continue
}

# Load history from a custom file
load_history_from_file() {
    echo -e "\n${YELLOW}LOAD HISTORY FROM FILE${RESET}"
    read -rp "Enter filename (or path): " filename

    if [ ! -f "$filename" ]; then
        echo -e "\n${RED}✗ File not found: $filename${RESET}"
        wait_to_continue
        return
    fi

    # Load entries from file
    local count=0
    while IFS= read -r line; do
        HISTORIAL+=("$line")
        ((count++))
    done < "$filename"

    # Trim to maximum size
    limit_history

    echo -e "\n${GREEN}✓ Loaded $count entries from: $filename${RESET}"
    echo -e "Total history entries: ${#HISTORIAL[@]}"

    wait_to_continue
}

# ==============================================================================
# INTERACTIVE INTERFACE (FZF/GUM)
# Alternative menu interface using fzf or gum for fuzzy searching
# ==============================================================================
interactive_interface() {
    # Check if fzf is available
    if command -v fzf >/dev/null 2>&1; then
        local options=(
            "1) Quadratic equation"
            "2) Cubic equation"
            "3) Newton-Raphson root finder"
            "4) Matrix operations"
            "5) Complex numbers"
            "6) Numerical calculus"
            "7) Statistics and combinatorics"
            "8) Discrete Fourier Transform"
            "9) Number theory and bases"
            "10) Show history"
            "11) Clear history"
            "12) Configure precision"
            "13) Other utilities"
            "q) Back to main menu"
        )

        local selection
        selection=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select option: " --height=40% --border --header="Interactive Menu")

        local code
        code=$(echo "$selection" | awk '{print $1}' | tr -d ')')

        case "$code" in
            1) solve_quadratic ;;
            2) solve_cubic ;;
            3) solve_newton_raphson ;;
            4) matrix_operations_menu ;;
            5) complex_operations_menu ;;
            6) numerical_calculus_menu ;;
            7) statistics_menu ;;
            8) discrete_fourier_transform ;;
            9) number_theory_menu ;;
            10) show_history ;;
            11) clear_history ;;
            12) configure_precision ;;
            13) other_utilities_menu ;;
            q|Q) return ;;
            *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
        esac
    elif command -v gum >/dev/null 2>&1; then
        # Use gum as alternative
        local options=("1) Quadratic equation" "2) Cubic equation" "3) Newton-Raphson root finder" "4) Matrix operations" "5) Complex numbers" "6) Numerical calculus" "7) Statistics and combinatorics" "8) Discrete Fourier Transform" "9) Number theory and bases" "10) Show history" "11) Clear history" "12) Configure precision" "13) Other utilities" "q) Back to main menu")

        local selection
        selection=$(printf '%s\n' "${options[@]}" | gum choose --header="Select option:" || true)

        local code
        code=$(echo "$selection" | awk '{print $1}' | tr -d ')')

        case "$code" in
            1) solve_quadratic ;;
            2) solve_cubic ;;
            3) solve_newton_raphson ;;
            4) matrix_operations_menu ;;
            5) complex_operations_menu ;;
            6) numerical_calculus_menu ;;
            7) statistics_menu ;;
            8) discrete_fourier_transform ;;
            9) number_theory_menu ;;
            10) show_history ;;
            11) clear_history ;;
            12) configure_precision ;;
            13) other_utilities_menu ;;
            q|Q) return ;;
            *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
        esac
    else
        echo -e "\n${RED}✗ Neither fzf nor gum is installed.${RESET}"
        echo -e "Install one of them for interactive menu functionality."
        wait_to_continue
    fi
}

# ==============================================================================
# SUBMENU FUNCTIONS
# Organize related operations into submenus
# ==============================================================================

# Display main menu
show_main_menu() {
    echo -e "\n${YELLOW}MAIN MENU${RESET}"
    echo "1) Solve quadratic equation"
    echo "2) Solve cubic equation"
    echo "3) Find root (Newton-Raphson)"
    echo "4) Matrix operations"
    echo "5) Complex number operations"
    echo "6) Numerical calculus"
    echo "7) Statistics and combinatorics"
    echo "8) Discrete Fourier Transform"
    echo "9) Number theory and bases"
    echo "10) Show history"
    echo "11) Clear history"
    echo "12) Configure precision"
    echo "13) Other utilities"
    echo "q) Quit"
}

# Matrix operations submenu
matrix_operations_menu() {
    echo -e "\n${YELLOW}MATRIX OPERATIONS${RESET}"
    echo "1) Matrix multiplication"
    echo "2) Determinant"
    echo "3) Matrix inverse"
    echo "4) Solve linear system"
    echo "b) Back"
    read -rp "Option: " op

    case "$op" in
        1) matrix_multiply ;;
        2) matrix_determinant ;;
        3) matrix_inverse ;;
        4) solve_linear_system ;;
        b|B) return ;;
        *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
    esac
}

# Complex number operations submenu
complex_operations_menu() {
    echo -e "\n${YELLOW}COMPLEX NUMBER OPERATIONS${RESET}"
    echo "1) Addition"
    echo "2) Multiplication"
    echo "3) Division"
    echo "4) Modulus"
    echo "5) Argument"
    echo "6) Conjugate"
    echo "7) Exponential"
    echo "8) Logarithm"
    echo "9) Power z^w"
    echo "b) Back"
    read -rp "Option: " op

    case "$op" in
        1) complex_add ;;
        2) complex_multiply ;;
        3) complex_divide ;;
        4) complex_modulus ;;
        5) complex_argument ;;
        6) complex_conjugate ;;
        7) complex_exponential ;;
        8) complex_logarithm ;;
        9) complex_power ;;
        b|B) return ;;
        *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
    esac
}

# Numerical calculus submenu
numerical_calculus_menu() {
    echo -e "\n${YELLOW}NUMERICAL CALCULUS${RESET}"
    echo "1) Numerical integration (Simpson's rule)"
    echo "2) Numerical derivative"
    echo "3) Solve ODE (Euler's method)"
    echo "b) Back"
    read -rp "Option: " op

    case "$op" in
        1) numerical_integration ;;
        2) numerical_derivative ;;
        3) solve_ode_euler ;;
        b|B) return ;;
        *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
    esac
}

# Statistics submenu
statistics_menu() {
    echo -e "\n${YELLOW}STATISTICS AND COMBINATORICS${RESET}"
    echo "1) Descriptive statistics"
    echo "2) Combinations and permutations"
    echo "3) Binomial distribution"
    echo "b) Back"
    read -rp "Option: " op

    case "$op" in
        1) descriptive_statistics ;;
        2) combinatorics ;;
        3) binomial_distribution ;;
        b|B) return ;;
        *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
    esac
}

# Number theory submenu
number_theory_menu() {
    echo -e "\n${YELLOW}NUMBER THEORY AND BASES${RESET}"
    echo "1) Prime factorization"
    echo "2) Base conversion"
    echo "b) Back"
    read -rp "Option: " op

    case "$op" in
        1) factorize_number ;;
        2) base_conversion ;;
        b|B) return ;;
        *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
    esac
}

# Other utilities submenu
other_utilities_menu() {
    while true; do
        echo -e "\n${YELLOW}OTHER UTILITIES${RESET}"
        echo "1) Extended factorial (Gamma function)"
        echo "2) GCD and LCM"
        echo "3) Save history to file"
        echo "4) Load history from file"
        echo "5) Create .deb package"
        echo "6) Create Arch package (.pkg.tar.zst)"
        echo "7) Interactive menu (fzf/gum)"
        echo "b) Back"
        read -rp "Option: " op

        case "$op" in
            1) extended_factorial ;;
            2) gcd_lcm ;;
            3) save_history_to_file ;;
            4) load_history_from_file ;;
            5) create_deb_package ;;
            6) create_arch_package ;;
            7) interactive_interface ;;
            b|B) return ;;
            *) echo -e "\n${RED}✗ Invalid option${RESET}"; wait_to_continue ;;
        esac
    done
}

# ==============================================================================
# MAIN PROGRAM LOOP
# Entry point and main menu handler
# ==============================================================================
main() {
    # Validate required dependencies
    validate_dependency awk
    validate_dependency bc

    # Main program loop
    while true; do
        show_header
        show_main_menu
        read -rp "Select an option: " option

        case "$option" in
            1) solve_quadratic ;;
            2) solve_cubic ;;
            3) solve_newton_raphson ;;
            4) matrix_operations_menu ;;
            5) complex_operations_menu ;;
            6) numerical_calculus_menu ;;
            7) statistics_menu ;;
            8) discrete_fourier_transform ;;
            9) number_theory_menu ;;
            10) show_history ;;
            11) clear_history ;;
            12) configure_precision ;;
            13) other_utilities_menu ;;
            q|Q)
                echo -e "\n${GREEN}Thank you for using Advanced Calculator!${RESET}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}✗ Invalid option${RESET}"
                wait_to_continue
                ;;
        esac
    done
}

# Start the calculator
main
