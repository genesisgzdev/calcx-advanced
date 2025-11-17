#!/bin/bash
# Symbolic Computation Library for CalcX Advanced
# Uses Python SymPy for algebraic manipulation

symbolic_simplify() {
    local expr="$1"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required for symbolic computation" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr, standard_transformations, implicit_multiplication_application

    expr_str = """$expr"""

    # Parse expression with implicit multiplication
    transformations = standard_transformations + (implicit_multiplication_application,)
    expr = parse_expr(expr_str, transformations=transformations)

    # Simplify
    result = simplify(expr)
    print(result)
except ImportError:
    print("Error: SymPy not installed. Install with: pip3 install sympy", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

symbolic_expand() {
    local expr="$1"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr

    expr_str = """$expr"""
    expr = parse_expr(expr_str)
    result = expand(expr)
    print(result)
except ImportError:
    print("Error: SymPy not installed", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

symbolic_factor() {
    local expr="$1"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr

    expr_str = """$expr"""
    expr = parse_expr(expr_str)
    result = factor(expr)
    print(result)
except ImportError:
    print("Error: SymPy not installed", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

symbolic_diff() {
    local expr="$1"
    local var="${2:-x}"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr

    expr_str = """$expr"""
    var_str = "$var"

    expr = parse_expr(expr_str)
    var_sym = Symbol(var_str)
    result = diff(expr, var_sym)
    print(result)
except ImportError:
    print("Error: SymPy not installed", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

symbolic_integrate() {
    local expr="$1"
    local var="${2:-x}"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr

    expr_str = """$expr"""
    var_str = "$var"

    expr = parse_expr(expr_str)
    var_sym = Symbol(var_str)
    result = integrate(expr, var_sym)
    print(result)
except ImportError:
    print("Error: SymPy not installed", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

symbolic_solve() {
    local equation="$1"
    local var="${2:-x}"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr

    eq_str = """$equation"""
    var_str = "$var"

    # Parse equation (assume = 0 if no = sign)
    if '=' in eq_str:
        lhs, rhs = eq_str.split('=')
        lhs_expr = parse_expr(lhs)
        rhs_expr = parse_expr(rhs)
        eq = Eq(lhs_expr, rhs_expr)
    else:
        eq = parse_expr(eq_str)

    var_sym = Symbol(var_str)
    solutions = solve(eq, var_sym)

    if isinstance(solutions, list):
        print(' , '.join(str(sol) for sol in solutions))
    else:
        print(solutions)
except ImportError:
    print("Error: SymPy not installed", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

symbolic_limit() {
    local expr="$1"
    local var="$2"
    local point="$3"
    local direction="${4:-+-}"  # +, -, or +- for two-sided

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr

    expr_str = """$expr"""
    var_str = "$var"
    point_str = "$point"
    direction_str = "$direction"

    expr = parse_expr(expr_str)
    var_sym = Symbol(var_str)

    # Parse point (can be oo for infinity)
    if point_str == "oo" or point_str == "inf":
        point_val = oo
    elif point_str == "-oo" or point_str == "-inf":
        point_val = -oo
    else:
        point_val = parse_expr(point_str)

    # Calculate limit
    if direction_str == "+":
        result = limit(expr, var_sym, point_val, '+')
    elif direction_str == "-":
        result = limit(expr, var_sym, point_val, '-')
    else:
        result = limit(expr, var_sym, point_val)

    print(result)
except ImportError:
    print("Error: SymPy not installed", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

symbolic_series() {
    local expr="$1"
    local var="$2"
    local point="${3:-0}"
    local order="${4:-6}"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python 3 required" >&2
        return 1
    fi

    python3 <<EOF
import sys
try:
    from sympy import *
    from sympy.parsing.sympy_parser import parse_expr

    expr_str = """$expr"""
    var_str = "$var"
    point_str = "$point"
    order_val = $order

    expr = parse_expr(expr_str)
    var_sym = Symbol(var_str)
    point_val = parse_expr(point_str) if point_str != "0" else 0

    result = series(expr, var_sym, point_val, n=order_val)
    print(result)
except ImportError:
    print("Error: SymPy not installed", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

# Check SymPy installation
check_sympy() {
    if ! command -v python3 >/dev/null 2>&1; then
        return 1
    fi

    python3 -c "import sympy" 2>/dev/null
    return $?
}

export -f symbolic_simplify symbolic_expand symbolic_factor
export -f symbolic_diff symbolic_integrate symbolic_solve
export -f symbolic_limit symbolic_series check_sympy
