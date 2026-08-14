# CalcX Advanced manual

## Launching

Run `./calcx.sh` from the repository or install the package with `pipx install .` and use `calcx` globally. With no expression CalcX starts its REPL. In scripts, always quote the expression so the shell cannot expand operators first.

## Expressions

Arithmetic uses `+`, `-`, `*`, `/`, `%`, `//` and `^`. Use `pi`, `e`, `tau`, `i`, `sqrt`, `sin`, `cos`, `tan`, `log`, `ln`, `log10`, `exp`, `abs`, `factorial`, `floor` and `ceil`. Invalid names, attributes, imports, comprehensions and keyword arguments are rejected before calculation.

## Automation

`--json` emits a single JSON object on success. Errors go to stderr in text mode, or become an `error`/`message` JSON object in JSON mode. Exit code `0` means success; expected user or domain errors return `2`.

## Persistence

Set `CALCX_HISTORY` for a custom history file and `CALCX_HISTORY_LIMIT` for its bound. The REPL supports `history` and `clear`. Files are created with parent directories and replaced atomically.

## Troubleshooting

Use `python3 --version`, `python3 -m calcx --version`, and `python3 -m compileall -q calcx` to separate installation from runtime issues. If a global `calcx` shadows the checkout, invoke `./calcx.sh` or `python3 -m calcx` from the project root.
