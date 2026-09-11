from __future__ import annotations

import argparse
import json
import sys
import os
from dataclasses import replace

from . import __version__
from .config import Config, ConfigError
from .engine import evaluate, format_value
from .errors import CalcXError
from .history import History


EXAMPLES = """Cuentas del día a día
  80 * 15 / 100       El 15 % de 80
  120 / 4            Repartir 120 entre cuatro
  sqrt(144)          Raíz cuadrada
  2^10               Potencias
  sin(pi/2)          Ángulos en radianes
  sqrt(-9)           Números complejos

Escribe ayuda, funciones, historial, precision 40 o salir.
Usa punto para los decimales y * para multiplicar."""


def accent(text: str) -> str:
    # Redirected output stays plain and works with screen readers and scripts.
    if sys.stdout.isatty() and "NO_COLOR" not in os.environ and os.environ.get("TERM") != "dumb":
        return f"\033[1;36m{text}\033[0m"
    return text


def explain_error(error: CalcXError) -> str:
    detail = str(error)
    if "Division" in detail or "division by zero" in detail:
        return "No se puede dividir entre cero. Revisa el número que está después de /."
    if "unknown name:" in detail:
        return f"No reconozco {detail.split(':', 1)[1].strip()}. Escribe funciones para ver los nombres disponibles."
    if "invalid expression" in detail or "unsupported" in detail or "not allowed" in detail:
        return "Revisa la cuenta y los paréntesis. Usa números y funciones como sqrt(144)."
    return f"No pude calcular esa expresión: {detail}"


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="calcx", description="Resuelve una cuenta o abre la calculadora escribiendo calcx.", epilog='Ejemplo: calcx "80 * 15 / 100"')
    parser.add_argument("expression", nargs="?", help="cuenta que quieres resolver, entre comillas")
    parser.add_argument("--precision", type=int, help="cifras significativas, de 1 a 1000")
    parser.add_argument("--json", action="store_true", help="resultado estructurado para otra aplicación")
    parser.add_argument("--interactive", action="store_true", help="abrir la calculadora")
    parser.add_argument("--examples", action="store_true", help="ver ejemplos sin calcular")
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
        try:
            History(config.history_file, config.history_limit).add(expression, rendered)
        except (OSError, UnicodeError) as exc:
            print(f"calcx: could not save history: {exc}", file=sys.stderr)
        return 0
    except CalcXError as exc:
        if as_json: print(json.dumps({"error": type(exc).__name__, "message": str(exc)}))
        else: print(f"calcx: {explain_error(exc)}", file=sys.stderr)
        return 2


def repl(config: Config) -> int:
    print(accent(f"CalcX {__version__}"))
    print("Tu espacio para hacer cuentas\n")
    print(EXAMPLES)
    print(f"\nPrecisión actual: {config.precision} cifras\n")
    while True:
        try: line = input("calcx> ").strip()
        except (EOFError, KeyboardInterrupt): print(); return 0
        line = {"salir": "quit", "ayuda": "help", "historial": "history", "borrar": "clear", "ejemplos": "help"}.get(line, line)
        if line in {"quit", "exit", "q"}: return 0
        if line == "help": print(EXAMPLES); continue
        if line in {"funciones", "functions"}:
            from .engine import FUNCTIONS
            print("Funciones: " + ", ".join(sorted(FUNCTIONS)))
            print("Constantes: pi, e, tau, i. log(8, 2) calcula el logaritmo en base 2.")
            continue
        if line.startswith("precision "):
            try:
                precision = int(line.split(maxsplit=1)[1])
                if not 1 <= precision <= 1000: raise ValueError
                config = replace(config, precision=precision)
                print(f"Las próximas cuentas usarán {precision} cifras.")
            except ValueError:
                print("Elige entre 1 y 1000 cifras. Por ejemplo: precision 40")
            continue
        if line in {"history", "clear"}:
            try:
                history = History(config.history_file, config.history_limit)
                if line == "history": print("\n".join(history.entries) or "Todavía no hay cuentas guardadas.")
                else: history.clear(); print("historial eliminado")
            except (OSError, UnicodeError) as exc:
                print(f"calcx: could not access history: {exc}", file=sys.stderr)
            continue
        if line:
            print(accent("Resultado"))
            calculate(line, config)
            print()


def main(argv: list[str] | None = None) -> int:
    parser = _parser()
    args = parser.parse_args(argv)
    if args.examples:
        print(EXAMPLES)
        return 0
    if args.json and (args.interactive or args.expression is None):
        parser.error('--json necesita una expresión y no se combina con --interactive')
    try:
        config = Config.load(args.precision)
    except ConfigError as exc:
        print(f"calcx: {exc}", file=sys.stderr)
        return 2
    return repl(config) if args.interactive or args.expression is None else calculate(args.expression, config, args.json)
