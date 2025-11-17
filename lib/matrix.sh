#!/bin/bash
# Matrix Operations Library for CalcX Advanced
# Provides functions for matrix operations including determinant, inverse, multiplication

# ==============================================================================
# MATRIX UTILITY FUNCTIONS
# ==============================================================================

# Parse matrix string format: [[1,2],[3,4]] into array
parse_matrix() {
    local matrix_str="$1"
    # Remove outer brackets and spaces
    matrix_str="${matrix_str//\[/}"
    matrix_str="${matrix_str//\]/}"
    echo "$matrix_str"
}

# Get matrix dimensions
get_matrix_dimensions() {
    local matrix_str="$1"
    # Count rows (number of ] before final ])
    local rows=$(echo "$matrix_str" | grep -o '\[' | wc -l)
    rows=$((rows - 1))

    # Count columns (elements in first row)
    local first_row=$(echo "$matrix_str" | sed 's/\[\[//;s/\]\].*//')
    local cols=$(echo "$first_row" | tr ',' '\n' | wc -l)

    echo "$rows $cols"
}

# ==============================================================================
# 2x2 MATRIX OPERATIONS
# ==============================================================================

# Calculate determinant of 2x2 matrix
# Matrix format: [[a,b],[c,d]]
determinant_2x2() {
    local a=$1 b=$2 c=$3 d=$4
    # det = ad - bc
    echo "scale=6; ($a * $d) - ($b * $c)" | bc -l
}

# Calculate inverse of 2x2 matrix
# Returns: space-separated values a b c d representing [[a,b],[c,d]]
inverse_2x2() {
    local a=$1 b=$2 c=$3 d=$4

    local det=$(determinant_2x2 $a $b $c $d)

    # Check if determinant is zero
    local is_zero=$(echo "$det == 0" | bc -l)
    if [ "$is_zero" -eq 1 ]; then
        echo "Error: Matrix is singular (determinant = 0), inverse does not exist"
        return 1
    fi

    # Inverse = (1/det) * [[d, -b], [-c, a]]
    local inv_a=$(echo "scale=6; $d / $det" | bc -l)
    local inv_b=$(echo "scale=6; -$b / $det" | bc -l)
    local inv_c=$(echo "scale=6; -$c / $det" | bc -l)
    local inv_d=$(echo "scale=6; $a / $det" | bc -l)

    echo "$inv_a $inv_b $inv_c $inv_d"
}

# Multiply two 2x2 matrices
# A * B = C
multiply_2x2() {
    local a1=$1 b1=$2 c1=$3 d1=$4
    local a2=$5 b2=$6 c2=$7 d2=$8

    # Result matrix elements
    # [[a1,b1],[c1,d1]] * [[a2,b2],[c2,d2]]
    local r1=$(echo "scale=6; ($a1 * $a2) + ($b1 * $c2)" | bc -l)
    local r2=$(echo "scale=6; ($a1 * $b2) + ($b1 * $d2)" | bc -l)
    local r3=$(echo "scale=6; ($c1 * $a2) + ($d1 * $c2)" | bc -l)
    local r4=$(echo "scale=6; ($c1 * $b2) + ($d1 * $d2)" | bc -l)

    echo "$r1 $r2 $r3 $r4"
}

# Add two 2x2 matrices
add_2x2() {
    local a1=$1 b1=$2 c1=$3 d1=$4
    local a2=$5 b2=$6 c2=$7 d2=$8

    local r1=$(echo "scale=6; $a1 + $a2" | bc -l)
    local r2=$(echo "scale=6; $b1 + $b2" | bc -l)
    local r3=$(echo "scale=6; $c1 + $c2" | bc -l)
    local r4=$(echo "scale=6; $d1 + $d2" | bc -l)

    echo "$r1 $r2 $r3 $r4"
}

# Subtract two 2x2 matrices
subtract_2x2() {
    local a1=$1 b1=$2 c1=$3 d1=$4
    local a2=$5 b2=$6 c2=$7 d2=$8

    local r1=$(echo "scale=6; $a1 - $a2" | bc -l)
    local r2=$(echo "scale=6; $b1 - $b2" | bc -l)
    local r3=$(echo "scale=6; $c1 - $c2" | bc -l)
    local r4=$(echo "scale=6; $d1 - $d2" | bc -l)

    echo "$r1 $r2 $r3 $r4"
}

# Scalar multiplication for 2x2 matrix
scalar_multiply_2x2() {
    local scalar=$1
    local a=$2 b=$3 c=$4 d=$5

    local r1=$(echo "scale=6; $scalar * $a" | bc -l)
    local r2=$(echo "scale=6; $scalar * $b" | bc -l)
    local r3=$(echo "scale=6; $scalar * $c" | bc -l)
    local r4=$(echo "scale=6; $scalar * $d" | bc -l)

    echo "$r1 $r2 $r3 $r4"
}

# Transpose 2x2 matrix
transpose_2x2() {
    local a=$1 b=$2 c=$3 d=$4
    # [[a,b],[c,d]] -> [[a,c],[b,d]]
    echo "$a $c $b $d"
}

# ==============================================================================
# 3x3 MATRIX OPERATIONS
# ==============================================================================

# Calculate determinant of 3x3 matrix using Rule of Sarrus
# Matrix: [[a,b,c],[d,e,f],[g,h,i]]
determinant_3x3() {
    local a=$1 b=$2 c=$3
    local d=$4 e=$5 f=$6
    local g=$7 h=$8 i=$9

    # det = aei + bfg + cdh - ceg - afh - bdi
    local pos1=$(echo "scale=6; $a * $e * $i" | bc -l)
    local pos2=$(echo "scale=6; $b * $f * $g" | bc -l)
    local pos3=$(echo "scale=6; $c * $d * $h" | bc -l)
    local neg1=$(echo "scale=6; $c * $e * $g" | bc -l)
    local neg2=$(echo "scale=6; $a * $f * $h" | bc -l)
    local neg3=$(echo "scale=6; $b * $d * $i" | bc -l)

    echo "scale=6; $pos1 + $pos2 + $pos3 - $neg1 - $neg2 - $neg3" | bc -l
}

# Transpose 3x3 matrix
transpose_3x3() {
    local a=$1 b=$2 c=$3
    local d=$4 e=$5 f=$6
    local g=$7 h=$8 i=$9

    # [[a,b,c],[d,e,f],[g,h,i]] -> [[a,d,g],[b,e,h],[c,f,i]]
    echo "$a $d $g $b $e $h $c $f $i"
}

# Add two 3x3 matrices
add_3x3() {
    local a1=$1 b1=$2 c1=$3 d1=$4 e1=$5 f1=$6 g1=$7 h1=$8 i1=$9
    shift 9
    local a2=$1 b2=$2 c2=$3 d2=$4 e2=$5 f2=$6 g2=$7 h2=$8 i2=$9

    local r1=$(echo "scale=6; $a1 + $a2" | bc -l)
    local r2=$(echo "scale=6; $b1 + $b2" | bc -l)
    local r3=$(echo "scale=6; $c1 + $c2" | bc -l)
    local r4=$(echo "scale=6; $d1 + $d2" | bc -l)
    local r5=$(echo "scale=6; $e1 + $e2" | bc -l)
    local r6=$(echo "scale=6; $f1 + $f2" | bc -l)
    local r7=$(echo "scale=6; $g1 + $g2" | bc -l)
    local r8=$(echo "scale=6; $h1 + $h2" | bc -l)
    local r9=$(echo "scale=6; $i1 + $i2" | bc -l)

    echo "$r1 $r2 $r3 $r4 $r5 $r6 $r7 $r8 $r9"
}

# Scalar multiplication for 3x3 matrix
scalar_multiply_3x3() {
    local scalar=$1
    local a=$2 b=$3 c=$4 d=$5 e=$6 f=$7 g=$8 h=$9 i=${10}

    local r1=$(echo "scale=6; $scalar * $a" | bc -l)
    local r2=$(echo "scale=6; $scalar * $b" | bc -l)
    local r3=$(echo "scale=6; $scalar * $c" | bc -l)
    local r4=$(echo "scale=6; $scalar * $d" | bc -l)
    local r5=$(echo "scale=6; $scalar * $e" | bc -l)
    local r6=$(echo "scale=6; $scalar * $f" | bc -l)
    local r7=$(echo "scale=6; $scalar * $g" | bc -l)
    local r8=$(echo "scale=6; $scalar * $h" | bc -l)
    local r9=$(echo "scale=6; $scalar * $i" | bc -l)

    echo "$r1 $r2 $r3 $r4 $r5 $r6 $r7 $r8 $r9"
}

# ==============================================================================
# MATRIX FORMATTING AND DISPLAY
# ==============================================================================

# Format matrix output for display
format_matrix_2x2() {
    local a=$1 b=$2 c=$3 d=$4
    echo "[[${a}, ${b}],"
    echo " [${c}, ${d}]]"
}

format_matrix_3x3() {
    local a=$1 b=$2 c=$3
    local d=$4 e=$5 f=$6
    local g=$7 h=$8 i=$9
    echo "[[${a}, ${b}, ${c}],"
    echo " [${d}, ${e}, ${f}],"
    echo " [${g}, ${h}, ${i}]]"
}

# ==============================================================================
# HIGH-LEVEL MATRIX OPERATIONS WITH PYTHON
# ==============================================================================

# For more complex operations, use Python with NumPy
matrix_operation_python() {
    local operation=$1
    local matrix_data=$2

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 is required for advanced matrix operations"
        return 1
    fi

    python3 <<EOF
import sys
try:
    import numpy as np

    # Parse matrix data
    matrix_str = """$matrix_data"""

    # Perform operation
    if "$operation" == "eigenvalues":
        matrix = np.array(eval(matrix_str))
        eigenvalues = np.linalg.eigvals(matrix)
        print("Eigenvalues:")
        for val in eigenvalues:
            if np.isreal(val):
                print(f"  {val.real:.6f}")
            else:
                print(f"  {val.real:.6f} + {val.imag:.6f}i")

    elif "$operation" == "eigenvectors":
        matrix = np.array(eval(matrix_str))
        eigenvalues, eigenvectors = np.linalg.eig(matrix)
        print("Eigenvectors:")
        print(eigenvectors)

    elif "$operation" == "rank":
        matrix = np.array(eval(matrix_str))
        rank = np.linalg.matrix_rank(matrix)
        print(f"Rank: {rank}")

    elif "$operation" == "trace":
        matrix = np.array(eval(matrix_str))
        trace = np.trace(matrix)
        print(f"Trace: {trace:.6f}")

    else:
        print(f"Unknown operation: $operation")
        sys.exit(1)

except ImportError:
    print("Error: NumPy is required for this operation")
    print("Install with: pip install numpy")
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
EOF
}

# ==============================================================================
# IDENTITY MATRIX GENERATION
# ==============================================================================

identity_2x2() {
    echo "1 0 0 1"
}

identity_3x3() {
    echo "1 0 0 0 1 0 0 0 1"
}

# ==============================================================================
# MATRIX VALIDATION
# ==============================================================================

# Check if matrix is symmetric
is_symmetric_2x2() {
    local a=$1 b=$2 c=$3 d=$4
    # Symmetric if b == c
    local diff=$(echo "scale=10; ($b - $c)" | bc -l)
    local is_zero=$(echo "$diff == 0" | bc -l)
    [ "$is_zero" -eq 1 ]
}

is_symmetric_3x3() {
    local a=$1 b=$2 c=$3
    local d=$4 e=$5 f=$6
    local g=$7 h=$8 i=$9
    # Symmetric if b==d, c==g, f==h
    local check1=$(echo "$b == $d" | bc -l)
    local check2=$(echo "$c == $g" | bc -l)
    local check3=$(echo "$f == $h" | bc -l)
    [ "$check1" -eq 1 ] && [ "$check2" -eq 1 ] && [ "$check3" -eq 1 ]
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

export -f parse_matrix get_matrix_dimensions
export -f determinant_2x2 inverse_2x2 multiply_2x2 add_2x2 subtract_2x2
export -f scalar_multiply_2x2 transpose_2x2
export -f determinant_3x3 transpose_3x3 add_3x3 scalar_multiply_3x3
export -f format_matrix_2x2 format_matrix_3x3
export -f matrix_operation_python
export -f identity_2x2 identity_3x3
export -f is_symmetric_2x2 is_symmetric_3x3
