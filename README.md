# CalcX Advanced

A professional-grade mathematical computation engine delivering arbitrary precision arithmetic and advanced scientific calculations through an elegant command-line interface. Built with Bash and Python, CalcX Advanced merges the reliability of battle-tested Unix tools with modern usability design.

## Overview

CalcX Advanced transcends basic calculator functionality. It solves quadratic and cubic equations, inverts matrices, performs numerical integration using Simpson's rule, computes discrete Fourier transforms, and executes complex number operations across rectangular and polar representations. Researchers rely on it for validation work, engineers use it for rapid design calculations, and students explore numerical methods without specialized software overhead.

The architecture leverages GNU bc for arbitrary precision arithmetic, Python's math libraries for transcendental functions, and a layered design pattern that separates computation, interface, persistence, and utility concerns. The result is a tool that respects your computational needs without unnecessary complexity.

## Technical Specifications

### Multi-Layer Architecture

The **computation layer** uses GNU bc for all floating-point operations, delivering arbitrary precision arithmetic without the rounding errors inherent in standard floating-point implementations. Transcendental functions (trigonometric, logarithmic, exponential) fall back to Python's math and cmath libraries with graceful degradation when unavailable.

The **interface layer** provides dual-mode operation: command-line for scripting and quick calculations, interactive for exploratory work. The interactive mode uses a menu system that dispatches to individual calculation functions, each implementing independent input validation and error handling.

The **persistence layer** manages calculation history through file storage with in-memory arrays, respecting maximum history size to prevent unbounded disk usage while maintaining rapid recall.

The **utility layer** provides reusable components: regex-based input validation, ANSI color output with proper reset sequences, dependency detection, and user interaction prompts. Consistency across all operations emerges from this shared infrastructure.

### Performance Profile

- Arbitrary precision via bc backend
- Sub-second execution for standard operations
- Memory footprint under 50MB during active computation
- Calculations up to 10^308 magnitude
- Matrix operations with dimension-aware scaling

### Code Structure

The 2500-line implementation organizes into logical sections with clear comment headers. Python detection (handling python3 vs python for cross-platform compatibility), command-line argument parsing, history management, and menu dispatch form the critical path. Consistent variable naming and function decomposition enable rapid navigation through the codebase.

## Getting Started

### Requirements

CalcX Advanced demands minimal dependencies, all standard on Unix-like systems:

- **Bash 4.0+** — POSIX-compliant shell
- **GNU bc 1.07+** — Arbitrary precision arithmetic
- **Python 3.6+** — Math and cmath libraries
- **awk** — Text processing

Optional but recommended:
- **fzf or gum** — Enhanced interactive menu selection

### Installation

On Ubuntu/Debian:
```bash
sudo apt-get install bc python3 gawk fzf
```

On macOS:
```bash
brew install bc python3 fzf
```

On Arch Linux:
```bash
sudo pacman -S bc python gawk fzf
```

**Deploy CalcX:**

```bash
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
chmod +x calcx_advanced.sh
./calcx_advanced.sh
```

For system-wide access:
```bash
sudo cp calcx_advanced.sh /usr/local/bin/calcx
sudo chmod +x /usr/local/bin/calcx
calcx
```

Windows users should use WSL2 with Ubuntu 20.04+ for optimal compatibility.

## Functional Capabilities

The calculator implements mathematical operations organized by domain. **Fundamental arithmetic** respects operator precedence with support for modular and remainder operations. **Scientific computing** includes the full trigonometric suite (standard and hyperbolic), logarithmic operations (natural, base-10, arbitrary base), and complex exponentiation. **Advanced mathematics** encompasses matrix determinants and inversion, statistical analysis (mean, median, variance, standard deviation), and combinatorics (permutations, combinations, factorial with extended precision).

**Specialized functions** handle complex arithmetic in both rectangular and polar forms, base conversion between binary/octal/decimal/hexadecimal, and number theory utilities (prime factorization, GCD, LCM). **Numerical methods** bring calculus to the terminal: Simpson's rule for integration, finite differences for derivatives, Euler's method for ODEs, and Newton-Raphson for root finding.

**Interface modes** span command-line (direct expression evaluation for scripts and quick calculations), interactive shell (menu-driven with visual feedback), and persistent history (all calculations logged across sessions).

### Usage Examples

**Command-line calculations:**
```bash
calcx "sqrt(144)"
calcx "2^10"
calcx "sin(3.14159/2)"
calcx "scale=50; 4*a(1)"  # Pi to 50 decimal places
```

**Interactive exploration:**
```bash
calcx
# Enter interactive mode with full menu system
# Option 1: Solve quadratic equations
# Option 4: Matrix operations
# Option 8: Discrete Fourier Transform
# Option 10: View calculation history
```

## Implementation Deep Dive

### Configuration System

Variables at the script's top control behavior:

- `MAX_HISTORIAL=20` — History entries retained
- `PRECISION=6` — Default significant figures
- `HIST_FILE="$HOME/.calc_ultra_history.log"` — History storage

Override via environment variables:
```bash
export MAX_HISTORIAL=50 PRECISION=15
./calcx_advanced.sh
```

### Error Handling

The implementation validates every user input with regex patterns before computation. Coefficients are verified as numbers. Divide-by-zero conditions are caught. Complex roots from quadratic equations are properly formatted. Missing dependencies produce clear error messages rather than silent failures. Terminal state is preserved through proper ANSI color reset sequences.

### Cross-Platform Design

The script detects python3 (Unix standard) or python (Windows) at initialization, validating that commands are functional rather than installer stubs. This detection sets the `PYTHON_CMD` variable used throughout execution. Similar detection occurs for bc, awk, and optional tools like fzf/gum, with graceful fallbacks when features are unavailable.

## Quality and Performance

### Design Principles

Input validation precedes all computation. Edge cases (zero coefficients, singular matrices, boundary conditions) are handled explicitly. Failures produce informative messages. Terminal state is always preserved. The implementation prioritizes numerical stability over microsecond-level performance optimization—the correct tradeoff for mathematical calculations where correctness matters.

### Known Constraints

- Terminal minimum: 24 lines for interactive mode
- Matrix operations: 100x100 maximum for performance
- Floating-point precision: system architecture limits (typically 15-17 significant digits)
- Some advanced operations require Python availability
- X11 display required for GUI mode (no Wayland native support)

### Performance Metrics

Standard arithmetic executes sub-second. 10x10 matrix determinants complete instantly, while 100x100 systems require 200-500ms. Memory footprint stays minimal (approximately 50MB active), with history storage consuming negligible disk space. The implementation uses efficient array truncation rather than file rewriting for history management.

## Real-World Applications

**Academic research** validates equations, computes transforms, and explores matrices without MATLAB licensing overhead. **Engineering calculations** perform quick inversions and numerical integration for design validation. **System administration** uses base conversion for networking and prime factorization for cryptography. **Data analysis workflows** generate statistics, examine distributions, and integrate into automated shell scripts. **Education** provides hands-on exploration of numerical algorithms with readable implementations. **Scientific computing** enables arbitrary precision for physics simulations and signal processing.

## Extension and Development

### Adding Operations

The modular design simplifies extensions. Each operation follows a consistent pattern: display a descriptive header, prompt for inputs, validate them, perform computation, format results, update history, and wait for acknowledgment. Implement as a bash function, add a menu entry, and register in the relevant case statement.

### Code Standards

The project follows Google Shell Style Guide conventions. Variables use descriptive names. Comment headers explain function purpose. Error messages include operation context. Proper variable quoting prevents word splitting. Input validation is comprehensive. POSIX compliance ensures maximum portability.

### Contributing Workflow

1. Fork the repository
2. Create feature branch: `git checkout -b feature/your-enhancement`
3. Implement following existing style
4. Test edge cases thoroughly
5. Commit with clear messages: `git commit -m "type(scope): description"`
6. Push and open pull request

## Licensing and Support

CalcX Advanced is distributed under the MIT License. You're free to use, modify, and distribute the software commercially or personally. See the LICENSE file for complete terms.

The software is provided without warranty. Users validate calculation results for critical applications. Implementations use established numerical algorithms and standard mathematical libraries.

For questions, bug reports, or suggestions, reach out through the project repository:

**Repository:** https://github.com/genesisgzdev/calcx-advanced  
**Developer:** Genesis GZ  
**Email:** genzt.dev@pm.me

## Mathematical Foundations

CalcX Advanced implements proven numerical methods. The **quadratic solver** uses the classic formula with discriminant analysis for real/complex root determination. **Matrix operations** employ cofactor expansion for small matrices and LU decomposition for larger systems, with Gaussian elimination and partial pivoting for inversion. **Root finding** implements Newton-Raphson iteration with finite difference approximation for derivatives. **Integration** uses Simpson's rule with subdivided intervals and parabolic fitting. **Signal processing** performs discrete Fourier transforms converting between time and frequency domains.

## Troubleshooting

**bc not found** — Install through your package manager. Required for arbitrary precision.

**Python not found** — Install Python 3.6 or later. The script auto-detects python3 or python availability.

**Permission denied** — Ensure execute permissions: `chmod +x calcx_advanced.sh`

**History permission error** — Verify write permissions in your home directory. History is stored at `~/.calc_ultra_history.log`.

**Precision limitations** — Floating-point operations have inherent precision limits. Use option 12 in interactive mode to adjust output formatting.

---

*Professional-grade mathematics deserves tools that respect both your time and your computational requirements. CalcX Advanced delivers the horsepower and transparency that serious calculation work demands.*
