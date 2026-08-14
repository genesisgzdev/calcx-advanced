# CalcX Advanced

CalcX Advanced is a safe scientific calculator for Linux, macOS and WSL. It keeps the familiar `calcx.sh` entry point while using a tested Python engine for expressions, complex numbers, matrices and numerical methods.

## Why this version is different

The expression language is parsed with Python's AST and an explicit allow-list. It never calls `eval`, `exec`, a shell, or a user-provided command. Errors are typed, sent to `stderr`, and return a non-zero status so CalcX can be used safely in scripts.

```text
CLI (calcx / calcx.sh)
        |
configuration + history (XDG)
        |
safe AST evaluator + numerical operations
        |
Decimal-compatible display / optional mpmath extension
```

## Install

For a checkout:

```bash
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced
./calcx.sh 'sqrt(144)'
```

Running `./calcx.sh` without arguments opens the original menu-driven interface. Use an expression for scripting, or `--interactive` for the newer Python REPL.

For an isolated command available everywhere:

```bash
python3 -m pip install --user pipx
pipx install .
calcx '2^10'
```

Optional arbitrary-precision functions:

```bash
pipx inject calcx-advanced mpmath
```

## CLI

```bash
calcx '2^10'
calcx 'sin(pi/2)'
calcx 'sqrt(-4)'
calcx --precision 50 '1/7'
calcx --json '2 + 2'
calcx --interactive
calcx --version
```

JSON output is designed for automation:

```json
{"expression": "2 + 2", "result": "4", "precision": 28}
```

Supported functions include trigonometry, hyperbolic functions, logarithms, exponentiation, factorial, rounding and complex arithmetic. Constants are `pi`, `e`, `tau` and `i`; `^` is accepted as exponentiation.

## Configuration and history

Configuration is read from `$XDG_CONFIG_HOME/calcx/config.env`, or `~/.config/calcx/config.env`:

```text
PRECISION=40
HISTORY_LIMIT=500
HISTORY_FILE=~/.local/state/calcx/history
```

Environment variables such as `CALCX_PRECISION`, `CALCX_HISTORY_LIMIT` and `CALCX_HISTORY` override the file; command-line arguments override both. History is written atomically under `~/.local/state/calcx` by default.

## Development

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
bash tests/run_tests.sh
python3 -m compileall -q calcx
bash -n calcx.sh
```

The optional `mpmath` dependency is intentionally not required for the core install. CI tests Ubuntu and macOS across supported Python versions and builds the project from `pyproject.toml`.

## Project status

Version 2.0.0 is the safe-engine migration release. The legacy Bash implementation remains in `src/` for auditability but is no longer the runtime path. Numerical output should still be independently checked for safety-critical work.

## License

MIT. See [LICENSE](LICENSE).
