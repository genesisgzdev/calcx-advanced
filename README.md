# CalcX Advanced

A sophisticated mathematical computation engine that bridges the gap between the precision of traditional command-line tools and the accessibility of modern interfaces. Built with Bash and Python, CalcX Advanced delivers professional-grade calculations through an intuitive terminal experience.

## What This Does

CalcX Advanced is a full-featured calculator that goes beyond basic arithmetic. It handles everything from quadratic equations and matrix operations to discrete Fourier transforms and complex number arithmetic. Whether you're a researcher needing arbitrary precision, an engineer working with system matrices, or a student exploring numerical methods, this tool provides the computational backbone without unnecessary overhead.

The core philosophy is straightforward: leverage existing, battle-tested Unix tools (bc for precision, Python for complex operations) and wrap them in a cohesive interface that doesn't get in your way. No bloat, no unnecessary dependencies, no trying to be smarter than you are.

## Key Capabilities

The calculator implements a comprehensive mathematical toolkit organized by problem domain.

**Equation Solving** handles quadratic and cubic equations directly through algebraic methods, plus a general-purpose Newton-Raphson root finder for transcendental equations. The quadratic solver returns both real and complex roots with proper discriminant analysis, while the cubic solver manages the more intricate case of three-degree polynomials.

**Matrix Operations** includes multiplication, determinant calculation, matrix inversion, and linear system solving. The implementation respects dimension limits for computational efficiency while maintaining numerical stability through validated approaches.

**Complex Number Arithmetic** provides complete support for rectangular and polar representations. You can add, multiply, divide complex numbers, compute modulus and argument, extract conjugates, and evaluate exponentials, logarithms, and arbitrary powers in the complex domain.

**Numerical Analysis** brings calculus to the terminal. Simpson's rule for numerical integration, finite difference approximation for derivatives, and Euler's method for solving ordinary differential equations. Practical tools for when you need numerical solutions rather than symbolic ones.

**Statistical Computation** generates descriptive statistics from datasets, handles combinatorial problems with permutations and combinations, and models binomial distributions. The calculator manages factorial calculations including extended precision through the Gamma function.

**Discrete Fourier Transform** converts time-domain signals to frequency-domain representations, essential for signal processing workflows.

**Number Theory Utilities** include prime factorization for integer analysis and base conversion between binary, octal, decimal, and hexadecimal representations.

**Calculation History** persists across sessions. Every calculation is recorded, can be recalled, and history is maintained in a configurable file for auditing and reproducibility.

## Installation

### Prerequisites

CalcX Advanced requires minimal dependencies, all commonly available on Unix-like systems:

- **Bash 4.0 or later** — The core shell environment
- **GNU bc 1.07 or later** — For arbitrary-precision arithmetic
- **Python 3.6 or later** — For complex mathematical operations (with standard math libraries)
- **awk** — For text processing and result formatting

Optional but recommended for enhanced usability:

- **fzf** or **gum** — For interactive menu selection with better UX

On Ubuntu/Debian systems:
```bash
sudo apt-get install bc python3
```

On macOS with Homebrew:
```bash
brew install bc python3
```

On Arch Linux:
```bash
sudo pacman -S bc python
```

### Quick Start

Get the calculator running in seconds:

```bash
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x calcx_advanced.sh
./calcx_advanced.sh
```

Or use it directly from anywhere after copying to your PATH:

```bash
cp calcx_advanced.sh /usr/local/bin/calcx
chmod +x /usr/local/bin/calcx
calcx                    # Launch interactive mode
calcx "2 * 3 + sqrt(16)" # Direct calculation
```

## Usage Patterns

### Interactive Mode

Start the calculator without arguments to enter the interactive menu:

```bash
./calcx_advanced.sh
```

You'll see a numbered menu with all available operations. Navigate using the option numbers, or install fzf/gum for a smoother fuzzy-search interface.

### Command-Line Mode

For scripting or quick calculations, pass the expression as arguments:

```bash
./calcx_advanced.sh "sqrt(144)"
./calcx_advanced.sh "3.14159 * 2"
./calcx_advanced.sh "2^10"
```

The calculator supports standard mathematical notation. bc syntax is preferred for pure arithmetic, while Python syntax is available through the fallback engine.

### Precision Configuration

Inside interactive mode, select option 12 to adjust numerical precision. The default is 6 significant figures, but you can configure it anywhere from -1 (general format) to your desired precision level. This setting persists across sessions.

### Working with History

All calculations are automatically logged. Access history through the interactive menu (option 10), or inspect the history file directly at `~/.calc_ultra_history.log`. History is limited to the 20 most recent calculations by default, but this is configurable through the `MAX_HISTORIAL` variable.

## Technical Architecture

The implementation follows a layered design that separates concerns and enables independent testing of components.

The **computation layer** uses GNU bc for all floating-point operations. bc provides arbitrary precision arithmetic without rounding errors that plague standard floating-point implementations. For operations requiring transcendental functions (sine, exponential, etc.), Python's math and cmath libraries serve as the fallback, with graceful degradation if Python is unavailable.

The **interface layer** provides both command-line and interactive modes. The interactive mode builds a menu system that forks to individual calculation functions. Each mathematical operation is implemented as a standalone bash function with input validation, error handling, and result formatting.

The **persistence layer** handles calculation history. Entries are appended to a file and maintained in memory as an array. The implementation respects a maximum history size to prevent unbounded disk usage.

The **utility layer** includes helper functions for common tasks: input validation with regex patterns, formatted output with ANSI colors, dependency checking, and user interaction prompts.

### Code Organization

The 2500-line script is organized into logical sections, each clearly marked with comment headers explaining the purpose and implementation strategy. This structure makes it straightforward to locate specific functionality, understand the flow, and extend with new operations.

Critical sections include the Python detection logic at the top (handles cross-platform python vs python3), the command-line parsing for non-interactive mode, history management infrastructure, and the main menu dispatcher.

## Notable Implementation Details

**Cross-Platform Python Detection** — The script intelligently detects whether your system has python3 (Unix standard) or just python (Windows). It validates the commands are actually functional, not just aliases to installer stubs.

**Error Handling** — Every user input is validated before computation. Regex patterns check that coefficients are valid numbers. Divide-by-zero conditions are caught. When complex numbers emerge from quadratic equations, they're properly formatted and presented.

**Flexible Output Formatting** — Results can be formatted with adjustable precision. The script uses printf to ensure consistent spacing and alignment in tabular output (particularly useful for matrix operations).

**Graceful Degradation** — If bc isn't available, Python handles arithmetic. If neither is available, the calculator exits with clear error messages rather than producing garbage. If fzf and gum are both missing, the calculator falls back to simple numbered menus.

**Color Output with Safety** — ANSI color codes improve readability without making the code illegible. Colors are properly reset to prevent terminal state corruption.

## Use Cases

**Academic Research** — Solve systems of equations, compute Fourier transforms, work with matrices and complex numbers without firing up MATLAB or Mathematica.

**Engineering Calculations** — Quick matrix inversions, system solving, and numerical integration for design validation.

**System Administration** — Base conversion utilities, GCD/LCM for scheduling problems, factorization for cryptographic purposes.

**Data Analysis** — Generate descriptive statistics, examine distributions, and validate calculations from your data pipeline.

**Educational Tool** — Explore numerical methods hands-on. The calculator's code demonstrates how to implement mathematical algorithms in practice.

## Configuration

Most behavior is controlled through variables at the top of the script:

- `MAX_HISTORIAL` — Number of history entries to retain (default: 20)
- `PRECISION` — Default output precision in significant figures (default: 6)
- `HIST_FILE` — Path where calculation history is stored

Edit these values directly in the script if needed, or set them via environment variables before running.

## Extending CalcX Advanced

The modular function structure makes adding new operations straightforward. Each calculation function follows this pattern:

1. Display a descriptive header with operation name
2. Prompt for necessary inputs using read commands
3. Validate all inputs with regex or bc tests
4. Perform computation through bc or Python
5. Format and display results
6. Add entry to history
7. Wait for user acknowledgment

To add a new operation, implement it as a bash function following this pattern, then add a menu entry and case statement in the relevant submenu function.

## Performance Characteristics

Standard arithmetic operations (addition, multiplication, trigonometric functions) execute in sub-second time. Matrix operations scale with dimensions — a 10x10 matrix determinant completes instantly, while 100x100 systems take a few hundred milliseconds. The implementation sacrifices some speed for numerical stability, which is the right tradeoff for mathematical calculations where correctness matters more than microsecond advantages.

Memory usage is minimal. The calculator maintains about 50MB during active computation, with history storage consuming negligible disk space.

## Known Limitations and Future Work

**GUI** — The current implementation is terminal-based. A Zenity-based GUI wrapper could be added for users preferring graphical interfaces, though the terminal approach is more versatile for scripting.

**Matrix Dimensions** — Matrix operations are constrained to 100x100 maximum to prevent runaway computation. This covers virtually all practical scenarios.

**Numerical Stability** — Some operations (particularly matrix inversion of nearly-singular matrices) may produce inaccurate results. This is inherent to floating-point computation and not specific to this implementation.

**Dependencies** — Relying on external tools (bc, Python) means unavailable environments won't run the calculator. This is an acceptable tradeoff for avoiding reimplementation of established mathematical libraries.

Future enhancements might include plugin architecture for user-defined functions, WebAssembly compilation for browser execution, or REST API interface for remote calculations.

## Contributing

The project welcomes improvements, bug reports, and feature suggestions. Follow this workflow:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-enhancement`
3. Implement changes following the existing code style
4. Test thoroughly with edge cases
5. Commit with clear messages: `git commit -m "type: description"`
6. Push and open a pull request

Code should follow Google Shell Style Guide conventions for consistency with existing implementations.

## Licensing

CalcX Advanced is distributed under the MIT License. You're free to use, modify, and distribute this software in commercial and personal projects. See the LICENSE file for complete terms.

## Support and Contact

For questions, bug reports, or suggestions, reach out through the project repository or contact the maintainer directly.

**Repository:** https://github.com/genesisgzdev/calcx-advanced  
**Maintainer:** Genesis GZ  
**Email:** genzt.dev@pm.me

---

*Professional-grade mathematics deserves tools that respect your time. CalcX Advanced provides the computational horsepower and interface transparency that serious calculation work demands.*
