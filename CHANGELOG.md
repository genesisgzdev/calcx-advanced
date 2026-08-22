# Changelog

All notable changes to CalcX Advanced are documented here.

## [2.0.5] - 2026-08-22

### Documentation

- Alinea la descripción de precisión con el backend real y elimina la opción `mpmath` que no participaba en la evaluación.

### Fixed

- Añade límites de dimensión y evaluaciones a matrices, integración y DFT, y usa la fórmula cuadrática estable cuando los coeficientes provocan cancelación.
- Mantiene los enteros para `factorial` y limita exponentes, nodos AST y argumentos desproporcionados.
- Usa tolerancia relativa para inversión de matrices y verifica el residuo de Newton.

### Riesgo y actualización

- No cambia la sintaxis pública ni requiere dependencias obligatorias nuevas.
- Las funciones trascendentales siguen limitadas por el backend numérico disponible; aumentar `Decimal` no convierte operaciones `float` en precisión arbitraria.

## [Unreleased]

## [2.0.4] - 2026-08-20

### Changed

- Refreshed the public README and release metadata around the current CLI and interactive behavior.
- Aligned the package version exposed by `calcx --version` with the published release.

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
