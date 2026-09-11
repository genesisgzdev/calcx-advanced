import json
import os
import subprocess
import sys
import tempfile
import unittest
from decimal import Decimal
from pathlib import Path

from calcx.engine import evaluate
from calcx.errors import DomainError
from calcx.operations import matrix_inverse, newton


class NumericRegressionTests(unittest.TestCase):
    def test_decimal_literal_keeps_all_supplied_digits(self):
        text = '0.123456789012345678901234567890123456789'
        self.assertEqual(evaluate(text, 50), Decimal(text))
        self.assertEqual(evaluate('1e400', 50), Decimal('1e400'))
        self.assertEqual(evaluate('0xff + 0b10'), 257)

    def test_real_function_results_compose_with_decimals(self):
        for expression, expected in [('log10(100)+1', 3), ('abs(i)+1', 2), ('log(8,2)^2', 9)]:
            with self.subTest(expression=expression):
                self.assertAlmostEqual(float(evaluate(expression)), expected)

    def test_invalid_complex_arithmetic_has_a_typed_error(self):
        for expression in ('i//2', 'i%2', '2^(10001+i)', '1e400*i'):
            with self.subTest(expression=expression), self.assertRaises(DomainError):
                evaluate(expression)

    def test_factorials_cannot_build_unbounded_integer_products(self):
        result = evaluate('factorial(1000)^100')
        self.assertIsInstance(result, Decimal)
        with self.assertRaises(DomainError):
            evaluate('factorial(1000)^10000')

    def test_newton_accepts_an_exact_stationary_root(self):
        self.assertEqual(newton(lambda x: x*x, lambda x: 2*x, 0), 0)

    def test_matrix_rejects_nonfinite_entries(self):
        for value in (float('nan'), float('inf')):
            with self.assertRaises(DomainError):
                matrix_inverse([[value]])

    def test_history_failure_does_not_corrupt_successful_json(self):
        with tempfile.TemporaryDirectory() as temporary:
            blocker = Path(temporary) / 'file'
            blocker.write_text('not a directory')
            result = subprocess.run(
                [sys.executable, '-m', 'calcx', '--json', '2+2'],
                env={**os.environ, 'CALCX_HISTORY': str(blocker / 'history')},
                text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 0)
            self.assertEqual(json.loads(result.stdout)['result'], '4')
            self.assertIn('history', result.stderr)
            self.assertNotIn('Traceback', result.stderr)
