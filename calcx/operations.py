"""Numerically defensive operations used by the CLI and API consumers."""
from __future__ import annotations

import cmath
import math
from .errors import ConvergenceError, DomainError, ExpressionError

MAX_MATRIX_DIMENSION = 128
MAX_INTEGRATION_INTERVALS = 1_000_000
MAX_DFT_LENGTH = 4_096


def quadratic(a: float, b: float, c: float) -> tuple[complex, complex]:
    if not all(math.isfinite(value) for value in (a, b, c)):
        raise DomainError("quadratic coefficients must be finite")
    if a == 0: raise DomainError("a must not be zero")
    discriminant = complex(b * b - 4 * a * c)
    root = cmath.sqrt(discriminant)
    # Avoid cancellation when b and sqrt(D) have similar magnitude.
    sign = 1 if b >= 0 else -1
    q = -0.5 * (b + sign * root)
    if q == 0:
        roots = ((-b + root) / (2 * a), (-b - root) / (2 * a))
    else:
        roots = (q / a, c / q)
    if not all(math.isfinite(value.real) and math.isfinite(value.imag) for value in roots):
        raise DomainError("quadratic result is not finite")
    return roots


def matrix_inverse(matrix: list[list[float]]) -> list[list[float]]:
    n = len(matrix)
    if not n or any(len(row) != n for row in matrix): raise ExpressionError("matrix must be non-empty and square")
    if n > MAX_MATRIX_DIMENSION:
        raise ExpressionError(f"matrix dimension exceeds {MAX_MATRIX_DIMENSION}")
    augmented = [list(map(float, row)) + [float(i == j) for j in range(n)] for i, row in enumerate(matrix)]
    if not all(math.isfinite(value) for row in augmented for value in row):
        raise DomainError("matrix entries must be finite")
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
    result = [row[n:] for row in augmented]
    if not all(math.isfinite(value) for row in result for value in row):
        raise DomainError("matrix inverse is not finite")
    return result


def integrate(function, start: float, end: float, intervals: int = 1000) -> float:
    if intervals < 2 or intervals % 2: raise ExpressionError("intervals must be a positive even number")
    if intervals > MAX_INTEGRATION_INTERVALS:
        raise ExpressionError(f"integration intervals exceed {MAX_INTEGRATION_INTERVALS}")
    step = (end - start) / intervals
    total = function(start) + function(end)
    for i in range(1, intervals): total += (4 if i % 2 else 2) * function(start + i * step)
    return total * step / 3


def newton(function, derivative, guess: float, tolerance: float = 1e-12, iterations: int = 100) -> float:
    if not math.isfinite(tolerance) or tolerance <= 0:
        raise ExpressionError("tolerance must be positive and finite")
    if not isinstance(iterations, int) or not 1 <= iterations <= 100_000:
        raise ExpressionError("iterations must be an integer between 1 and 100000")
    x = float(guess)
    if not math.isfinite(x):
        raise ConvergenceError("initial guess must be finite")
    for _ in range(iterations):
        fx = function(x)
        if math.isfinite(fx) and abs(fx) <= tolerance:
            return x
        dfx = derivative(x)
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
    if n > MAX_DFT_LENGTH:
        raise ExpressionError(f"DFT length exceeds {MAX_DFT_LENGTH}")
    return [sum(value * cmath.exp(-2j * math.pi * k * j / n) for j, value in enumerate(values)) for k in range(n)]
