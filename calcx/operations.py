"""Numerically defensive operations used by the CLI and API consumers."""
from __future__ import annotations

import cmath
import math
from .errors import ConvergenceError, DomainError, ExpressionError


def quadratic(a: float, b: float, c: float) -> tuple[complex, complex]:
    if a == 0: raise DomainError("a must not be zero")
    discriminant = complex(b * b - 4 * a * c)
    root = cmath.sqrt(discriminant)
    return ((-b + root) / (2 * a), (-b - root) / (2 * a))


def matrix_inverse(matrix: list[list[float]]) -> list[list[float]]:
    n = len(matrix)
    if not n or any(len(row) != n for row in matrix): raise ExpressionError("matrix must be non-empty and square")
    augmented = [list(map(float, row)) + [float(i == j) for j in range(n)] for i, row in enumerate(matrix)]
    scale = max((abs(value) for row in augmented for value in row[:n]), default=0.0)
    if scale == 0.0: raise DomainError("matrix is singular")
    for col in range(n):
        pivot = max(range(col, n), key=lambda row: abs(augmented[row][col]))
        if abs(augmented[pivot][col]) <= scale * 1e-14: raise DomainError("matrix is singular")
        augmented[col], augmented[pivot] = augmented[pivot], augmented[col]
        divisor = augmented[col][col]
        augmented[col] = [value / divisor for value in augmented[col]]
        for row in range(n):
            if row == col: continue
            factor = augmented[row][col]
            augmented[row] = [a - factor * b for a, b in zip(augmented[row], augmented[col])]
    return [row[n:] for row in augmented]


def integrate(function, start: float, end: float, intervals: int = 1000) -> float:
    if intervals < 2 or intervals % 2: raise ExpressionError("intervals must be a positive even number")
    step = (end - start) / intervals
    total = function(start) + function(end)
    for i in range(1, intervals): total += (4 if i % 2 else 2) * function(start + i * step)
    return total * step / 3


def newton(function, derivative, guess: float, tolerance: float = 1e-12, iterations: int = 100) -> float:
    x = float(guess)
    for _ in range(iterations):
        fx, dfx = function(x), derivative(x)
        if not math.isfinite(fx) or not math.isfinite(dfx) or abs(dfx) < 1e-15:
            raise ConvergenceError("derivative is invalid or too close to zero")
        next_x = x - fx / dfx
        if not math.isfinite(next_x): raise ConvergenceError("method produced a non-finite value")
        if abs(next_x - x) <= tolerance and abs(function(next_x)) <= tolerance:
            return next_x
        x = next_x
    raise ConvergenceError("method did not converge")


def dft(values: list[complex]) -> list[complex]:
    n = len(values)
    if not n: return []
    return [sum(value * cmath.exp(-2j * math.pi * k * j / n) for j, value in enumerate(values)) for k in range(n)]
