# CalcX Advanced

A high-performance scientific calculator engineered in Bash with arbitrary precision arithmetic capabilities. Combines the computational power of GNU bc and Python with an intuitive Zenity-based graphical interface for complex mathematical operations.

## Architecture

CalcX Advanced operates through a dual-mode architecture:

**Command-line mode** provides direct expression evaluation via `bc` and Python backends, supporting arbitrary precision arithmetic and complex mathematical expressions. Ideal for scripting, automation, and quick calculations.

**Interactive GUI mode** leverages Zenity dialogs to present a menu-driven interface for accessing advanced mathematical functions including equation solvers, matrix operations, numerical calculus, statistical analysis, and number theory computations.

The modular library system (`lib/`) provides reusable mathematical functions that can be sourced independently in other Bash scripts, enabling unit conversions, matrix calculations, and number theory operations without requiring the full calculator interface.

## Installation

### Quick Installation

```bash
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x scripts/install.sh && ./scripts/install.sh
The installation script will:

Set executable permissions on all required files
Create symbolic link in /usr/local/bin/calcx
Verify system dependencies
Initialize configuration directory
Manual Installation
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x calcx.sh src/calcx-advanced.sh lib/*.sh scripts/*.sh
sudo ln -sf "$(pwd)/calcx.sh" /usr/local/bin/calcx
Dependencies
Required:

Bash 4.0 or higher
GNU bc 1.07+ (arbitrary precision calculator)
Optional (enables advanced features):

Python 3.6+ (complex numbers, advanced calculus, DFT)
Zenity 3.0+ (GUI dialog interface)
Verification:

bash --version | head -1
bc --version | head -1
python3 --version
zenity --version
Usage
Command-Line Mode
Direct expression evaluation for terminal usage and shell scripting:

# Arithmetic with arbitrary precision
calcx "scale=50; 4*a(1)"  # Calculate π to 50 decimal places

# Exponential and logarithmic functions
calcx "e(10)"             # e^10
calcx "l(2.718281828)"    # Natural logarithm

# Power operations
calcx "2^1024"            # Large integer exponentiation
calcx "sqrt(2)^2"         # Root operations

# Complex expressions
calcx "(5 + 3) * 2^4 - 10 / 2"
bc Functions Available:

s(x) - sine (x in radians)
c(x) - cosine
a(x) - arctangent
l(x) - natural logarithm
e(x) - exponential function
sqrt(x) - square root
scale=n - set decimal precision
Python Fallback
When bc cannot evaluate an expression, Python automatically handles:

calcx "import math; math.factorial(50)"
calcx "complex(3, 4) * complex(1, 2)"
calcx "sum([i**2 for i in range(100)])"
Interactive GUI Mode
Launch the full calculator interface:

calcx
The Zenity-based interface provides organized menus for:

Algebraic Operations:

Quadratic equation solver (ax² + bx + c = 0)
Cubic equation solver (ax³ + bx² + cx + d = 0)
Newton-Raphson iterative root finding
System of linear equations (Gaussian elimination)
Matrix Operations:

Matrix multiplication (2×2, 3×3)
Determinant calculation
Matrix inverse computation
Linear system solving
Complex Number Arithmetic:

Addition, subtraction, multiplication, division
Modulus and argument calculation
Polar to rectangular conversion
Complex exponential and logarithm
Complex power operations
Numerical Calculus:

Numerical integration (Simpson's rule, trapezoidal)
Numerical differentiation (finite differences)
Ordinary differential equations (Euler method)
Statistical Functions:

Descriptive statistics (mean, median, mode, variance, std deviation)
Permutations and combinations
Binomial probability distributions
Discrete Fourier Transform (DFT)
Number Theory:

Prime factorization
Base conversion (binary, octal, decimal, hexadecimal, arbitrary base)
Greatest common divisor (GCD)
Least common multiple (LCM)
Extended factorial computations
Library Reference
lib/math_functions.sh
Core mathematical functions for shell scripting:

source lib/math_functions.sh

# Factorial calculation
result=$(factorial 10)  # 3628800

# Fibonacci sequence generation
fibonacci 10            # Outputs: 0 1 1 2 3 5 8 13 21 34

# Number theory
gcd 48 18              # 6
lcm 12 15              # 60
is_prime 97 && echo "Prime" || echo "Composite"
Function signatures:

factorial(n) - Returns n! for n ≥ 0
fibonacci(n) - Prints first n Fibonacci numbers
gcd(a, b) - Greatest common divisor via Euclidean algorithm
lcm(a, b) - Least common multiple
is_prime(n) - Returns 0 if prime, 1 otherwise
lib/conversions.sh
Comprehensive unit conversion library supporting 9 measurement categories:

source lib/conversions.sh

# Temperature conversions
celsius_to_fahrenheit 100      # 212
fahrenheit_to_kelvin 32        # 273.15
kelvin_to_celsius 373.15       # 100

# Length conversions
miles_to_kilometers 26.2       # 42.164877 (marathon distance)
meters_to_feet 1000            # 3280.84
inches_to_centimeters 12       # 30.48

# Weight conversions
kilograms_to_pounds 75         # 165.3465
pounds_to_kilograms 200        # 90.7185

# Speed conversions
mph_to_kph 65                  # 104.60736
kph_to_mps 100                 # 27.777778

# Data storage conversions
bytes_to_kilobytes 2048        # 2
megabytes_to_gigabytes 2048    # 2
gigabytes_to_terabytes 1024    # 1

# Volume conversions
liters_to_gallons 10           # 2.64172
gallons_to_liters 5            # 18.92706

# Time conversions
hours_to_minutes 2.5           # 150
days_to_hours 7                # 168

# Energy conversions
calories_to_joules 1000        # 4184.1
joules_to_kilowatt_hours 3600000  # 1

# Pressure conversions
psi_to_pascals 14.7            # 101352.9
bar_to_pascals 1               # 100000

# Generic conversion with natural language
convert "100 celsius to fahrenheit"     # 212
convert "50 miles to kilometers"        # 80.4672
convert "1024 megabytes to gigabytes"   # 1
Available conversion pairs: All conversions are bidirectional. Format: <unit1>_to_<unit2>.

lib/matrix.sh
Matrix operations library for linear algebra:

source lib/matrix.sh

# 2x2 matrix operations
determinant_2x2 3 8 4 6        # -14
inverse_2x2 4 7 2 6            # Returns: 0.6 -0.7 -0.2 0.4
multiply_2x2 1 2 3 4 5 6 7 8   # Matrix product
add_2x2 1 2 3 4 5 6 7 8        # Element-wise addition
subtract_2x2 5 6 7 8 1 2 3 4   # Element-wise subtraction
scalar_multiply_2x2 3 1 2 3 4  # Scalar multiplication
transpose_2x2 1 2 3 4          # Matrix transpose

# 3x3 matrix operations
determinant_3x3 6 1 1 4 -2 5 2 8 7  # -306
transpose_3x3 1 2 3 4 5 6 7 8 9
add_3x3 1 2 3 4 5 6 7 8 9 9 8 7 6 5 4 3 2 1
scalar_multiply_3x3 2 1 2 3 4 5 6 7 8 9

# Utility functions
identity_2x2                    # Returns: 1 0 0 1
identity_3x3                    # Returns: 1 0 0 0 1 0 0 0 1
is_symmetric_2x2 1 2 2 4 && echo "Symmetric"
is_symmetric_3x3 1 2 3 2 5 6 3 6 9 && echo "Symmetric"

# Display formatting
result=$(multiply_2x2 1 2 3 4 5 6 7 8)
format_matrix_2x2 $result
# Output:
# [[19, 22],
#  [43, 50]]
Matrix representations: Matrices are represented as space-separated values in row-major order.

2×2 matrix [[a,b],[c,d]] → a b c d
3×3 matrix [[a,b,c],[d,e,f],[g,h,i]] → a b c d e f g h i
Scripting Integration
Shell Script Example
#!/bin/bash
source /path/to/calcx-advanced/lib/conversions.sh
source /path/to/calcx-advanced/lib/math_functions.sh

# Calculate fuel efficiency
mpg=35.5
kpl=$(echo "scale=2; $(mph_to_kph 1) / 3.785411784 * $mpg" | bc)
echo "Fuel efficiency: $mpg MPG = $kpl km/L"

# Financial calculation
principal=10000
rate=0.05
years=10
amount=$(calcx "scale=2; $principal * e($rate * $years)")
echo "Compound interest (continuous): \$${amount}"

# Factorial sum
sum=0
for i in {1..10}; do
    fact=$(factorial $i)
    sum=$(calcx "$sum + $fact")
done
echo "Sum of factorials 1! to 10!: $sum"
Data Processing Pipeline
# Convert temperature data file
while read temp_f; do
    temp_c=$(fahrenheit_to_celsius $temp_f)
    echo "$temp_f°F = $temp_c°C"
done < temperatures.txt > converted.txt

# Statistical analysis with calcx
cat data.csv | awk '{sum+=$1} END {print sum/NR}' | xargs -I {} calcx "sqrt({})"
Configuration
Configuration File
Create ~/.config/calcx/calcx.conf:

# Numerical precision (number of significant figures)
# -1 uses general format (%g), positive values set precision
CALC_PRECISION=15

# Maximum history entries
MAX_HISTORIAL=50

# History file location
HIST_FILE="$HOME/.calcx_history"

# Color output (true/false)
COLOR_OUTPUT=true

# Verbose mode for debugging
VERBOSE_MODE=false
Environment Variables
Override configuration via environment variables:

export CALC_PRECISION=20
export MAX_HISTORIAL=100
calcx "4*a(1)"  # Calculate π with 20-digit precision
Configuration Priority
Settings are loaded in order (later overrides earlier):

System defaults (hardcoded in source)
System-wide config (/etc/calcx/calcx.conf)
User config (~/.config/calcx/calcx.conf)
Environment variables
Command-line arguments
Testing
Running Tests
cd calcx-advanced/tests
./run_tests.sh
Output includes:

Basic functionality tests
Unit tests for conversion library (14 test cases)
Unit tests for matrix operations (27 test cases)
Integration tests for end-to-end workflows
Benchmark tests for performance validation
Test Structure
tests/
├── run_tests.sh           # Main test runner
├── test_basic.sh          # Basic functionality
├── unit/
│   ├── test_conversions.sh  # Unit conversion tests
│   └── test_matrix.sh       # Matrix operation tests
├── integration/
│   └── (integration tests)
└── benchmark/
    └── (performance tests)
Writing Tests
Example unit test:

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
Updating
cd /path/to/calcx-advanced
./scripts/update.sh
The update script performs:

Repository fetch from GitHub
Stash uncommitted local changes
Version comparison
Merge latest changes
Restore stashed changes
Dependency validation
Permission updates
Uninstallation
cd /path/to/calcx-advanced
./scripts/uninstall.sh
Removes:

Symbolic link from /usr/local/bin/calcx
User configuration directory (optional)
History files (optional)
Performance Characteristics
Computational precision: Arbitrary precision via GNU bc (limited only by available memory)

Expression evaluation: Sub-millisecond for standard arithmetic operations

Matrix operations:

2×2 determinant: ~1ms
3×3 determinant: ~2ms
Matrix multiplication: O(n³) complexity
Memory footprint: <10MB base, scales with calculation complexity and history size

Supported ranges:

Integers: Limited by memory
Decimals: Arbitrary precision (configurable)
Exponents: bc supports up to 2^31-1
Development
Project Structure
calcx-advanced/
├── calcx.sh                    # Entry point wrapper
├── src/
│   └── calcx-advanced.sh       # Main calculator engine (2500+ lines)
├── lib/                        # Reusable function libraries
│   ├── math_functions.sh       # Number theory and basic math
│   ├── conversions.sh          # Unit conversion (380+ lines)
│   ├── matrix.sh               # Linear algebra (360+ lines)
│   └── colors.sh               # Terminal color definitions
├── config/
│   └── calcx.conf              # Default configuration
├── scripts/
│   ├── install.sh              # Installation automation
│   ├── uninstall.sh            # Clean removal
│   └── update.sh               # Version management
├── tests/                      # Test suite (41 tests)
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
├── VERSION                     # Version tracking
└── README.md
Contributing
Code standards:

POSIX-compliant shell scripting where possible
Use shellcheck for static analysis
Maintain bc compatibility for portability
Document all functions with inline comments
Include error handling for edge cases
Testing requirements:

Unit tests for all new library functions
Integration tests for feature additions
Performance benchmarks for optimization changes
Verify calculations against known values
Commit conventions:

type(scope): subject

body

footer
Types: feat, fix, docs, refactor, test, perf

Debugging
Enable debug mode:

export CALCX_DEBUG=1
export CALCX_VERBOSE=1
calcx "expression" 2> debug.log
Trace execution:

bash -x calcx.sh "expression"
Known Limitations
Zenity GUI required for interactive mode (command-line mode works without)
Complex matrix operations (>3×3) require Python with NumPy
DFT implementation limited to small datasets (performance)
Windows compatibility requires Git Bash or WSL
Some trigonometric functions use bc's limited precision (bc -l provides ~20 digits)
Troubleshooting
bc not found:

# Ubuntu/Debian
sudo apt install bc

# macOS
brew install bc

# Arch Linux
sudo pacman -S bc
Zenity not found (GUI mode):

# Ubuntu/Debian
sudo apt install zenity

# macOS
brew install zenity

# Arch Linux
sudo pacman -S zenity
Permission denied:

chmod +x calcx.sh src/*.sh lib/*.sh scripts/*.sh
Python module errors:

python3 -m pip install numpy  # For advanced matrix operations
License
MIT License

Copyright (c) 2025 Genesis GZ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author
Genesis GZ Full Stack Developer GitHub: @genesisgzdev Email: genzt.dev@pm.me

Version 1.0.0 (2025-11-11)
