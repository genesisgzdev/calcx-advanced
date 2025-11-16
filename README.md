# CalcX Advanced

High-performance scientific calculator built with Bash and arbitrary 
precision arithmetic. Combines GNU bc and Python computational power 
with Zenity GUI for complex mathematical operations.

## Architecture

**Dual-mode operation:**

**Command-line mode** - Direct expression evaluation via bc/Python 
backends. Supports arbitrary precision arithmetic and complex 
expressions. Perfect for scripting and automation.

**Interactive GUI mode** - Zenity dialog-driven interface providing 
access to equation solvers, matrix operations, numerical calculus, 
statistics, and number theory.

**Modular libraries** - Reusable functions in `lib/` can be sourced 
independently for unit conversions, matrix calculations, and number 
theory without the full calculator interface.

## Installation

### Quick Install

```bash
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x scripts/install.sh && ./scripts/install.sh
The installer will:

Set executable permissions on required files
Create symlink in /usr/local/bin/calcx
Verify dependencies
Initialize configuration
Manual Install
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x calcx.sh src/calcx-advanced.sh lib/*.sh scripts/*.sh
sudo ln -sf "$(pwd)/calcx.sh" /usr/local/bin/calcx
Dependencies
Required:

Bash 4.0+
GNU bc 1.07+
Optional:

Python 3.6+ (advanced features)
Zenity 3.0+ (GUI interface)
Verify installation:

bash --version | head -1
bc --version | head -1
python3 --version
zenity --version
Usage
Command-Line Mode
Terminal usage and shell scripting:

# Arbitrary precision arithmetic
calcx "scale=50; 4*a(1)"     # π to 50 decimals

# Exponential and logarithmic
calcx "e(10)"                # e^10
calcx "l(2.718281828)"       # Natural log

# Power operations
calcx "2^1024"               # Large exponents
calcx "sqrt(2)^2"            # Root operations

# Complex expressions
calcx "(5 + 3) * 2^4 - 10 / 2"
Available bc functions:

s(x) - sine (radians)
c(x) - cosine
a(x) - arctangent
l(x) - natural logarithm
e(x) - exponential
sqrt(x) - square root
scale=n - decimal precision
Python Fallback
When bc cannot evaluate, Python handles automatically:

calcx "import math; math.factorial(50)"
calcx "complex(3, 4) * complex(1, 2)"
calcx "sum([i**2 for i in range(100)])"
Interactive GUI
Launch full interface:

calcx
Available operations:

Algebraic:

Quadratic solver (ax² + bx + c = 0)
Cubic solver (ax³ + bx² + cx + d = 0)
Newton-Raphson root finding
Linear system solver (Gaussian elimination)
Matrix:

Multiplication (2×2, 3×3)
Determinant calculation
Matrix inverse
Linear systems
Complex Numbers:

Basic arithmetic (add, subtract, multiply, divide)
Modulus and argument
Polar/rectangular conversion
Exponential and logarithm
Power operations
Numerical Calculus:

Integration (Simpson's rule, trapezoidal)
Differentiation (finite differences)
ODEs (Euler method)
Statistics:

Descriptive stats (mean, median, mode, variance, std dev)
Permutations and combinations
Binomial distributions
Discrete Fourier Transform
Number Theory:

Prime factorization
Base conversion (binary, octal, decimal, hex, arbitrary)
GCD and LCM
Extended factorials
Library Reference
lib/math_functions.sh
Core mathematical functions:

source lib/math_functions.sh

# Factorial
result=$(factorial 10)       # 3628800

# Fibonacci
fibonacci 10                 # 0 1 1 2 3 5 8 13 21 34

# Number theory
gcd 48 18                    # 6
lcm 12 15                    # 60
is_prime 97 && echo "Prime" || echo "Composite"
Function reference:

factorial(n) - Returns n! for n ≥ 0
fibonacci(n) - Prints first n Fibonacci numbers
gcd(a, b) - Euclidean algorithm GCD
lcm(a, b) - Least common multiple
is_prime(n) - Returns 0 if prime, 1 otherwise
lib/conversions.sh
Unit conversion library (9 categories):

source lib/conversions.sh

# Temperature
celsius_to_fahrenheit 100    # 212
fahrenheit_to_kelvin 32      # 273.15
kelvin_to_celsius 373.15     # 100

# Length
miles_to_kilometers 26.2     # 42.164877
meters_to_feet 1000          # 3280.84
inches_to_centimeters 12     # 30.48

# Weight
kilograms_to_pounds 75       # 165.3465
pounds_to_kilograms 200      # 90.7185

# Speed
mph_to_kph 65                # 104.60736
kph_to_mps 100               # 27.777778

# Data storage
bytes_to_kilobytes 2048      # 2
megabytes_to_gigabytes 2048  # 2
gigabytes_to_terabytes 1024  # 1

# Volume
liters_to_gallons 10         # 2.64172
gallons_to_liters 5          # 18.92706

# Time
hours_to_minutes 2.5         # 150
days_to_hours 7              # 168

# Energy
calories_to_joules 1000      # 4184.1
joules_to_kilowatt_hours 3600000  # 1

# Pressure
psi_to_pascals 14.7          # 101352.9
bar_to_pascals 1             # 100000

# Natural language conversion
convert "100 celsius to fahrenheit"      # 212
convert "50 miles to kilometers"         # 80.4672
convert "1024 megabytes to gigabytes"    # 1
All conversions are bidirectional. Format: <unit1>_to_<unit2>

lib/matrix.sh
Linear algebra operations:

source lib/matrix.sh

# 2x2 operations
determinant_2x2 3 8 4 6             # -14
inverse_2x2 4 7 2 6                 # 0.6 -0.7 -0.2 0.4
multiply_2x2 1 2 3 4 5 6 7 8        # Product
add_2x2 1 2 3 4 5 6 7 8             # Element-wise add
subtract_2x2 5 6 7 8 1 2 3 4        # Element-wise sub
scalar_multiply_2x2 3 1 2 3 4       # Scalar multiply
transpose_2x2 1 2 3 4               # Transpose

# 3x3 operations
determinant_3x3 6 1 1 4 -2 5 2 8 7  # -306
transpose_3x3 1 2 3 4 5 6 7 8 9
add_3x3 1 2 3 4 5 6 7 8 9 9 8 7 6 5 4 3 2 1
scalar_multiply_3x3 2 1 2 3 4 5 6 7 8 9

# Utilities
identity_2x2                        # 1 0 0 1
identity_3x3                        # 1 0 0 0 1 0 0 0 1
is_symmetric_2x2 1 2 2 4 && echo "Symmetric"
is_symmetric_3x3 1 2 3 2 5 6 3 6 9 && echo "Symmetric"

# Display formatting
result=$(multiply_2x2 1 2 3 4 5 6 7 8)
format_matrix_2x2 $result
# Output:
# [[19, 22],
#  [43, 50]]
Matrix representation:

2×2: [[a,b],[c,d]] → a b c d
3×3: [[a,b,c],[d,e,f],[g,h,i]] → a b c d e f g h i
Scripting Integration
Shell Script Example
#!/bin/bash
source /path/to/calcx-advanced/lib/conversions.sh
source /path/to/calcx-advanced/lib/math_functions.sh

# Fuel efficiency
mpg=35.5
kpl=$(echo "scale=2; $(mph_to_kph 1) / 3.785411784 * $mpg" | bc)
echo "Fuel efficiency: $mpg MPG = $kpl km/L"

# Financial calculation
principal=10000
rate=0.05
years=10
amount=$(calcx "scale=2; $principal * e($rate * $years)")
echo "Compound interest: \$${amount}"

# Factorial sum
sum=0
for i in {1..10}; do
    fact=$(factorial $i)
    sum=$(calcx "$sum + $fact")
done
echo "Sum of factorials 1! to 10!: $sum"
Data Pipeline
# Temperature conversion
while read temp_f; do
    temp_c=$(fahrenheit_to_celsius $temp_f)
    echo "$temp_f°F = $temp_c°C"
done < temps.txt > converted.txt

# Statistical analysis
cat data.csv | awk '{sum+=$1} END {print sum/NR}' | \
    xargs -I {} calcx "sqrt({})"
Configuration
Config File
Create ~/.config/calcx/calcx.conf:

# Precision (-1 for general format, positive for sig figs)
CALC_PRECISION=15

# History settings
MAX_HISTORIAL=50
HIST_FILE="$HOME/.calcx_history"

# Display
COLOR_OUTPUT=true
VERBOSE_MODE=false
Environment Variables
export CALC_PRECISION=20
export MAX_HISTORIAL=100
calcx "4*a(1)"  # π with 20-digit precision
Priority Order
System defaults (hardcoded)
System config (/etc/calcx/calcx.conf)
User config (~/.config/calcx/calcx.conf)
Environment variables
Command-line arguments
Testing
Run Tests
cd calcx-advanced/tests
./run_tests.sh
Output:

Basic functionality tests
Unit tests: conversions (14 cases)
Unit tests: matrix ops (27 cases)
Integration tests
Benchmarks
Test Structure
tests/
├── run_tests.sh              # Main runner
├── test_basic.sh             # Basic tests
├── unit/
│   ├── test_conversions.sh   # Conversion tests
│   └── test_matrix.sh        # Matrix tests
├── integration/
└── benchmark/
Writing Tests
#!/bin/bash
source lib/conversions.sh

# Test temperature conversion
result=$(celsius_to_fahrenheit 100)
expected=212
tolerance=0.01

diff=$(echo "scale=10; ($expected - $result)" | bc -l)
abs_diff=$(echo "scale=10; if ($diff < 0) -$diff else $diff" | bc -l)
is_equal=$(echo "$abs_diff < $tolerance" | bc -l)

if [ "$is_equal" -eq 1 ]; then
    echo "PASS: celsius_to_fahrenheit"
    exit 0
else
    echo "FAIL: Expected $expected, got $result"
    exit 1
fi
Maintenance
Update
cd /path/to/calcx-advanced
./scripts/update.sh
Update process:

Fetch from GitHub
Stash local changes
Version comparison
Merge changes
Restore stashed changes
Validate dependencies
Update permissions
Uninstall
cd /path/to/calcx-advanced
./scripts/uninstall.sh
Removes:

/usr/local/bin/calcx symlink
User config (optional)
History files (optional)
Performance
Precision: Arbitrary via GNU bc (memory-limited only)

Speed: Sub-millisecond for standard arithmetic

Matrix operations:

2×2 determinant: ~1ms
3×3 determinant: ~2ms
Multiplication: O(n³)
Memory: <10MB base, scales with complexity

Ranges:

Integers: Memory-limited
Decimals: Arbitrary precision
Exponents: Up to 2^31-1
Development
Project Structure
calcx-advanced/
├── calcx.sh                  # Entry wrapper
├── src/
│   └── calcx-advanced.sh     # Main engine (2500+ lines)
├── lib/
│   ├── math_functions.sh     # Number theory
│   ├── conversions.sh        # Units (380+ lines)
│   ├── matrix.sh             # Linear algebra (360+ lines)
│   └── colors.sh             # Terminal colors
├── config/
│   └── calcx.conf            # Defaults
├── scripts/
│   ├── install.sh
│   ├── uninstall.sh
│   └── update.sh
├── tests/                    # 41 tests total
│   ├── run_tests.sh
│   ├── test_basic.sh
│   └── unit/
│       ├── test_conversions.sh
│       └── test_matrix.sh
├── examples/
│   ├── basic_usage.sh
│   └── advanced_usage.sh
├── docs/
│   └── MANUAL.md
├── VERSION
└── README.md
Contributing
Code standards:

POSIX-compliant where possible
Use shellcheck for validation
Maintain bc compatibility
Document all functions
Handle edge cases
Testing:

Unit tests for new functions
Integration tests for features
Performance benchmarks
Verify against known values
Commits:

type(scope): subject

body

footer
Types: feat, fix, docs, refactor, test, perf

Debugging
# Debug mode
export CALCX_DEBUG=1
export CALCX_VERBOSE=1
calcx "expression" 2> debug.log

# Trace execution
bash -x calcx.sh "expression"
Limitations
Zenity required for GUI (CLI works without)
Matrix ops >3×3 need Python/NumPy
DFT limited to small datasets
Windows needs Git Bash or WSL
bc trig functions ~20 digit precision
Troubleshooting
bc not found:

sudo apt install bc              # Ubuntu/Debian
brew install bc                  # macOS
sudo pacman -S bc                # Arch
Zenity missing:

sudo apt install zenity          # Ubuntu/Debian
brew install zenity              # macOS
sudo pacman -S zenity            # Arch
Permission errors:

chmod +x calcx.sh src/*.sh lib/*.sh scripts/*.sh
Python modules:

python3 -m pip install numpy
License
MIT License

Copyright (c) 2025 Genesis GZ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author
Genesis GZ Full Stack Developer GitHub: @genesisgzdev Email: genzt.dev@pm.me

Version 1.0.0 (2025-11-11)

