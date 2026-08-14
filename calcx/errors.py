class CalcXError(Exception):
    """Base class for expected user-facing failures."""


class ExpressionError(CalcXError):
    pass


class DomainError(CalcXError):
    pass


class ConvergenceError(CalcXError):
    pass
