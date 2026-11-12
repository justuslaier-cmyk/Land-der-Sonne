#!/usr/bin/env python3
"""Regression tests for fail-closed release evidence validation."""
import pathlib
import subprocess
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
GATE = ROOT / "tools/release_gate.py"

class ReleaseGateTests(unittest.TestCase):
    def test_audit_mode_accepts_honest_blocked_state(self):
        result = subprocess.run([sys.executable, str(GATE), "--mode", "audit"], capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("RELEASE_GATE_BLOCKED", result.stdout)

    def test_release_mode_refuses_unaccepted_requirements(self):
        result = subprocess.run([sys.executable, str(GATE), "--mode", "release"], capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("P01", result.stdout)
        self.assertIn("P98", result.stdout)

    def test_all_98_ids_are_exact_and_ordered(self):
        sys.path.insert(0, str(ROOT / "tools"))
        from release_gate import inspect
        errors, missing = inspect()
        self.assertFalse(errors, errors)
        self.assertEqual(len([x for x in missing if x.startswith("P")]), 98)

if __name__ == "__main__":
    unittest.main()
