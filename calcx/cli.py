from __future__ import annotations

import argparse
import json
import sys

from . import __version__
from .config import Config, ConfigError
from .engine import evaluate, format_value
from .errors import CalcXError
from .history import History


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="calcx", description="Safe scientific calculator")
    parser.add_argument("expression", nargs="?", help="expression to evaluate")
    parser.add_argument("--precision", type=int, help="significant digits for display")
    parser.add_argument("--json", action="store_true", help="emit structured JSON")
    parser.add_argument("--interactive", action="store_true", help="start the REPL")
    parser.add_argument("--version", action="version", version=__version__)
    return parser


def calculate(expression: str, config: Config, as_json: bool = False) -> int:
    try:
        value = evaluate(expression, config.precision)
        rendered = format_value(value, config.precision)
        if as_json:
            print(json.dumps({"expression": expression, "result": rendered, "precision": config.precision}, ensure_ascii=False))
        else:
            print(rendered)
        History(config.history_file, config.history_limit).add(expression, rendered)
        return 0
    except CalcXError as exc:
        if as_json: print(json.dumps({"error": type(exc).__name__, "message": str(exc)}))
        else: print(f"calcx: {exc}", file=sys.stderr)
        return 2


def repl(config: Config) -> int:
    print(f"CalcX {__version__}. Escribe 'help' o 'quit'.")
    while True:
        try: line = input("calcx> ").strip()
        except (EOFError, KeyboardInterrupt): print(); return 0
        if line in {"quit", "exit", "q"}: return 0
        if line == "help": print("Escribe una expresión, 'history', 'clear' o 'quit'."); continue
        if line == "history": print("\n".join(History(config.history_file, config.history_limit).entries)); continue
        if line == "clear": History(config.history_file, config.history_limit).clear(); print("historial eliminado"); continue
        if line: calculate(line, config)


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        config = Config.load(args.precision)
    except ConfigError as exc:
        print(f"calcx: {exc}", file=sys.stderr)
        return 2
    return repl(config) if args.interactive or args.expression is None else calculate(args.expression, config, args.json)
