# CalcX architecture

CalcX has two launch paths that share the Python package for expression mode:

~~~mermaid
flowchart LR
    A[calcx.sh] -->|no expression| M[legacy Bash menu in src/calcx-advanced.sh]
    A -->|expression or flags| C[calcx CLI]
    P[python -m calcx] --> C
    C --> CFG[Config.load]
    CFG --> E[AST allow-list evaluator]
    E --> O[Decimal and complex operations]
    C --> H[bounded atomic history]
    E --> OUT[text or JSON stdout]
    E --> ERR[typed errors and exit code 2]
~~~

## Runtime boundaries

- calcx.sh selects the legacy menu when it receives no expression. The Python package is the runtime for direct expressions, JSON output and --interactive.
- calcx/engine.py parses ast.Expression and rejects nodes outside its visitor allow-list. It never executes Python code.
- Decimal values are used for literal arithmetic, while scientific functions convert values to the numeric type required by math or cmath.
- Config.load reads XDG_CONFIG_HOME/calcx/config.env, then environment overrides, then CLI precision. History is written below ~/.local/state/calcx unless CALCX_HISTORY changes it.
- operations.py exposes matrix, quadratic, integration, Newton and DFT functions to library consumers; the command-line expression allow-list does not expose every library operation as a callable.

## Verification surface

The unit tests exercise the Python engine and the shell suite exercises the wrapper and legacy menu. compileall and bash -n check syntax only. Neither test is a numerical certification for safety-critical use.
