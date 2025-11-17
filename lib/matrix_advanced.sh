#!/bin/bash
# Advanced Matrix Operations Library for CalcX Advanced
# Supports arbitrary matrix dimensions with optimized algorithms

# ==============================================================================
# MATRIX PARSING AND VALIDATION
# ==============================================================================

parse_matrix() {
    local matrix_str="$1"
    # Parse matrix string format: [[1,2,3],[4,5,6]]
    # Returns: rows cols element1 element2 ...

    # Remove all spaces first
    matrix_str="${matrix_str// /}"

    # Remove outer brackets
    matrix_str="${matrix_str#\[}"
    matrix_str="${matrix_str%\]}"

    # Count rows and extract elements
    local rows=0
    local cols=0
    local elements=()

    # Replace ],[ with a unique delimiter, then split
    matrix_str="${matrix_str//\],\[/|}"

    # Split by the delimiter to get rows
    IFS='|' read -ra row_array <<< "$matrix_str"
    for row in "${row_array[@]}"; do
        # Remove any remaining brackets
        row="${row#\[}"
        row="${row%\]}"

        [[ -z "$row" ]] && continue

        # Split row by commas to get elements
        IFS=',' read -ra elem_array <<< "$row"
        local row_cols=0

        for elem in "${elem_array[@]}"; do
            [[ -z "$elem" ]] && continue
            elements+=("$elem")
            row_cols=$((row_cols + 1))
        done

        if [ $rows -eq 0 ]; then
            cols=$row_cols
        elif [ $row_cols -ne $cols ]; then
            echo "Error: Inconsistent row lengths" >&2
            return 1
        fi

        rows=$((rows + 1))
    done

    echo "$rows $cols ${elements[@]}"
}

# ==============================================================================
# ARBITRARY DIMENSION MATRIX OPERATIONS
# ==============================================================================

matrix_multiply_general() {
    local a_rows=$1 a_cols=$2
    shift 2
    local -a matrix_a=("$@")

    # Second matrix starts after first matrix elements
    local b_rows=${matrix_a[$((a_rows * a_cols))]}
    local b_cols=${matrix_a[$((a_rows * a_cols + 1))]}

    # Extract matrix B
    local -a matrix_b=()
    local offset=$((a_rows * a_cols + 2))
    for ((i=0; i<b_rows*b_cols; i++)); do
        matrix_b[$i]=${matrix_a[$((offset + i))]}
    done

    # Validate dimensions
    if [ $a_cols -ne $b_rows ]; then
        echo "Error: Matrix dimensions incompatible for multiplication" >&2
        return 1
    fi

    # Result matrix: a_rows x b_cols
    local -a result=()

    for ((i=0; i<a_rows; i++)); do
        for ((j=0; j<b_cols; j++)); do
            local sum=0
            for ((k=0; k<a_cols; k++)); do
                local a_elem=${matrix_a[$((i * a_cols + k))]}
                local b_elem=${matrix_b[$((k * b_cols + j))]}
                local product=$(echo "scale=6; $a_elem * $b_elem" | bc -l)
                sum=$(echo "scale=6; $sum + $product" | bc -l)
            done
            result+=("$sum")
        done
    done

    echo "$a_rows $b_cols ${result[@]}"
}

determinant_general() {
    local n=$1
    shift
    local -a matrix=("$@")

    if [ $n -eq 1 ]; then
        echo "${matrix[0]}"
        return 0
    fi

    if [ $n -eq 2 ]; then
        local det=$(echo "scale=6; (${matrix[0]} * ${matrix[3]}) - (${matrix[1]} * ${matrix[2]})" | bc -l)
        echo "$det"
        return 0
    fi

    # Use Python for larger matrices (LU decomposition)
    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python required for matrices larger than 2x2" >&2
        return 1
    fi

    # Convert array to comma-separated string for Python
    local matrix_str=$(IFS=,; echo "${matrix[*]}")

    python3 <<EOF
import sys
n = $n
matrix = [$matrix_str]
matrix_2d = [matrix[i*n:(i+1)*n] for i in range(n)]

def determinant(mat):
    n = len(mat)
    if n == 1:
        return mat[0][0]
    if n == 2:
        return mat[0][0]*mat[1][1] - mat[0][1]*mat[1][0]

    # LU decomposition for efficiency
    det = 1
    for i in range(n):
        # Find pivot
        max_row = i
        for k in range(i+1, n):
            if abs(mat[k][i]) > abs(mat[max_row][i]):
                max_row = k

        if max_row != i:
            mat[i], mat[max_row] = mat[max_row], mat[i]
            det *= -1

        if abs(mat[i][i]) < 1e-10:
            return 0

        det *= mat[i][i]

        for k in range(i+1, n):
            factor = mat[k][i] / mat[i][i]
            for j in range(i+1, n):
                mat[k][j] -= factor * mat[i][j]

    return det

try:
    result = determinant(matrix_2d)
    print(f"{result:.6f}")
except:
    sys.exit(1)
EOF
}

matrix_inverse_general() {
    local n=$1
    shift
    local -a matrix=("$@")

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python required for matrix inversion" >&2
        return 1
    fi

    # Convert array to comma-separated string for Python
    local matrix_str=$(IFS=,; echo "${matrix[*]}")

    python3 <<EOF
import sys
n = $n
matrix = [$matrix_str]
matrix_2d = [matrix[i*n:(i+1)*n] for i in range(n)]

def matrix_inverse(mat):
    n = len(mat)
    # Create augmented matrix [A|I]
    aug = [row + [0]*n for row in mat]
    for i in range(n):
        aug[i][n+i] = 1

    # Gauss-Jordan elimination
    for i in range(n):
        # Find pivot
        max_row = i
        for k in range(i+1, n):
            if abs(aug[k][i]) > abs(aug[max_row][i]):
                max_row = k
        aug[i], aug[max_row] = aug[max_row], aug[i]

        if abs(aug[i][i]) < 1e-10:
            return None  # Singular matrix

        # Scale row
        pivot = aug[i][i]
        for j in range(2*n):
            aug[i][j] /= pivot

        # Eliminate column
        for k in range(n):
            if k != i:
                factor = aug[k][i]
                for j in range(2*n):
                    aug[k][j] -= factor * aug[i][j]

    # Extract inverse
    inverse = [row[n:] for row in aug]
    return inverse

try:
    inv = matrix_inverse(matrix_2d)
    if inv is None:
        print("Error: Singular matrix", file=sys.stderr)
        sys.exit(1)

    # Flatten and print
    result = [elem for row in inv for elem in row]
    print(' '.join(f"{x:.6f}" for x in result))
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

matrix_add_general() {
    local rows=$1 cols=$2
    shift 2
    local -a matrix_a=("$@")

    # Second matrix starts after first matrix elements
    local -a matrix_b=()
    local offset=$((rows * cols))
    for ((i=0; i<rows*cols; i++)); do
        matrix_b[$i]=${matrix_a[$((offset + i))]}
    done

    # Add matrices element-wise
    local -a result=()
    for ((i=0; i<rows*cols; i++)); do
        local sum=$(echo "scale=6; ${matrix_a[$i]} + ${matrix_b[$i]}" | bc -l)
        result+=("$sum")
    done

    echo "${result[@]}"
}

matrix_transpose_general() {
    local rows=$1 cols=$2
    shift 2
    local -a matrix=("$@")

    local -a result=()
    for ((j=0; j<cols; j++)); do
        for ((i=0; i<rows; i++)); do
            result+=(${matrix[$((i * cols + j))]})
        done
    done

    echo "${result[@]}"
}

# ==============================================================================
# MATRIX FORMATTING
# ==============================================================================

format_matrix_general() {
    local rows=$1 cols=$2
    shift 2
    local -a matrix=("$@")

    echo "["
    for ((i=0; i<rows; i++)); do
        echo -n " ["
        for ((j=0; j<cols; j++)); do
            local idx=$((i * cols + j))
            printf "%.4f" "${matrix[$idx]}"
            if [ $j -lt $((cols - 1)) ]; then
                echo -n ", "
            fi
        done
        if [ $i -lt $((rows - 1)) ]; then
            echo "],"
        else
            echo "]"
        fi
    done
    echo "]"
}

# ==============================================================================
# LEGACY COMPATIBILITY (2x2 and 3x3)
# ==============================================================================

determinant_2x2() {
    local a=$1 b=$2 c=$3 d=$4
    echo "scale=6; ($a * $d) - ($b * $c)" | bc -l
}

inverse_2x2() {
    local a=$1 b=$2 c=$3 d=$4
    local det=$(determinant_2x2 $a $b $c $d)
    local is_zero=$(echo "$det == 0" | bc -l)

    if [ "$is_zero" -eq 1 ]; then
        echo "Error: Singular matrix" >&2
        return 1
    fi

    local inv_a=$(echo "scale=6; $d / $det" | bc -l)
    local inv_b=$(echo "scale=6; -$b / $det" | bc -l)
    local inv_c=$(echo "scale=6; -$c / $det" | bc -l)
    local inv_d=$(echo "scale=6; $a / $det" | bc -l)

    echo "$inv_a $inv_b $inv_c $inv_d"
}

multiply_2x2() {
    local a1=$1 b1=$2 c1=$3 d1=$4
    local a2=$5 b2=$6 c2=$7 d2=$8

    local r1=$(echo "scale=6; ($a1 * $a2) + ($b1 * $c2)" | bc -l)
    local r2=$(echo "scale=6; ($a1 * $b2) + ($b1 * $d2)" | bc -l)
    local r3=$(echo "scale=6; ($c1 * $a2) + ($d1 * $c2)" | bc -l)
    local r4=$(echo "scale=6; ($c1 * $b2) + ($d1 * $d2)" | bc -l)

    echo "$r1 $r2 $r3 $r4"
}

add_2x2() {
    local a1=$1 b1=$2 c1=$3 d1=$4
    local a2=$5 b2=$6 c2=$7 d2=$8
    echo "$(echo "scale=6; $a1 + $a2" | bc -l) $(echo "scale=6; $b1 + $b2" | bc -l) $(echo "scale=6; $c1 + $c2" | bc -l) $(echo "scale=6; $d1 + $d2" | bc -l)"
}

subtract_2x2() {
    local a1=$1 b1=$2 c1=$3 d1=$4
    local a2=$5 b2=$6 c2=$7 d2=$8
    echo "$(echo "scale=6; $a1 - $a2" | bc -l) $(echo "scale=6; $b1 - $b2" | bc -l) $(echo "scale=6; $c1 - $c2" | bc -l) $(echo "scale=6; $d1 - $d2" | bc -l)"
}

scalar_multiply_2x2() {
    local scalar=$1
    local a=$2 b=$3 c=$4 d=$5
    echo "$(echo "scale=6; $scalar * $a" | bc -l) $(echo "scale=6; $scalar * $b" | bc -l) $(echo "scale=6; $scalar * $c" | bc -l) $(echo "scale=6; $scalar * $d" | bc -l)"
}

transpose_2x2() {
    echo "$1 $3 $2 $4"
}

determinant_3x3() {
    local a=$1 b=$2 c=$3 d=$4 e=$5 f=$6 g=$7 h=$8 i=$9
    local pos1=$(echo "scale=6; $a * $e * $i" | bc -l)
    local pos2=$(echo "scale=6; $b * $f * $g" | bc -l)
    local pos3=$(echo "scale=6; $c * $d * $h" | bc -l)
    local neg1=$(echo "scale=6; $c * $e * $g" | bc -l)
    local neg2=$(echo "scale=6; $a * $f * $h" | bc -l)
    local neg3=$(echo "scale=6; $b * $d * $i" | bc -l)
    echo "scale=6; $pos1 + $pos2 + $pos3 - $neg1 - $neg2 - $neg3" | bc -l
}

transpose_3x3() {
    echo "$1 $4 $7 $2 $5 $8 $3 $6 $9"
}

add_3x3() {
    local -a result=()
    for ((i=1; i<=9; i++)); do
        local val1="${!i}"
        local val2="${!$((i+9))}"
        result+=($(echo "scale=6; $val1 + $val2" | bc -l))
    done
    echo "${result[@]}"
}

scalar_multiply_3x3() {
    local scalar=$1
    shift
    local -a result=()
    for val in "$@"; do
        result+=($(echo "scale=6; $scalar * $val" | bc -l))
    done
    echo "${result[@]}"
}

identity_2x2() {
    echo "1 0 0 1"
}

identity_3x3() {
    echo "1 0 0 0 1 0 0 0 1"
}

is_symmetric_2x2() {
    [ "$2" = "$3" ]
}

is_symmetric_3x3() {
    [ "$2" = "$4" ] && [ "$3" = "$7" ] && [ "$6" = "$8" ]
}

format_matrix_2x2() {
    echo "[[$1, $2],"
    echo " [$3, $4]]"
}

format_matrix_3x3() {
    echo "[[$1, $2, $3],"
    echo " [$4, $5, $6],"
    echo " [$7, $8, $9]]"
}

export -f parse_matrix determinant_general matrix_inverse_general matrix_multiply_general
export -f matrix_add_general matrix_transpose_general format_matrix_general
export -f determinant_2x2 inverse_2x2 multiply_2x2 add_2x2 subtract_2x2
export -f scalar_multiply_2x2 transpose_2x2 determinant_3x3 transpose_3x3
export -f add_3x3 scalar_multiply_3x3 identity_2x2 identity_3x3
export -f is_symmetric_2x2 is_symmetric_3x3 format_matrix_2x2 format_matrix_3x3
