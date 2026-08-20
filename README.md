# CalcX Advanced

CalcX is a small scientific calculator for the terminal. It keeps the simple `calcx.sh` entry point, but the expression engine now runs through a restricted Python AST instead of evaluating arbitrary code.

It works on Linux, macOS and WSL and is useful both at the prompt and inside scripts.

[![CI](https://github.com/genesisgzdev/calcx-advanced/actions/workflows/ci.yml/badge.svg)](https://github.com/genesisgzdev/calcx-advanced/actions/workflows/ci.yml)
[![Latest release](https://img.shields.io/github/v/release/genesisgzdev/calcx-advanced)](https://github.com/genesisgzdev/calcx-advanced/releases)
[![License](https://img.shields.io/github/license/genesisgzdev/calcx-advanced)](LICENSE)

## What it can do

- Decimal arithmetic with configurable precision
- Complex numbers, matrices and numerical methods
- Trigonometric, logarithmic, hyperbolic and rounding functions
- JSON output for scripts and other tools
- A menu interface, a direct CLI and an interactive Python REPL
- XDG-based configuration and bounded atomic history storage

The core package has no mandatory third-party dependency. `mpmath` can be added when arbitrary-precision functions are needed.

## Quick start

```bash
git clone https://github.com/genesisgzdev/calcx-advanced.git
cd calcx-advanced

./calcx.sh 'sqrt(144)'
./calcx.sh --json '2 + 2'
./calcx.sh --precision 50 '1/7'
./calcx.sh --interactive
```

To install the `calcx` command with `pipx`:

```bash
python3 -m pip install --user pipx
pipx install .
calcx '2^10'
```

`^` is accepted as exponentiation. Constants include `pi`, `e`, `tau` and `i`.

## A note about safety

Expressions are parsed with Python's AST and checked against an explicit allow-list. CalcX does not call `eval`, `exec`, a shell or a user-provided command while evaluating an expression. Invalid expressions are reported on `stderr` and return a non-zero exit code.

That makes the CLI suitable for automation, but it is still a calculator. Results used in safety-critical or financial work should be checked independently.

## Configuration and history

The optional config file is read from `$XDG_CONFIG_HOME/calcx/config.env` or `~/.config/calcx/config.env`:

```text
PRECISION=40
HISTORY_LIMIT=500
HISTORY_FILE=~/.local/state/calcx/history
```

`CALCX_PRECISION`, `CALCX_HISTORY_LIMIT` and `CALCX_HISTORY` override the file. Command-line options take precedence over both. History is stored under `~/.local/state/calcx` by default.

## Development

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
bash tests/run_tests.sh
python3 -m compileall -q calcx
bash -n calcx.sh
```

The project is currently at version `2.0.4`. The old Bash implementation remains in `src/` for reference, while the Python package is the runtime used by the modern CLI path.

## License

MIT. See [LICENSE](LICENSE).
