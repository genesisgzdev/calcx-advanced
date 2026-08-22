import json
import os
import subprocess
import sys
import unittest
from pathlib import Path

from calcx.engine import evaluate
from calcx.errors import DomainError, ExpressionError
from calcx.operations import dft, integrate, matrix_inverse, newton, quadratic


class EngineTests(unittest.TestCase):
    def test_expression_math_and_power(self):
        self.assertEqual(evaluate("2^10"), 1024)
        self.assertAlmostEqual(evaluate("sin(pi/2)").real, 1)

    def test_expression_cannot_execute_code(self):
        with self.assertRaises(ExpressionError): evaluate('__import__("os").system("id")')

    def test_legacy_shell_fallback_does_not_use_python_eval(self):
        source = (Path(__file__).parents[1] / "src" / "calcx-advanced.sh").read_text(encoding="utf-8")
        self.assertNotIn("eval(", source)

    def test_domain_errors_are_typed(self):
        with self.assertRaises(DomainError): evaluate("1/0")

    def test_matrix_and_quadratic(self):
        inverse = matrix_inverse([[4, 7], [2, 6]])
        self.assertAlmostEqual(inverse[0][0], 0.6)
        self.assertEqual({round(root.real) for root in quadratic(1, -3, 2)}, {1, 2})

    def test_numerical_operations(self):
        self.assertAlmostEqual(integrate(lambda x: x * x, 0, 1), 1 / 3)
        self.assertAlmostEqual(newton(lambda x: x*x - 2, lambda x: 2*x, 1), 2**0.5)
        self.assertAlmostEqual(dft([1, 1])[0].real, 2)

    def test_cli_json_and_failure(self):
        root = Path(__file__).parents[1]
        env = {**os.environ, "PYTHONPATH": str(root)}
        good = subprocess.run([sys.executable, "-m", "calcx", "--json", "2+2"], cwd=root, env=env, text=True, capture_output=True)
        self.assertEqual(good.returncode, 0)
        self.assertEqual(json.loads(good.stdout)["result"], "4")
        bad = subprocess.run([sys.executable, "-m", "calcx", "1/0"], cwd=root, env=env, text=True, capture_output=True)
        self.assertNotEqual(bad.returncode, 0)
        self.assertIn("calcx:", bad.stderr)


if __name__ == "__main__":
    unittest.main()
