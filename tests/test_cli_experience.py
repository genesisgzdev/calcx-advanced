import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


class CalculatorExperienceTests(unittest.TestCase):
    def run_calculator(self, *arguments, input=None):
        with tempfile.TemporaryDirectory() as directory:
            return subprocess.run([sys.executable, '-m', 'calcx', *arguments], input=input,
                                  text=True, capture_output=True, timeout=5,
                                  env={**os.environ, 'CALCX_HISTORY': str(Path(directory) / 'history'), 'NO_COLOR': '1'})

    def test_spanish_commands_calculate_change_precision_and_read_history(self):
        result = self.run_calculator(input='80 * 15 / 100\nprecision 40\n1/7\nhistorial\nsalir\n')
        self.assertEqual(result.returncode, 0)
        self.assertIn('80 * 15 / 100 = 12', result.stdout)
        self.assertIn('0.1428571428571428571428571428571428571429', result.stdout)
        self.assertNotIn('\x1b[', result.stdout)

    def test_json_requires_expression_and_never_waits_for_input(self):
        result = self.run_calculator('--json')
        self.assertEqual(result.returncode, 2)
        self.assertNotIn('Tu espacio', result.stdout)

    def test_invalid_precision_is_reported_instead_of_silently_changed(self):
        result = self.run_calculator('--precision', '1001', '1/7')
        self.assertEqual(result.returncode, 2)
        self.assertIn('1000', result.stderr)

    def test_json_contract_stays_machine_readable(self):
        result = self.run_calculator('--json', 'sqrt(144)')
        self.assertEqual(json.loads(result.stdout)['result'], '12')
