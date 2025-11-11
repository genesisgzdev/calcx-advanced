Advanced mathematical calculator with graphical interface and command-line support
## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Mathematical Functions](#mathematical-functions)
- [Development](#development)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Overview

CalcX Advanced is a comprehensive mathematical calculator developed in Bash with Python support, featuring a Zenity-based graphical interface. The calculator provides extensive mathematical operations ranging from basic arithmetic to complex number calculations, matrix operations, and unit conversions. Designed for both casual users and professionals requiring advanced computational capabilities directly from their terminal or through an intuitive GUI.

## Features

### Core Functionality

- **Multiple Interface Modes**
  - Graphical User Interface via Zenity
  - Command-line direct calculation
  - Interactive shell mode
  - Batch processing support

- **Mathematical Operations**
  - Basic arithmetic (addition, subtraction, multiplication, division)
  - Advanced arithmetic (exponentiation, roots, modulo)
  - Trigonometric functions (sin, cos, tan, asin, acos, atan)
  - Hyperbolic functions (sinh, cosh, tanh)
  - Logarithmic functions (natural log, base 10, custom base)
  - Exponential calculations
  - Factorial and combinatorial operations
  - Complex number arithmetic
  - Matrix operations (multiplication, determinant, inverse)
  - Statistical functions (mean, median, standard deviation)

- **Conversion Systems**
  - Temperature (Celsius, Fahrenheit, Kelvin)
  - Length (metric and imperial units)
  - Weight and mass conversions
  - Base number conversions (binary, octal, hexadecimal)
  - Currency conversion support (with external API)

- **Additional Features**
  - Persistent calculation history
  - Configurable precision settings
  - Session management
  - Error handling and validation
  - Cross-platform compatibility

## System Requirements

### Minimum Requirements

- Operating System: Linux, macOS, Windows (via WSL or Git Bash)
- Bash: Version 4.0 or higher
- Python: Version 3.6 or higher
- Available RAM: 512 MB
- Disk Space: 10 MB

### Required Dependencies

- `zenity` - GUI dialog interface
- `bc` - Arbitrary precision calculator
- `python3` - Python interpreter
- `coreutils` - Basic Unix utilities

### Optional Dependencies

- `gnuplot` - For graphing capabilities
- `dc` - Reverse-polish calculator
- `curl` - For online features

## Installation

### Linux Installation

#### Debian/Ubuntu-based Systems
```bash
# Install dependencies
sudo apt update
sudo apt install -y zenity bc python3 python3-pip coreutils

# Clone repository
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced

# Run installer
chmod +x scripts/install.sh
sudo ./scripts/install.sh
```

#### Red Hat/Fedora-based Systems
```bash
# Install dependencies
sudo dnf install -y zenity bc python3 python3-pip coreutils

# Clone and install
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x scripts/install.sh
sudo ./scripts/install.sh
```

#### Arch Linux
```bash
# Install dependencies
sudo pacman -S zenity bc python coreutils

# Clone and install
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x scripts/install.sh
sudo ./scripts/install.sh
```

### macOS Installation
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install zenity bc python3 coreutils

# Clone and install
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x scripts/install.sh
./scripts/install.sh
```

### Windows Installation

#### Using Windows Subsystem for Linux (WSL)
```bash
# Enable WSL and install Ubuntu from Microsoft Store
# Then follow Linux installation instructions
```

#### Using Git Bash
```bash
# Zenity comes pre-installed with Git Bash
# Clone repository
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced

# Make executable
chmod +x calcx.sh

# Run directly
./calcx.sh
```

### Manual Installation
```bash
# Clone repository
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced

# Make scripts executable
chmod +x calcx.sh
chmod +x src/calcx-advanced.sh
chmod +x scripts/*.sh

# Create symbolic link (optional)
sudo ln -sf $(pwd)/calcx.sh /usr/local/bin/calcx

# Copy configuration
mkdir -p ~/.config/calcx
cp config/calcx.conf ~/.config/calcx/
```

## Usage

### GUI Mode

Launch the graphical interface:
```bash
calcx
# or
./calcx.sh
```

Navigate through the menu to select operation types:
1. Basic Calculator
2. Scientific Mode
3. Unit Converter
4. Matrix Operations
5. Settings
6. History
7. Exit

### Command-Line Mode

Direct calculation from terminal:
```bash
# Basic operations
calcx "2 + 2"
calcx "10 * 5 - 3"
calcx "(8 + 2) / 5"

# Scientific functions
calcx "sin(45)"
calcx "log(100)"
calcx "sqrt(144)"

# Complex expressions
calcx "2^8 + sqrt(16) * log(10)"
calcx "factorial(5) + fibonacci(10)"
```

### Interactive Shell Mode

Start interactive session:
```bash
calcx --shell
# or
calcx -i
```

Interactive commands:
```
CalcX> 2 + 2
4

CalcX> sqrt(16)
4

CalcX> history
[Shows calculation history]

CalcX> help
[Shows available commands]

CalcX> exit
```

### Batch Processing

Process multiple calculations from file:
```bash
# Create calculation file
echo "2 + 2" > calculations.txt
echo "sqrt(16)" >> calculations.txt
echo "log(100)" >> calculations.txt

# Process file
calcx --batch calculations.txt
```

## Configuration

Configuration file location: `~/.config/calcx/calcx.conf`

### Configuration Parameters
```bash
# Precision Settings
CALC_PRECISION=10          # Decimal places for results
SCIENTIFIC_NOTATION=false  # Use scientific notation for large numbers

# Interface Settings
DEFAULT_MODE=scientific    # Options: basic, scientific, programmer
GUI_THEME=default         # GUI theme selection

# History Settings
MAX_HISTORY=1000          # Maximum history entries
HISTORY_FILE="$HOME/.calcx_history"  # History file location

# System Settings
VERBOSE_MODE=false        # Enable debug output
COLOR_OUTPUT=true         # Colored terminal output
TEMP_DIR="/tmp/calcx"     # Temporary files directory
LOG_FILE="$HOME/.calcx.log"  # Log file location
ENABLE_LOGGING=false      # Enable logging
```

### Environment Variables
```bash
export CALCX_PRECISION=15        # Override precision
export CALCX_MODE=scientific      # Set default mode
export CALCX_HISTORY=~/.calcx    # Custom history location
```

## Project Structure
```
calcx-advanced/
├── calcx.sh                 # Main launcher script
├── src/
│   └── calcx-advanced.sh    # Core calculator engine
├── lib/
│   ├── math_functions.sh    # Mathematical function library
│   ├── colors.sh           # Terminal color definitions
│   ├── conversions.sh      # Unit conversion functions
│   └── matrix.sh           # Matrix operation functions
├── config/
│   ├── calcx.conf          # Default configuration
│   └── units.conf          # Unit conversion definitions
├── scripts/
│   ├── install.sh          # Installation script
│   ├── uninstall.sh        # Uninstallation script
│   └── update.sh           # Update script
├── tests/
│   ├── run_tests.sh        # Test runner
│   ├── test_basic.sh       # Basic operation tests
│   ├── test_scientific.sh  # Scientific function tests
│   └── test_matrix.sh      # Matrix operation tests
├── examples/
│   ├── basic_usage.sh      # Basic usage examples
│   ├── advanced_usage.sh   # Advanced usage examples
│   └── scientific.sh       # Scientific calculation examples
├── docs/
│   ├── MANUAL.md           # User manual
│   ├── API.md              # API documentation
│   └── CONTRIBUTING.md     # Contribution guidelines
└── assets/
    ├── icons/              # GUI icons
    └── themes/             # GUI themes
```

## Mathematical Functions

### Arithmetic Operations

- Addition: `a + b`
- Subtraction: `a - b`
- Multiplication: `a * b`
- Division: `a / b`
- Modulo: `a % b`
- Exponentiation: `a ^ b`
- Square root: `sqrt(a)`
- Nth root: `root(a, n)`

### Trigonometric Functions

- Sine: `sin(x)`
- Cosine: `cos(x)`
- Tangent: `tan(x)`
- Arcsine: `asin(x)`
- Arccosine: `acos(x)`
- Arctangent: `atan(x)`
- Degrees to radians: `rad(x)`
- Radians to degrees: `deg(x)`

### Logarithmic and Exponential

- Natural logarithm: `ln(x)` or `log(x)`
- Base-10 logarithm: `log10(x)`
- Base-2 logarithm: `log2(x)`
- Custom base: `logn(x, base)`
- Exponential: `exp(x)` or `e^x`
- Power: `pow(x, y)`

### Statistical Functions

- Sum: `sum(a, b, c, ...)`
- Mean: `mean(a, b, c, ...)`
- Median: `median(a, b, c, ...)`
- Standard deviation: `stddev(a, b, c, ...)`
- Variance: `variance(a, b, c, ...)`
- Minimum: `min(a, b, c, ...)`
- Maximum: `max(a, b, c, ...)`

### Special Functions

- Factorial: `factorial(n)` or `n!`
- Gamma function: `gamma(x)`
- Beta function: `beta(x, y)`
- Permutation: `perm(n, r)`
- Combination: `comb(n, r)`
- Fibonacci: `fib(n)`
- Greatest common divisor: `gcd(a, b)`
- Least common multiple: `lcm(a, b)`

### Complex Numbers

- Complex addition: `(a+bi) + (c+di)`
- Complex multiplication: `(a+bi) * (c+di)`
- Complex division: `(a+bi) / (c+di)`
- Magnitude: `abs(a+bi)`
- Phase: `phase(a+bi)`
- Conjugate: `conj(a+bi)`

### Matrix Operations

- Matrix addition: `[A] + [B]`
- Matrix multiplication: `[A] * [B]`
- Determinant: `det([A])`
- Inverse: `inv([A])`
- Transpose: `trans([A])`
- Eigenvalues: `eigen([A])`

## Development

### Build from Source
```bash
# Clone repository
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced

# Checkout development branch
git checkout develop

# Install development dependencies
pip3 install --user pytest black flake8

# Run tests
./tests/run_tests.sh

# Format code
black src/*.py
shellcheck src/*.sh
```

### Code Style Guidelines

- Shell scripts follow POSIX standards
- Python code follows PEP 8
- Use 4 spaces for indentation
- Maximum line length: 100 characters
- Functions and variables use snake_case
- Constants use UPPERCASE

### Adding New Functions

1. Add function to appropriate library file
2. Update documentation
3. Add unit tests
4. Update examples
5. Submit pull request

## Testing

### Running Tests
```bash
# Run all tests
cd tests
./run_tests.sh

# Run specific test suite
./test_basic.sh
./test_scientific.sh
./test_matrix.sh

# Run with verbose output
./run_tests.sh -v

# Run with coverage
./run_tests.sh --coverage
```

### Test Coverage

Current test coverage includes:
- Basic operations: 100%
- Scientific functions: 95%
- Matrix operations: 90%
- Unit conversions: 85%
- Error handling: 95%

## Troubleshooting

### Common Issues

#### Calculator not launching
```bash
# Check dependencies
which zenity bc python3

# Check permissions
ls -l calcx.sh

# Fix permissions
chmod +x calcx.sh
```

#### GUI not appearing
```bash
# Check display variable
echo $DISPLAY

# Set display (if needed)
export DISPLAY=:0

# Test zenity
zenity --info --text="Test"
```

#### Calculations returning errors
```bash
# Check bc installation
echo "2 + 2" | bc

# Check Python installation
python3 --version

# Run diagnostic
./scripts/diagnose.sh
```

#### Permission denied errors
```bash
# Fix script permissions
find . -name "*.sh" -exec chmod +x {} \;

# Fix installation directory
sudo chown -R $USER:$USER /usr/local/bin/calcx
```

### Debug Mode

Enable debug mode for detailed output:
```bash
# Set environment variable
export CALCX_DEBUG=1

# Run calculator
calcx

# Check log file
tail -f ~/.calcx.log
```

### Getting Help

- Check documentation: `docs/MANUAL.md`
- View examples: `examples/`
- Report issues: https://github.com/genesisgzdev/calcx-advanced/issues
- Contact support: genzt.dev@pm.me

## Contributing

### How to Contribute

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Make changes and test
4. Commit changes (`git commit -m "feat: add new feature"`)
5. Push to branch (`git push origin feature/new-feature`)
6. Create Pull Request

### Contribution Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation
- Keep commits atomic and descriptive
- Reference issues in commits

### Commit Message Format
```
type: subject

body (optional)

footer (optional)
```

Types: feat, fix, docs, style, refactor, perf, test, chore

### Development Environment Setup
```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/calcx-advanced.git
cd calcx-advanced

# Add upstream remote
git remote add upstream https://github.com/genesisgzdev/calcx-advanced.git

# Create branch
git checkout -b feature/your-feature

# Make changes and test
./tests/run_tests.sh

# Commit and push
git add .
git commit -m "feat: your feature description"
git push origin feature/your-feature
```

## License

This project is licensed under the MIT License.
```
MIT License

Copyright (c) 2025 Genesis GZ (genesisgzdev)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Author

Genesis GZ (genesisgzdev)

- GitHub: https://github.com/genesisgzdev
- Email: genzt.dev@pm.me
- Repository: https://github.com/genesisgzdev/calcx-advanced

## Version History

- **1.0.0** (2025-11-11)
  - Initial release
  - Core mathematical functions
  - Zenity GUI implementation
  - Command-line interface
  - Basic test suite

## Acknowledgments

- GNU Project for bc calculator
- Zenity development team
- Python Software Foundation
- Open source community contributors

---
Thank you very much for watching :)
