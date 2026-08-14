# Changelog

All notable changes to CalcX Advanced are documented here.

## [2.0.3] - 2026-08-14

### Changed

- Simplified the interactive header into a balanced, centered text treatment.
- Removed the boxed cyberpunk-style status panel and redundant mode label.

## [2.0.2] - 2026-08-14

### Changed

- Replaced the stacked legacy menu with a two-column terminal dashboard.
- Grouped tools into Equations, Linear Algebra, Numerical Lab and Data & Number Theory workspaces.
- Added centered branding, precision status and compact keyboard hints without changing option numbers.

## [2.0.1] - 2026-08-14

### Fixed

- Restored the original menu-driven interface when `./calcx.sh` is invoked without arguments.
- Kept the safe Python engine for expression mode and exposed the modern REPL through `--interactive`.
- Clarified the three supported entry modes in the README and manual.

## [2.0.0] - 2026-08-14

### Added

- Safe AST-based Python expression engine with an explicit allow-list.
- Decimal-backed arithmetic with configurable precision and complex results.
- Typed domain, syntax and convergence errors with stable exit codes.
- JSON output for automation and machine-readable failures.
- Matrix inversion, quadratic roots, Simpson integration, Newton iteration and DFT APIs.
- XDG configuration and bounded, atomic history persistence.
- Python package metadata, `pipx` installation path, MIT license and CI workflows.
- Runtime tests covering security rejection, numerical operations, CLI output and failures.

### Fixed

- Restored executable permissions on the actual entry point and operational scripts.
- Removed the unsafe Python `eval` fallback from command-line evaluation.
- Stopped advertising configuration values that the old Bash runtime never loaded.
- Replaced destructive uninstall behavior with package removal that preserves user data.
- Corrected stale installation examples and unsupported claims in the documentation.

### Compatibility

- `./calcx.sh '2 + 2'` remains supported.
- `^` continues to mean exponentiation in command-line expressions.
- The legacy Bash implementation remains available under `src/` for auditability but is no longer the runtime engine.
