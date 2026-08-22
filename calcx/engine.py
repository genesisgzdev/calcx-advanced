"""A deliberately small, allow-listed expression evaluator.

Expressions are parsed with :mod:`ast`; Python code is never executed.
"""
from __future__ import annotations

import ast
import cmath
import math
from decimal import Decimal, localcontext
from typing import Any, Callable

from .errors import DomainError, ExpressionError

MAX_AST_NODES = 256
MAX_EXPONENT = 10_000
MAX_FACTORIAL_ARGUMENT = 1_000


def _sqrt(x: Any) -> Any:
    if isinstance(x, Decimal) and x >= 0:
        return x.sqrt()
    number = float(x) if isinstance(x, Decimal) else x
    if isinstance(number, complex) or number < 0:
        return cmath.sqrt(number)
    return math.sqrt(number)


def _log(x: Any, base: Any = math.e) -> Any:
    number = float(x) if isinstance(x, Decimal) else x
    if number == 0 or (not isinstance(number, complex) and number < 0):
        raise DomainError("logarithm requires a positive value")
    return cmath.log(number) / cmath.log(base) if isinstance(number, complex) else math.log(number, float(base))


def _factorial(value: Any) -> int:
    if isinstance(value, Decimal):
        if value != value.to_integral_value() or value < 0:
            raise DomainError("factorial requires a non-negative integer")
        value = int(value)
    elif isinstance(value, float) and (not value.is_integer() or value < 0):
        raise DomainError("factorial requires a non-negative integer")
    value = int(value)
    if value > MAX_FACTORIAL_ARGUMENT:
        raise DomainError(f"factorial argument exceeds {MAX_FACTORIAL_ARGUMENT}")
    return math.factorial(value)


FUNCTIONS: dict[str, Callable[..., Any]] = {
    "abs": abs, "sqrt": _sqrt, "sin": cmath.sin, "cos": cmath.cos,
    "tan": cmath.tan, "asin": cmath.asin, "acos": cmath.acos,
    "atan": cmath.atan, "sinh": cmath.sinh, "cosh": cmath.cosh,
    "tanh": cmath.tanh, "exp": cmath.exp, "log": _log,
    "ln": lambda x: _log(x), "log10": lambda x: _log(x, 10),
    "floor": math.floor, "ceil": math.ceil, "factorial": _factorial,
}
CONSTANTS = {"pi": Decimal(str(math.pi)), "e": Decimal(str(math.e)), "tau": Decimal(str(math.tau)), "i": 1j}


class _Evaluator(ast.NodeVisitor):
    def visit_Expression(self, node: ast.Expression) -> Any:
        return self.visit(node.body)

    def visit_Constant(self, node: ast.Constant) -> Any:
        if isinstance(node.value, (int, float)) and not isinstance(node.value, bool):
            return Decimal(str(node.value))
        if isinstance(node.value, complex):
            return node.value
        raise ExpressionError("unsupported literal")

    def visit_Name(self, node: ast.Name) -> Any:
        if node.id in CONSTANTS:
            return CONSTANTS[node.id]
        raise ExpressionError(f"unknown name: {node.id}")

    def visit_BinOp(self, node: ast.BinOp) -> Any:
        left, right = self.visit(node.left), self.visit(node.right)
        if isinstance(left, complex) or isinstance(right, complex):
            left, right = complex(left), complex(right)
        try:
            if isinstance(node.op, ast.Add): return left + right
            if isinstance(node.op, ast.Sub): return left - right
            if isinstance(node.op, ast.Mult): return left * right
            if isinstance(node.op, ast.Div): return left / right
            if isinstance(node.op, ast.FloorDiv): return left // right
            if isinstance(node.op, ast.Mod): return left % right
            if isinstance(node.op, ast.Pow):
                exponent = float(right) if isinstance(right, Decimal) else right
                if isinstance(exponent, (int, float)) and abs(exponent) > MAX_EXPONENT:
                    raise DomainError(f"exponent magnitude exceeds {MAX_EXPONENT}")
                return left ** right
        except (ArithmeticError, ValueError, ZeroDivisionError) as exc:
            raise DomainError(str(exc)) from exc
        raise ExpressionError("unsupported operator")

    def visit_UnaryOp(self, node: ast.UnaryOp) -> Any:
        value = self.visit(node.operand)
        if isinstance(node.op, ast.USub): return -value
        if isinstance(node.op, ast.UAdd): return value
        raise ExpressionError("unsupported unary operator")

    def visit_Call(self, node: ast.Call) -> Any:
        if not isinstance(node.func, ast.Name) or node.func.id not in FUNCTIONS:
            raise ExpressionError("function is not allowed")
        if node.keywords:
            raise ExpressionError("keyword arguments are not allowed")
        try:
            arguments = tuple(self.visit(arg) for arg in node.args)
            return FUNCTIONS[node.func.id](*arguments)
        except (ArithmeticError, ValueError, TypeError) as exc:
            raise DomainError(str(exc)) from exc

    def generic_visit(self, node: ast.AST) -> Any:
        raise ExpressionError(f"syntax is not allowed: {type(node).__name__}")


def evaluate(expression: str, precision: int = 28) -> Any:
    """Evaluate an allow-listed expression and return a JSON-friendly value."""
    expression = expression.strip().replace("^", "**")
    if not expression or len(expression) > 4096:
        raise ExpressionError("expression must contain 1-4096 characters")
    try:
        tree = ast.parse(expression, mode="eval")
    except SyntaxError as exc:
        raise ExpressionError(f"invalid expression: {exc.msg}") from exc
    nodes = list(ast.walk(tree))
    if len(nodes) > MAX_AST_NODES:
        raise ExpressionError(f"expression exceeds the {MAX_AST_NODES}-node limit")
    if max((len(list(ast.walk(node))) for node in nodes), default=0) > MAX_AST_NODES:
        raise ExpressionError("expression nesting is too deep")
    with localcontext() as context:
        context.prec = max(1, min(int(precision), 1000))
        return _Evaluator().visit(tree)


def format_value(value: Any, precision: int = 12) -> str:
    if isinstance(value, complex):
        real, imag = value.real, value.imag
        if abs(imag) < 10 ** (-precision): return format(real, f".{precision}g")
        return f"{real:.{precision}g}{imag:+.{precision}g}i"
    if isinstance(value, Decimal):
        return format(value, f".{precision}g")
    if isinstance(value, float):
        return format(value, f".{precision}g")
    return str(value)
