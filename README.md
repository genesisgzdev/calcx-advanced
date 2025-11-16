# CalcX Advanced

A high-performance scientific calculator built with Bash, featuring arbitrary precision
arithmetic via GNU bc and Python. Includes both command-line interface and interactive
GUI mode powered by Zenity for advanced mathematical operations.

## Features

### Command-Line Mode
Execute mathematical expressions directly from the terminal:
```bash
calcx "2^1024"                    # Large integer calculations
calcx "scale=50; 4*a(1)"          # Pi to 50 decimal places
calcx "e(10)"                     # Exponential functions
Interactive GUI Mode
Launch the full calculator interface with Zenity dialogs:

calcx                             # Start interactive mode
Provides access to:

Quadratic and cubic equation solvers
Matrix operations (determinants, inverse, multiplication)
Complex number arithmetic
Numerical calculus (integration, differentiation, ODEs)
Statistical analysis and combinatorics
Number theory (prime factorization, base conversion, GCD/LCM)
Function Libraries
Reusable Bash libraries for scripting:

lib/math_functions.sh - Factorial, Fibonacci, GCD, LCM, primality testing
lib/conversions.sh - Unit conversions across 9 measurement categories
lib/matrix.sh - Linear algebra operations for 2x2 and 3x3 matrices
Installation
Clone and install:

git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x scripts/install.sh && ./scripts/install.sh
Or install manually:

git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x calcx.sh src/calcx-advanced.sh lib/*.sh scripts/*.sh
sudo ln -sf "$(pwd)/calcx.sh" /usr/local/bin/calcx
Requirements
Required:

Bash 4.0+
GNU bc 1.07+
Optional:

Python 3.6+ (enables advanced features like DFT, complex numbers)
Zenity 3.0+ (required for GUI mode)
Usage Examples
Basic Calculations
calcx "100 + 50 * 2"              # Result: 200
calcx "sqrt(169)"                 # Result: 13
calcx "2^8"                       # Result: 256
Scientific Functions
The bc calculator provides these functions:

calcx "s(3.14159/2)"              # sine
calcx "c(0)"                      # cosine
calcx "l(2.718281828)"            # natural logarithm
calcx "e(1)"                      # exponential (e^x)
calcx "scale=10; sqrt(2)"         # square root with precision
Python Fallback
Complex expressions automatically use Python when bc cannot evaluate:

calcx "import math; math.factorial(50)"
calcx "complex(3, 4) * complex(1, 2)"
Library Functions
Math Functions
Source the library:

source lib/math_functions.sh
Available functions:

factorial 10                      # Returns: 3628800
fibonacci 10                      # Prints: 0 1 1 2 3 5 8 13 21 34
gcd 48 18                         # Returns: 6
lcm 12 15                         # Returns: 60
is_prime 97 && echo "Prime"       # Test primality
Unit Conversions
Source the library:

source lib/conversions.sh
Temperature:

celsius_to_fahrenheit 100         # 212
fahrenheit_to_kelvin 32           # 273.15
kelvin_to_celsius 373.15          # 100
Length:

miles_to_kilometers 26.2          # 42.164877
meters_to_feet 1000               # 3280.84
inches_to_centimeters 12          # 30.48
Weight:

kilograms_to_pounds 75            # 165.3465
pounds_to_kilograms 200           # 90.7185
Speed:

mph_to_kph 65                     # 104.60736
kph_to_mps 100                    # 27.777778
Data Storage:

bytes_to_kilobytes 2048           # 2
megabytes_to_gigabytes 2048       # 2
gigabytes_to_terabytes 1024       # 1
Generic conversion with natural language:

convert "100 celsius to fahrenheit"        # 212
convert "50 miles to kilometers"           # 80.4672
convert "1024 megabytes to gigabytes"      # 1
Matrix Operations
Source the library:

source lib/matrix.sh
2x2 matrices:

determinant_2x2 3 8 4 6                    # -14
inverse_2x2 4 7 2 6                        # 0.6 -0.7 -0.2 0.4
multiply_2x2 1 2 3 4 5 6 7 8               # Matrix multiplication
add_2x2 1 2 3 4 5 6 7 8                    # Element-wise addition
scalar_multiply_2x2 3 1 2 3 4              # Scalar multiplication
transpose_2x2 1 2 3 4                      # Transpose
3x3 matrices:

determinant_3x3 6 1 1 4 -2 5 2 8 7         # -306
transpose_3x3 1 2 3 4 5 6 7 8 9
add_3x3 1 2 3 4 5 6 7 8 9 9 8 7 6 5 4 3 2 1
Utilities:

identity_2x2                               # 1 0 0 1
identity_3x3                               # 1 0 0 0 1 0 0 0 1
is_symmetric_2x2 1 2 2 4 && echo "Symmetric"
Format output:

result=$(multiply_2x2 1 2 3 4 5 6 7 8)
format_matrix_2x2 $result
# Output:
# [[19, 22],
#  [43, 50]]
Scripting Integration
Example shell script using the libraries:

#!/bin/bash
source /path/to/calcx-advanced/lib/conversions.sh
source /path/to/calcx-advanced/lib/math_functions.sh

# Convert temperature data
while read temp_f; do
    temp_c=$(fahrenheit_to_celsius $temp_f)
    echo "$temp_f°F = $temp_c°C"
done < temperatures.txt

# Calculate compound interest
principal=10000
rate=0.05
years=10
amount=$(calcx "scale=2; $principal * e($rate * $years)")
echo "Amount after $years years: \$${amount}"

# Sum of factorials
sum=0
for i in {1..10}; do
    fact=$(factorial $i)
    sum=$(calcx "$sum + $fact")
done
echo "Sum of factorials 1! to 10!: $sum"
Configuration
Create ~/.config/calcx/calcx.conf:

# Numerical precision (significant figures)
CALC_PRECISION=15

# History settings
MAX_HISTORIAL=50
HIST_FILE="$HOME/.calcx_history"

# Display options
COLOR_OUTPUT=true
VERBOSE_MODE=false
Override with environment variables:

export CALC_PRECISION=20
calcx "4*a(1)"                             # Pi with 20 digits
Configuration priority (highest to lowest):

Command-line arguments
Environment variables
User config (~/.config/calcx/calcx.conf)
System config (/etc/calcx/calcx.conf)
Defaults
Testing
Run the test suite:

cd calcx-advanced/tests
./run_tests.sh
Test coverage:

14 unit tests for unit conversions
27 unit tests for matrix operations
Basic functionality tests
Integration tests
Benchmarks
Performance
Precision: Arbitrary precision arithmetic via GNU bc (memory-limited only)

Speed: Sub-millisecond for standard operations

Matrix operations:

2x2 determinant: ~1ms
3x3 determinant: ~2ms
Multiplication: O(n³) complexity
Memory: Less than 10MB base footprint

Maintenance
Update to latest version:

cd /path/to/calcx-advanced
./scripts/update.sh
Uninstall:

cd /path/to/calcx-advanced
./scripts/uninstall.sh
Known Limitations
Zenity required for interactive GUI mode (command-line works without it)
Matrix operations larger than 3x3 require Python with NumPy
DFT limited to small datasets for performance reasons
Windows requires Git Bash or WSL
Trigonometric functions limited to bc precision (~20 digits)
Troubleshooting
bc not found:

sudo apt install bc              # Ubuntu/Debian
brew install bc                  # macOS
sudo pacman -S bc                # Arch Linux
Zenity not found:

sudo apt install zenity          # Ubuntu/Debian
brew install zenity              # macOS
sudo pacman -S zenity            # Arch Linux
Permission denied:

chmod +x calcx.sh src/*.sh lib/*.sh scripts/*.sh
Project Structure
calcx-advanced/
├── calcx.sh                     # Entry point
├── src/
│   └── calcx-advanced.sh        # Main calculator (2500+ lines)
├── lib/
│   ├── math_functions.sh        # Number theory functions
│   ├── conversions.sh           # Unit conversions (380+ lines)
│   ├── matrix.sh                # Linear algebra (360+ lines)
│   └── colors.sh                # Terminal colors
├── config/
│   └── calcx.conf               # Default configuration
├── scripts/
│   ├── install.sh
│   ├── uninstall.sh
│   └── update.sh
├── tests/                       # 41 tests
│   ├── run_tests.sh
│   ├── test_basic.sh
│   └── unit/
│       ├── test_conversions.sh
│       └── test_matrix.sh
├── examples/
├── docs/
└── VERSION
Contributing
Code standards:

POSIX-compliant shell scripting
Use shellcheck for validation
Document all functions
Include unit tests
Commit format:

type(scope): subject

body
Types: feat, fix, docs, refactor, test, perf

License
MIT License - Copyright (c) 2025 Genesis GZ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author
Genesis GZ - Full Stack Developer
GitHub: @genesisgzdev
Email: genzt.dev@pm.me

Version 1.0.0 (2025-11-11)
