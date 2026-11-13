#!/usr/bin/env python3
"""Regression tests for fail-closed release evidence validation."""
import pathlib
import json
import shutil
import tempfile
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


    def test_tampering_cannot_unlock_release(self):
        sys.path.insert(0, str(ROOT / "tools"))
        from release_gate import inspect
        with tempfile.TemporaryDirectory() as temp:
            root = pathlib.Path(temp)
            for relative in ("docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md",
                             "docs/quality/RELEASE_6_1_REQUIREMENTS_REGISTER.md",
                             "docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json"):
                destination = root / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / relative, destination)
            checklist = root / "docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md"
            checklist.write_text(checklist.read_text(encoding="utf-8").replace(
                "- [ ] P01 ", "- [x] P01 ", 1), encoding="utf-8")
            errors, missing = inspect(root)
            self.assertTrue(any("P01" in e or "match" in e for e in errors), errors)
            checklist.write_text((ROOT / "docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md").read_text(encoding="utf-8"), encoding="utf-8")
            evidence_file = root / "docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json"
            evidence = json.loads(evidence_file.read_text(encoding="utf-8"))
            evidence["gates"]["windows_10_gui"] = {"status": "verified", "commit": "0" * 40}
            evidence_file.write_text(json.dumps(evidence), encoding="utf-8")
            errors, missing = inspect(root)
            self.assertTrue(any("windows_10_gui" in e for e in errors), errors)
            evidence["schema"] = 999
            evidence_file.write_text(json.dumps(evidence), encoding="utf-8")
            errors, missing = inspect(root)
            self.assertIn("Unsupported release evidence schema", errors)

    def test_missing_gate_definition_is_invalid(self):
        sys.path.insert(0, str(ROOT / "tools"))
        from release_gate import inspect
        with tempfile.TemporaryDirectory() as temp:
            root = pathlib.Path(temp)
            for relative in ("docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md",
                             "docs/quality/RELEASE_6_1_REQUIREMENTS_REGISTER.md",
                             "docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json"):
                target = root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / relative, target)
            path = root / "docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json"
            payload = json.loads(path.read_text(encoding="utf-8"))
            del payload["gates"]["windows_11_gui"]
            path.write_text(json.dumps(payload), encoding="utf-8")
            errors, missing = inspect(root)
            self.assertTrue(any("Missing release gate definitions" in e for e in errors), errors)
            self.assertIn("windows_11_gui", missing)
            payload["gates"]["windows_11_gui"] = {"status": "unknown"}
            path.write_text(json.dumps(payload), encoding="utf-8")
            errors, missing = inspect(root)
            self.assertTrue(any("Unknown gate status" in e for e in errors), errors)

    def test_malformed_evidence_is_rejected_without_crash(self):
        sys.path.insert(0, str(ROOT / "tools"))
        from release_gate import inspect
        with tempfile.TemporaryDirectory() as temp:
            root = pathlib.Path(temp)
            for relative in ("docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md",
                             "docs/quality/RELEASE_6_1_REQUIREMENTS_REGISTER.md"):
                destination = root / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / relative, destination)
            path = root / "docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json"
            for payload in ({"schema": 1, "requirements": [], "gates": []},
                            {"schema": 1, "requirements": {}, "gates": {"fake": {"status": "verified"}}}):
                path.write_text(json.dumps(payload), encoding="utf-8")
                errors, _ = inspect(root)
                self.assertTrue(errors, payload)

if __name__ == "__main__":
    unittest.main()
