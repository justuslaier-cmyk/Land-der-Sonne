#!/usr/bin/env python3
"""Fail-closed Land der Sonne release gate. No network or third-party dependencies.

Audit mode validates the register and prints BLOCKED as a successful *audit*
when release evidence is missing. Release mode only succeeds with 98 individually
accepted entries and explicit native/manual evidence; CI cannot self-certify it.
"""
import argparse
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
CHECKLIST = ROOT / "docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md"
REGISTER = ROOT / "docs/quality/RELEASE_6_1_REQUIREMENTS_REGISTER.md"
EVIDENCE = ROOT / "docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json"
ITEM = re.compile(r"^- \[([ x])\] (P\d{2}) (.+)$", re.MULTILINE)
ROW = re.compile(r"^\| (P\d{2}) \| (.+?) \| (.+?) \| (OFFEN|ABGENOMMEN) \| (.+?) \|$", re.MULTILINE)
SHA = re.compile(r"^[a-f0-9]{40}$")
REQUIRED = ("windows_10_gui", "windows_11_gui", "human_playthroughs",
            "target_hardware_performance", "visual_review", "licenses",
            "reproducible_build", "release_archive")


def inspect(root=ROOT):
    problems = []
    checklist = (root / "docs/vision/BINDING_GAME_REQUIREMENTS_CHECKLIST.md").read_text(encoding="utf-8")
    register = (root / "docs/quality/RELEASE_6_1_REQUIREMENTS_REGISTER.md").read_text(encoding="utf-8")
    items = list(ITEM.finditer(checklist))
    rows = list(ROW.finditer(register))
    ids = [f"P{i:02d}" for i in range(1, 99)]
    if [m.group(2) for m in items] != ids:
        problems.append("Binding checklist is missing, reordered or duplicates P01–P98")
    if [m.group(1) for m in rows] != ids:
        problems.append("Release register is missing, reordered or duplicates P01–P98")
    for item, row in zip(items, rows):
        if item.group(2) != row.group(1):
            problems.append("Requirement ID mismatch: " + item.group(2))
            continue
        if item.group(3).replace("|", "/") != row.group(2):
            problems.append("Requirement text mismatch: " + item.group(2))
        if (item.group(1) == "x") != (row.group(4) == "ABGENOMMEN"):
            problems.append("Unchecked or falsely accepted: " + item.group(2))
    accepted = [m.group(2) for m in items if m.group(1) == "x"]
    missing = [x for x in ids if x not in accepted]
    evidence_path = root / "docs/quality/RELEASE_6_1_NATIVE_EVIDENCE.json"
    evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
    if sorted(evidence.get("requirements", {}).keys()) != sorted(accepted):
        problems.append("Individual acceptance records do not match checklist")
    for key in accepted:
        record = evidence["requirements"][key]
        if not isinstance(record, dict) or not SHA.fullmatch(str(record.get("commit", ""))):
            problems.append("Missing full commit SHA for " + key)
            continue
        for field in ("test", "result", "integration", "reviewer"):
            if not isinstance(record.get(field), str) or not record[field].strip():
                problems.append("Missing " + field + " for " + key)
    for key in REQUIRED:
        record = evidence.get("gates", {}).get(key, {})
        if not isinstance(record, dict) or record.get("status") != "verified":
            missing.append(key)
            continue
        for field in ("commit", "method", "result", "reviewer", "artifact"):
            if not isinstance(record.get(field), str) or not record[field].strip():
                problems.append("Invalid gate evidence " + key + ": " + field)
        if not SHA.fullmatch(str(record.get("commit", ""))):
            problems.append("Invalid commit for gate " + key)
    return problems, missing


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("audit", "release"), default="audit")
    args = parser.parse_args()
    try:
        problems, missing = inspect()
    except (OSError, ValueError, KeyError) as exc:
        print("RELEASE_GATE_INVALID:", exc)
        return 2
    if problems:
        print("RELEASE_GATE_INVALID: " + "; ".join(problems))
        return 2
    if missing:
        print("RELEASE_GATE_BLOCKED: " + str(len(missing)) +
              " missing acceptance requirements/gates: " + ", ".join(missing))
        return 0 if args.mode == "audit" else 1
    print("RELEASE_GATE_ELIGIBLE: all evidence structurally present; human review still required")
    return 0


if __name__ == "__main__":
    sys.exit(main())
